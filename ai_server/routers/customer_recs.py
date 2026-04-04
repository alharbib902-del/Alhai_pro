"""توصيات العملاء - Customer Recommendations Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

logger = logging.getLogger(__name__)
from auth import AuthenticatedUser, verify_store_access
from models.schemas import RecommendationRequest, RecommendationResponse
from services.ml_service import generate_recommendations

router = APIRouter()


@router.post("/recommendations", response_model=RecommendationResponse, summary="توصيات العملاء")
async def get_recommendations(
    request: RecommendationRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    توصيات منتجات مخصصة لكل عميل.

    - **customer_id**: عميل محدد (اختياري)
    - **context**: general / upsell / cross_sell / retention
    """
    try:
        return generate_recommendations(
            org_id=request.org_id,
            store_id=request.store_id,
            customer_id=request.customer_id,
            top_n=request.top_n,
            language=request.language,
        )
    except Exception:
        logger.exception("خطأ في التوصيات")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
