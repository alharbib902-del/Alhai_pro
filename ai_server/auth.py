"""
JWT Authentication & Authorization - مصادقة وتفويض JWT

Security middleware for the Alhai AI server.
- Extracts and verifies JWT Bearer tokens from Authorization header
- Validates user membership in the requested org/store via store_members table
- Returns 401 for missing/invalid tokens, 403 for unauthorized access
"""

from __future__ import annotations

import logging
from typing import Annotated

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from pydantic import BaseModel

from config import Settings, get_settings
from models.database import get_supabase_client

# Default Supabase JWT audience claim value
_DEFAULT_JWT_AUDIENCE = "authenticated"

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Scheme – extracts the Bearer token from the Authorization header
# ---------------------------------------------------------------------------
_bearer_scheme = HTTPBearer(
    scheme_name="Supabase JWT",
    description="JWT Bearer token issued by Supabase Auth",
    auto_error=True,  # returns 403 automatically when header is absent
)


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------
class AuthenticatedUser(BaseModel):
    """Payload injected into route handlers after successful authentication."""

    user_id: str
    email: str | None = None
    role: str | None = None  # Supabase role (e.g. "authenticated")


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------
_SUPABASE_JWT_ALGORITHMS = ["HS256"]


def _decode_token(token: str, settings: Settings) -> dict:
    """Decode and verify a Supabase JWT.

    Raises HTTPException(401) on any failure.
    """
    secret = settings.jwt_secret
    if not secret:
        logger.error("JWT_SECRET is not configured – cannot verify tokens")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="خطأ في إعداد المصادقة - Authentication configuration error",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = jwt.decode(
            token,
            secret,
            algorithms=_SUPABASE_JWT_ALGORITHMS,
            audience=settings.jwt_audience if hasattr(settings, "jwt_audience") and settings.jwt_audience else _DEFAULT_JWT_AUDIENCE,
            options={
                "verify_aud": True,
                "verify_exp": True,
            },
        )
    except JWTError as exc:
        logger.warning("JWT verification failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="رمز المصادقة غير صالح أو منتهي الصلاحية - Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Supabase puts the user ID in the "sub" claim
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="رمز المصادقة لا يحتوي على معرّف المستخدم - Token missing user ID",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return payload


def _check_store_membership(user_id: str, store_id: str) -> bool:
    """Query the store_members table to verify the user belongs to the store.

    Schema (supabase_init.sql): store_members has store_id (UUID) and user_id
    (UUID) but NO org_id column. Authorization is based on store_id + user_id.

    Returns True when the membership row exists, False otherwise.
    Falls back to allowing access when the Supabase client is unavailable
    (e.g. during local development without a database).
    """
    client = get_supabase_client()
    if client is None:
        # No DB configured – deny by default (secure).
        # Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY to enable membership checks.
        logger.error(
            "Supabase client unavailable; denying access for user=%s (configure DB to enable)",
            user_id,
        )
        return False

    try:
        result = (
            client.table("store_members")
            .select("id")
            .eq("user_id", user_id)
            .eq("store_id", store_id)
            .eq("is_active", True)
            .limit(1)
            .execute()
        )
        return bool(result.data)
    except Exception:
        # If the query itself fails (table missing, network error, etc.)
        # log and deny by default.
        logger.exception(
            "store_members lookup failed for user=%s store=%s",
            user_id,
            store_id,
        )
        return False


# ---------------------------------------------------------------------------
# Public FastAPI dependency
# ---------------------------------------------------------------------------
async def get_current_user(
    credentials: Annotated[
        HTTPAuthorizationCredentials, Depends(_bearer_scheme)
    ],
    settings: Annotated[Settings, Depends(get_settings)],
) -> AuthenticatedUser:
    """FastAPI dependency that authenticates the caller.

    Usage in a router::

        @router.post("/my-endpoint")
        async def my_endpoint(
            request: MyRequest,
            user: AuthenticatedUser = Depends(get_current_user),
        ):
            ...

    Raises:
        HTTPException 401 – missing or invalid token
    """
    payload = _decode_token(credentials.credentials, settings)

    return AuthenticatedUser(
        user_id=payload["sub"],
        email=payload.get("email"),
        role=payload.get("role"),
    )


async def verify_store_access(
    request: Request,
    user: Annotated[AuthenticatedUser, Depends(get_current_user)],
) -> AuthenticatedUser:
    """FastAPI dependency that authenticates **and** authorises the caller.

    It reads ``org_id`` and ``store_id`` from the JSON request body and checks
    the ``store_members`` table to ensure the user has access.

    This is the dependency that should be used on all AI routes because every
    request model inherits from ``BaseRequest`` which requires these fields.

    Raises:
        HTTPException 401 – missing / invalid token  (from get_current_user)
        HTTPException 403 – user is not a member of the requested org/store
    """
    # Read org_id / store_id from the request body.  The body may already have
    # been consumed by FastAPI's JSON parsing, so we cache it.
    try:
        body = await request.json()
    except Exception:
        body = {}

    org_id: str | None = body.get("org_id")
    store_id: str | None = body.get("store_id")

    if not org_id or not store_id:
        # Let the Pydantic model validation handle the missing fields; we just
        # skip the membership check here.
        return user

    if not _check_store_membership(user.user_id, store_id):
        logger.warning(
            "Access denied: user=%s org=%s store=%s",
            user.user_id,
            org_id,
            store_id,
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية الوصول لهذا المتجر - Access denied for this store",
        )

    return user
