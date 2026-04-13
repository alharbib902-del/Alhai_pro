"""تحليل سلة المشتريات - Basket Analysis Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import BasketRequest, BasketResponse
from services.aggregations import InsufficientDataError, basket_from_items
from services.ml_service import analyze_basket
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/basket", response_model=BasketResponse, summary="تحليل سلة المشتريات")
async def basket_analysis(
    request: BasketRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل أنماط الشراء واكتشاف المنتجات المرتبطة.

    Uses mlxtend apriori on real sale_items when >=20 transactions are
    available; otherwise falls back to deterministic mock.

    - **min_support**: الحد الأدنى لنسبة الدعم
    - **top_n**: عدد القواعد المطلوبة
    """
    try:
        try:
            items = SupabaseService.get_sale_items(
                org_id=str(request.org_id), store_id=str(request.store_id)
            )
            if items:
                result = basket_from_items(
                    sale_items=items,
                    min_support=request.min_support,
                    min_confidence=request.min_confidence,
                    top_n=request.top_n,
                    language=request.language,
                )
                logger.info(
                    "basket_analysis real data (org=%s store=%s items=%d)",
                    request.org_id,
                    request.store_id,
                    len(items),
                )
                return result
        except InsufficientDataError as e:
            logger.info("basket_analysis insufficient data: %s", e)
        except ValueError as e:
            logger.warning("basket_analysis validation error: %s", e)
            raise HTTPException(status_code=422, detail=str(e))
        except Exception:
            logger.exception(
                "basket_analysis real aggregation failed; falling back to mock"
            )

        result = analyze_basket(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            top_n=request.top_n,
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "basket_analysis mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تحليل السلة")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
