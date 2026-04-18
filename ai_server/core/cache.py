"""Redis cache for OpenAI responses.

Thin sync wrapper. Used only to deduplicate repeat chat completions for the
same (org, store, endpoint, context, message, lang) tuple. If Redis is
unavailable we log once and skip caching -- calls proceed as normal.
"""

from __future__ import annotations

import hashlib
import logging
import os

from config import get_settings

logger = logging.getLogger(__name__)

_client = None
_client_tried = False
_unavailable_logged = False


def _get_client():
    global _client, _client_tried, _unavailable_logged
    if _client_tried:
        return _client
    _client_tried = True

    url = get_settings().redis_url
    if not url:
        return None
    try:
        import redis

        _client = redis.Redis.from_url(
            url,
            socket_connect_timeout=1.0,
            socket_timeout=1.0,
            decode_responses=True,
        )
        _client.ping()
        logger.info("OpenAI Redis cache enabled")
        return _client
    except Exception as exc:
        if not _unavailable_logged:
            logger.warning("OpenAI Redis cache disabled: %s", exc)
            _unavailable_logged = True
        _client = None
        return None


def _reset_for_tests():
    global _client, _client_tried, _unavailable_logged
    _client = None
    _client_tried = False
    _unavailable_logged = False


def build_key(
    org_id: str,
    store_id: str,
    endpoint_hint: str,
    message: str,
    language: str,
    context: str = "general",
) -> str:
    """Build cache key scoped to (org, store, endpoint, context, message, lang).

    Hashes the full message -- truncating the input before hashing would let
    long messages sharing a common prefix collide.
    """
    digest = hashlib.sha256(message.encode("utf-8")).hexdigest()[:16]
    return (
        f"openai:{org_id}:{store_id}:{endpoint_hint}:"
        f"{context}:{digest}:{language}"
    )


def get(key: str) -> str | None:
    client = _get_client()
    if client is None:
        return None
    try:
        return client.get(key)
    except Exception:
        logger.debug("Redis GET failed", exc_info=True)
        return None


def set_value(key: str, value: str, ttl_seconds: int | None = None) -> None:
    client = _get_client()
    if client is None:
        return
    if ttl_seconds is None:
        ttl_seconds = int(os.environ.get("OPENAI_CACHE_TTL_SECONDS", "86400"))
    try:
        client.setex(key, ttl_seconds, value)
    except Exception:
        logger.debug("Redis SETEX failed", exc_info=True)
