"""OpenAI Service - خدمة الذكاء الاصطناعي عبر OpenAI"""

from openai import OpenAI
from config import get_settings

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


SYSTEM_PROMPT = """أنت مساعد ذكي لنظام نقاط البيع "الحي" (Alhai POS).
تساعد أصحاب المتاجر والبقالات في السعودية بتحليل المبيعات والمخزون والموظفين والعملاء.
- أجب بالعربية دائماً
- كن مختصراً ومفيداً
- قدم أرقام وإحصائيات عند الإمكان
- اقترح إجراءات عملية
- استخدم عملة الريال السعودي (ر.س)"""


def chat_completion(message: str, context: str = "general") -> str | None:
    """Send a message to OpenAI and get a response. Returns None if not configured."""
    client = get_client()
    if client is None:
        return None

    system = SYSTEM_PROMPT
    if context != "general":
        system += f"\n\nالسياق الحالي: {context}"

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
