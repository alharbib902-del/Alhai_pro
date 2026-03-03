"""المخزون الذكي - Smart Inventory Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import InventoryRequest, InventoryResponse
from services.ml_service import analyze_inventory

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
        return analyze_inventory(
            org_id=request.org_id,
            store_id=request.store_id,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في تحليل المخزون: {e}")
