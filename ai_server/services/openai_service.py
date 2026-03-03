"""OpenAI Service - خدمة الذكاء الاصطناعي عبر OpenAI"""

from openai import OpenAI
from config import get_settings
from i18n.translations import get_language_prompt

_client: OpenAI | None = None


def get_client() -> OpenAI | None:
    """Get OpenAI client, returns None if API key not configured."""
    global _client
    settings = get_settings()
    if not settings.openai_api_key:
        return None
    if _client is None:
        _client = OpenAI(api_key=settings.openai_api_key)
    return _client


def chat_completion(message: str, context: str = "general",
                    language: str = "ar") -> str | None:
    """Send a message to OpenAI and get a response. Returns None if not configured."""
    client = get_client()
    if client is None:
        return None

    system = get_language_prompt(language)
    if context != "general":
        context_label = {"ar": "السياق الحالي", "en": "Current context",
                         "ur": "موجودہ سیاق", "hi": "वर्तमान संदर्भ",
                         "bn": "বর্তমান প্রসঙ্গ", "fil": "Kasalukuyang konteksto",
                         "id": "Konteks saat ini"}.get(language, "Context")
        system += f"\n\n{context_label}: {context}"

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": message},
        ],
        max_tokens=500,
        temperature=0.7,
    )
    return response.choices[0].message.content
