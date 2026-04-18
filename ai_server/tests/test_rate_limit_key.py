"""Rate-limit key function tests - اختبارات دالة مفتاح الحد.

Bucket MUST be derived only from the cryptographically verified JWT `sub`
claim. Body-controlled fields (store_id in particular) must not influence the
key, otherwise a holder of any valid token can rotate buckets per-request and
bypass the per-user limit.
"""

import time
from unittest.mock import MagicMock

import jwt
import pytest

TEST_SECRET = "test-jwt-secret-used-only-in-tests-0123456789abcdefghijklmnopqrst"


def _token(user_id: str = "user-a", *, ttl_seconds: int = 3600) -> str:
    now = int(time.time())
    return jwt.encode(
        {
            "sub": user_id,
            "aud": "authenticated",
            "iat": now,
            "exp": now + ttl_seconds,
        },
        TEST_SECRET,
        algorithm="HS256",
    )


def _expired_token(user_id: str = "user-a") -> str:
    now = int(time.time())
    return jwt.encode(
        {
            "sub": user_id,
            "aud": "authenticated",
            "iat": now - 7200,
            "exp": now - 3600,
        },
        TEST_SECRET,
        algorithm="HS256",
    )


class _State:
    """Plain state object so `getattr(..., default)` returns the default when attr
    really isn't set (MagicMock auto-creates attrs which breaks the assertion)."""


def _fake_request(token: str | None = None, store_id: str | None = None,
                  cached_body: bytes | None = None, ip: str = "1.1.1.1"):
    req = MagicMock()
    req.headers = {"Authorization": f"Bearer {token}"} if token else {}
    state = _State()
    if store_id is not None:
        state.store_id = store_id
    state.cached_body = cached_body
    req.state = state
    req.client.host = ip
    return req


def test_key_falls_back_to_ip_when_unauthenticated():
    from rate_limit import rate_limit_key
    req = _fake_request(token=None, ip="9.9.9.9")
    assert rate_limit_key(req) == "9.9.9.9"


def test_key_uses_user_sub_when_authenticated():
    from rate_limit import rate_limit_key
    req = _fake_request(token=_token("user-a"))
    assert rate_limit_key(req) == "user:user-a"


def test_key_ignores_spoofed_body_store_id():
    """Regression: body-provided store_id MUST NOT rotate the bucket.

    Previously the key was `user:{sub}:store:{body.store_id}`, so an
    authenticated caller could bypass per-user limits by sending a fresh
    store_id per request. The membership check runs inside the route, too late
    to stop SlowAPI from minting a new bucket.
    """
    from rate_limit import rate_limit_key
    t = _token("user-a")
    k_no_store = rate_limit_key(_fake_request(token=t))
    k_store_x = rate_limit_key(_fake_request(token=t, store_id="store-x"))
    k_store_y = rate_limit_key(_fake_request(token=t, store_id="store-y"))
    # Same authenticated user must always share the same bucket.
    assert k_no_store == k_store_x == k_store_y == "user:user-a"


def test_key_ignores_cached_body_store_id():
    """Regression: even when request_id_middleware stashed a JSON body with
    store_id, rate_limit_key must not peek at it."""
    from rate_limit import rate_limit_key
    t = _token("user-a")
    req_a = _fake_request(token=t, cached_body=b'{"store_id": "aaa"}')
    req_b = _fake_request(token=t, cached_body=b'{"store_id": "bbb"}')
    assert rate_limit_key(req_a) == rate_limit_key(req_b) == "user:user-a"


def test_key_rejects_expired_token():
    """Expired JWTs must fall back to IP, not keep the old user's bucket alive."""
    from rate_limit import rate_limit_key
    req = _fake_request(token=_expired_token("user-a"), ip="9.9.9.9")
    assert rate_limit_key(req) == "9.9.9.9"


def test_key_rejects_garbage_token():
    from rate_limit import rate_limit_key
    req = _fake_request(token="not-a-real-jwt", ip="9.9.9.9")
    assert rate_limit_key(req) == "9.9.9.9"
