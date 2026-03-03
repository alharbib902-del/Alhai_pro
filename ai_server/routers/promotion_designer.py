"""تصميم العروض - Promotion Designer Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import PromotionRequest, PromotionResponse
from services.ml_service import design_promotions

router = APIRouter()


@router.post("/promotions", response_model=PromotionResponse, summary="تصميم العروض")
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
            org_id=request.org_id,
            store_id=request.store_id,
            goal=request.goal,
            duration_days=request.duration_days,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تصميم العروض: {e}")
