"""
Test all 15 AI endpoints - اختبار جميع نقاط النهاية

The auth dependency (verify_store_access) is overridden with a stub so that
the endpoint logic can be tested in isolation without a real JWT or Supabase.
Dedicated auth tests are in test_auth.py.
"""

import pytest
from fastapi.testclient import TestClient

from auth import AuthenticatedUser, verify_store_access
from main import app

# ---------------------------------------------------------------------------
# Auth override – bypass JWT verification for endpoint tests
# ---------------------------------------------------------------------------
_TEST_USER = AuthenticatedUser(
    user_id="test_user_001",
    email="test@alhai.app",
    role="authenticated",
)


async def _stub_verify_store_access() -> AuthenticatedUser:
    """Return a fake authenticated user for every request."""
    return _TEST_USER


app.dependency_overrides[verify_store_access] = _stub_verify_store_access

client = TestClient(app)

BASE_BODY = {"org_id": "00000000-0000-4000-a000-000000000001", "store_id": "00000000-0000-4000-a000-000000000002"}


# ============================================================================
# HEALTH CHECK
# ============================================================================

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] in ("healthy", "degraded")
    assert "dependencies" in data
    assert data["service"] == "alhai-ai-server"


# ============================================================================
# 1. SALES FORECAST
# ============================================================================

def test_forecast():
    response = client.post("/ai/forecast", json={**BASE_BODY, "days_ahead": 7})
    assert response.status_code == 200
    data = response.json()
    assert "predictions" in data
    assert "summary" in data
    assert len(data["predictions"]) == 7
    assert data["summary"]["trend"] in ["up", "down", "stable"]


def test_forecast_30_days():
    response = client.post("/ai/forecast", json={**BASE_BODY, "days_ahead": 30})
    assert response.status_code == 200
    assert len(response.json()["predictions"]) == 30


# ============================================================================
# 2. SMART PRICING
# ============================================================================

def test_pricing():
    response = client.post("/ai/pricing", json={**BASE_BODY, "strategy": "optimal"})
    assert response.status_code == 200
    data = response.json()
    assert "suggestions" in data
    assert len(data["suggestions"]) > 0
    assert data["strategy_used"] == "optimal"


# ============================================================================
# 3. FRAUD DETECTION
# ============================================================================

def test_fraud_detection():
    response = client.post("/ai/fraud", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "alerts" in data
    assert "summary" in data
    assert data["summary"]["total_flagged"] > 0


def test_fraud_with_sale_id():
    response = client.post("/ai/fraud", json={**BASE_BODY, "sale_id": "sale_123"})
    assert response.status_code == 200
    assert response.json()["alerts"][0]["sale_id"] == "sale_123"


# ============================================================================
# 4. BASKET ANALYSIS
# ============================================================================

def test_basket_analysis():
    response = client.post("/ai/basket", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "rules" in data
    assert "summary" in data
    assert "frequently_bought_together" in data
    assert len(data["rules"]) > 0


# ============================================================================
# 5. CUSTOMER RECOMMENDATIONS
# ============================================================================

def test_recommendations():
    response = client.post("/ai/recommendations", json={**BASE_BODY, "top_n": 5})
    assert response.status_code == 200
    data = response.json()
    assert "recommendations" in data
    assert len(data["recommendations"]) == 5
    assert "customer_segments" in data


# ============================================================================
# 6. SMART INVENTORY
# ============================================================================

def test_inventory():
    response = client.post("/ai/inventory", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "alerts" in data
    assert "optimization" in data
    assert "abc_classification" in data
    # First alert should be critical priority
    assert data["alerts"][0]["priority"] == "critical"


# ============================================================================
# 7. COMPETITOR ANALYSIS
# ============================================================================

def test_competitor():
    response = client.post("/ai/competitor", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "competitors" in data
    assert "price_comparisons" in data
    assert "opportunities" in data
    assert len(data["competitors"]) > 0


# ============================================================================
# 8. SMART REPORTS
# ============================================================================

def test_reports():
    response = client.post("/ai/reports", json={**BASE_BODY, "report_type": "daily_summary"})
    assert response.status_code == 200
    data = response.json()
    assert "sections" in data
    assert "executive_summary" in data
    assert "key_metrics" in data
    assert len(data["sections"]) > 0


# ============================================================================
# 9. STAFF ANALYTICS
# ============================================================================

def test_staff():
    response = client.post("/ai/staff", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "employees" in data
    assert "summary" in data
    assert "shift_recommendations" in data
    assert len(data["employees"]) > 0
    # Employees should be ranked
    assert data["employees"][0]["rank"] == 1


# ============================================================================
# 10. PRODUCT RECOGNITION
# ============================================================================

def test_recognize_barcode():
    response = client.post("/ai/recognize", json={**BASE_BODY, "barcode": "6281048123456"})
    assert response.status_code == 200
    data = response.json()
    assert "products" in data
    assert data["method"] == "barcode"
    assert data["products"][0]["confidence"] > 0.9


def test_recognize_text():
    response = client.post("/ai/recognize", json={**BASE_BODY, "description": "أرز بسمتي"})
    assert response.status_code == 200
    assert response.json()["method"] == "text"


# ============================================================================
# 11. SENTIMENT ANALYSIS
# ============================================================================

def test_sentiment():
    response = client.post("/ai/sentiment", json=BASE_BODY)
    assert response.status_code == 200
    data = response.json()
    assert "results" in data
    assert "summary" in data
    total = data["summary"]["positive_percent"] + data["summary"]["negative_percent"] + data["summary"]["neutral_percent"]
    assert abs(total - 100) < 1  # Should sum to ~100%


def test_sentiment_with_text():
    response = client.post("/ai/sentiment", json={**BASE_BODY, "text": "المتجر ممتاز والخدمة رائعة"})
    assert response.status_code == 200
    assert response.json()["results"][0]["sentiment"] == "إيجابي"


# ============================================================================
# 12. RETURN PREDICTION
# ============================================================================

def test_returns():
    response = client.post("/ai/returns", json={**BASE_BODY, "days_ahead": 30})
    assert response.status_code == 200
    data = response.json()
    assert "predictions" in data
    assert "summary" in data
    assert "prevention_tips" in data
    assert len(data["prevention_tips"]) > 0


# ============================================================================
# 13. PROMOTION DESIGNER
# ============================================================================

def test_promotions():
    response = client.post("/ai/promotions", json={**BASE_BODY, "goal": "increase_sales"})
    assert response.status_code == 200
    data = response.json()
    assert "promotions" in data
    assert "best_timing" in data
    assert len(data["promotions"]) > 0
    # Promotions should be prioritized
    assert data["promotions"][0]["priority"] == 1


# ============================================================================
# 14. CHAT WITH DATA
# ============================================================================

def test_chat():
    response = client.post("/ai/chat", json={**BASE_BODY, "message": "كم مبيعات اليوم؟"})
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert "conversation_id" in data
    assert "suggestions" in data
    assert len(data["suggestions"]) > 0


def test_chat_inventory():
    response = client.post("/ai/chat", json={**BASE_BODY, "message": "ما حالة المخزون؟"})
    assert response.status_code == 200
    data = response.json()
    assert data["chart_type"] == "pie"


# ============================================================================
# 15. ASSISTANT
# ============================================================================

def test_assistant():
    response = client.post("/ai/assistant", json={**BASE_BODY, "query": "ما المبيعات اليوم؟"})
    assert response.status_code == 200
    data = response.json()
    assert "answer" in data
    assert "confidence" in data
    assert "actions" in data
    assert data["confidence"] > 0.5


def test_assistant_general():
    response = client.post("/ai/assistant", json={**BASE_BODY, "query": "مرحبا"})
    assert response.status_code == 200
    assert len(response.json()["actions"]) > 0


# ============================================================================
# CONSISTENCY TESTS
# ============================================================================

def test_deterministic_results():
    """Same org+store should return same results."""
    r1 = client.post("/ai/forecast", json={**BASE_BODY, "days_ahead": 7}).json()
    r2 = client.post("/ai/forecast", json={**BASE_BODY, "days_ahead": 7}).json()
    assert r1["predictions"][0]["predicted_revenue"] == r2["predictions"][0]["predicted_revenue"]


def test_different_stores_different_results():
    """Different stores should return different results."""
    r1 = client.post("/ai/forecast", json={"org_id": "00000000-0000-4000-a000-000000000001", "store_id": "00000000-0000-4000-a000-000000000010", "days_ahead": 7}).json()
    r2 = client.post("/ai/forecast", json={"org_id": "00000000-0000-4000-a000-000000000001", "store_id": "00000000-0000-4000-a000-000000000020", "days_ahead": 7}).json()
    assert r1["predictions"][0]["predicted_revenue"] != r2["predictions"][0]["predicted_revenue"]


# ============================================================================
# AUTH REJECTION TESTS - verify that without the override, auth is required
# ============================================================================

def test_unauthenticated_request_rejected():
    """Requests without a Bearer token should be rejected with 403."""
    # Create a fresh test client without the auth override
    from main import app as fresh_app
    # Temporarily remove the override
    saved = fresh_app.dependency_overrides.copy()
    fresh_app.dependency_overrides.clear()
    try:
        unauthenticated_client = TestClient(fresh_app)
        response = unauthenticated_client.post(
            "/ai/forecast", json={**BASE_BODY, "days_ahead": 7}
        )
        # HTTPBearer auto_error=True returns 403 when no Authorization header
        assert response.status_code == 403
    finally:
        fresh_app.dependency_overrides.update(saved)
