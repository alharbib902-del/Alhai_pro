# تقرير المرحلة 1 — فحص البنية التحتية
**التاريخ:** 2026-04-14
**المدقق:** Claude Opus 4.6 (Senior Architecture Auditor)
**النطاق:** `alhai_core` | `alhai_database` | `alhai_sync`
**إصدار التقرير:** 1.0

---

## 1. ملخص تنفيذي

الحزم الثلاث التحتية تُظهر بنية معمارية ناضجة (Clean Architecture, Drift ORM, 4-phase sync engine) مع استثمار واضح في الاختبارات (63+38+21 = 122 ملف اختبار). عُثر على **ثغرة SQL Injection واحدة حرجة** في `database_backup_service.dart` حيث أسماء الأعمدة من JSON خارجي تُدمج مباشرة في SQL. المزامنة تعمل على الخيط الرئيسي (UI thread) بدون Isolate مما يُجمّد الواجهة أثناء المزامنات الكبيرة. البيانات المالية (المبيعات) ليست append-only فعلياً رغم وصفها بـ "sacred". التوصية: **مقبول مع تحفظات** بعد إصلاح البنود الحرجة الثلاثة.

---

## 2. نتائج alhai_core

### A1. Dependency Injection

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| A1.1 | حزمة DI المستخدمة | **PASS** | `get_it: ^7.7.0` + `injectable: ^2.3.2` + `flutter_riverpod: ^2.4.9` — ملف `alhai_core/lib/src/di/injection.dart:7` يعرّف `final getIt = GetIt.instance` ويستخدم `@InjectableInit()` | — |
| A1.2 | توحيد Container | **WARN** | Container مركزي في `alhai_core` لكن **كل تطبيق يعيد تسجيل خدمات خاصة به**: `apps/admin/lib/di/injection.dart` (سطر 22: `allowReassignment = true`)، `apps/cashier/lib/di/injection.dart` (سطر 23)، `customer_app/lib/di/injection.dart` (سطر 26) — 7 أنماط DI مختلفة عبر التطبيقات | MEDIUM |
| A1.3 | فصل أنواع التسجيل | **PASS** | 4 modules في `alhai_core/lib/src/di/modules/`: `core_module.dart` (SharedPreferences=preResolve async, SecureStorage=singleton)، `networking_module.dart` (Dio=lazySingleton)، `datasources_module.dart` (14 datasource=lazySingleton)، `repositories_module.dart` (13 repo=lazySingleton). مجموع: ~2 async + ~29 lazySingleton | — |
| A1.4 | قابلية استبدال Mock | **PASS** | جميع الـ repositories معرّفة كـ abstract interfaces (مثل `auth_repository.dart:1-25`) مع implementations منفصلة. `mocktail` مستخدم في 63 ملف اختبار. التطبيقات تستخدم `allowReassignment=true` لاستبدال الـ implementations | — |

**تفصيل A1.2 — التجزؤ المعماري:**
```
alhai_core       → Injectable (code-gen) + GetIt + Riverpod providers
apps/admin       → Manual GetIt overrides (reuses core getIt)
apps/admin_lite  → Manual GetIt overrides (reuses core getIt)
apps/cashier     → Manual GetIt + 4 app-specific services
customer_app     → Separate `locator` variable, manual setup
driver_app       → Separate `locator` variable, manual setup
super_admin      → Pure Riverpod (GetIt unused but in pubspec)
distributor_portal → Pure Riverpod (GetIt unused but in pubspec)
```
هذا التجزؤ **مقصود جزئياً** (كل تطبيق يحتاج خدمات مختلفة) لكنه يُضعف ضمانات التوحيد.

---

### A2. HTTP Layer

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| A2.1 | حزمة HTTP | **PASS** | `dio: ^5.4.0` — `alhai_core/lib/src/networking/secure_http_client.dart:56` | — |
| A2.2a | Authorization header تلقائي | **PASS** | `auth_interceptor.dart:49`: `options.headers['Authorization'] = 'Bearer ${tokens.accessToken}'` | — |
| A2.2b | tenant_id header تلقائي | **WARN** | لا يوجد interceptor مركزي يضيف `X-Tenant-ID` أو `X-Org-ID` تلقائياً. الـ org_id يُرسل في payload المزامنة فقط | MEDIUM |
| A2.2c | Logging في Debug فقط | **PASS** | `secure_http_client.dart:83-87`: logging interceptor يُضاف فقط `if (kDebugMode)`. الـ `LoggingInterceptor` يقبل body فقط في debug: `logRequestBody: kDebugMode` (سطر 40) | — |
| A2.3a | 401 Unauthorized | **PASS** | `auth_interceptor.dart:64-108`: يكشف 401 → يجدد التوكن عبر `/auth/refresh` → يعيد الطلب مع `_retried=true` لمنع الحلقات. عند فشل التجديد يمسح التوكنات ويرفض | — |
| A2.3b | 403 Forbidden | **PASS** | `error_mapper.dart:77-80`: يُعيد `AuthException(message, code: 'FORBIDDEN', statusCode: 403)`. الرسالة تُستخرج من body الاستجابة مع دعم `ar/en` localization | — |
| A2.3c | 5xx + Retry | **PASS** | `secure_http_client.dart:153-169`: Retry لـ 5xx + timeout + connection errors. Exponential backoff: 1s, 2s, 4s (3 محاولات). `delayMs = 1000 * (1 << retryCount)` | — |
| A2.3d | Timeout | **PASS** | `secure_http_client.dart:51-52`: `connectTimeout: 30s`, `receiveTimeout: 30s` — قيم معقولة | — |
| A2.3e | Network error | **PASS** | `error_mapper.dart:18-21`: `NetworkException('No internet connection', code: 'NO_INTERNET')` | — |
| A2.4 | تسريب أمني في print | **PASS** | فحص `grep -rn "print\|debugPrint" alhai_core/lib/ | grep -iE "token\|password\|key\|secret\|authorization"` = **0 نتائج**. الـ `LoggingInterceptor` يمسك حقول حساسة في قائمة `_sensitiveFields` (سطر 27-37) ويعرض `***MASKED***` بدلاً منها | — |
| A2.5 | استخدام HTTP مباشر خارج core | **PASS** | فحص `grep -rn "import 'package:http/\|import 'package:dio/" apps/ --include="*.dart"` = **0 نتائج**. طبقة الشبكة موحّدة فعلياً | — |

**دليل PII masking في LoggingInterceptor:**
```dart
// logging_interceptor.dart:27-37
static const _sensitiveFields = [
  'password', 'otp', 'pin', 'token',
  'access_token', 'refresh_token', 'secret',
  'credit_card', 'cvv',
];
// سطر 182: يُظهر '***MASKED***' بدل القيمة
```

---

### A3. إدارة الحالة

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| A3.1 | النمط المعتمد | **PASS** | `flutter_riverpod: ^2.4.9` — مقدمات Riverpod في `alhai_core/lib/src/di/providers.dart` (328 سطر) | — |
| A3.2 | توحيد النمط | **PASS** | فحص `pubspec.yaml` لكل التطبيقات: جميعها تستخدم `flutter_riverpod`. لا يوجد `flutter_bloc` أو `getx` في أي تطبيق | — |
| A3.3 | BaseBloc/BaseNotifier | **WARN** | لا يوجد `BaseNotifier` أو `BaseCubit` في alhai_core. كل feature يبدأ من الصفر. غياب base class يعني احتمال تكرار منطق مشترك (error handling, loading states) | LOW |

---

### A4. التشفير وإدارة المفاتيح

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| A4.1a | Tokens في SecureStorage | **PASS** | `auth_local_datasource.dart:48-51`: `_secureStorage.write(key: _tokensKey, value: jsonString)` — tokens مخزنة في `FlutterSecureStorage` (تشفير native) | — |
| A4.1b | SharedPreferences سليم | **PASS** | فحص `grep -rn "SharedPreferences" alhai_core/lib/ apps/*/lib/ | grep -iE "token\|password\|key\|secret\|jwt\|session"` = **0 نتائج**. SharedPreferences يُخزّن بيانات المستخدم غير الحساسة فقط (id, name, email, roles) في `auth_local_datasource.dart:77` | — |
| A4.2 | خوارزميات التشفير | **PASS** | فحص `grep AES\|DES\|MD5\|SHA1\|SHA256\|SHA512` = **0 نتائج** (لا symmetric encryption). الحزمة تستخدم `crypto: ^3.0.3` لـ SHA-256 hashing فقط: cert pinning (`secure_http_client.dart:144`) و image versioning (`image_service.dart`) | — |
| A4.3 | IV/Nonce | **N/A** | لا يوجد تشفير متماثل في الحزمة — tokens مشفّرة بواسطة FlutterSecureStorage (native keychain/keystore)، والقاعدة مشفّرة بـ `sqlcipher_flutter_libs` | — |

---

## 3. نتائج alhai_database

### B1. Drift Schema

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| B1.1a | مفتاح أولي لكل جدول | **PASS** | جميع الـ 41+ جدول تستخدم `id` (text) كـ PRIMARY KEY، باستثناء `sync_metadata` الذي يستخدم `table_name` كمفتاح | — |
| B1.1b | tenant_id/org_id | **WARN** | 23 جدول حصلت على `org_id` في migration v10. لكن **8 جداول بدون عزل tenant**: `order_items`, `sale_items`, `order_status_history`, `product_expiry`, `return_items`, `purchase_items`, `user_stores`, `settings` (storeId فقط). الجداول الفرعية (items) تعتمد على الجدول الأب للعزل | MEDIUM |
| B1.1c | created_at / updated_at | **WARN** | أغلب الجداول تملك `created_at`. بعضها يفتقد `updated_at`: `audit_log`, `cash_movements`, `inventory_movements`, `stock_deltas`. وبعضها يفتقد كلاهما: `sync_metadata`, `order_status_history` | LOW |
| B1.1d | soft-delete | **PASS** | تمت إضافة `deleted_at` في migration v12 لـ 15 جدول أعمال رئيسي (products, sales, orders, customers, etc.) — الجداول التي لا تملكها هي إما system tables أو transactional logs | — |
| B1.2 | Foreign Keys | **PASS** | `app_database.dart:258`: `PRAGMA foreign_keys = ON` مفعّل. FK مستخدم بحذر — لا يوجد CASCADE عشوائي. العلاقات عبر Drift decorators مع indexes استراتيجية | — |

### B2. Migrations

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| B2.1 | ترتيب Migrations | **PASS** | 22 إصدار schema، مرتّب تصاعدياً (v2→v22). كل migration موثّق بتعليق عربي. `app_database.dart:270-1040` | — |
| B2.2 | ALTER vs drop-recreate | **PASS** | الغالبية `ALTER TABLE ADD COLUMN`. حالات drop-recreate تستخدم نمط آمن: CREATE temp → INSERT INTO temp SELECT FROM original → DROP original → RENAME temp. مثال: v13 migration سطر 601-625 ينقل البيانات قبل الحذف | — |
| B2.3 | اختبار Migrations | **PASS** | `test/migration_test.dart` (256 سطر): يختبر schema version=22، كل الجداول والـ DAOs. يختبر إنشاء DB فارغة | — |
| B2.4 | Rollback tests | **FAIL** | لا يوجد أي اختبار rollback. لا يوجد `onDowngrade` callback. إذا فشلت migration يبقى الـ schema في حالة وسيطة | HIGH |

**دليل غياب rollback:**
```
grep -rn "onDowngrade\|rollback\|downgrade" packages/alhai_database/lib/ = 0 نتائج
```

### B3. DAOs وأمان SQL

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| B3.1a | SQL Injection — backup service | **FAIL** | `database_backup_service.dart:378`: أسماء أعمدة من JSON خارجي تُدمج مباشرة: `'INSERT OR REPLACE INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)'` — الـ `columns` مستخرجة من `rowMap.keys` (سطر 366) وهي بيانات JSON مستوردة. ملف backup خبيث يمكنه حقن SQL عبر أسماء أعمدة مثل `"id); DROP TABLE sales; --"` | **CRITICAL** |
| B3.1b | SQL Injection — sales DAO | **WARN** | `sales_dao.dart` سطور 445, 527, 575, 656, 690: WHERE clause مبنية بـ string concatenation ثم interpolated في SQL. القيم ذاتها parameterized لكن هيكل SQL يُبنى ديناميكياً. المدخلات من متغيرات داخلية (storeId, dates) وليست من المستخدم مباشرة | MEDIUM |
| B3.1c | SQL Injection — conflict resolver | **WARN** | `conflict_resolver.dart:596-603`: أسماء أعمدة من `serverData.keys` (payload من sync queue) تُدمج في SQL: `'$c = excluded.$c'`. البيانات من DB المحلي لكن بدون whitelist validation | MEDIUM |
| B3.1d | Table name validation | **PASS** | `sync_table_validator.dart`: whitelist من 50 جدول مسموح. دالة `validateTableName()` ترمي `ArgumentError` للجداول غير المعروفة | — |
| B3.2 | اختبارات DAO | **PASS** | 31 ملف اختبار لـ 32 DAO + 3 performance tests + 2 integration tests + 1 migration test = **38 ملف اختبار** | — |

**PoC — SQL Injection عبر backup خبيث (B3.1a):**
```json
// ملف backup خبيث
{
  "products": [
    {
      "id": "1",
      "name); DELETE FROM sales WHERE (1=1": "malicious"
    }
  ]
}
```
```dart
// database_backup_service.dart:366-379
final columns = rowMap.keys.toList();  // يأخذ المفاتيح مباشرة
// ينتج: INSERT OR REPLACE INTO products (id, name); DELETE FROM ...) VALUES (?, ?)
```

### B4. البحث النصي العربي

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| B4.1 | تقنية البحث | **PASS** | FTS5 مع `unicode61 remove_diacritics 1` — `products_fts.dart:33`: `tokenize='unicode61 remove_diacritics 1'` | — |
| B4.2a | بحث "حليب" vs "الحليب" | **PASS** | FTS5 tokenizer يفصل الكلمات ويدعم prefix matching عبر `*`. `_prepareQuery()` سطر 228 يضيف wildcard | — |
| B4.2b | تطويل (kashida) | **WARN** | `_prepareQuery()` سطر 230-237 يزيل special characters لكن **لا يعالج حرف التطويل** (U+0640 ـ). بحث عن "حلـيـب" قد لا يجد "حليب" | MEDIUM |
| B4.3 | أداء البحث | **INFO** | 3 ملفات اختبار أداء موجودة: `database_performance_test.dart`, `inventory_performance_test.dart`, `sales_performance_test.dart`. لم يُنفَّذ اختبار 50k منتج فعلياً (يتطلب بيئة تشغيل) | — |

**دليل غياب معالجة التطويل:**
```dart
// products_fts.dart:230-237
String _prepareQuery(String query) {
  // يزيل special characters لكن يحتفظ بالعربية (U+0600-U+06FF)
  // حرف التطويل U+0640 يقع ضمن النطاق العربي فلن يُزال
  // لكن FTS5 يعامله ككلمة مختلفة
  query = query.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
  ...
}
```

### B5. تصدير CSV

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| B5.1 | UTF-8 BOM | **N/A** | لا توجد وظيفة تصدير CSV في `alhai_database`. يوجد فقط **استيراد CSV** في `database_seeder.dart`. التصدير يُحتمل أنه في طبقة التطبيق أو `alhai_services` | — |
| B5.2 | تنسيق الأرقام | **N/A** | — | — |
| B5.3 | تنسيق التواريخ | **N/A** | — | — |

---

## 4. نتائج alhai_sync

### C1. استراتيجية المزامنة

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C1.1 | نموذج المزامنة | **PASS** | نظام متعدد الاستراتيجيات (4 مراحل): Pull → Push → Bidirectional → StockDelta. كل جدول له استراتيجية محددة: `serverWins` (products, categories), `localWins` (sales, expenses), `lastWriteWins` (customers, orders), `merge` (stock deltas) — `conflict_resolver.dart:210-279` | — |
| C1.2 | توثيق معماري | **WARN** | لا يوجد `ARCHITECTURE.md` أو ملف توثيق مستقل. المعمارية موثّقة في تعليقات الكود فقط (مثل `push_strategy.dart:1-31` يشرح DUAL-QUEUE) | MEDIUM |

### C2. حل التعارضات

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C2.1a | منطق حل التعارض | **PASS** | `ConflictResolver` (610 سطر) يدعم 5 أنواع تعارض و5 استراتيجيات حل. كل جدول له قاعدة محددة: sales→localWins, products→serverWins, customers→lastWriteWins. الـ orders لها معاملة خاصة بأولوية الحالة (completed > delivering > created) — `conflict_resolver.dart:436-479` | — |
| C2.1b | تنبيه المستخدم | **WARN** | التعارضات تُحل تلقائياً بدون إشعار للمستخدم. `SyncStatusTracker` يعرض عدد العناصر في dead letter queue لكن لا يوجد UI notification عند حل تعارض. `ResolutionStrategy.manual` موجود لكن لا يوجد UI له | MEDIUM |
| C2.1c | تسجيل التعارض | **PASS** | كل تعارض يُسجّل في `audit_log` عبر `logSyncOperation()` — `sync_queue_dao.dart:673-700`. تفاصيل التعارض (local_data, server_data) تُخزن كـ JSON في `sync_queue.last_error` | — |
| C2.1d | استرجاع البيانات المفقودة | **PASS** | Dead Letter Queue يحتفظ بالعناصر الفاشلة مع البيانات الأصلية. `retryDeadLetterItems()` يعيد المحاولة — `sync_queue_dao.dart:517-529` | — |
| C2.2 | بيانات مالية append-only | **FAIL** | المبيعات وُصفت بأنها "sacred" (`push_strategy.dart:564-569`) لكنها **ليست append-only فعلياً**. جدول `sales` يدعم عمليات UPDATE. لا يوجد constraint يمنع تعديل الفاتورة بعد إنشائها. هذا خطر على سلامة البيانات المالية والامتثال الضريبي | **CRITICAL** |

**دليل C2.2 — المبيعات قابلة للتعديل:**
```dart
// push_strategy.dart:76 — sales في قائمة الدفع
static const pushTables = ['sales', 'sale_items', ...];
// لا يوجد فلتر يمنع operation='UPDATE' على sales

// conflict_resolver.dart:219-226 — sales تستخدم localWins
case 'sales':
case 'sale_items':
  return ResolutionStrategy.localWins;
// هذا يعني أن تعديل محلي يفوز على السيرفر — خطير ماليًا
```

### C3. Idempotency

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C3.1 | رفض العملية المكررة | **PASS** | Idempotency key: `${tableName}_${recordId}_${operation.name}` — `sync_service.dart:80-81`. عند duplicate key (PostgreSQL 23505) يتحول تلقائياً لـ upsert — `push_strategy.dart:219-257`. السيرفر يستخدم `upsert(payload, onConflict: 'id')` | — |
| C3.2 | Client UUID | **PASS** | كل عنصر في queue يحمل UUID عبر `uuid: ^4.4.0`. Device ID يُمرر عند `SyncEngine.initialize()` ويُستخدم في stock delta sync — `sync_engine.dart:142-143` | — |

### C4. Queue المستمر

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C4.1 | تخزين Queue | **PASS** | SQLite عبر Drift table `sync_queue` — مستمر عبر إغلاق التطبيق. الجدول يحتوي: `id, tableName_, recordId, operation, payload, status, idempotencyKey, priority, createdAt, retryCount, maxRetries` | — |
| C4.2a | استرداد بعد الانهيار | **PASS** | 3 مستويات حماية: (1) عند بدء التطبيق `recoverStuckSyncingItems(5min)` — `sync_manager.dart:152`، (2) `resetStuckItems(60s)` — `sync_manager.dart:172`، (3) قبل كل دورة مزامنة — `sync_manager.dart:631-650` | — |
| C4.2b | استئناف من نقطة التوقف | **PASS** | العناصر المعلقة تُعاد لحالة `pending` وتُكمل المزامنة. لا تبدأ من الصفر ولا تضيع. Dead letter queue يحتفظ بالفاشلة نهائياً بعد 5 محاولات | — |

### C5. الأداء والخيوط

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C5.1 | Isolate منفصل | **FAIL** | فحص `grep -rn "Isolate\|compute" packages/alhai_sync/lib/` = **0 نتائج**. المزامنة تعمل بالكامل على main isolate عبر `Timer.periodic(30s)` و async/await. عند مزامنة آلاف العناصر، الـ I/O serialization يحجب الـ UI thread | **CRITICAL** |
| C5.2 | اختبار حمل | **INFO** | لم يُنفَّذ اختبار 10,000 منتج + 1,000 فاتورة (يتطلب بيئة Supabase). الاختبارات الموجودة تستخدم mocks | — |

**دليل C5.1:**
```dart
// sync_manager.dart — الـ timer يعمل على main isolate
_pushTimer = Timer.periodic(
  const Duration(seconds: 15),
  (_) => _runPushSync(),  // هذا يعمل على UI thread
);
```

### C6. أمان المزامنة

| البند | الوصف | النتيجة | الدليل | الخطورة |
|-------|-------|---------|--------|---------|
| C6.1 | tenant_id في payload | **PASS** | org_id يُدمج في payload المزامنة. `bidirectional_strategy.dart` و `push_strategy.dart` يرسلان org_id مع البيانات. الـ pull يفلتر بـ `org_id` | — |
| C6.2 | تحقق السيرفر | **DEFERRED** | التحقق من أن السيرفر يطابق `org_id` في الـ payload مع المستخدم المصادَق عليه → يُفحص في المرحلة 6 (أمن Supabase RLS) | — |

---

## 5. العيوب المعمارية الحرجة

### عيب 1: المبيعات ليست Append-Only (C2.2)
**الملف:** `packages/alhai_sync/lib/src/strategies/push_strategy.dart`
**الخطورة:** CRITICAL

المبيعات (sales) يُمكن تعديلها بعد الإنشاء عبر sync queue. هذا يعني:
- موظف يمكنه تغيير مبلغ فاتورة بعد البيع
- تعارض مزامنة قد يفقد بيانات مالية (localWins بدون audit)
- عدم توافق مع متطلبات ZATCA (الفواتير الإلكترونية غير قابلة للتعديل)

```dart
// push_strategy.dart:76 — لا يوجد حماية ضد UPDATE على sales
static const pushTables = ['sales', 'sale_items', 'orders', ...];
// المطلوب: فلتر يرفض operation='UPDATE' على sales بعد status='completed'
```

### عيب 2: المزامنة على Main Thread (C5.1)
**الملف:** `packages/alhai_sync/lib/src/sync_manager.dart`
**الخطورة:** CRITICAL

كل عمليات المزامنة تعمل على الخيط الرئيسي. مع 1000+ عنصر في الـ queue:
- JSON serialization/deserialization يحجب UI
- استعلامات SQLite المعقدة تحجب UI
- التطبيق يبدو "متجمداً" للمستخدم أثناء المزامنة

### عيب 3: DI مجزّأ عبر التطبيقات (A1.2)
**الملف:** متعدد — كل `apps/*/lib/di/injection.dart`
**الخطورة:** MEDIUM

7 أنماط DI مختلفة تزيد من:
- خطر التسجيل الخاطئ (override بدون قصد)
- صعوبة الصيانة عند إضافة خدمة جديدة
- احتمال استخدام implementation مختلف في تطبيقين

---

## 6. العيوب الأمنية الحرجة

### ثغرة 1: SQL Injection عبر Backup Import (B3.1a)
**الملف:** `packages/alhai_database/lib/src/services/database_backup_service.dart:366-379`
**الخطورة:** CRITICAL

**الوصف:** أسماء الأعمدة تُستخرج من مفاتيح JSON المستورد بدون أي تعقيم أو whitelist validation، ثم تُدمج مباشرة في SQL statement.

**PoC:**
```json
{
  "products": [{
    "id": "x",
    "name) VALUES ('x','hacked'); DROP TABLE sales; --": "payload"
  }]
}
```

**المتجه:** ملف backup مُعدّل يُستورد عبر وظيفة `importFromJson()`.

**الإصلاح المقترح:**
```dart
// إضافة whitelist validation للأعمدة
final allowedColumns = _getTableColumns(tableName);
final safeColumns = columns.where((c) => allowedColumns.contains(c)).toList();
if (safeColumns.length != columns.length) {
  throw ArgumentError('Invalid column names in backup data');
}
```

### ثغرة 2: Column Injection في Conflict Resolver (B3.1c)
**الملف:** `packages/alhai_sync/lib/src/conflict_resolver.dart:596`
**الخطورة:** MEDIUM

```dart
// سطر 596 — أسماء الأعمدة من serverData.keys بدون validation
final updates = columns
    .where((c) => c != 'id')
    .map((c) => '$c = excluded.$c')  // ← string interpolation
    .join(', ');
```

**المتجه:** بيانات sync_queue المحلية — يتطلب وصولاً مادياً للجهاز أو backup خبيث.

---

## 7. تحليل الأداء

| القياس | القيمة | الحالة | الملاحظات |
|--------|--------|--------|-----------|
| Timeout HTTP | 30s connect + 30s receive | مقبول | قيم معقولة لاتصالات 3G/4G |
| Retry Strategy | 3 محاولات, backoff: 1s→2s→4s | مقبول | Exponential backoff صحيح |
| Sync Interval | Push: 15s, Pull: 30s | مقبول | لكن يعمل على main thread |
| Circuit Breaker | 5 failures → 5min cooldown | مقبول | يمنع الـ thrashing |
| Stuck Recovery | 60s + 5min thresholds | مقبول | 3 مستويات حماية |
| FTS Tokenizer | unicode61 + remove_diacritics | مقبول | يدعم العربية بشكل أساسي |
| DB Cache | 8MB (`PRAGMA cache_size = -8000`) | مقبول | — |
| Sync Batch Size | 100 items per push | مقبول | — |
| Pull Page Size | 500 records | مقبول | Max 200 pages = 100k records |
| Backup Retention | Auto-cleanup > 3 days synced | مقبول | — |
| Isolate Usage | **لا يوجد** | **فشل** | المزامنة على UI thread |
| البحث عن 50k منتج | **لم يُقاس** | غير محدد | يتطلب بيئة تشغيل |
| مزامنة 10k+1k عنصر | **لم يُقاس** | غير محدد | يتطلب Supabase |

---

## 8. نتائج تغطية الاختبارات

| الحزمة | ملفات المصدر | ملفات الاختبار | نسبة الملفات | ملاحظات |
|--------|-------------|---------------|-------------|---------|
| alhai_core | ~181 (lib/) | 63 (test/) | 35% ملفات | يغطي repositories, models, exceptions, services |
| alhai_database | ~85 (lib/) | 38 (test/) | 45% ملفات | 31/32 DAOs مختبرة + 3 performance + 2 integration |
| alhai_sync | ~20 (lib/) | 21 (test/) | **105%** ملفات | تغطية ممتازة — ملف اختبار لكل ملف مصدر + helpers |

**ملاحظة:** النسب أعلاه هي نسبة الملفات (file coverage) وليست code line coverage. لم يُنفَّذ `flutter test --coverage` بسبب متطلبات البيئة (Flutter SDK + dependencies). تغطية alhai_sync هي الأفضل بوضوح.

**اختبارات بارزة موجودة:**
- Integration: `sale_transaction_flow_test.dart` (496 سطر), `sync_queue_flow_test.dart` (391 سطر)
- Performance: 3 ملفات (293+277+323 سطر)
- Conflict resolution: `conflict_resolver_test.dart` (543 سطر)
- All sync strategies: pull, push, bidirectional, stock_delta (كل منها ~250-300 سطر)

**اختبارات مفقودة:**
- Migration rollback tests
- Arabic search with kashida (تطويل)
- Load testing (50k products, 10k sync items)
- CSV export (لأن الوظيفة غير موجودة في هذه الطبقة)

---

## 9. قائمة الإصلاحات المرتّبة بالأولوية

### CRITICAL (يوقف الانتقال للمرحلة 2)

| # | البند | الوصف | الملف | السطر |
|---|-------|-------|-------|-------|
| C1 | SQL Injection في Backup Import | أسماء أعمدة من JSON تُدمج في SQL بدون whitelist | `database_backup_service.dart` | 366-379 |
| C2 | المبيعات ليست Append-Only | sales تدعم UPDATE بعد الإنشاء — خطر مالي وضريبي | `push_strategy.dart` | 76 |
| C3 | المزامنة على Main Thread | لا يوجد Isolate — UI يتجمد أثناء المزامنات الكبيرة | `sync_manager.dart` | كامل الملف |

### HIGH

| # | البند | الوصف | الملف | السطر |
|---|-------|-------|-------|-------|
| H1 | غياب Migration Rollback | لا يوجد `onDowngrade` — فشل migration يترك DB في حالة وسيطة | `app_database.dart` | — |
| H2 | Column Injection في Conflict Resolver | أسماء أعمدة من payload بدون validation | `conflict_resolver.dart` | 596 |
| H3 | غياب Tenant ID Header | لا يوجد interceptor يضيف org_id في HTTP headers تلقائياً | `auth_interceptor.dart` | — |

### MEDIUM

| # | البند | الوصف | الملف | السطر |
|---|-------|-------|-------|-------|
| M1 | DI مجزّأ عبر التطبيقات | 7 أنماط DI مختلفة — fragility risk | `apps/*/lib/di/` | — |
| M2 | جداول فرعية بدون org_id | `order_items`, `sale_items` تعتمد على الأب للعزل | `tables/*.dart` | — |
| M3 | تطويل عربي غير مدعوم | بحث "حلـيـب" قد لا يجد "حليب" | `products_fts.dart` | 230 |
| M4 | لا تنبيه للمستخدم عند تعارض | التعارضات تُحل بصمت بدون إشعار | `sync_status_tracker.dart` | — |
| M5 | غياب توثيق معماري للمزامنة | لا ARCHITECTURE.md — الفريق الجديد سيتعثر | `packages/alhai_sync/` | — |
| M6 | WHERE clause interpolation في sales DAO | هيكل SQL يُبنى ديناميكياً (المدخلات داخلية) | `sales_dao.dart` | 445+ |

### LOW

| # | البند | الوصف | الملف | السطر |
|---|-------|-------|-------|-------|
| L1 | غياب BaseNotifier | كل feature يبني state management من الصفر | `alhai_core/lib/src/di/` | — |
| L2 | بعض الجداول بدون updated_at | `audit_log`, `cash_movements`, `inventory_movements` | `tables/*.dart` | — |
| L3 | GetIt غير مستخدم في super_admin و distributor_portal | الحزمة في pubspec لكن لا تُستخدم فعلياً — dead dependency | `super_admin/pubspec.yaml` | 27-28 |

---

## 10. التوصية النهائية

### 🟡 مقبول مع تحفظات

البنية التحتية **ناضجة معمارياً** وتُظهر استثماراً جيداً في:
- Clean Architecture مع Repository pattern
- نظام مزامنة متقدم (4 مراحل، 5 استراتيجيات تعارض، dead letter queue)
- تغطية اختبارات جيدة خصوصاً في alhai_sync
- أمان طبقة HTTP (cert pinning, PII masking, token refresh)
- تخزين آمن للتوكنات (FlutterSecureStorage)

**شروط الانتقال للمرحلة 2:**

1. **إلزامي (CRITICAL):**
   - [ ] إصلاح SQL Injection في backup import (C1) — إضافة column whitelist validation
   - [ ] تحويل المبيعات لـ append-only (C2) — منع UPDATE بعد status=completed
   - [ ] نقل المزامنة لـ Isolate منفصل (C3) — أو على الأقل JSON serialization

2. **مطلوب قبل الإطلاق (HIGH):**
   - [ ] إضافة migration rollback أو على الأقل backup + restore strategy (H1)
   - [ ] تعقيم أسماء الأعمدة في conflict resolver (H2)
   - [ ] إضافة org_id header في interceptor مركزي (H3)

3. **مطلوب ضمن الأسبوعين القادمين (MEDIUM):**
   - [ ] معالجة حرف التطويل العربي في FTS (M3)
   - [ ] إضافة ARCHITECTURE.md لحزمة المزامنة (M5)
   - [ ] تنبيه المستخدم عند حل تعارض بيانات مالية (M4)

---

**انتهى التقرير**
*تم التدقيق على commit: `67a337a` (main branch)*
*مدة التدقيق: جلسة واحدة — 2026-04-14*
