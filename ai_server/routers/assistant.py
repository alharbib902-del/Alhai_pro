"""المساعد الذكي - Smart Assistant Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import AssistantRequest, AssistantResponse, SuggestedAction
from services.ml_service import get_assistant_response
from services.openai_service import chat_completion

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
        ai_reply = chat_completion(request.query, context=request.context)
        if ai_reply:
            return AssistantResponse(
                answer=ai_reply,
                confidence=0.90,
                data=None,
                actions=[
                    SuggestedAction(action="sales_summary", label="ملخص المبيعات", route="/ai/reports"),
                    SuggestedAction(action="inventory_check", label="فحص المخزون", route="/ai/inventory"),
                ],
                related_topics=["المبيعات", "المخزون", "الموظفين"],
            )

        # Fallback to mock data
        return get_assistant_response(
            org_id=request.org_id,
            store_id=request.store_id,
            query=request.query,
            context=request.context,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في المساعد الذكي: {e}")
