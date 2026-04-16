"""
Tests for Settings startup validation - اختبارات التحقق من إعدادات البدء

These tests exercise the @field_validator / @model_validator hooks on
`config.Settings`. They temporarily disable the conftest's
ALHAI_SKIP_STARTUP_VALIDATION escape hatch so the real validators fire.
"""

from __future__ import annotations

import pytest


VALID_SECRET = "a" * 40  # long enough (>= 32 chars)
VALID_URL = "https://test.supabase.co"


@pytest.fixture(autouse=True)
def _enable_validation(monkeypatch):
    """Turn OFF the skip-validation flag for these tests specifically."""
    monkeypatch.setenv("ALHAI_SKIP_STARTUP_VALIDATION", "0")


def _build_settings(**overrides):
    from config import Settings

    kwargs = {
        "jwt_secret": VALID_SECRET,
        "supabase_url": VALID_URL,
        "supabase_anon_key": "anon",
        "supabase_service_role_key": "service",
    }
    kwargs.update(overrides)
    return Settings(**kwargs)


# ---------------------------------------------------------------------------
# JWT_SECRET
# ---------------------------------------------------------------------------

def test_empty_jwt_secret_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(jwt_secret="")
    # pydantic wraps RuntimeError raised inside a validator in a
    # ValidationError, but the underlying message must still be surfaced.
    assert "JWT_SECRET" in str(exc_info.value)


def test_whitespace_only_jwt_secret_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(jwt_secret="   \t  ")
    assert "JWT_SECRET" in str(exc_info.value)


def test_short_jwt_secret_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(jwt_secret="a" * 31)  # one char under the limit
    msg = str(exc_info.value)
    assert "JWT_SECRET" in msg
    assert "32" in msg or "short" in msg.lower()


def test_valid_jwt_secret_accepted():
    s = _build_settings(jwt_secret="x" * 32)  # exactly the minimum
    assert s.jwt_secret == "x" * 32


# ---------------------------------------------------------------------------
# SUPABASE_URL
# ---------------------------------------------------------------------------

def test_non_https_supabase_url_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(supabase_url="http://insecure.example.com")
    assert "SUPABASE_URL" in str(exc_info.value)


def test_empty_supabase_url_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(supabase_url="")
    assert "SUPABASE_URL" in str(exc_info.value)


def test_valid_supabase_url_accepted():
    s = _build_settings(supabase_url="https://my-project.supabase.co")
    assert s.supabase_url == "https://my-project.supabase.co"


# ---------------------------------------------------------------------------
# SUPABASE_SERVICE_ROLE_KEY
# ---------------------------------------------------------------------------

def test_whitespace_service_role_key_rejected():
    with pytest.raises((RuntimeError, ValueError)) as exc_info:
        _build_settings(supabase_service_role_key="   ")
    assert "SERVICE_ROLE" in str(exc_info.value).upper()


def test_empty_service_role_key_allowed_for_local_dev():
    # Explicit empty string is allowed so developers can run locally without
    # Supabase; only whitespace-only values are rejected.
    s = _build_settings(supabase_service_role_key="")
    assert s.supabase_service_role_key == ""
