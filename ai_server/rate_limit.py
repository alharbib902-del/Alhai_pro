"""
Per-endpoint rate limiting configuration.

Heavy endpoints (image recognition, chat, reports) get stricter limits.
Light endpoints (forecast, pricing, etc.) get standard limits.

Key function: `user:{sub}` derived ONLY from a cryptographically valid and
unexpired Bearer JWT; falls back to remote IP when the caller is
unauthenticated. The bucket MUST NOT be influenced by body-controlled values
like `store_id` -- a prior revision did so, which let any authenticated caller
rotate buckets by submitting a different store_id per request (the membership
check runs later, inside the route). Membership / store-scoped quotas, if ever
needed, belong in a post-auth counter, not in SlowAPI's key function.
"""

import logging

import jwt as _jwt
from jwt.exceptions import InvalidTokenError as _JWTError
from slowapi import Limiter
from slowapi.util import get_remote_address

logger = logging.getLogger(__name__)


def _verified_user_id(request) -> str | None:
    """Return JWT `sub` if the Bearer token is signed, audience-correct, unexpired."""
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
            options={"verify_aud": True, "verify_exp": True},
        )
        sub = payload.get("sub")
        return str(sub) if sub else None
    except _JWTError:
        return None
    except Exception:
        logger.debug("rate-limit key_func: unexpected JWT decode error", exc_info=True)
        return None


def rate_limit_key(request) -> str:
    """SlowAPI key function.

    Returns `user:{sub}` for any request with a valid unexpired Bearer token,
    else the remote IP. Body-controlled values are intentionally ignored.
    """
    user_id = _verified_user_id(request)
    if user_id:
        return f"user:{user_id}"
    return get_remote_address(request)


limiter = Limiter(key_func=rate_limit_key, default_limits=["60/minute"])

RATE_STANDARD = "60/minute"      # Standard AI endpoints
RATE_HEAVY = "20/minute"         # Heavy endpoints (image processing, OpenAI calls)
RATE_CHAT = "30/minute"          # Chat/assistant endpoints (OpenAI calls)
RATE_HEALTH = "120/minute"       # Health check (lightweight)
