"""تحليل المشاعر - Sentiment Analysis Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import SentimentRequest, SentimentResponse
from services.ml_service import analyze_sentiment

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
            org_id=request.org_id,
            store_id=request.store_id,
            text=request.text,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل المشاعر: {e}")
