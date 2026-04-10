# استلام مشروع: Alhai AI Server

## هويتك ودورك

أنت مهندس Python/FastAPI + ML مسؤول عن **AI Server** — خدمة FastAPI تُوفّر 15 endpoint للذكاء الاصطناعي للتطبيقات. هذا **ليس مشروع Dart/Flutter** — هو Python backend مستقل يُنشر كخدمة منفصلة (Render/Railway/Fly.io).

## الحقيقة الصادمة التي يجب أن تعرفها

**الخدمة الحالية ليست ذكية حقيقية**. كل الـ 15 endpoint تُرجع بيانات **deterministic mock** مُولَّدة بـ seed من `hash(org_id:store_id)`. هناك `SupabaseService` مُعدَّة لجلب بيانات حقيقية، وبعض الـ routers مربوطة الآن (5 من 15) لكن الـ ML logic نفسه لا يستخدم البيانات الحقيقية في التحليل.

**التحسين الذي تم مؤخراً**:
- أُضيفت حقول `is_mock_data` و `data_source` لكل response
- 5 routers تُحاول جلب بيانات حقيقية قبل الرجوع لـ mock
- SupabaseService تم إصلاح `get_products()` (كان يُفلتر بـ org_id فقط، الآن بـ store_id أيضاً)

**المهمة الحقيقية أمامك**: استبدال mock functions بـ ML/statistics فعلية تستخدم بيانات Supabase.

## القواعد الصارمة

1. **لا تُخفِ حقيقة أن البيانات mock** — `is_mock_data: true` إلزامي عند استخدام mock
2. **لا تستخدم `service_role_key` في client responses** — السيرفر فقط
3. **لا PII في logs** — Python `logger` يجب ألا يسجّل أرقام هواتف، emails، etc.
4. **لا tokens في responses** — حتى لو للتحليل
5. **JWT verification إلزامية** — كل endpoint يستخدم `Depends(verify_store_access)`
6. **Rate limiting إلزامي** — `slowapi` مُدمج، استخدمه
7. **لا OpenAI calls بدون fallback** — إذا OpenAI failed، ارجع 503 أو mock مع `data_source="mock"`

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **FastAPI + Pydantic + Supabase SDK** stack نظيف
- **15 endpoints** مُعرَّفة وتُرجع responses صحيحة الشكل
- **JWT auth** عبر `verify_store_access` dependency
- **Rate limiting** عبر `slowapi` (60/min per IP)
- **CORS** مُعدَّل صحيحاً
- **OpenAI integration** في chat/assistant endpoints (اختياري)
- **Logging** عبر Python `logging` module
- **Environment config** عبر `pydantic-settings` + `.env`
- **Dockerfile** موجود في `ai_server/Dockerfile`
- **Render deployment** مُعدَّل في `ai_server/render.yaml`
- **Mock indicators**: `is_mock_data` + `data_source` في كل response

### الـ 15 Endpoints وحالتها

| Endpoint | Router | Real Data? | Notes |
|----------|--------|-----------|-------|
| POST /forecast | sales_forecast.py | ⚠️ Partial (tries real, falls to mock) | Needs real time-series model |
| POST /pricing | smart_pricing.py | ❌ Mock only | Needs historical pricing |
| POST /fraud | fraud_detection.py | ❌ Mock only | Needs isolation forest on transactions |
| POST /basket | basket_analysis.py | ⚠️ Partial | Needs apriori or FP-growth |
| POST /recommendations | customer_recs.py | ❌ Mock only | Needs collaborative filtering |
| POST /inventory | smart_inventory.py | ⚠️ Partial (wired to get_products) | Aggregation logic missing |
| POST /competitors | competitor.py | ❌ Mock only | Needs external data source |
| POST /report | smart_reports.py | ⚠️ Partial | Aggregation missing |
| POST /staff | staff_analytics.py | ⚠️ Partial | Per-employee metrics missing |
| POST /recognize | product_recognition.py | ❌ Mock only | Needs vision API |
| POST /sentiment | sentiment.py | ❌ Mock only | Needs real reviews source |
| POST /returns | return_prediction.py | ❌ Mock only | Needs ML model |
| POST /promotions | promotion_designer.py | ❌ Mock only | Needs simulation logic |
| POST /chat | chat_with_data.py | ✅ OpenAI + mock fallback | Works if OPENAI_API_KEY set |
| POST /assistant | assistant.py | ✅ OpenAI + mock fallback | Works if OPENAI_API_KEY set |

### البلوكرز

#### 1. لا real ML في 10 endpoints
هذا **ليس bug** — هو scope غير مكتمل. المنتج يُعرض كـ "AI" لكنه scaffold.

**الأولوية الموصى بها**:
1. **sales_forecast** — استخدم `statsmodels` (ARIMA) على بيانات sales
2. **basket_analysis** — استخدم `mlxtend.apriori` على sale_items
3. **smart_inventory** — aggregation SQL فقط (ليس ML)
4. **smart_reports** — aggregation SQL فقط (ليس ML)
5. **staff_analytics** — aggregation SQL فقط
6. **fraud_detection** — `sklearn.ensemble.IsolationForest` على transactions

**endpoints لا تُركّز عليها الآن**: recognize, sentiment, promotions — تحتاج datasets خارجية.

#### 2. OpenAI dependency optional but untested fallback
إذا `OPENAI_API_KEY` فارغ، يجب أن يعود 503 أو mock. السلوك الحالي صحيح لكن يحتاج integration test.

#### 3. لا tests
`ai_server/` لا يحتوي على tests Python. يحتاج `pytest` suite.

#### 4. لا monitoring
لا Sentry Python SDK، لا APM.

## البنية

```
ai_server/
├── main.py                           # FastAPI app
├── config.py                         # pydantic-settings
├── models/
│   ├── schemas.py                    # ⚠️ has is_mock_data + data_source on all responses
│   └── database.py                   # get_supabase_client()
├── routers/
│   ├── sales_forecast.py             # ⚠️ partial real data
│   ├── smart_pricing.py              # mock only
│   ├── fraud_detection.py            # mock only
│   ├── basket_analysis.py            # ⚠️ partial
│   ├── customer_recs.py              # mock only
│   ├── smart_inventory.py            # ⚠️ partial
│   ├── competitor.py                 # mock only
│   ├── smart_reports.py              # ⚠️ partial
│   ├── staff_analytics.py            # ⚠️ partial
│   ├── product_recognition.py        # mock only
│   ├── sentiment.py                  # mock only
│   ├── return_prediction.py          # mock only
│   ├── promotion_designer.py         # mock only
│   ├── chat_with_data.py             # OpenAI + mock fallback
│   └── assistant.py                  # OpenAI + mock fallback
├── services/
│   ├── ml_service.py                 # ⚠️ 998 lines of MOCK generators
│   ├── supabase_service.py           # Real queries (recently fixed)
│   └── openai_service.py             # Optional OpenAI client
├── auth/
│   └── dependencies.py               # verify_store_access
├── requirements.txt                  # fastapi, supabase, openai, numpy, etc.
├── Dockerfile
├── render.yaml                       # Render deployment
└── .env.example
```

## التبعيات (requirements.txt)

```
fastapi==0.115.0
uvicorn[standard]==0.30.6
pydantic==2.9.2
pydantic-settings==2.5.2
supabase==2.9.1
python-dotenv==1.0.1
httpx==0.27.2
python-jose[cryptography]==3.3.0
python-multipart==0.0.12
slowapi==0.1.9
numpy==1.26.4
openai==1.58.1
pytest==8.3.3
pytest-asyncio==0.24.0
```

**ناقصة للـ real ML**:
- `statsmodels` — لـ ARIMA forecasting
- `scikit-learn` — لـ IsolationForest, clustering
- `mlxtend` — لـ basket analysis
- `pandas` — لـ data manipulation

## Environment Variables (`.env`)

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon>
SUPABASE_SERVICE_ROLE_KEY=<service_role>  # ⚠️ server-side only!
JWT_SECRET=<supabase jwt secret>
OPENAI_API_KEY=<optional>
HOST=0.0.0.0
PORT=8000
DEBUG=false
ALLOWED_ORIGINS=https://app.alhai.sa,https://admin.alhai.sa,...
```

## خطوات الاستلام

### 1. إعداد Environment
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\ai_server
python -m venv venv
source venv/Scripts/activate  # Windows Git Bash
pip install -r requirements.txt
cp .env.example .env
# املأ .env بقيم حقيقية (test project)
```

### 2. تشغيل الخدمة محلياً
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
افتح `http://localhost:8000/docs` لـ Swagger UI.

### 3. اختبار endpoint واحد
```bash
curl -X POST http://localhost:8000/forecast \
  -H "Authorization: Bearer <valid-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"org_id":"...","store_id":"...","days_ahead":7}'
```

تحقق من الـ response — يجب أن يحتوي `is_mock_data` و `data_source`.

### 4. فحص الكود الفعلي
```bash
# تحقق من أن mock indicators مُضافة
grep -r "is_mock_data" ai_server/models/schemas.py

# تحقق من أن routers تحاول real data
grep -l "SupabaseService" ai_server/routers/
```

### 5. فحص الأمان
```bash
# يجب ألا يظهر service_role في الـ routers
grep -r "service_role" ai_server/routers/

# يجب أن تستخدم الـ routers verify_store_access
grep -r "verify_store_access" ai_server/routers/ | wc -l
```
**توقّع**: 15+ (كل endpoint)

## معايير القبول

- [ ] الخدمة تبدأ بدون أخطاء (`uvicorn main:app`)
- [ ] Swagger UI يعرض 15 endpoints
- [ ] كل endpoint يُرجع `is_mock_data` + `data_source`
- [ ] JWT auth مُفعَّلة على كل endpoint
- [ ] Rate limiting يعمل
- [ ] CORS لا يسمح بـ origins خارج القائمة
- [ ] لا service_role في responses
- [ ] pytest suite موجود (حتى لو بسيط)
- [ ] Dockerfile يبني بنجاح

## خارطة الطريق للـ real ML (مقترح)

### Phase 1 — Real aggregations (أسبوع)
- smart_inventory: SQL aggregation على products + stock_deltas
- smart_reports: SQL aggregation على sales
- staff_analytics: SQL aggregation per employee
- **لا ML بعد** — فقط حقائق من DB

### Phase 2 — Statistical models (أسبوعين)
- sales_forecast: ARIMA/Prophet
- basket_analysis: apriori algorithm
- fraud_detection: IsolationForest

### Phase 3 — Advanced (شهر+)
- customer_recs: collaborative filtering
- return_prediction: supervised learning
- promotion_designer: multi-armed bandit

### Out of scope
- product_recognition (vision APIs)
- sentiment (needs review source)
- competitor (needs scraping/external data)

## ما هو خارج نطاقك

- ❌ تعديل Flutter apps (ذاك قسم آخر)
- ❌ Supabase schema (migrations قسم منفصل)
- ❌ OpenAI billing/quota management
- ❌ GPU infrastructure للـ deep learning

## البدء

```
استلام AI Server.
- uvicorn startup: [نجح/فشل]
- Swagger UI: 15 endpoints؟
- /forecast response: is_mock_data موجود؟
- grep service_role in routers: empty؟
- pytest: [موجود/مفقود]

الأولوية للـ ML الحقيقي؟ أي endpoint أولاً؟
```
