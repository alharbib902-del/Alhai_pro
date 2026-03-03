"""كشف الاحتيال - Fraud Detection Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import FraudRequest, FraudResponse
from services.ml_service import detect_fraud

router = APIRouter()


@router.post("/fraud", response_model=FraudResponse, summary="كشف الاحتيال")
async def detect_fraud_endpoint(
    request: FraudRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    كشف العمليات المشبوهة والاحتيال في المبيعات.

    - **sale_id**: تحليل عملية بيع محددة (اختياري)
    """
    try:
        return detect_fraud(
            org_id=request.org_id,
            store_id=request.store_id,
            sale_id=request.sale_id,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في كشف الاحتيال: {e}")
