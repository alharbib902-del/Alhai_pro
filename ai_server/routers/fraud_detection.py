"""كشف الاحتيال - Fraud Detection Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import FraudRequest, FraudResponse
from services.aggregations import InsufficientDataError, fraud_from_sales
from services.ml_service import detect_fraud
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/fraud", response_model=FraudResponse, summary="كشف الاحتيال")
async def detect_fraud_endpoint(
    request: FraudRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    كشف العمليات المشبوهة والاحتيال في المبيعات.

    Uses sklearn IsolationForest on real sales when >=50 transactions are
    available; otherwise falls back to deterministic mock.

    - **sale_id**: تحليل عملية بيع محددة (اختياري)
    """
    try:
        try:
            sales = SupabaseService.get_sales(
                org_id=str(request.org_id), store_id=str(request.store_id)
            )
            if sales:
                result = fraud_from_sales(sales=sales, language=request.language)
                logger.info(
                    "fraud_detection real data (org=%s store=%s sales=%d)",
                    request.org_id,
                    request.store_id,
                    len(sales),
                )
                return result
        except InsufficientDataError as e:
            logger.info("fraud_detection insufficient data: %s", e)
        except ValueError as e:
            logger.warning("fraud_detection validation error: %s", e)
            raise HTTPException(status_code=422, detail=str(e))
        except Exception:
            logger.exception(
                "fraud_detection real aggregation failed; falling back to mock"
            )

        result = detect_fraud(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            sale_id=request.sale_id,
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "fraud_detection mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في كشف الاحتيال")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
