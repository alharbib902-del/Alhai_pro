"""المساعد الذكي - Smart Assistant Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Request as FastAPIRequest

from auth import AuthenticatedUser, verify_store_access
from i18n.translations import t
from models.schemas import AssistantRequest, AssistantResponse, SuggestedAction
from rate_limit import RATE_CHAT, limiter
from services.ml_service import get_assistant_response
from services.openai_service import chat_completion

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/assistant", response_model=AssistantResponse, summary="المساعد الذكي")
@limiter.limit(RATE_CHAT)
async def smart_assistant(
    request: FastAPIRequest,
    body: AssistantRequest,
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
        ai_reply = chat_completion(
            body.query,
            context=body.context,
            language=body.language,
            org_id=str(body.org_id),
            store_id=str(body.store_id),
            endpoint_hint="assistant",
        )
        if ai_reply:
            return AssistantResponse(
                answer=ai_reply,
                confidence=0.90,
                data=None,
                actions=[
                    SuggestedAction(action="sales_summary", label=t("action_sales_summary", body.language), route="/ai/reports"),
                    SuggestedAction(action="inventory_check", label=t("action_inventory_check", body.language), route="/ai/inventory"),
                ],
                related_topics=[t("topic_sales", body.language), t("topic_inventory", body.language), t("topic_employees", body.language)],
            )

        # Fallback to mock data
        return get_assistant_response(
            org_id=str(body.org_id),
            store_id=str(body.store_id),
            query=body.query,
            context=body.context,
            language=body.language,
        )
    except ValueError as e:
        logger.warning("assistant validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في المساعد الذكي")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
