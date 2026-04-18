"""
Per-endpoint rate limiting configuration.

Heavy endpoints (image recognition, chat, reports) get stricter limits.
Light endpoints (forecast, pricing, etc.) get standard limits.

Key function: prefer `user:{sub}:store:{store_id}` when we have both from the
verified JWT + request body, so one store can't exhaust another store's bucket
(important for multi-tenant fairness). Falls back to `user:{sub}` if we have a
token but no store_id (e.g. auth endpoints), then to remote IP.
"""

import json
import logging

import jwt as _jwt
from jwt.exceptions import InvalidTokenError as _JWTError
from slowapi import Limiter
from slowapi.util import get_remote_address

logger = logging.getLogger(__name__)


def _verified_user_id(request) -> str | None:
    """Return the JWT `sub` claim if the Bearer token is cryptographically valid."""
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None
    token = auth_header[7:]
    try:
        from config import get_settings

        s = get_settings()
        secret_obj = s.jwt_secret
        secret = (
            secret_obj.get_secret_value()
            if hasattr(secret_obj, "get_secret_value")
            else (secret_obj or "")
        )
        if not secret:
            return None
        payload = _jwt.decode(
            token,
            secret,
            algorithms=["HS256"],
            audience=s.jwt_audience or "authenticated",
            options={"verify_aud": True, "verify_exp": False},
        )
        sub = payload.get("sub")
        return str(sub) if sub else None
    except _JWTError:
        return None
    except Exception:
        logger.debug("rate-limit key_func: unexpected JWT decode error", exc_info=True)
        return None


def _store_id_from_request(request) -> str | None:
    """Best-effort peek at store_id on the request state (set by auth middleware)
    or on a cached body. Never blocks and never raises.
    """
    store_id = getattr(request.state, "store_id", None)
    if store_id:
        return str(store_id)
    # Fall back to reading a cached body if FastAPI has already parsed it.
    body_bytes = getattr(request.state, "cached_body", None)
    if body_bytes:
        try:
            data = json.loads(body_bytes)
            sid = data.get("store_id")
            if sid:
                return str(sid)
        except Exception:
            return None
    return None


def rate_limit_key(request) -> str:
    """SlowAPI key function: user+store bucket when possible, else user, else IP."""
    user_id = _verified_user_id(request)
    if user_id:
        store_id = _store_id_from_request(request)
        if store_id:
            return f"user:{user_id}:store:{store_id}"
        return f"user:{user_id}"
    return get_remote_address(request)


limiter = Limiter(key_func=rate_limit_key, default_limits=["60/minute"])

RATE_STANDARD = "60/minute"      # Standard AI endpoints
RATE_HEAVY = "20/minute"         # Heavy endpoints (image processing, OpenAI calls)
RATE_CHAT = "30/minute"          # Chat/assistant endpoints (OpenAI calls)
RATE_HEALTH = "120/minute"       # Health check (lightweight)
