"""Rate-limit key function tests - اختبارات دالة مفتاح الحد."""

import time
from unittest.mock import MagicMock

import jwt
import pytest

TEST_SECRET = "test-jwt-secret-used-only-in-tests-0123456789abcdefghijklmnopqrst"


def _token(user_id: str = "user-a") -> str:
    return jwt.encode(
        {
            "sub": user_id,
            "aud": "authenticated",
            "iat": int(time.time()),
            "exp": int(time.time()) + 3600,
        },
        TEST_SECRET,
        algorithm="HS256",
    )


class _State:
    """Plain state object so `getattr(..., default)` returns the default when attr
    really isn't set (MagicMock auto-creates attrs which breaks the assertion)."""


def _fake_request(token: str | None = None, store_id: str | None = None, ip: str = "1.1.1.1"):
    req = MagicMock()
    req.headers = {"Authorization": f"Bearer {token}"} if token else {}
    state = _State()
    if store_id is not None:
        state.store_id = store_id
    state.cached_body = None
    req.state = state
    req.client.host = ip
    return req


def test_key_falls_back_to_ip_when_unauthenticated():
    from rate_limit import rate_limit_key
    req = _fake_request(token=None, ip="9.9.9.9")
    assert rate_limit_key(req) == "9.9.9.9"


def test_key_uses_user_only_when_no_store():
    from rate_limit import rate_limit_key
    req = _fake_request(token=_token("user-a"), store_id=None)
    assert rate_limit_key(req) == "user:user-a"


def test_key_combines_user_and_store_when_both_present():
    from rate_limit import rate_limit_key
    req = _fake_request(token=_token("user-a"), store_id="store-1")
    assert rate_limit_key(req) == "user:user-a:store:store-1"


def test_same_user_different_stores_get_different_keys():
    """The whole point of this upgrade: one store must not starve another."""
    from rate_limit import rate_limit_key
    k1 = rate_limit_key(_fake_request(token=_token("user-a"), store_id="store-1"))
    k2 = rate_limit_key(_fake_request(token=_token("user-a"), store_id="store-2"))
    assert k1 != k2
    assert k1 == "user:user-a:store:store-1"
    assert k2 == "user:user-a:store:store-2"


def test_store_id_from_cached_body_fallback():
    """If middleware stashed raw body instead of parsed store_id, we still parse it."""
    from rate_limit import rate_limit_key
    req = _fake_request(token=_token("user-a"))
    req.state.cached_body = b'{"store_id": "store-from-body"}'
    assert rate_limit_key(req) == "user:user-a:store:store-from-body"
