"""OpenAI Service - خدمة الذكاء الاصطناعي عبر OpenAI"""

import logging

from openai import OpenAI, OpenAIError
from config import get_settings
from core import cache as openai_cache
from i18n.translations import get_language_prompt

logger = logging.getLogger(__name__)

_client: OpenAI | None = None


def get_client() -> OpenAI | None:
    """Get OpenAI client, returns None if API key not configured."""
    global _client
    settings = get_settings()
    api_key_obj = settings.openai_api_key
    api_key = (
        api_key_obj.get_secret_value()
        if hasattr(api_key_obj, "get_secret_value")
        else (api_key_obj or "")
    )
    if not api_key:
        return None
    if _client is None:
        _client = OpenAI(
            api_key=api_key,
            max_retries=2,
            timeout=30.0,
        )
    return _client


def chat_completion(
    message: str,
    context: str = "general",
    language: str = "ar",
    *,
    org_id: str = "_",
    store_id: str = "_",
    endpoint_hint: str = "chat",
) -> str | None:
    """Send a message to OpenAI and get a response.

    Returns None if the client isn't configured OR if the OpenAI API fails.
    Callers MUST check for None and fall back to a mock response.

    Caching layers (both best-effort, never raise):
    - Redis (our own): dedupes repeat calls across users for the same tuple.
    - OpenAI automatic prompt caching: triggered when the static system prompt
      is sent first as a stable >=1024-token prefix (so we keep it verbatim at
      index 0 of the messages list).
    """
    client = get_client()
    if client is None:
        return None

    cache_key = openai_cache.build_key(
        org_id=org_id,
        store_id=store_id,
        endpoint_hint=endpoint_hint,
        message=message,
        language=language,
    )
    cached = openai_cache.get(cache_key)
    if cached is not None:
        return cached

    system = get_language_prompt(language)
    if context != "general":
        context_label = {"ar": "السياق الحالي", "en": "Current context",
                         "ur": "موجودہ سیاق", "hi": "वर्तमान संदर्भ",
                         "bn": "বর্তমান প্রসঙ্গ", "fil": "Kasalukuyang konteksto",
                         "id": "Konteks saat ini"}.get(language, "Context")
        system += f"\n\n{context_label}: {context}"

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": message},
            ],
            max_tokens=500,
            temperature=0.7,
            extra_body={"prompt_cache_key": f"alhai:{language}:{endpoint_hint}"},
        )
        reply = response.choices[0].message.content
        if reply:
            openai_cache.set_value(cache_key, reply)
        return reply
    except OpenAIError as exc:
        logger.warning("OpenAI chat_completion failed, falling back to mock: %s", exc)
        return None
    except Exception:
        logger.exception("Unexpected error in chat_completion; falling back to mock")
        return None
