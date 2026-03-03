"""الدردشة مع البيانات - Chat with Data Router"""

from fastapi import APIRouter, Depends, HTTPException
from auth import AuthenticatedUser, verify_store_access
from models.schemas import ChatRequest, ChatResponse
from services.ml_service import chat_with_data

router = APIRouter()


@router.post("/chat", response_model=ChatResponse, summary="الدردشة مع البيانات")
async def chat(
    request: ChatRequest,
    user: AuthenticatedUser = Depends(verify_store_access),
):
    """
    دردشة ذكية مع بيانات المتجر - اسأل أي سؤال بالعربية أو الإنجليزية.

    - **message**: رسالة المستخدم
    - **conversation_id**: لاستمرار محادثة سابقة
    """
    try:
        return chat_with_data(
            org_id=request.org_id,
            store_id=request.store_id,
            message=request.message,
            conversation_id=request.conversation_id,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"خطأ في الدردشة: {e}")
