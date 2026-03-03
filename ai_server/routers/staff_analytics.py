"""تحليل الموظفين - Staff Analytics Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import StaffRequest, StaffResponse
from services.ml_service import analyze_staff

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
        return analyze_staff(
            org_id=request.org_id,
            store_id=request.store_id,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل الموظفين: {e}")
