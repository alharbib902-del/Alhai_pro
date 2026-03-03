"""المساعد الذكي - Smart Assistant Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import AssistantRequest, AssistantResponse
from services.ml_service import get_assistant_response

router = APIRouter()


@router.post("/assistant", response_model=AssistantResponse, summary="المساعد الذكي")
async def smart_assistant(
    request: AssistantRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    المساعد الذكي - يجيب على الأسئلة ويقترح إجراءات.

    - **query**: استفسار المستخدم
    - **context**: general / sales / inventory / finance / operations
    """
    try:
        return get_assistant_response(
            org_id=request.org_id,
            store_id=request.store_id,
            query=request.query,
            context=request.context,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في المساعد الذكي: {e}")
