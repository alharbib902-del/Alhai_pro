"""تحليل سلة المشتريات - Basket Analysis Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import BasketRequest, BasketResponse
from services.ml_service import analyze_basket

router = APIRouter()


@router.post("/basket", response_model=BasketResponse, summary="تحليل سلة المشتريات")
async def basket_analysis(
    request: BasketRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل أنماط الشراء واكتشاف المنتجات المرتبطة.

    - **min_support**: الحد الأدنى لنسبة الدعم
    - **top_n**: عدد القواعد المطلوبة
    """
    try:
        return analyze_basket(
            org_id=request.org_id,
            store_id=request.store_id,
            top_n=request.top_n,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل السلة: {e}")
