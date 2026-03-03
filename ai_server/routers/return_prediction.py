"""التنبؤ بالمرتجعات - Return Prediction Router"""

from fastapi import APIRouter, Depends, HTTPException
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
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في التنبؤ بالمرتجعات: {e}")
