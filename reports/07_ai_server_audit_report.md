# تقرير مراجعة سيرفر الذكاء الاصطناعي - Alhai AI Server Audit Report

**التاريخ:** 28 فبراير 2026
**المراجع:** Lead Audit Agent
**المشروع:** `ai_server/` — خادم الذكاء الاصطناعي لمنصة الحي
**النوع:** مراجعة شاملة متعددة الوكلاء
**الحالة:** مكتمل

---

## الملخص التنفيذي

سيرفر الذكاء الاصطناعي (ai_server) هو خادم FastAPI بلغة Python يوفر **15 خدمة AI** لتطبيق نقاط البيع الحي. المشروع مبني بشكل جيد من الناحية الهيكلية، مع فصل واضح بين الطبقات (routers, services, models). ومع ذلك، يعتمد حالياً على **بيانات وهمية (dummy data)** بدلاً من نماذج تعلم آلي حقيقية، مما يعني أنه في مرحلة **النموذج الأولي (MVP/Prototype)**.

### إحصائيات المشروع

| المقياس | القيمة |
|---------|--------|
| إجمالي ملفات Python | 28 ملف |
| إجمالي الأسطر | 2,666 سطر |
| عدد الـ Endpoints | 15 endpoint + health check |
| عدد الاختبارات | 24 اختبار (في ملفين) |
| Framework | FastAPI 0.115.0 |
| Python | 3.11 (Docker) / 3.13 (محلي) |
| قاعدة البيانات | Supabase (PostgreSQL) |
| الـ Commit الوحيد | `feat: create FastAPI AI server with 15 ML endpoints` |

### التقييم الإجمالي

| المحور | التقييم | النسبة |
|--------|---------|--------|
| جودة الكود والهيكل | جيد جداً | 78% |
| الأمان | جيد | 72% |
| الأداء والتحسين | متوسط | 55% |
| تصميم الـ API والتوثيق | جيد جداً | 80% |
| **الإجمالي** | **جيد** | **71%** |

---

## 🏗️ الخطوة 1: هيكل المشروع

```
ai_server/
├── main.py                    (94 سطر)  ← نقطة الدخول
├── config.py                  (35 سطر)  ← إعدادات التطبيق
├── auth.py                    (213 سطر) ← المصادقة والتفويض
├── requirements.txt           (12 تبعية)
├── Dockerfile                 (متعدد المراحل)
├── .gitignore
├── models/
│   ├── __init__.py
│   ├── schemas.py             (512 سطر) ← نماذج Pydantic
│   └── database.py            (29 سطر)  ← اتصال Supabase
├── services/
│   ├── __init__.py
│   ├── ml_service.py          (691 سطر) ← منطق ML (بيانات وهمية)
│   └── supabase_service.py    (101 سطر) ← خدمة قراءة البيانات
├── routers/                   (15 router ≈ 27-31 سطر لكل واحد)
│   ├── sales_forecast.py
│   ├── smart_pricing.py
│   ├── fraud_detection.py
│   ├── basket_analysis.py
│   ├── customer_recs.py
│   ├── smart_inventory.py
│   ├── competitor.py
│   ├── smart_reports.py
│   ├── staff_analytics.py
│   ├── product_recognition.py
│   ├── sentiment.py
│   ├── return_prediction.py
│   ├── promotion_designer.py
│   ├── chat_with_data.py
│   └── assistant.py
└── tests/
    ├── __init__.py
    ├── test_endpoints.py      (332 سطر) ← اختبارات الـ endpoints
    └── test_auth.py           (226 سطر) ← اختبارات المصادقة
```

### خدمات الـ AI المتوفرة (15 خدمة)

| # | الخدمة | المسار | الوصف |
|---|--------|--------|-------|
| 1 | التنبؤ بالمبيعات | `POST /ai/forecast` | تنبؤ بالمبيعات 7-90 يوم |
| 2 | التسعير الذكي | `POST /ai/pricing` | اقتراحات تسعير ذكية |
| 3 | كشف الاحتيال | `POST /ai/fraud` | كشف العمليات المشبوهة |
| 4 | تحليل السلة | `POST /ai/basket` | تحليل أنماط الشراء |
| 5 | توصيات العملاء | `POST /ai/recommendations` | توصيات منتجات مخصصة |
| 6 | المخزون الذكي | `POST /ai/inventory` | تحليل وتحسين المخزون |
| 7 | تحليل المنافسين | `POST /ai/competitor` | مقارنة أسعار ومنافسة |
| 8 | التقارير الذكية | `POST /ai/reports` | تقارير تحليلية |
| 9 | تحليل الموظفين | `POST /ai/staff` | أداء الموظفين |
| 10 | التعرف على المنتجات | `POST /ai/recognize` | من صورة/باركود/نص |
| 11 | تحليل المشاعر | `POST /ai/sentiment` | تحليل تقييمات العملاء |
| 12 | التنبؤ بالمرتجعات | `POST /ai/returns` | توقع المرتجعات |
| 13 | تصميم العروض | `POST /ai/promotions` | تصميم عروض ذكية |
| 14 | الدردشة مع البيانات | `POST /ai/chat` | محادثة ذكية |
| 15 | المساعد الذكي | `POST /ai/assistant` | مساعد شامل |

---

## 🔧 Agent 7.1: جودة الكود والهيكل

### النقاط الإيجابية

1. **هيكل منظم وواضح:** فصل ممتاز بين الطبقات (routers, services, models) - كل طبقة لها مسؤولية واحدة
2. **Framework مناسب:** استخدام FastAPI وهو الأنسب لخوادم AI (دعم async، OpenAPI تلقائي، Pydantic validation)
3. **التسمية متسقة:** جميع الملفات والمتغيرات تتبع `snake_case` بشكل صحيح
4. **Type Hints مستخدمة:** جميع الدوال والنماذج تحتوي على type hints واضحة
5. **Pydantic Models شاملة:** 512 سطر من نماذج البيانات مع `Field` validation و descriptions ثنائية اللغة
6. **لا يوجد TODO/FIXME/HACK:** المشروع نظيف من الملاحظات المؤجلة
7. **لا يوجد `print()` statements:** يستخدم `logging` بشكل صحيح
8. **Configuration مركزي:** `pydantic-settings` مع `lru_cache` للـ singleton
9. **Docstrings ثنائية اللغة:** كل endpoint فيه وصف بالعربية والإنجليزية
10. **كل الـ Routers متسقة:** نمط موحد ≈ 28-31 سطر لكل router

### المشاكل المكتشفة

#### AI-CRT-001: خدمة ML تعتمد على بيانات وهمية كلياً (حرج)
- **الملف:** `services/ml_service.py`
- **السطر:** 1-692 (الملف بأكمله)
- **الوصف:** جميع الـ 15 خدمة AI تُرجع بيانات وهمية (dummy data) بدلاً من استخدام نماذج تعلم آلي حقيقية. الملف يعترف بذلك صراحة في السطر 3-4:
  ```python
  """Returns realistic dummy data based on input parameters.
  Uses deterministic seeding for consistent results per org/store."""
  ```
- **الأثر:** المنصة لا تقدم أي ذكاء اصطناعي حقيقي حالياً
- **التوصية:** وضع خطة تدريجية لاستبدال كل خدمة وهمية بنموذج ML حقيقي. البدء بالخدمات الأكثر قيمة (التنبؤ بالمبيعات، المخزون الذكي)

#### AI-CRT-002: SupabaseService غير مستخدمة فعلياً (حرج)
- **الملف:** `services/supabase_service.py`
- **الوصف:** خدمة `SupabaseService` تحتوي على 5 methods لقراءة البيانات (`get_sales`, `get_products`, `get_customers`, `get_employees`, `get_sale_items`) لكن **لا يوجد أي router أو service يستخدمها**. جميع الـ routers تستدعي `ml_service` مباشرة
- **الأثر:** كود ميت يأخذ حيزاً بدون فائدة
- **التوصية:** ربط `SupabaseService` بـ `ml_service` لتغذية نماذج ML بالبيانات الحقيقية عند الانتقال من البيانات الوهمية

#### AI-MED-001: ملف ml_service.py كبير جداً (متوسط)
- **الملف:** `services/ml_service.py` — **691 سطر**
- **الوصف:** ملف واحد يحتوي على 15 دالة لكل خدمات AI. مع نمو النماذج الحقيقية سيصبح غير قابل للإدارة
- **التوصية:** تقسيمه إلى ملفات منفصلة لكل خدمة: `services/forecast_service.py`, `services/pricing_service.py`, إلخ

#### AI-MED-002: ملف schemas.py كبير (متوسط)
- **الملف:** `models/schemas.py` — **512 سطر**
- **الوصف:** 45+ نموذج Pydantic في ملف واحد
- **التوصية:** تقسيمه إلى ملفات حسب الخدمة: `models/forecast_schemas.py`, `models/pricing_schemas.py`, إلخ

#### AI-MED-003: استخدام MD5 للـ seed (متوسط)
- **الملف:** `services/ml_service.py:47`
- **الوصف:** استخدام `hashlib.md5()` لتوليد seed. MD5 ضعيف أمنياً حتى لو كان الاستخدام هنا غير أمني
- **التوصية:** استبداله بـ `hashlib.sha256()` كممارسة أفضل

#### AI-LOW-001: `__init__.py` ملفات فارغة (منخفض)
- **الملفات:** `routers/__init__.py`, `models/__init__.py`, `services/__init__.py`, `tests/__init__.py`
- **الوصف:** جميع ملفات `__init__.py` فارغة تماماً
- **التوصية:** إضافة `__all__` exports أو docstrings وصفية

#### AI-LOW-002: `global _client` في database.py (منخفض)
- **الملف:** `models/database.py:9`
- **الوصف:** استخدام `global _client` pattern بدلاً من pattern أنظف مثل class-based singleton
- **التوصية:** استخدام `@lru_cache` أو dependency injection

#### AI-LOW-003: Error messages تكشف تفاصيل داخلية (منخفض)
- **الملفات:** جميع الـ routers
- **الوصف:** في الـ `except` blocks، يتم تمرير `str(e)` للعميل:
  ```python
  raise HTTPException(status_code=500, detail=f"خطأ في التنبؤ بالمبيعات: {e}")
  ```
  هذا قد يكشف مسارات ملفات أو تفاصيل داخلية
- **التوصية:** في بيئة الإنتاج، إرجاع رسالة عامة فقط وتسجيل التفاصيل في الـ logs

---

## 🔒 Agent 7.2: مراجعة الأمان

### النقاط الإيجابية

1. **JWT Authentication مطبق بشكل صحيح:**
   - استخدام `HTTPBearer` scheme
   - التحقق من `exp` (انتهاء الصلاحية)
   - التحقق من `sub` claim (معرّف المستخدم)
   - رفض التوكنات بدون JWT_SECRET مُعدّ
2. **Store Membership Authorization:** التحقق من عضوية المستخدم في المتجر عبر جدول `store_members`
3. **Fail-Closed Design:** عند عدم توفر Supabase client، يتم **رفض** الوصول (لا يُسمح افتراضياً)
4. **`.env` في `.gitignore`:** الأسرار لا تُخزن في Git
5. **لا توجد أسرار مكشوفة في الكود:** جميع المفاتيح تُقرأ من متغيرات البيئة
6. **CORS مقيد:** لا يستخدم wildcard `*` في الأصول المسموحة، بل قائمة محددة
7. **Pydantic Validation:** جميع المدخلات يتم التحقق منها عبر نماذج Pydantic
8. **Docker non-root user:** الحاوية تعمل بمستخدم غير root (`appuser`)
9. **اختبارات أمان شاملة:** 11 اختبار مصادقة يغطي جميع السيناريوهات
10. **ORM/Client queries:** استخدام Supabase client بدلاً من SQL خام يمنع SQL Injection

### المشاكل المكتشفة

#### AI-CRT-003: لا يوجد Rate Limiting (حرج)
- **الملف:** `main.py`
- **الوصف:** لا يوجد أي rate limiting على الـ endpoints. مهاجم يمكنه إرسال آلاف الطلبات بثوانٍ
- **الأثر:** هجمات DoS وإساءة استخدام API
- **التوصية:** إضافة `slowapi` أو `fastapi-limiter`:
  ```python
  # pip install slowapi
  from slowapi import Limiter
  limiter = Limiter(key_func=get_remote_address)
  @router.post("/forecast")
  @limiter.limit("30/minute")
  ```

#### AI-CRT-004: لا يوجد Prompt Injection Prevention (حرج)
- **الملفات:** `routers/chat_with_data.py`, `routers/assistant.py`, `routers/sentiment.py`
- **الوصف:** الـ endpoints التي تقبل نصوصاً حرة (`message`, `query`, `text`) لا تحتوي على أي تصفية ضد Prompt Injection. عندما يتم ربط نماذج LLM حقيقية، هذا سيكون ثغرة خطيرة
- **التوصية:** إضافة input sanitization layer قبل تمرير النص لنموذج AI

#### AI-MED-004: CORS `allow_methods=["*"]` و `allow_headers=["*"]` (متوسط)
- **الملف:** `main.py:45-46`
- **الوصف:** السماح بجميع الـ HTTP methods والـ headers. يجب تقييدها إلى ما هو مطلوب فقط
- **التوصية:**
  ```python
  allow_methods=["GET", "POST", "OPTIONS"],
  allow_headers=["Authorization", "Content-Type"],
  ```

#### AI-MED-005: Global Exception Handler يكشف تفاصيل في debug mode (متوسط)
- **الملف:** `main.py:57`
- **الوصف:** `str(exc) if settings.debug else ...` — في بيئة التطوير يكشف تفاصيل الخطأ كاملة
- **التوصية:** التأكد من أن `DEBUG=False` في بيئة الإنتاج. إضافة check إلزامي

#### AI-MED-006: لا يوجد audit logging للعمليات الحساسة (متوسط)
- **الوصف:** لا يتم تسجيل من أرسل أي طلب لأي endpoint. في بيئة POS هذا مهم للمساءلة
- **التوصية:** إضافة middleware لتسجيل: user_id, endpoint, timestamp, org_id, store_id

#### AI-MED-007: `verify_store_access` يتخطى الفحص عند غياب org_id/store_id (متوسط)
- **الملف:** `auth.py:196-199`
- **الوصف:**
  ```python
  if not org_id or not store_id:
      return user  # يتخطى فحص العضوية!
  ```
  إذا أرسل مهاجم طلباً بدون `org_id` أو `store_id`، يتم تجاوز فحص التفويض
- **التوصية:** رفض الطلب عند غياب هذه الحقول بدلاً من تخطي الفحص. Pydantic validation ستلتقطها لكن الترتيب غير مضمون

#### AI-LOW-004: dependencies قد تحتوي على ثغرات معروفة (منخفض)
- **الملف:** `requirements.txt`
- **الوصف:** `python-jose==3.3.0` — هذه المكتبة لم تُحدّث منذ فترة. يُفضل استخدام `PyJWT` الأكثر صيانة
- **التوصية:** تشغيل `pip audit` و `safety check` بشكل دوري. الانتقال إلى `PyJWT`

#### AI-LOW-005: لا يوجد `.env.example` (منخفض)
- **الوصف:** لا يوجد ملف مرجعي يوضح متغيرات البيئة المطلوبة
- **التوصية:** إنشاء `.env.example`:
  ```
  SUPABASE_URL=
  SUPABASE_ANON_KEY=
  SUPABASE_SERVICE_ROLE_KEY=
  JWT_SECRET=
  DEBUG=false
  ALLOWED_ORIGINS=http://localhost:3000
  ```

---

## ⚡ Agent 7.3: الأداء والتحسين

### النقاط الإيجابية

1. **البيانات الوهمية سريعة جداً:** حالياً جميع الاستجابات فورية (< 1ms) لأنها بيانات محسوبة
2. **Health Check endpoint موجود:** `GET /health` مع Docker HEALTHCHECK
3. **Deterministic seeding:** نتائج متسقة لنفس المتجر بدون عشوائية
4. **Docker multi-stage build:** يقلل حجم الصورة
5. **Uvicorn مع workers:** `--workers 2` في Docker CMD

### المشاكل المكتشفة

#### AI-CRT-005: لا يوجد Caching (حرج)
- **الوصف:** لا يوجد أي caching mechanism. نفس الطلب يُعالج من الصفر في كل مرة. عندما تُضاف نماذج ML حقيقية، هذا سيكون bottleneck كبير
- **التوصية:** إضافة Redis cache أو `cachetools` في الذاكرة:
  ```python
  from functools import lru_cache
  # أو Redis: from fastapi_cache import FastAPICache
  ```

#### AI-CRT-006: لا يوجد Background Tasks للعمليات الثقيلة (حرج)
- **الوصف:** جميع الـ endpoints تعمل synchronously. عند إضافة نماذج ML حقيقية (خاصة التعرف على الصور)، الاستجابة ستكون بطيئة جداً
- **التوصية:** استخدام `BackgroundTasks` أو Celery/RQ للعمليات الثقيلة. إضافة WebSocket أو polling endpoint لمتابعة التقدم

#### AI-MED-008: لا يوجد Connection Pooling مُعد (متوسط)
- **الملف:** `models/database.py`
- **الوصف:** Supabase client singleton لكن لا يوجد connection pool management. مع workers متعددة قد تنشأ مشاكل
- **التوصية:** استخدام `lifespan` event في FastAPI لإدارة connections

#### AI-MED-009: لا يوجد Graceful Shutdown (متوسط)
- **الملف:** `main.py`
- **الوصف:** لا يوجد `lifespan` handler لإغلاق الاتصالات بشكل سلس عند إيقاف السيرفر
- **التوصية:**
  ```python
  from contextlib import asynccontextmanager
  @asynccontextmanager
  async def lifespan(app: FastAPI):
      # startup
      yield
      # shutdown - cleanup connections
  app = FastAPI(lifespan=lifespan)
  ```

#### AI-MED-010: Supabase queries بدون pagination حقيقية (متوسط)
- **الملف:** `services/supabase_service.py`
- **الوصف:** `get_sales()` يجلب `.limit(1000)` و `get_sale_items()` يجلب `.limit(5000)` بدون pagination. للمتاجر الكبيرة هذا غير كافٍ وقد يسبب مشاكل ذاكرة
- **التوصية:** تطبيق cursor-based pagination أو date-based batching

#### AI-MED-011: لا يوجد Request Timeout (متوسط)
- **الوصف:** لا يوجد timeout على الطلبات. طلب يعلق في Supabase query سيحجز worker للأبد
- **التوصية:** إضافة timeout middleware أو استخدام `asyncio.wait_for()`

#### AI-LOW-006: `ml_service` يستخدم دوال synchronous (منخفض)
- **الملف:** `services/ml_service.py`
- **الوصف:** جميع دوال ML هي sync functions تُستدعى من async endpoints. حالياً لا مشكلة (بيانات وهمية) لكن مع نماذج حقيقية ستحتاج `run_in_executor()`
- **التوصية:** تحويل إلى async أو استخدام threadpool executor

---

## 🎨 Agent 7.4: تصميم الـ API والتوثيق

### النقاط الإيجابية

1. **RESTful conventions:** جميع الـ endpoints تتبع POST مع مسارات واضحة ومنطقية
2. **OpenAPI/Swagger docs كاملة:** متوفرة على `/docs` و `/redoc` تلقائياً
3. **Response models محددة:** كل endpoint يحدد `response_model` بشكل صريح
4. **Tags بالعربية:** كل router مُصنف بتاق عربي واضح في الـ docs
5. **Bilingual descriptions:** كل حقل في schemas.py يحتوي على وصف عربي + إنجليزي
6. **Field validation:** استخدام `ge`, `le`, `description`, `default_factory` بشكل شامل
7. **Consistent error format:** جميع الأخطاء تحتوي على `error` و `detail`
8. **Base request pattern:** جميع الطلبات ترث من `BaseRequest` مع `org_id` و `store_id`

### المشاكل المكتشفة

#### AI-MED-012: لا يوجد API Versioning (متوسط)
- **الوصف:** جميع الـ endpoints تحت `/ai/` بدون رقم إصدار. عند تغيير الـ API لاحقاً سيصعب الحفاظ على التوافق
- **التوصية:** استخدام `/api/v1/ai/` من البداية

#### AI-MED-013: جميع الـ endpoints تقبل POST فقط (متوسط)
- **الوصف:** حتى الخدمات التي تقرأ بيانات فقط (مثل `/ai/reports`, `/ai/staff`) تستخدم POST. الأصل أن القراءة تكون GET مع query parameters
- **التوصية:** إضافة GET endpoints للاستعلامات البسيطة مع الحفاظ على POST للطلبات المعقدة

#### AI-MED-014: لا يوجد Pagination في الاستجابات (متوسط)
- **الوصف:** جميع الاستجابات تُرجع كل النتائج دفعة واحدة. مثلاً `FraudResponse.alerts` قد تحتوي على عدد كبير من التنبيهات
- **التوصية:** إضافة `page`, `page_size`, `total` في الاستجابات

#### AI-LOW-007: Error responses غير متسقة (منخفض)
- **الوصف:** الـ global exception handler يُرجع `{"error": ..., "detail": ...}` لكن HTTPException يُرجع `{"detail": ...}` فقط. التنسيق غير موحد
- **التوصية:** إنشاء error middleware موحد:
  ```python
  class ErrorResponse(BaseModel):
      error_code: str
      message: str
      detail: str | None = None
  ```

#### AI-LOW-008: لا يوجد WebSocket endpoint (منخفض)
- **الوصف:** خدمة "الدردشة مع البيانات" (`/ai/chat`) تعمل عبر HTTP POST بدلاً من WebSocket. هذا يعني كل رسالة تتطلب طلب جديد
- **التوصية:** إضافة WebSocket endpoint للمحادثات لتجربة مستخدم أفضل

#### AI-LOW-009: لا يوجد Webhook callback mechanism (منخفض)
- **الوصف:** للعمليات الطويلة (مثل تدريب نموذج أو تحليل شامل)، لا يوجد آلية callback
- **التوصية:** إضافة webhook URL في الطلب لإشعار العميل عند اكتمال العملية

---

## 📋 ملخص المشاكل حسب الأولوية

### مشاكل حرجة (6)

| الرمز | الوصف | المحور |
|-------|-------|--------|
| AI-CRT-001 | خدمة ML تعتمد على بيانات وهمية كلياً | جودة الكود |
| AI-CRT-002 | SupabaseService غير مستخدمة فعلياً | جودة الكود |
| AI-CRT-003 | لا يوجد Rate Limiting | الأمان |
| AI-CRT-004 | لا يوجد Prompt Injection Prevention | الأمان |
| AI-CRT-005 | لا يوجد Caching | الأداء |
| AI-CRT-006 | لا يوجد Background Tasks | الأداء |

### مشاكل متوسطة (14)

| الرمز | الوصف | المحور |
|-------|-------|--------|
| AI-MED-001 | ملف ml_service.py كبير (691 سطر) | جودة الكود |
| AI-MED-002 | ملف schemas.py كبير (512 سطر) | جودة الكود |
| AI-MED-003 | استخدام MD5 للـ seed | جودة الكود |
| AI-MED-004 | CORS methods/headers بلا تقييد | الأمان |
| AI-MED-005 | Exception handler يكشف تفاصيل في debug | الأمان |
| AI-MED-006 | لا يوجد audit logging | الأمان |
| AI-MED-007 | تخطي فحص التفويض عند غياب IDs | الأمان |
| AI-MED-008 | لا يوجد Connection Pooling | الأداء |
| AI-MED-009 | لا يوجد Graceful Shutdown | الأداء |
| AI-MED-010 | Supabase queries بدون pagination | الأداء |
| AI-MED-011 | لا يوجد Request Timeout | الأداء |
| AI-MED-012 | لا يوجد API Versioning | تصميم API |
| AI-MED-013 | POST فقط حتى لعمليات القراءة | تصميم API |
| AI-MED-014 | لا يوجد Pagination في الاستجابات | تصميم API |

### مشاكل منخفضة (9)

| الرمز | الوصف | المحور |
|-------|-------|--------|
| AI-LOW-001 | ملفات `__init__.py` فارغة | جودة الكود |
| AI-LOW-002 | `global _client` pattern | جودة الكود |
| AI-LOW-003 | Error messages تكشف تفاصيل | جودة الكود |
| AI-LOW-004 | python-jose قديمة | الأمان |
| AI-LOW-005 | لا يوجد `.env.example` | الأمان |
| AI-LOW-006 | دوال ML synchronous | الأداء |
| AI-LOW-007 | Error responses غير متسقة | تصميم API |
| AI-LOW-008 | لا يوجد WebSocket للدردشة | تصميم API |
| AI-LOW-009 | لا يوجد Webhook mechanism | تصميم API |

---

## ✅ نقاط القوة الرئيسية

1. **هيكل نظيف ومنظم** — فصل واضح بين الطبقات يسهل التطوير المستقبلي
2. **أمان أساسي متين** — JWT + store membership + fail-closed design
3. **اختبارات شاملة** — 24 اختبار يغطي جميع الـ endpoints + اختبارات أمان مخصصة
4. **Pydantic validation قوي** — جميع المدخلات والمخرجات محددة بدقة
5. **Docker production-ready** — multi-stage, non-root, healthcheck
6. **توثيق تلقائي ثنائي اللغة** — OpenAPI/Swagger بالعربية والإنجليزية
7. **نمط متسق** — جميع الـ 15 router تتبع نفس البنية تماماً
8. **Deterministic testing** — نتائج متسقة تسهل الاختبار

---

## 🗺️ خارطة الطريق المقترحة

### المرحلة 1: تأمين أساسي (أسبوع 1-2)
- [ ] إضافة Rate Limiting (`slowapi`)
- [ ] تقييد CORS methods و headers
- [ ] إصلاح تخطي فحص التفويض (AI-MED-007)
- [ ] إضافة `.env.example`
- [ ] إضافة audit logging middleware
- [ ] استبدال `python-jose` بـ `PyJWT`

### المرحلة 2: تحسينات أداء (أسبوع 3-4)
- [ ] إضافة API versioning (`/api/v1/`)
- [ ] إضافة Redis cache
- [ ] إضافة `lifespan` handler (graceful shutdown)
- [ ] إضافة request timeout middleware
- [ ] إضافة pagination في الاستجابات
- [ ] توحيد error response format

### المرحلة 3: ربط البيانات الحقيقية (أسبوع 5-8)
- [ ] ربط `SupabaseService` بالـ endpoints
- [ ] تقسيم `ml_service.py` إلى خدمات منفصلة
- [ ] تقسيم `schemas.py` إلى ملفات منفصلة
- [ ] إضافة data pipeline لتغذية نماذج ML
- [ ] إضافة input sanitization للنصوص

### المرحلة 4: نماذج ML حقيقية (أسبوع 9-16)
- [ ] التنبؤ بالمبيعات — Prophet/ARIMA
- [ ] تحليل المشاعر — Arabic NLP model
- [ ] تحليل سلة المشتريات — Apriori/FP-Growth
- [ ] التعرف على المنتجات — Computer Vision model
- [ ] الدردشة مع البيانات — LLM integration
- [ ] إضافة background task processing (Celery)
- [ ] إضافة WebSocket للدردشة
- [ ] إضافة model monitoring و A/B testing

---

## الخلاصة

سيرفر الذكاء الاصطناعي لمنصة الحي **مبني على أساس هيكلي ممتاز** مع معايير أمان جيدة واختبارات شاملة. التحدي الرئيسي هو الانتقال من **البيانات الوهمية إلى نماذج AI حقيقية**، وهو ما يتطلب:

1. **ربط مصادر البيانات** (SupabaseService ← ML models)
2. **إضافة infrastructure** (Redis, Celery, monitoring)
3. **تدريب نماذج ML** لكل خدمة من الـ 15 خدمة

المشروع في حالة **نموذج أولي ناضج** — الـ API contract جاهز وواضح، والهيكل يسمح بالتوسع. الأولوية القصوى هي معالجة المشاكل الأمنية (Rate Limiting, Prompt Injection) قبل أي deployment إنتاجي.

---

> **تم إنشاء هذا التقرير في:** 28 فبراير 2026
> **بواسطة:** Lead Audit Agent — مراجعة شاملة متعددة الوكلاء
> **إجمالي الملفات المراجعة:** 28 ملف Python + Dockerfile + requirements.txt + .gitignore
> **إجمالي المشاكل:** 6 حرجة + 14 متوسطة + 9 منخفضة = **29 مشكلة**
