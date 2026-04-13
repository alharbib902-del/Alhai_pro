"""تصميم العروض - Promotion Designer Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import PromotionRequest, PromotionResponse
from services.ml_service import design_promotions

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/promotions", response_model=PromotionResponse, summary="تصميم العرو��")
async def design_promotions_endpoint(
    request: PromotionRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تصميم عروض ترويجية ذكية بناءً على الأهداف.

    - **goal**: increase_sales / clear_stock / attract_customers / increase_basket
    - **budget**: الميزانية المتاحة (اختياري)
    """
    try:
        return design_promotions(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            goal=request.goal,
            duration_days=request.duration_days,
            language=request.language,
        )
    except ValueError as e:
        logger.warning("promotion_designer validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تصميم العروض")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
