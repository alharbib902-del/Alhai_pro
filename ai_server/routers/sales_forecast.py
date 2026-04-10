"""التنبؤ بالمبيعات - Sales Forecast Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import ForecastRequest, ForecastResponse
from services.aggregations import InsufficientDataError, forecast_from_sales
from services.ml_service import generate_forecast
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/forecast", response_model=ForecastResponse, summary="التنبؤ بالمبيعات")
async def forecast_sales(
    request: ForecastRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    التنبؤ بالمبيعات المستقبلية بناءً على البيانات التاريخية.

    Uses ARIMA when >=14 days of data are available, moving-average otherwise,
    and falls back to deterministic mock only when <7 days exist.

    - **days_ahead**: عدد أيام التنبؤ (7/14/30/90)
    - **product_ids**: تحديد منتجات معينة (اختياري)
    """
    try:
        try:
            sales = SupabaseService.get_sales(
                org_id=request.org_id, store_id=request.store_id
            )
            if sales:
                result = forecast_from_sales(
                    sales=sales,
                    days_ahead=request.days_ahead,
                    language=request.language,
                )
                logger.info(
                    "sales_forecast real data (org=%s store=%s sales=%d)",
                    request.org_id,
                    request.store_id,
                    len(sales),
                )
                return result
        except InsufficientDataError as e:
            logger.info("sales_forecast insufficient data: %s", e)
        except Exception:
            logger.exception(
                "sales_forecast real aggregation failed; falling back to mock"
            )

        result = generate_forecast(
            org_id=request.org_id,
            store_id=request.store_id,
            days_ahead=request.days_ahead,
            product_ids=request.product_ids,
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "sales_forecast mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except Exception:
        logger.exception("خطأ في التنبؤ بالمبيعات")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
