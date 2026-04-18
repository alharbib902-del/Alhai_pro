"""الدردشة مع البيانات - Chat with Data Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Request as FastAPIRequest

from auth import AuthenticatedUser, verify_store_access
from i18n.translations import t
from models.schemas import ChatRequest, ChatResponse
from rate_limit import RATE_CHAT, limiter
from services.ml_service import chat_with_data
from services.openai_service import chat_completion

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/chat", response_model=ChatResponse, summary="الدردشة مع البيانات")
@limiter.limit(RATE_CHAT)
async def chat(
    request: FastAPIRequest,
    body: ChatRequest,
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
        ai_reply = chat_completion(
            body.message,
            context="chat_with_data",
            language=body.language,
            org_id=str(body.org_id),
            store_id=str(body.store_id),
            endpoint_hint="chat",
        )
        if ai_reply:
            conv_id = body.conversation_id or "conv_ai"
            return ChatResponse(
                reply=ai_reply,
                data=None,
                chart_type=None,
                suggestions=[t("suggest_today_sales", body.language), t("suggest_inventory_status", body.language), t("suggest_best_employee", body.language)],
                conversation_id=conv_id,
            )

        # Fallback to mock data
        return chat_with_data(
            org_id=str(body.org_id),
            store_id=str(body.store_id),
            message=body.message,
            conversation_id=body.conversation_id,
            language=body.language,
        )
    except ValueError as e:
        logger.warning("chat validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في الدردشة")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
