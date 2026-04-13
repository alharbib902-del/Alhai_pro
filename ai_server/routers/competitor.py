"""تحليل المنافسين - Competitor Analysis Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import CompetitorRequest, CompetitorResponse
from services.ml_service import analyze_competitors

logger = logging.getLogger(__name__)

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
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            language=request.language,
        )
    except ValueError as e:
        logger.warning("competitor validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تحليل المنافسين")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
