"""التنبؤ بالمرتجعات - Return Prediction Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import ReturnRequest, ReturnResponse
from services.ml_service import predict_returns

logger = logging.getLogger(__name__)

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
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            days_ahead=request.days_ahead,
            language=request.language,
        )
    except ValueError as e:
        logger.warning("return_prediction validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خ��أ في التنبؤ بالمرت��عات")
        raise HTTPException(status_code=500, detail="ح��ث خطأ غير متوقع")
