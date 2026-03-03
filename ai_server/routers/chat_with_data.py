"""الدردشة مع البيانات - Chat with Data Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import ChatRequest, ChatResponse
from services.ml_service import chat_with_data
from services.openai_service import chat_completion
from i18n.translations import t

router = APIRouter()


@router.post("/chat", response_model=ChatResponse, summary="الدردشة مع البيانات")
async def chat(
    request: ChatRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    دردشة ذكية مع بيانات المتجر - اسأل أي سؤال بالعربية أو الإنجليزية.
    يستخدم OpenAI إذا كان مفتاح API متاحاً، وإلا يعود للبيانات الافتراضية.

    - **message**: رسالة المستخدم
    - **conversation_id**: لاستمرار محادثة سابقة
    """
    try:
        # Try OpenAI first
        ai_reply = chat_completion(request.message, context="chat_with_data", language=request.language)
        if ai_reply:
            conv_id = request.conversation_id or "conv_ai"
            return ChatResponse(
                reply=ai_reply,
                data=None,
                chart_type=None,
                suggestions=[t("suggest_today_sales", request.language), t("suggest_inventory_status", request.language), t("suggest_best_employee", request.language)],
                conversation_id=conv_id,
            )

        # Fallback to mock data
        return chat_with_data(
            org_id=request.org_id,
            store_id=request.store_id,
            message=request.message,
            conversation_id=request.conversation_id,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في الدردشة: {e}")
