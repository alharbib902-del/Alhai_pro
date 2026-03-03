"""التقارير الذكية - Smart Reports Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import ReportRequest, ReportResponse
from services.ml_service import generate_report

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
        return generate_report(
            org_id=request.org_id,
            store_id=request.store_id,
            report_type=request.report_type,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في إنشاء التقرير: {e}")
