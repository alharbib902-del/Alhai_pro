"""
Shared pytest fixtures - ثوابت واختبارات مشتركة

This conftest:
- Sets safe test env vars (JWT_SECRET, SUPABASE_URL, etc.) BEFORE the app is
  imported so Settings validators pass at import time.
- Exposes a `client` fixture returning a TestClient bound to the FastAPI app.
- Clears `app.dependency_overrides` between tests so they don't leak.

Tests that want to exercise the Settings validators directly (see
`test_config_validation.py`) set `ALHAI_SKIP_STARTUP_VALIDATION=0` and build
a Settings instance themselves.
"""

from __future__ import annotations

import os

# 64-char random-looking string: length > 32, satisfies the validator.
_TEST_JWT_SECRET = "test-jwt-secret-used-only-in-tests-0123456789abcdefghijklmnopqrst"
_TEST_SUPABASE_URL = "https://test.supabase.co"

# These must be set before `main` / `config` is imported anywhere. Putting the
# assignments at module top-level of conftest ensures pytest runs them before
# any test module is collected.
os.environ.setdefault("JWT_SECRET", _TEST_JWT_SECRET)
os.environ.setdefault("SUPABASE_URL", _TEST_SUPABASE_URL)
os.environ.setdefault("SUPABASE_ANON_KEY", "test-anon-key")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "test-service-role-key")
os.environ.setdefault("OPENAI_API_KEY", "test-openai-key")
# Allow legacy tests that build Settings(jwt_secret="short") to keep working.
os.environ.setdefault("ALHAI_SKIP_STARTUP_VALIDATION", "1")

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402


@pytest.fixture
def client():
    """TestClient bound to the FastAPI app, with dependency overrides reset."""
    from main import app

    saved = app.dependency_overrides.copy()
    app.dependency_overrides.clear()
    try:
        yield TestClient(app)
    finally:
        app.dependency_overrides.clear()
        app.dependency_overrides.update(saved)


@pytest.fixture
def test_jwt_secret() -> str:
    return _TEST_JWT_SECRET


@pytest.fixture
def test_supabase_url() -> str:
    return _TEST_SUPABASE_URL
