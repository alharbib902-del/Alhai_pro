# AI Server / خادم الذكاء الاصطناعي

Python FastAPI backend serving 15 AI features for the Alhai POS platform. Provides sales forecasting, smart pricing, fraud detection, basket analysis, customer recommendations, inventory optimization, competitor analysis, sentiment analysis, and more.

## Who Uses This / من يستخدمه

Called by the Admin Dashboard and Admin Lite apps (via the `alhai_ai` Flutter package) to power all AI-driven features. Not a user-facing application.

---

## Prerequisites / المتطلبات

| Tool | Version |
|------|---------|
| Python | >= 3.10 |
| pip | latest |
| Supabase account | Required for database access |
| OpenAI API Key | Required for GPT-powered features |

---

## Local Setup / الإعداد المحلي

```bash
# 1. Navigate to the ai_server directory
cd ai_server

# 2. Create and activate a virtual environment
python -m venv venv
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Copy environment file and fill in values
cp .env.example .env
# Edit .env with your credentials (see table below)

# 5. Run the server
uvicorn main:app --reload --port 8000

# 6. Open API docs in browser
#    Swagger UI:  http://localhost:8000/docs
#    ReDoc:       http://localhost:8000/redoc
```

---

## Environment Variables / متغيرات البيئة

Copy `.env.example` to `.env` and fill in:

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anonymous key |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Supabase service role key (server-side access) |
| `JWT_SECRET` | Yes | JWT signing secret (must match Supabase) |
| `OPENAI_API_KEY` | Yes | OpenAI API key for GPT-powered features |
| `HOST` | No | Server host (default: `0.0.0.0`) |
| `PORT` | No | Server port (default: `8000`) |
| `DEBUG` | No | Enable debug mode (default: `false`) |
| `ALLOWED_ORIGINS` | No | Comma-separated CORS origins |

---

## Project Structure / هيكل المشروع

```
ai_server/
  main.py             # FastAPI app entry point, middleware, router registration
  config.py           # Pydantic settings (loaded from .env)
  auth.py             # JWT authentication
  rate_limit.py       # SlowAPI rate limiting config
  requirements.txt    # Python dependencies
  .env.example        # Environment variable template
  models/
    database.py       # Supabase client setup
    schemas.py        # Pydantic request/response schemas
  services/
    aggregations.py   # Data aggregation pipelines
    ml_service.py     # scikit-learn / statsmodels ML logic
    openai_service.py # OpenAI GPT integration
    supabase_service.py # Supabase data access layer
  routers/            # One router per AI feature (15 total)
    sales_forecast.py
    smart_pricing.py
    fraud_detection.py
    basket_analysis.py
    customer_recs.py
    smart_inventory.py
    competitor.py
    smart_reports.py
    staff_analytics.py
    product_recognition.py
    sentiment.py
    return_prediction.py
    promotion_designer.py
    chat_with_data.py
    assistant.py
  tests/              # pytest test suite
    test_auth.py
    test_endpoints.py
    test_aggregations.py
  docs/               # Additional documentation
  i18n/               # Internationalization resources
  Dockerfile          # Container build
  railway.toml        # Railway deployment config
  render.yaml         # Render deployment config
```

---

## AI Features (15 Routers) / الخدمات الذكية

| Router | Arabic Tag | Description |
|--------|-----------|-------------|
| `sales_forecast` | التنبؤ بالمبيعات | Predict future sales using ML models |
| `smart_pricing` | التسعير الذكي | Dynamic pricing recommendations |
| `fraud_detection` | كشف الاحتيال | Detect suspicious transactions |
| `basket_analysis` | تحليل سلة المشتريات | Market basket / association rules |
| `customer_recs` | توصيات العملاء | Personalized product recommendations |
| `smart_inventory` | المخزون الذكي | Reorder point and stock optimization |
| `competitor` | تحليل المنافسين | Competitor pricing analysis |
| `smart_reports` | التقارير الذكية | AI-generated narrative reports |
| `staff_analytics` | تحليل الموظفين | Staff performance analysis |
| `product_recognition` | التعرف على المنتجات | Product image recognition |
| `sentiment` | تحليل المشاعر | Customer review sentiment analysis |
| `return_prediction` | التنبؤ بالمرتجعات | Predict product returns |
| `promotion_designer` | تصميم العروض | AI-designed promotions |
| `chat_with_data` | الدردشة مع البيانات | Natural language data queries |
| `assistant` | المساعد الذكي | General AI assistant |

---

## Key Libraries / المكتبات الرئيسية

| Library | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `uvicorn` | ASGI server |
| `pydantic` / `pydantic-settings` | Data validation, settings |
| `supabase` | Supabase Python client |
| `openai` | OpenAI GPT API client |
| `scikit-learn` | Machine learning models |
| `statsmodels` | Statistical models, time series |
| `pandas` / `numpy` | Data manipulation |
| `mlxtend` | Association rules (basket analysis) |
| `slowapi` | Rate limiting |
| `python-jose` | JWT handling |

---

## Running Tests / تشغيل الاختبارات

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run a specific test file
pytest tests/test_endpoints.py
```

---

## Deployment / النشر

Deployment configs are provided for Railway (`railway.toml`) and Render (`render.yaml`). A `Dockerfile` is also available for container-based deployments.

```bash
# Docker build
docker build -t alhai-ai-server .

# Docker run
docker run -p 8000:8000 --env-file .env alhai-ai-server
```

---

## API Documentation / توثيق الواجهة البرمجية

When the server is running, interactive API docs are available at:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

All AI endpoints are prefixed with `/ai/` and require JWT authentication.
