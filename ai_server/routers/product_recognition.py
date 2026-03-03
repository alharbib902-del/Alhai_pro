"""التعرف على المنتجات - Product Recognition Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import RecognitionRequest, RecognitionResponse
from services.ml_service import recognize_product

router = APIRouter()


@router.post("/recognize", response_model=RecognitionResponse, summary="التعرف على المنتجات")
async def recognize(
    request: RecognitionRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    التعرف على المنتجات من صورة أو باركود أو وصف نصي.

    - **image_base64**: صورة بتنسيق Base64
    - **barcode**: رقم الباركود
    - **description**: وصف نصي
    """
    try:
        return recognize_product(
            org_id=request.org_id,
            store_id=request.store_id,
            barcode=request.barcode,
            description=request.description,
            language=request.language,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في التعرف على المنتج: {e}")
