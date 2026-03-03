"""التنبؤ بالمبيعات - Sales Forecast Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import ForecastRequest, ForecastResponse
from services.ml_service import generate_forecast

router = APIRouter()


@router.post("/forecast", response_model=ForecastResponse, summary="التنبؤ بالمبيعات")
async def forecast_sales(
    request: ForecastRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    التنبؤ بالمبيعات المستقبلية بناءً على البيانات التاريخية.

    - **days_ahead**: عدد أيام التنبؤ (7/14/30/90)
    - **product_ids**: تحديد منتجات معينة (اختياري)
    """
    try:
        return generate_forecast(
            org_id=request.org_id,
            store_id=request.store_id,
            days_ahead=request.days_ahead,
            product_ids=request.product_ids,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في التنبؤ بالمبيعات: {e}")
