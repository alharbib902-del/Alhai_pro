"""
Tests for the /health endpoint - اختبارات فحص الصحة

Health is a lightweight endpoint; it should always respond with 200 and the
expected JSON shape even when Supabase is unavailable (status then reports
as "degraded").
"""


def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_json_shape(client):
    response = client.get("/health")
    data = response.json()

    # Required keys
    for key in ("status", "service", "version", "dependencies"):
        assert key in data, f"missing key: {key}"

    assert data["service"] == "alhai-ai-server"
    # status is "healthy" when Supabase ping works, "degraded" otherwise —
    # both are acceptable during tests (no live DB).
    assert data["status"] in ("healthy", "degraded")

    # Dependencies section
    assert isinstance(data["dependencies"], dict)
    assert "supabase" in data["dependencies"]
    assert data["dependencies"]["supabase"] in ("connected", "unavailable")
