"""تحليل ا��موظفين - Staff Analytics Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import StaffRequest, StaffResponse
from services.aggregations import InsufficientDataError, staff_from_sales_employees
from services.ml_service import analyze_staff
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/staff", response_model=StaffResponse, summary="تحليل الموظفين")
async def staff_analytics(
    request: StaffRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل أداء الموظفين مع توصيات الورديات.

    - **employee_id**: موظف محدد (اختياري)
    """
    try:
        try:
            employees = SupabaseService.get_employees(
                org_id=str(request.org_id), store_id=str(request.store_id)
            )
            sales = SupabaseService.get_sales(
                org_id=str(request.org_id), store_id=str(request.store_id)
            )
            if employees:
                result = staff_from_sales_employees(
                    sales=sales or [],
                    employees=employees,
                    language=request.language,
                )
                logger.info(
                    "staff_analytics real data (org=%s store=%s employees=%d sales=%d)",
                    request.org_id,
                    request.store_id,
                    len(employees),
                    len(sales or []),
                )
                return result
        except InsufficientDataError as e:
            logger.info("staff_analytics insufficient data: %s", e)
        except ValueError as e:
            logger.warning("staff_analytics validation error: %s", e)
            raise HTTPException(status_code=422, detail=str(e))
        except Exception:
            logger.exception(
                "staff_analytics real aggregation failed; falling back to mock"
            )

        result = analyze_staff(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "staff_analytics mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تحليل الموظفين")
        raise HTTPException(status_code=500, detail="حدث خ��أ غير متوقع")
