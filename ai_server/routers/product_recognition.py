"""التعرف على المنتجات - Product Recognition Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException

logger = logging.getLogger(__name__)
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
    except Exception:
        logger.exception("خطأ في التعرف على المنتج")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
