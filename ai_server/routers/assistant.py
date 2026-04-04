"""المساعد الذكي - Smart Assistant Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

logger = logging.getLogger(__name__)
from auth import AuthenticatedUser, verify_store_access
from models.schemas import AssistantRequest, AssistantResponse, SuggestedAction
from services.ml_service import get_assistant_response
from services.openai_service import chat_completion
from i18n.translations import t

router = APIRouter()


@router.post("/assistant", response_model=AssistantResponse, summary="المساعد الذكي")
async def smart_assistant(
    request: AssistantRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    المساعد الذكي - يجيب على الأسئلة ويقترح إجراءات.
    يستخدم OpenAI إذا كان مفتاح API متاحاً، وإلا يعود للبيانات الافتراضية.

    - **query**: استفسار المستخدم
    - **context**: general / sales / inventory / finance / operations
    """
    try:
        # Try OpenAI first
        ai_reply = chat_completion(request.query, context=request.context, language=request.language)
        if ai_reply:
            return AssistantResponse(
                answer=ai_reply,
                confidence=0.90,
                data=None,
                actions=[
                    SuggestedAction(action="sales_summary", label=t("action_sales_summary", request.language), route="/ai/reports"),
                    SuggestedAction(action="inventory_check", label=t("action_inventory_check", request.language), route="/ai/inventory"),
                ],
                related_topics=[t("topic_sales", request.language), t("topic_inventory", request.language), t("topic_employees", request.language)],
            )

        # Fallback to mock data
        return get_assistant_response(
            org_id=request.org_id,
            store_id=request.store_id,
            query=request.query,
            context=request.context,
            language=request.language,
        )
    except Exception:
        logger.exception("خطأ في المساعد الذكي")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
