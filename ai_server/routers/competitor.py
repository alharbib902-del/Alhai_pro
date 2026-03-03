"""تحليل المنافسين - Competitor Analysis Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import CompetitorRequest, CompetitorResponse
from services.ml_service import analyze_competitors

router = APIRouter()


@router.post("/competitor", response_model=CompetitorResponse, summary="تحليل المنافسين")
async def competitor_analysis(
    request: CompetitorRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل المنافسين ومقارنة الأسعار.

    - **radius_km**: نطاق البحث بالكيلومتر
    """
    try:
        return analyze_competitors(
            org_id=request.org_id,
            store_id=request.store_id,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل المنافسين: {e}")
