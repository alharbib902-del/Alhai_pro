"""التنبؤ بالمرتجعات - Return Prediction Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

logger = logging.getLogger(__name__)
from auth import AuthenticatedUser, verify_store_access
from models.schemas import ReturnRequest, ReturnResponse
from services.ml_service import predict_returns

router = APIRouter()


@router.post("/returns", response_model=ReturnResponse, summary="التنبؤ بالمرتجعات")
async def predict_returns_endpoint(
    request: ReturnRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    التنبؤ بالمرتجعات المحتملة مع نصائح للوقاية.

    - **days_ahead**: فترة التنبؤ بالأيام
    """
    try:
        return predict_returns(
            org_id=request.org_id,
            store_id=request.store_id,
            days_ahead=request.days_ahead,
            language=request.language,
        )
    except Exception:
        logger.exception("خطأ في التنبؤ بالمرتجعات")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
