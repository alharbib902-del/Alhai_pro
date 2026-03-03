"""
Tests for JWT authentication & store authorization - اختبارات المصادقة والتفويض

Tests cover:
- Valid JWT accepted
- Missing token rejected (403 - HTTPBearer auto_error)
- Expired / malformed token rejected (401)
- User without store membership rejected (403)
"""

import time
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient
from jose import jwt

from config import Settings, get_settings
from main import app

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
TEST_JWT_SECRET = "test-jwt-secret-for-unit-tests"
BASE_BODY = {"org_id": "org_test_001", "store_id": "store_test_001"}


def _make_token(
    user_id: str = "user_001",
    email: str = "user@alhai.app",
    role: str = "authenticated",
    exp_offset: int = 3600,
    secret: str = TEST_JWT_SECRET,
) -> str:
    """Create a signed JWT for testing."""
    payload = {
        "sub": user_id,
        "email": email,
        "role": role,
        "iat": int(time.time()),
        "exp": int(time.time()) + exp_offset,
    }
    return jwt.encode(payload, secret, algorithm="HS256")


def _auth_header(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _settings_with_secret(secret: str = TEST_JWT_SECRET) -> Settings:
    """Create a Settings instance with the test JWT secret."""
    return Settings(
        jwt_secret=secret,
        supabase_url="https://test.supabase.co",
        supabase_anon_key="",
        supabase_service_role_key="",
    )


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture(autouse=True)
def _clear_overrides():
    """Ensure no dependency overrides leak between auth tests."""
    saved = app.dependency_overrides.copy()
    app.dependency_overrides.clear()
    yield
    app.dependency_overrides.clear()
    app.dependency_overrides.update(saved)


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def client_with_secret(client):
    """TestClient with the JWT secret configured via dependency override."""
    app.dependency_overrides[get_settings] = lambda: _settings_with_secret()
    return client


# ---------------------------------------------------------------------------
# Tests: token validation
# ---------------------------------------------------------------------------

def test_missing_token_returns_403(client):
    """No Authorization header at all."""
    response = client.post("/ai/forecast", json={**BASE_BODY, "days_ahead": 7})
    assert response.status_code == 403  # HTTPBearer auto_error


def test_invalid_token_returns_401(client_with_secret):
    """Garbage token."""
    response = client_with_secret.post(
        "/ai/forecast",
        json={**BASE_BODY, "days_ahead": 7},
        headers=_auth_header("not-a-real-jwt"),
    )
    assert response.status_code == 401


def test_expired_token_returns_401(client_with_secret):
    """Token with exp in the past."""
    token = _make_token(exp_offset=-3600)  # expired 1 hour ago
    response = client_with_secret.post(
        "/ai/forecast",
        json={**BASE_BODY, "days_ahead": 7},
        headers=_auth_header(token),
    )
    assert response.status_code == 401


def test_wrong_secret_returns_401(client_with_secret):
    """Token signed with a different secret."""
    token = _make_token(secret="wrong-secret")
    response = client_with_secret.post(
        "/ai/forecast",
        json={**BASE_BODY, "days_ahead": 7},
        headers=_auth_header(token),
    )
    assert response.status_code == 401


# ---------------------------------------------------------------------------
# Tests: store membership
# ---------------------------------------------------------------------------

def test_valid_token_with_membership_succeeds(client_with_secret):
    """Happy path: valid JWT + user is a store member."""
    token = _make_token()
    with patch("auth._check_store_membership", return_value=True) as mock_check:
        response = client_with_secret.post(
            "/ai/forecast",
            json={**BASE_BODY, "days_ahead": 7},
            headers=_auth_header(token),
        )
        # Verify the function was called with correct args (no org_id)
        mock_check.assert_called_once_with("user_001", BASE_BODY["store_id"])
    assert response.status_code == 200
    assert "predictions" in response.json()


def test_valid_token_without_membership_returns_403(client_with_secret):
    """Valid JWT but user is NOT a member of the requested store."""
    token = _make_token()
    with patch("auth._check_store_membership", return_value=False) as mock_check:
        response = client_with_secret.post(
            "/ai/forecast",
            json={**BASE_BODY, "days_ahead": 7},
            headers=_auth_header(token),
        )
        # Verify the function was called with correct args (no org_id)
        mock_check.assert_called_once_with("user_001", BASE_BODY["store_id"])
    assert response.status_code == 403


def test_membership_check_queries_correct_columns(client_with_secret):
    """Verify _check_store_membership builds the correct Supabase query
    matching supabase_init.sql schema (no org_id column)."""
    from unittest.mock import MagicMock

    mock_client = MagicMock()
    mock_table = MagicMock()
    mock_client.table.return_value = mock_table
    mock_table.select.return_value = mock_table
    mock_table.eq.return_value = mock_table
    mock_table.limit.return_value = mock_table
    mock_table.execute.return_value = MagicMock(data=[{"id": "member_1"}])

    with patch("auth.get_supabase_client", return_value=mock_client):
        from auth import _check_store_membership
        result = _check_store_membership("user_001", "store_001")

    assert result is True
    mock_client.table.assert_called_once_with("store_members")
    mock_table.select.assert_called_once_with("id")
    # Verify eq calls: user_id, store_id, is_active — NO org_id
    eq_calls = [call.args for call in mock_table.eq.call_args_list]
    assert ("user_id", "user_001") in eq_calls
    assert ("store_id", "store_001") in eq_calls
    assert ("is_active", True) in eq_calls
    # Ensure org_id is NOT queried
    eq_keys = [call[0] for call in eq_calls]
    assert "org_id" not in eq_keys


def test_no_supabase_client_denies_by_default(client_with_secret):
    """When Supabase client is unavailable, membership check should DENY (not allow)."""
    with patch("auth.get_supabase_client", return_value=None):
        from auth import _check_store_membership
        result = _check_store_membership("user_001", "store_001")
    assert result is False, "Must deny access when DB is unavailable (fail-closed)"


def test_no_jwt_secret_configured_returns_401(client):
    """Server misconfiguration: JWT_SECRET is empty."""
    app.dependency_overrides[get_settings] = lambda: _settings_with_secret(secret="")
    token = _make_token()
    response = client.post(
        "/ai/forecast",
        json={**BASE_BODY, "days_ahead": 7},
        headers=_auth_header(token),
    )
    assert response.status_code == 401


def test_token_without_sub_claim_returns_401(client_with_secret):
    """Token that lacks the 'sub' claim."""
    # Manually build a token without 'sub'
    payload = {
        "email": "user@alhai.app",
        "role": "authenticated",
        "iat": int(time.time()),
        "exp": int(time.time()) + 3600,
    }
    token = jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")
    response = client_with_secret.post(
        "/ai/forecast",
        json={**BASE_BODY, "days_ahead": 7},
        headers=_auth_header(token),
    )
    assert response.status_code == 401
