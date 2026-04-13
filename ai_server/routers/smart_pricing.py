"""التسعير الذكي - Smart Pricing Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import PricingRequest, PricingResponse
from services.ml_service import generate_pricing

logger = logging.getLogger(__name__)

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
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            product_ids=request.product_ids,
            strategy=request.strategy,
            language=request.language,
        )
    except ValueError as e:
        logger.warning("smart_pricing validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في التسعير الذكي")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
