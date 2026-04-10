"""التقارير الذكية - Smart Reports Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import ReportRequest, ReportResponse
from services.aggregations import InsufficientDataError, reports_from_sales
from services.ml_service import generate_report
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/reports", response_model=ReportResponse, summary="التقارير الذكية")
async def smart_reports(
    request: ReportRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تقارير ذكية مع تحليلات وتوصيات.

    - **report_type**: daily_summary / weekly / monthly / custom
    """
    try:
        try:
            sales = SupabaseService.get_sales(
                org_id=request.org_id, store_id=request.store_id
            )
            sale_items = SupabaseService.get_sale_items(
                org_id=request.org_id, store_id=request.store_id
            )
            if sales:
                result = reports_from_sales(
                    sales=sales,
                    sale_items=sale_items or None,
                    report_type=request.report_type,
                    language=request.language,
                )
                logger.info(
                    "smart_reports real data (org=%s store=%s sales=%d)",
                    request.org_id,
                    request.store_id,
                    len(sales),
                )
                return result
        except InsufficientDataError as e:
            logger.info("smart_reports insufficient data: %s", e)
        except Exception:
            logger.exception(
                "smart_reports real aggregation failed; falling back to mock"
            )

        result = generate_report(
            org_id=request.org_id,
            store_id=request.store_id,
            report_type=request.report_type,
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "smart_reports mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except Exception:
        logger.exception("خطأ في إنشاء التقرير")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
