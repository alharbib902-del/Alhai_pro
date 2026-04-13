"""المخزون الذكي - Smart Inventory Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

from auth import AuthenticatedUser, verify_store_access
from models.schemas import InventoryRequest, InventoryResponse
from services.aggregations import InsufficientDataError, inventory_from_products
from services.ml_service import analyze_inventory
from services.supabase_service import SupabaseService

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/inventory", response_model=InventoryResponse, summary="المخزون الذكي")
async def smart_inventory(
    request: InventoryRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    تحليل ذكي للمخزون مع توصيات إعادة الطلب.

    - **include_reorder**: تضمين توصيات إعادة الطلب
    """
    try:
        try:
            products = SupabaseService.get_products(
                org_id=str(request.org_id), store_id=str(request.store_id)
            )
            if products:
                result = inventory_from_products(products, language=request.language)
                logger.info(
                    "smart_inventory real data (org=%s store=%s products=%d)",
                    request.org_id,
                    request.store_id,
                    len(products),
                )
                return result
        except InsufficientDataError as e:
            logger.info("smart_inventory insufficient data: %s", e)
        except ValueError as e:
            logger.warning("smart_inventory validation error: %s", e)
            raise HTTPException(status_code=422, detail=str(e))
        except Exception:
            logger.exception(
                "smart_inventory real aggregation failed; falling back to mock"
            )

        result = analyze_inventory(
            org_id=str(request.org_id),
            store_id=str(request.store_id),
            language=request.language,
        )
        result.is_mock_data = True
        result.data_source = "mock"
        logger.info(
            "smart_inventory mock data (org=%s store=%s)",
            request.org_id,
            request.store_id,
        )
        return result
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في تحليل المخزون")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
