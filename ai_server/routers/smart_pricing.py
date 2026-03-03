"""التسعير الذكي - Smart Pricing Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import PricingRequest, PricingResponse
from services.ml_service import generate_pricing

router = APIRouter()


@router.post("/pricing", response_model=PricingResponse, summary="التسعير الذكي")
async def smart_pricing(
    request: PricingRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    اقتراحات تسعير ذكية بناءً على الطلب والمنافسة.

    - **strategy**: optimal (الأمثل) / competitive (تنافسي) / margin (هامش ربح)
    """
    try:
        return generate_pricing(
            org_id=request.org_id,
            store_id=request.store_id,
            product_ids=request.product_ids,
            strategy=request.strategy,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في التسعير الذكي: {e}")
