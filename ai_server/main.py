"""
Alhai POS AI Server - خادم الذكاء الاصطناعي لنقاط البيع

FastAPI backend serving 15 AI features for the Alhai POS app.
"""

import json
import logging
import time
import uuid

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware

from config import get_settings
from core.logging_config import (
    configure_logging,
    reset_request_context,
    set_request_context,
)
from rate_limit import limiter, RATE_HEALTH
from routers import (
    assistant,
    basket_analysis,
    chat_with_data,
    competitor,
    customer_recs,
    fraud_detection,
    product_recognition,
    promotion_designer,
    return_prediction,
    sales_forecast,
    sentiment,
    smart_inventory,
    smart_pricing,
    smart_reports,
    staff_analytics,
)

logger = logging.getLogger(__name__)

settings = get_settings()

configure_logging(settings.debug)

# limiter is imported from rate_limit module

app = FastAPI(
    title="Alhai POS AI Server",
    description="خادم الذكاء الاصطناعي لنظام نقاط البيع الحي - 15 خدمة ذكية",
    version="1.0.0",
    # Disable public OpenAPI docs in production to avoid information disclosure;
    # set DEBUG=true locally to re-enable.
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    openapi_url="/openapi.json" if settings.debug else None,
)

# Rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# HTTPS redirect in production (defence-in-depth behind the reverse proxy).
if not settings.debug:
    app.add_middleware(HTTPSRedirectMiddleware)

# Host header validation — reject requests that don't match an allowed host.
# In debug mode we accept everything so local curl / localhost still works.
if settings.trusted_hosts:
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.trusted_hosts)

# CORS - only allow configured origins (no wildcard)
# Note: with allow_credentials=True, allow_headers MUST be an explicit list
# (spec forbids "*" combined with credentials). Only POST/GET/OPTIONS are used.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Request-ID"],
)


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    request_id = getattr(request.state, "request_id", "unknown")
    logger.exception(
        "Unhandled exception request_id=%s method=%s path=%s",
        request_id,
        request.method,
        request.url.path,
    )
    return JSONResponse(
        status_code=500,
        content={
            "error": "خطأ داخلي في الخادم",  # Internal server error
            "detail": "حدث خطأ غير متوقع",
            "request_id": request_id,
        },
    )


# Request body size limit (10 MB)
MAX_BODY_SIZE = 10 * 1024 * 1024


@app.middleware("http")
async def limit_request_body_middleware(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > MAX_BODY_SIZE:
        return JSONResponse(
            status_code=413,
            content={"error": "حجم الطلب كبير جداً", "detail": "Request body too large"},
        )
    return await call_next(request)


# Request ID tracking middleware
@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    request.state.request_id = request_id
    # Peek at the body once, cache it so rate_limit can read store_id and so
    # downstream handlers still get a parseable body.
    body = b""
    if request.method in ("POST", "PUT", "PATCH"):
        try:
            body = await request.body()
        except Exception:
            body = b""
    request.state.cached_body = body
    if body:
        try:
            data = json.loads(body)
            if isinstance(data, dict):
                sid = data.get("store_id")
                if sid:
                    request.state.store_id = str(sid)
        except Exception:
            pass

    set_request_context(request_id=request_id)
    try:
        response = await call_next(request)
    finally:
        reset_request_context()
    response.headers["X-Request-ID"] = request_id
    return response


# Audit logging middleware
@app.middleware("http")
async def audit_log_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration_ms = (time.time() - start) * 1000
    request_id = getattr(request.state, "request_id", "unknown")
    client_ip = request.client.host if request.client else "unknown"
    store_id = getattr(request.state, "store_id", None)
    logger.info(
        "request handled",
        extra={
            "request_id": request_id,
            "ip": client_ip,
            "method": request.method,
            "endpoint": request.url.path,
            "status": response.status_code,
            "duration_ms": round(duration_ms, 1),
            "store_id": store_id,
        },
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
    # HSTS — force HTTPS for 1 year; only emit when not in debug mode to avoid
    # trapping local http://localhost testing into https.
    if not settings.debug:
        response.headers["Strict-Transport-Security"] = (
            "max-age=31536000; includeSubDomains"
        )
    # Lock down powerful browser features we never use.
    response.headers["Permissions-Policy"] = (
        "geolocation=(), microphone=(), camera=(), payment=()"
    )
    return response


# Health check
@app.get("/health", tags=["System"])
@limiter.limit(RATE_HEALTH)
async def health_check(request: Request):
    """فحص صحة الخادم - Health check endpoint"""
    from models.database import get_supabase_client

    supabase_ok = False
    try:
        client = get_supabase_client()
        if client is not None:
            # Simple connectivity check
            client.table("store_members").select("id").limit(1).execute()
            supabase_ok = True
    except Exception:
        logger.warning("Health check: Supabase connectivity failed")

    overall = "healthy" if supabase_ok else "degraded"
    return {
        "status": overall,
        "service": "alhai-ai-server",
        "version": "1.0.0",
        "dependencies": {
            "supabase": "connected" if supabase_ok else "unavailable",
        },
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
