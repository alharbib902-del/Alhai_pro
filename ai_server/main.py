"""
Alhai POS AI Server - خادم الذكاء الاصطناعي لنقاط البيع

FastAPI backend serving 15 AI features for the Alhai POS app.
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from config import get_settings

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

app = FastAPI(
    title="Alhai POS AI Server",
    description="خادم الذكاء الاصطناعي لنظام نقاط البيع الحي - 15 خدمة ذكية",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS - only allow configured origins (no wildcard)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
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
