# تقرير التدقيق الشامل - Prompts احترافية لجميع التطبيقات الـ 11
**التاريخ:** 2026-04-13
**المشروع:** Alhai POS Monorepo

---

## الفهرس

| # | التطبيق | المشاكل P0 | المشاكل P1 | المشاكل P2 | المشاكل P3 |
|---|---------|-----------|-----------|-----------|-----------|
| 1 | [Admin](#1-admin) | 4 | 5 | 6 | 10 |
| 2 | [Admin Lite](#2-admin-lite) | 3 | 5 | 6 | 5 |
| 3 | [Cashier](#3-cashier) | 6 | 6 | 8 | 5 |
| 4 | [AI Server](#4-ai-server) | 7 | 8 | 3 | 5 |
| 5 | [Customer App](#5-customer-app) | 5 | 5 | 7 | 5 |
| 6 | [Distributor Portal](#6-distributor-portal) | 4 | 6 | 6 | 3 |
| 7 | [Driver App](#7-driver-app) | 6 | 8 | 6 | 6 |
| 8 | [POS App](#8-pos-app) | 7 | 6 | 3 | 3 |
| 9 | [Super Admin](#9-super-admin) | 5 | 5 | 5 | 5 |
| 10 | [Admin POS](#10-admin-pos) | 4 | 4 | 8 | 9 |
| 11 | [Admin POS Lite](#11-admin-pos-lite) | 4 | 8 | 8 | 6 |

---

# 1. Admin

## Prompt احترافي لتطبيق Admin

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل المكتشفة في تطبيق Admin الموجود في `apps/admin/`. التطبيق هو لوحة التحكم الإدارية الرئيسية (62 شاشة، 1928+ سطر اختبار).

### P0 - حرج (أصلح فوراً)

1. **تخزين مفتاح تشفير قاعدة البيانات بشكل غير آمن على الويب**
   - الملف: `lib/main.dart` الأسطر 135-178
   - المفتاح يُخزّن في SharedPreferences (localStorage) على الويب
   - الحل: استخدم WebCrypto API مع مفاتيح غير قابلة للاستخراج، أو اشتق المفتاح من رمز جلسة المستخدم

2. **معالجة الأخطاء الصامتة في Supabase و Firebase**
   - الملف: `lib/main.dart` الأسطر 64-95
   - استثناءات تُقبض لكن لا تُعيد محاولة أو تُعطل التطبيق
   - الحل: أظهر شاشة خطأ واضحة إذا فشل Supabase، أضف exponential backoff

3. **عدم التحقق من بيانات اعتماد API في شاشات الإعدادات**
   - الملفات: `lib/screens/settings/integrations/whatsapp_management_screen.dart` و `shipping_gateways_screen.dart`
   - حقول API keys بدون تحقق أو masking
   - الحل: أضف ObscureText، احفظ في FlutterSecureStorage فقط

4. **سياسة تخزين آمن غير متسقة عبر المنصات**
   - الملف: `lib/main.dart` الأسطر 135-178
   - الويب يستخدم SharedPreferences، الأجهزة تستخدم FlutterSecureStorage
   - الحل: أنشئ واجهة SecureStorageProvider موحدة

### P1 - عالي

5. **معالجة الأخطاء الناقصة في Providers** — `lib/providers/marketing_providers.dart`, `purchases_providers.dart`, `settings_db_providers.dart`
6. **معالجة الأخطاء الصامتة في عشرات الشاشات** — جميع catch blocks بدون UI feedback
7. **اختبارات الوحدة ناقصة** — 72 ملف اختبار لكن التغطية منخفضة
8. **توثيق API ناقص** — README 17 سطر فقط
9. **عدم فحص الصلاحيات قبل قراءة البيانات الحساسة**

### P2 - متوسط

10. حماية API Keys في الإعدادات (عرض آخر 4 أحرف فقط)
11. عدم وجود Retry Logic مع backoff
12. الصلاحيات hardcoded بدلاً من قاعدة البيانات — `lib/core/constants/admin_permissions.dart`
13. اختبارات offline ناقصة
14. عدم التحقق من المدخلات الرقمية في شاشات الإعدادات
15. وثائق الكود ناقصة

### P3 - منخفض

16-25: معالجة حالات حدية، Accessibility ضعيفة (58 Semantics فقط)، عدم معالجة timeout الشبكة، Sentry DSN غير مشروط، عدم وجود قفل متشائم، سجل نشاط ناقص، عدم استخدام const constructors، ترجمات ناقصة، اختبارات أداء، توثيق الاختلافات بين التطبيقات.

---

# 2. Admin Lite

## Prompt احترافي لتطبيق Admin Lite

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في تطبيق Admin Lite الموجود في `apps/admin_lite/`. التطبيق نسخة مبسطة من لوحة التحكم (39 ملف، 13,132 سطر، 12 ملف اختبار).

### P0 - حرج

1. **معالجة الأخطاء الصامتة** — `lib/di/injection.dart:49`, `lib/router/lite_router.dart:83`, `lib/screens/management/lite_quick_price_screen.dart:389` — جميعها `catch (_) {}` بدون تسجيل
2. **التنقل المشروط غير الآمن** — `lib/screens/settings/lite_settings_screen.dart:268,278` — أزرار Terms/Privacy بـ TODO بدون تنفيذ
3. **نقص توثيق التوافقية** — `pubspec.yaml` حزم محلية بمسارات نسبية بدون إصدارات

### P1 - عالي

4. تكرار Router Guard Logic في 3 تطبيقات — `lib/router/lite_router.dart:63-67`
5. شاشات كبيرة تحتاج تقسيم — Dashboard (912 سطر)، Router (911 سطر)، Settings (725 سطر)
6. معالجة ناقصة للبيانات الفارغة
7. نقص اختبارات التكامل
8. Accessibility ناقصة — BottomNavigationBar labels غير مترجمة

### P2 - متوسط

9. عدم استخدام const constructors — `analysis_options.yaml` معطل
10. تخزين مفاتيح غير آمن على الويب — `lib/main.dart:131-142`
11. نقص معالجة حالات الشبكة (timeout, intermittent)
12. تغطية اختبارات ~17% فقط
13. عدم التعامل مع Edge Cases
14. Hard-coded strings في navigation

### P3 - منخفض

15-19: توثيق الكود، Constants للقيم المكررة، Lazy Loading، تخزين مؤقت أفضل، رسائل نجاح/فشل واضحة.

---

# 3. Cashier

## Prompt احترافي لتطبيق Cashier

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في تطبيق Cashier الموجود في `apps/cashier/`. هذا تطبيق نقطة البيع الرقمية (41,868 سطر، 47 شاشة، 67 اختبار).

### P0 - حرج (أصلح اليوم)

1. **تسرب بيانات اعتماد حساسة** — `.dart_define.env` يحتوي على مفاتيح Supabase، Wasender API token، Webhook secret حقيقية. أزل الملف فوراً، جدد المفاتيح، أضفه لـ .gitignore
2. **مفتاح Supabase مكشوف في كود الإنتاج**
3. **عدم تشفير قاعدة البيانات على الويب** — `lib/main.dart:204-209` مفتاح في localStorage
4. **CSP ضعيفة جداً** — `web/index.html:24` تسمح بـ unsafe-inline و unsafe-eval
5. **عدم وجود Certificate Pinning**
6. **عدم وجود حماية CSRF على Web**

### P1 - عالي

7. معالجة أخطاء صامتة في 47 شاشة — 124 كتلة catch بدون feedback
8. Async Operations بدون proper error handling — `lib/core/services/connectivity_service.dart:137-150`
9. Force unwrap بدون فحص — `ref.read(currentStoreIdProvider)!`
10. تغطية اختبار 0.16% — 67 اختبار لـ 41,868 سطر
11. لا اختبارات تكامل offline-first
12. 78 debugPrint تسرب الأداء

### P2 - متوسط

13-20: عدم التحقق من توقيع ZATCA QR، عدم تشفير Offline Queue، توثيق ناقص، ثنائية نظام الطابور، Router Guard مكرر، عدم وجود CHANGELOG، key.properties غير محمي، عملية إصدار غير واضحة.

### P3 - منخفض

21-30: رسائل خطأ تقنية بدلاً من عربية، Session Timeout logging، Accessibility labels، Magic Numbers، Activity logging.

---

# 4. AI Server

## Prompt احترافي لخادم AI Server

أنت مطور Python محترف. مهمتك إصلاح جميع المشاكل في AI Server الموجود في `ai_server/`. خدمة FastAPI مع 15 ميزة ذكية.

### P0 - حرج

1. **تسريب معلومات الخطأ** — `main.py:66-74` يرسل `str(exc)` للعميل حتى مع `debug=False`
2. **عدم التحقق من UUIDs** — `models/schemas.py:15-19` org_id و store_id كـ strings بدون validation
3. **استثناءات Supabase صامتة** — `services/supabase_service.py:29,47,66,84,102` جميعها `except Exception: return []`
4. **JWT audience verification معطلة** — `auth.py:71-76` `verify_aud: False`
5. **Rate limiting موحد** — `main.py:41` — 60/min لجميع endpoints
6. **base64 images بدون حد حجم** — `models/schemas.py:359` — DoS ممكن
7. **استثناءات صامتة في جميع الرواتر** — 15 router بنفس النمط

### P1 - عالي

8. 8 من 15 endpoint بدون اختبارات
9. عدم التحقق من قيود المدخلات — `days_ahead`, `min_support`, `message` بدون حدود
10. MD5 للـ seeding — `services/ml_service.py:48-51`
11. لا caching للـ membership checks — `auth.py:100-139`
12. لا pagination في Supabase queries
13. RequestID tracking مفقود
14. CORS hardcoded — `config.py:27`
15. عدم وجود request body size limit

### P2 - متوسط

16. تكرار الكود في 15 router — أنشئ decorator `@with_fallback_to_mock`
17. Health Check لا يتحقق من dependencies
18. Import statements غير منسقة

### P3 - منخفض

19-22: Metrics/monitoring مفقودة، Environment variable validation، Dependencies version pinning، README مفقود.

---

# 5. Customer App

## Prompt احترافي لتطبيق Customer App

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في تطبيق العميل الموجود في `customer_app/`. التطبيق الموجه للعملاء (69 ملف Dart، 10 ملفات اختبار).

### P0 - حرج

1. **معالجة أخطاء صامتة** — `lib/features/addresses/data/addresses_datasource.dart:37-39`, `catalog_screen.dart:85-89`, `orders_datasource.dart:72-83`, `splash_screen.dart:41-44`
2. **Force unwrap بدون فحص null** — `addresses_datasource.dart:11`, `orders_datasource.dart:36,117`, `checkout_provider.dart:54`
3. **عدم التعامل مع TimeoutException بشكل متسق** — أنشئ `NetworkException` مخصصة
4. **افتقاد التحقق من Type Casting** — `orders_datasource.dart:23-25`, `products_datasource.dart:50-51`
5. **عدم وجود Certificate Pinning** — `lib/core/supabase/supabase_client.dart:44-46`

### P1 - عالي

6. تغطية اختبارات ~14% — 10 ملفات لـ 69 ملف
7. StateNotifier مع SharedPreferences بدون Thread Safety — `cart_provider.dart:28-49`
8. عدم استخدام RPC بدلاً من استعلامات متعددة — `addresses_datasource.dart:82-94`
9. غياب Pagination — `addresses_datasource.dart:13-23`, `categories_datasource.dart:12-27`
10. إعادة بناء UI غير ضرورية — `catalog_screen.dart:128-143` بدون `.select()`

### P2 - متوسط

11-17: Cache invalidation ناقصة، `mounted` بدون معيار، Input Validation مركزية، `http: any` بدون version، Global Error Handler، Logging مركزي، API Documentation.

### P3 - منخفض

18-22: Accessibility Labels، RTL Testing، معالجة Offline غير موحدة، Inconsistent Error Messages، Proguard Rules.

---

# 6. Distributor Portal

## Prompt احترافي لبوابة الموزعين

أنت مطور Flutter Web محترف. مهمتك إصلاح جميع المشاكل في Distributor Portal الموجود في `distributor_portal/`. بوابة B2B للموزعين.

### P0 - حرج

1. **تخزين رموز المصادقة في LocalStorage** — `lib/core/supabase/supabase_client.dart` — عرضة لـ XSS
2. **عدم تسجيل الأخطاء الحرجة** — `lib/providers/distributor_session_timeout.dart:83-98` — logout بدون logging
3. **عدم التحقق من RPC responses** — `lib/data/distributor_datasource.dart` — بدون schema validation
4. **تسرب معلومات حساسة في رسائل الخطأ**

### P1 - عالي

5. معالجة أخطاء صامتة في Datasource — `getDashboardKpis():668-679`, `getReportData():810-826`
6. SharedPreferences بدون error handling — `lib/providers/distributor_settings_providers.dart:28-49`
7. Supabase init failure بدون UI fallback — `lib/main.dart:50-55`
8. اختبارات Screen فارغة — 5 ملفات بـ 0 اختبارات
9. حجم Cache بدون حد — `distributor_datasource.dart:154-174`
10. استعلامات N+1 محتملة — `distributor_datasource.dart:770-773`

### P2 - متوسط

11. CSP ضعيفة — `web/index.html:25` — unsafe-inline و unsafe-eval
12. عدم التحقق من أطوال النصوص
13. نقص Semantic Labels
14. Hard-coded Strings — `distributor_login_screen.dart:189,234`
15. أسماء أيام وأشهر hardcoded — `distributor_datasource.dart:627-641`
16. DI فارغ — `lib/di/injection.dart`

### P3 - منخفض

17-19: نقص التوثيق، عدم وجود structured logging، قيود Web Build بدون CI/CD.

---

# 7. Driver App

## Prompt احترافي لتطبيق السائق

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في Driver App الموجود في `driver_app/`. تطبيق سائقي التوصيل.

### P0 - حرج

1. **معالجة أخطاء صامتة** — `driver_auth_datasource.dart:87-89`, `delivery_datasource.dart:101-109,135-143`, `offline_queue_service.dart:129-137,326-347`
2. **عدم استخدام Session Refresh القوي** — `lib/main.dart:119-143` — tokens قد تنتهي أثناء التشغيل
3. **عدم التحقق من بيانات ProofDatasource** — `proof_datasource.dart:12-48` — صور بدون حد حجم أو نوع
4. **عدم توفر مفتاح Release** — `android/app/build.gradle.kts:44-75` — يسقط لـ debug signing
5. **عدم تفعيل ProGuard/R8** — الكود قابل للعكس
6. **حفظ موقع السائق بدون تشفير** — `delivery_datasource.dart:357-394`

### P1 - عالي

7. 8 ملفات اختبار فقط — بدون اختبارات لـ providers و UI الرئيسية
8. عدم استخدام SelectAsync — `delivery_providers.dart:30-42` — rebuilds غير ضرورية
9. عدم استخدام Pagination — `delivery_datasource.dart:150-182` — limit(50) ثابتة
10. Realtime بدون column projection — `delivery_datasource.dart:219-241`
11. عدم التحقق من iOS location permission — `location_service.dart:22-63`
12. Fallback UI مفقود لـ Certificate Pinning failure
13. Chat بدون Retry Logic — `chat_datasource.dart:25-44`
14. Concurrent Updates race condition — `delivery_datasource.dart:256-335`

### P2 - متوسط

15. عدم توثيق Dart-Define متطلبات
16. Image Caching غير مثالي
17. عدم استخدام Lazy Loading لـ Order Items
18. عدم تفعيل Network Security Config في Android
19. Accessibility Labels ناقصة
20. لغة hardcoded عربي فقط — `main.dart:156`

### P3 - منخفض

21-26: Magic Strings، عدم استخدام Equatable، Const Constructors ناقصة، RepaintBoundary مفقود، Loading Skeleton، Haptic Feedback غير متسق.

---

# 8. POS App

## Prompt احترافي لتطبيق POS الرئيسي

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في POS App (Cashier) الموجود في `apps/cashier/`. هذا التطبيق الرئيسي لنقطة البيع.

### P0 - حرج (أصلح فوراً)

1. **تسرب بيانات في .dart_define.env** — مفاتيح Supabase و Wasender حقيقية — أزل فوراً وجدد المفاتيح
2. **معالجة أخطاء ناقصة في العمليات المالية** — 47+ شاشة بـ catch صامت — البيع قد يفشل بصمت
3. **العمليات المالية غير Atomic** — عدم استخدام `database.transaction()` — قد يسبب عدم توازن حسابات
4. **غياب Audit Trail** — جدول audit_log موجود لكن غير مستخدم — مخالفة PDPL
5. **غياب سياسة الخصوصية** — مخالفة قانونية
6. **Crash Reporting غير مفعل** — Sentry DSN غير محقون أثناء البناء
7. **لا Idempotency في العمليات المالية** — الضغط المزدوج ينشئ عمليتين

### P1 - عالي

8. عدم وجود Soft Delete — المنتجات تُحذف نهائياً — مخالفة محاسبية
9. عدم حفظ السلة (Cart) محلياً — crash يفقد كل السلة
10. عدم وجود Offline Mode indicator — المستخدم لا يعرف حالة الاتصال
11. Session Timeout قد لا يعمل بشكل صحيح
12. ZATCA غير مطبق — مخالفة قانونية
13. الطباعة غير مطبقة فعلياً — تطبيق POS بدون طباعة

### P2 - متوسط

14. 336 setState — إعادة بناء مفرطة
15. 245 EdgeInsets.only بدلاً من EdgeInsetsDirectional — مشاكل RTL
16. عدم وجود تأكيد حذف

### P3 - منخفض

17. 78 debugPrint، 69 تحذير analyzer
18. README boilerplate، لا CHANGELOG
19. تغطية اختبارات منخفضة

---

# 9. Super Admin

## Prompt احترافي لتطبيق Super Admin

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في Super Admin الموجود في `super_admin/`. لوحة تحكم المسؤول الأساسي بأعلى صلاحيات.

### P0 - حرج

1. **معالجة أخطاء صامتة في بيانات حساسة** — `sa_subscriptions_datasource.dart:45,94,187,215,233,258` و `sa_analytics_datasource.dart:28,108,187` — `catch (_) {}` في عمليات الفوترة والإيرادات
2. **غياب Audit Logging** — شاشة واحدة فقط (create_store) تسجل، باقي العمليات بدون تسجيل
3. **غياب RBAC في مستويات متعددة** — التحقق فقط في router، لا في datasource level
4. **غياب Input Validation** — `sa_create_store_screen.dart:46-56`, `sa_login_screen.dart:31-36`
5. **استعلامات Supabase بدون حماية كافية** — `sa_stores_datasource.dart:34-36`, `sa_users_datasource.dart:23-26`

### P1 - عالي

6. رسائل خطأ تكشف معلومات حساسة — `sa_dashboard_screen.dart:50`, `sa_logs_screen.dart:141-152`
7. N+1 Problem — `sa_subscriptions_datasource.dart:32-47` — استعلام لكل صف
8. خطأ في حساب شهر الإيرادات — `sa_analytics_datasource.dart:45-48`
9. TODO في كود الإنتاج — `audit_log_service.dart:26-28,97-98`
10. عمليات حذف بدون تأكيد آمن

### P2 - متوسط

11. تغطية اختبار منخفضة — فقط 2 datasource tests، 4 model tests، 7 screen tests
12. استخدام `dynamic` type — `audit_log_service.dart:30,33`, datasources
13. عدم وجود timeout handling — `supabase_client.dart:26-28`
14. `debugPrint` في الإنتاج
15. غياب Retry Logic

### P3 - منخفض

16-20: غياب توثيق، عدم اتساق أسماء الثوابت، String.fromEnvironment بدون default، لا README، لا CI/CD.

---

# 10. Admin POS

## Prompt احترافي لتطبيق Admin POS

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في Admin POS الموجود في `apps/admin/` (واجهة إدارة POS).

### P0 - حرج

1. **تخزين مفاتيح تشفير غير آمن على الويب** — `lib/main.dart:138-160`
2. **معالجة أخطاء صامتة** — `loyalty_program_screen.dart`, `product_form_screen.dart`, `purchase_form_screen.dart`, `supplier_form_screen.dart` — `catch (_) {}`
3. **أخطاء بتعليقات `// ignore`** — `branch_management_screen.dart`, `employee_profile_screen.dart`
4. **نقص معالجة أخطاء تحميل البيانات** — `product_form_screen.dart:74-89` — فشل الفئات بدون UI feedback

### P1 - عالي

5. 135 TextFormField بدون validations — عدم التحقق من المدخلات
6. عدم التحقق من القيم المنطقية قبل الحفظ — Price > 0, Cost <= Price
7. عدم وجود Certificate Pinning
8. Windows Backslashes في pubspec_overrides.yaml — `..\\..\\packages\\` بدلاً من `../../packages/`

### P2 - متوسط

9. غياب تقارير تغطية اختبار
10. غياب error states في Riverpod Providers — `marketing_providers.dart`, `purchases_providers.dart`
11. فقدان وثائق API
12. لا اختبارات تكامل شاملة
13. Null Safety ناقص — استخدام `!` operators
14. عدم وجود Offline Support Documentation
15. Response Status Validation مفقود
16. Rate Limiting Handling مفقود

### P3 - منخفض

17-25: Code Documentation، README غير مفيد، Performance Monitoring، Web Security Headers، Service Worker versioning، Accessibility، Localization، Analytics، Riverpod autoDispose.

---

# 11. Admin POS Lite

## Prompt احترافي لتطبيق Admin POS Lite

أنت مطور Flutter محترف. مهمتك إصلاح جميع المشاكل في Admin POS Lite الموجود في `admin_pos_lite/`. نسخة مبسطة من واجهة إدارة POS (28 شاشة، ~40 ملف).

### P0 - حرج

1. **معالجة أخطاء ناقصة** — `lib/di/injection.dart:44-51` — Supabase failure بدون logging
2. **استثناءات عامة** — `lite_reports_providers.dart:42,265,347` — `Exception('No store selected')` — أنشئ custom exceptions
3. **عدم تعريف Bundle ID** — `android/gradle.properties` — لا applicationId واضح
4. **عدم وجود توقيع Release** — لا keystore أو signing.properties

### P1 - عالي

5. Router Guards بدون اختبارات شاملة — `lib/router/lite_router.dart:61-162` — 80 مسار
6. تخزين مفاتيح غير آمن على الويب — `lib/main.dart:130-143`
7. لا اختبارات تكامل حقيقية
8. عدم وجود تحسينات أداء — autoDispose يعيد جلب كل مرة
9. تغطية اختبارات < 20% — 12 ملف فقط
10. Accessibility ناقصة — 18 Semantics فقط
11. عدم معالجة Edge Cases — قيم سالبة، overflow، نصوص طويلة
12. Hard-coded navigation strings — `lite_shell.dart:76`

### P2 - متوسط

13. وثائق ناقصة
14. معالجة Session Expiry بدون رسالة للمستخدم — `lite_router.dart:126`
15. Localization ناقصة — بعض النصوص hardcoded
16. Database Migrations غير واضحة
17. Memory Management — dispose() غير مضمون
18. Global Error Boundary ناقص
19. Feature Flags مفقودة
20. Version Pinning ناقص — `flutter_secure_storage: ^9.0.0`

### P3 - منخفض

21-26: Code Splitting للويب، Hardcoded Shell labels، Custom Error Page، analysis_options معطلة، API Documentation، Sentry للويب.

---

# المشاكل المشتركة عبر جميع التطبيقات

## الأنماط المتكررة التي تحتاج إصلاح مركزي

1. **معالجة الأخطاء الصامتة** — موجودة في 11/11 تطبيق — أنشئ ErrorHandler مركزي في `alhai_core`
2. **تخزين مفاتيح غير آمن على الويب** — موجود في 8/11 تطبيق — حل مركزي مطلوب
3. **تغطية اختبارات منخفضة** — جميع التطبيقات أقل من 30% — هدف: 70%
4. **Certificate Pinning مفقود** — 9/11 تطبيق
5. **Accessibility ضعيفة** — 11/11 تطبيق
6. **Router Guard مكرر** — 3 تطبيقات — استخرج لـ `alhai_auth`
7. **Input Validation ناقصة** — 8/11 تطبيق
8. **توثيق ناقص** — 11/11 تطبيق

---

## خطة التنفيذ الموصى بها

### الأسبوع 1: P0 فقط
- إزالة الأسرار المكشوفة (Cashier .dart_define.env)
- إصلاح معالجة الأخطاء الصامتة في جميع التطبيقات
- تأمين تخزين المفاتيح على الويب

### الأسبوع 2: P1 أمان
- Certificate Pinning
- Input Validation
- RBAC و Audit Logging (Super Admin)

### الأسبوع 3: P1 جودة
- زيادة تغطية الاختبارات
- إصلاح N+1 queries
- توثيق شامل

### الأسبوع 4: P2-P3
- Accessibility
- Performance
- تحسينات عامة
