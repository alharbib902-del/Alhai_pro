"""Redis cache layer for OpenAI responses - اختبارات كاش OpenAI."""

from unittest.mock import MagicMock, patch

import pytest

from core import cache as openai_cache


@pytest.fixture(autouse=True)
def _reset_cache_module():
    openai_cache._reset_for_tests()
    yield
    openai_cache._reset_for_tests()


def test_build_key_format():
    key = openai_cache.build_key(
        org_id="org1",
        store_id="store1",
        endpoint_hint="chat",
        message="hello world",
        language="ar",
        context="general",
    )
    assert key.startswith("openai:org1:store1:chat:general:")
    assert key.endswith(":ar")
    # shape: openai:org:store:endpoint:context:digest:lang
    parts = key.split(":")
    assert len(parts) == 7
    assert len(parts[5]) == 16


def test_build_key_hashes_full_message_no_truncation():
    long_msg = "x" * 5000
    key1 = openai_cache.build_key("o", "s", "chat", long_msg, "ar")
    key2 = openai_cache.build_key("o", "s", "chat", long_msg + "y", "ar")
    # Messages differ only past byte 500 -- must still produce different keys.
    assert key1 != key2


def test_build_key_tenant_scoped():
    """Regression: cross-tenant / cross-endpoint / cross-context isolation.

    Identical message + language but differing scoping MUST produce distinct
    cache keys. Previously these all collapsed to a single global namespace.
    """
    msg, lang = "what is my sales forecast?", "en"
    base = openai_cache.build_key("orgA", "storeA", "assistant", msg, lang, context="sales")

    # Different org -> different key
    assert base != openai_cache.build_key("orgB", "storeA", "assistant", msg, lang, context="sales")
    # Different store -> different key
    assert base != openai_cache.build_key("orgA", "storeB", "assistant", msg, lang, context="sales")
    # Different endpoint (assistant vs chat) -> different key
    assert base != openai_cache.build_key("orgA", "storeA", "chat", msg, lang, context="sales")
    # Different context (sales vs inventory) -> different key (was the prompt-vs-key gap)
    assert base != openai_cache.build_key("orgA", "storeA", "assistant", msg, lang, context="inventory")
    # Default (unscoped) callers collapse to "_" but must not collide with a real tenant
    assert base != openai_cache.build_key("_", "_", "chat", msg, lang)


def test_cache_hit_returns_cached_value():
    fake_redis = MagicMock()
    fake_redis.ping.return_value = True
    fake_redis.get.return_value = "cached-reply"

    with patch("redis.Redis.from_url", return_value=fake_redis), \
         patch.object(openai_cache, "get_settings") as mock_settings:
        mock_settings.return_value.redis_url = "redis://fake:6379/0"
        result = openai_cache.get("openai:o:s:chat:abcd1234abcd1234:ar")
    assert result == "cached-reply"


def test_cache_miss_returns_none():
    fake_redis = MagicMock()
    fake_redis.ping.return_value = True
    fake_redis.get.return_value = None

    with patch("redis.Redis.from_url", return_value=fake_redis), \
         patch.object(openai_cache, "get_settings") as mock_settings:
        mock_settings.return_value.redis_url = "redis://fake:6379/0"
        assert openai_cache.get("missing-key") is None


def test_cache_disabled_when_no_url():
    with patch.object(openai_cache, "get_settings") as mock_settings:
        mock_settings.return_value.redis_url = ""
        assert openai_cache.get("any-key") is None
        openai_cache.set_value("any-key", "val")


def test_cache_fallback_when_redis_unavailable():
    with patch("redis.Redis.from_url", side_effect=RuntimeError("conn refused")), \
         patch.object(openai_cache, "get_settings") as mock_settings:
        mock_settings.return_value.redis_url = "redis://bad:6379/0"
        assert openai_cache.get("k") is None
        openai_cache.set_value("k", "v")


def test_chat_completion_redis_hit_skips_openai():
    """If Redis returns a value, OpenAI client should never be called."""
    fake_redis = MagicMock()
    fake_redis.ping.return_value = True
    fake_redis.get.return_value = "from-cache"

    with patch("redis.Redis.from_url", return_value=fake_redis), \
         patch.object(openai_cache, "get_settings") as mock_cache_settings:
        mock_cache_settings.return_value.redis_url = "redis://fake:6379/0"

        with patch("services.openai_service.get_client") as mock_get_client:
            mock_client = MagicMock()
            mock_get_client.return_value = mock_client

            from services.openai_service import chat_completion

            result = chat_completion(
                "hi there",
                language="en",
                org_id="org1",
                store_id="store1",
                endpoint_hint="assistant",
            )
    assert result == "from-cache"
    # OpenAI was never called because cache hit
    mock_client.chat.completions.create.assert_not_called()


def test_chat_completion_redis_miss_calls_openai_and_caches():
    """On miss, OpenAI is called and the response is stored in Redis."""
    fake_redis = MagicMock()
    fake_redis.ping.return_value = True
    fake_redis.get.return_value = None

    with patch("redis.Redis.from_url", return_value=fake_redis), \
         patch.object(openai_cache, "get_settings") as mock_cache_settings:
        mock_cache_settings.return_value.redis_url = "redis://fake:6379/0"

        fake_openai = MagicMock()
        fake_completion = MagicMock()
        fake_completion.choices = [MagicMock(message=MagicMock(content="openai-reply"))]
        fake_openai.chat.completions.create.return_value = fake_completion

        with patch("services.openai_service.get_client", return_value=fake_openai):
            from services.openai_service import chat_completion

            result = chat_completion(
                "hi there",
                language="en",
                org_id="org1",
                store_id="store1",
                endpoint_hint="assistant",
            )

    assert result == "openai-reply"
    fake_openai.chat.completions.create.assert_called_once()
    # SETEX (via setex) should have been used for TTL'd write
    assert fake_redis.setex.called
