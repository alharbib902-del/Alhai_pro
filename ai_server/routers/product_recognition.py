"""التعرف على المنتجات - Product Recognition Router"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Request as FastAPIRequest

from auth import AuthenticatedUser, verify_store_access
from models.schemas import RecognitionRequest, RecognitionResponse
from rate_limit import RATE_HEAVY, limiter
from services.ml_service import recognize_product

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/recognize", response_model=RecognitionResponse, summary="التعرف على المنتجات")
@limiter.limit(RATE_HEAVY)
async def recognize(
    request: FastAPIRequest,
    body: RecognitionRequest,
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
            org_id=str(body.org_id),
            store_id=str(body.store_id),
            barcode=body.barcode,
            description=body.description,
            language=body.language,
        )
    except ValueError as e:
        logger.warning("product_recognition validation error: %s", e)
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        logger.exception("خطأ في التعرف على المنتج")
        raise HTTPException(status_code=500, detail="حدث خطأ غير متوقع")
