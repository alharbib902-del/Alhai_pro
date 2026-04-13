"""تحليل المشاعر - Sentiment Analysis Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import SentimentRequest, SentimentResponse
from services.ml_service import analyze_sentiment

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/sentiment", response_model=SentimentResponse, summary="تحليل المشاعر")
async def sentiment_analysis(
    request: SentimentRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل مشاعر العملاء من التقييمات والتعليقات.

    - **text**: نص لتحليله مباشرة (اختياري)
    - **source**: reviews / social / support
    """
    try:
        return analyze_sentiment(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            text=request.text,
            language=request.language,
        )
    except ValueError as e:
        logger.warning("sentiment validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تحليل ال��شاعر")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
