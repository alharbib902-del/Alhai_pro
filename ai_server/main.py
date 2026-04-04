"""
Alhai POS AI Server - خادم الذكاء الاصطناعي لنقاط البيع

FastAPI backend serving 15 AI features for the Alhai POS app.
"""

import logging
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from config import get_settings

logger = logging.getLogger(__name__)

from routers import (
    sales_forecast,
    smart_pricing,
    fraud_detection,
    basket_analysis,
    customer_recs,
    smart_inventory,
    competitor,
    smart_reports,
    staff_analytics,
    product_recognition,
    sentiment,
    return_prediction,
    promotion_designer,
    chat_with_data,
    assistant,
)

settings = get_settings()

limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

app = FastAPI(
    title="Alhai POS AI Server",
    description="خادم الذكاء الاصطناعي لنظام نقاط البيع الحي - 15 خدمة ذكية",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS - only allow configured origins (no wildcard)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*", "Authorization"],
)


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "error": "خطأ داخلي في الخادم",  # Internal server error
            "detail": str(exc) if settings.debug else "حدث خطأ غير متوقع",
        },
    )


# Audit logging middleware
@app.middleware("http")
async def audit_log_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = (time.time() - start) * 1000
    logger.info(
        "method=%s path=%s status=%d duration=%.1fms",
        request.method,
        request.url.path,
        response.status_code,
        duration,
    )
    return response


# Security headers middleware
@app.middleware("http")
async def security_headers_middleware(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    return response


# Health check
@app.get("/health", tags=["System"])
async def health_check():
    """فحص صحة الخادم - Health check endpoint"""
    return {
        "status": "healthy",
        "service": "alhai-ai-server",
        "version": "1.0.0",
    }


# Register routers
app.include_router(sales_forecast.router, prefix="/ai", tags=["التنبؤ بالمبيعات"])
app.include_router(smart_pricing.router, prefix="/ai", tags=["التسعير الذكي"])
app.include_router(fraud_detection.router, prefix="/ai", tags=["كشف الاحتيال"])
app.include_router(basket_analysis.router, prefix="/ai", tags=["تحليل سلة المشتريات"])
app.include_router(customer_recs.router, prefix="/ai", tags=["توصيات العملاء"])
app.include_router(smart_inventory.router, prefix="/ai", tags=["المخزون الذكي"])
app.include_router(competitor.router, prefix="/ai", tags=["تحليل المنافسين"])
app.include_router(smart_reports.router, prefix="/ai", tags=["التقارير الذكية"])
app.include_router(staff_analytics.router, prefix="/ai", tags=["تحليل الموظفين"])
app.include_router(product_recognition.router, prefix="/ai", tags=["التعرف على المنتجات"])
app.include_router(sentiment.router, prefix="/ai", tags=["تحليل المشاعر"])
app.include_router(return_prediction.router, prefix="/ai", tags=["التنبؤ بالمرتجعات"])
app.include_router(promotion_designer.router, prefix="/ai", tags=["تصميم العروض"])
app.include_router(chat_with_data.router, prefix="/ai", tags=["الدردشة مع البيانات"])
app.include_router(assistant.router, prefix="/ai", tags=["المساعد الذكي"])


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=settings.host, port=settings.port, reload=settings.debug)
