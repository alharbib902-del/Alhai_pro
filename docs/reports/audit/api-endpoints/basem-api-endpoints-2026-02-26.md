# تقرير تدقيق نقاط النهاية (API Endpoints) - منصة الحي

**التاريخ:** 2026-02-26
**المدقق:** باسم
**النطاق:** جميع الحزم والتطبيقات في Alhai Monorepo
**الحالة:** مراجعة شاملة - قراءة فقط

---

## الفهرس

1. [ملخص تنفيذي](#ملخص-تنفيذي)
2. [جدول ملخص بالارقام](#جدول-ملخص-بالارقام)
3. [قائمة بجميع نقاط النهاية](#قائمة-بجميع-نقاط-النهاية)
4. [النتائج التفصيلية](#النتائج-التفصيلية)
5. [التوصيات مع اولوية التنفيذ](#التوصيات-مع-اولوية-التنفيذ)
6. [التقييم النهائي](#التقييم-النهائي)

---

## ملخص تنفيذي

تم اجراء تدقيق شامل لجميع نقاط النهاية (API Endpoints) في منصة الحي والتي تشمل:
- **خدمات المزامنة** (`packages/alhai_sync/`): 6 استراتيجيات مزامنة مع Supabase
- **المصادقة** (`packages/alhai_auth/`): OTP عبر WhatsApp + Supabase Auth
- **الذكاء الاصطناعي** (`packages/alhai_ai/` + `ai_server/`): 15 خدمة AI عبر FastAPI
- **التخزين** (`alhai_core/`): رفع الصور عبر Supabase Storage + R2
- **دوال Edge** (`supabase/functions/`): وظيفتان (رفع الصور + المنتجات العامة)
- **دوال RPC** (`supabase/*.sql`): 3 دوال (get_my_stores, get_store_categories, get_store_products)

### ملخص المشاكل

| التصنيف | العدد |
|---------|-------|
| حرج | 5 |
| متوسط | 9 |
| منخفض | 7 |
| **الاجمالي** | **21** |

### التقييم العام: **6.5 / 10**

المنصة تتمتع ببنية مزامنة متقدمة ونظام مصادقة جيد، لكن يوجد عدة ثغرات حرجة في الامان والتعامل مع الاخطاء تحتاج معالجة عاجلة.

---

## جدول ملخص بالارقام

| المقياس | القيمة |
|---------|--------|
| اجمالي نقاط النهاية (Supabase REST) | ~45 عملية |
| استدعاءات RPC | 5 (get_my_stores, get_store_categories, get_store_products, apply_stock_deltas, get_my_stores مكرر) |
| دوال Edge Functions | 2 (upload-product-images, public-products) |
| نقاط نهاية AI Server | 16 (health + 15 خدمة) |
| استدعاءات WhatsApp API | 1 (WaSender /send-message) |
| اجمالي الجداول المزامنة | ~40 جدول |
| قنوات Realtime | 6 جداول (products, categories, orders, notifications, shifts, inventory_movements) |
| عمليات التخزين (Storage) | 4 انواع (upload, list, remove, getPublicUrl) |
| ملفات الخدمات المفحوصة | 52 ملف Dart + 16 ملف Python + 3 ملفات TypeScript + 4 ملفات SQL |

---

## قائمة بجميع نقاط النهاية

### 1. Supabase REST API (عبر `supabase.from()`)

| الجدول | العمليات | الملف |
|--------|----------|------|
| اي جدول (ديناميكي) | upsert, delete, select | `packages/alhai_sync/lib/src/sync_api_service.dart` |
| اي جدول (ديناميكي) | upsert, delete, select | `packages/alhai_sync/lib/src/org_sync_service.dart` |
| اي جدول (ديناميكي) | upsert, delete | `packages/alhai_sync/lib/src/strategies/push_strategy.dart` |
| اي جدول (ديناميكي) | select, range, order | `packages/alhai_sync/lib/src/strategies/pull_strategy.dart` |
| اي جدول (ديناميكي) | select, upsert, delete | `packages/alhai_sync/lib/src/strategies/bidirectional_strategy.dart` |
| اي جدول (ديناميكي) | select (range, order) | `packages/alhai_sync/lib/src/initial_sync.dart` |
| inventory_movements | upsert | `packages/alhai_sync/lib/src/strategies/stock_delta_sync.dart:175` |
| products | select (stock_qty) | `packages/alhai_sync/lib/src/strategies/stock_delta_sync.dart:199` |
| product-images (Storage) | uploadBinary, remove, list, getPublicUrl | `alhai_core/lib/src/services/image_service.dart` |

### 2. Supabase RPC

| الدالة | المعاملات | الملف |
|--------|-----------|------|
| `get_my_stores` | (بدون) | `packages/alhai_auth/lib/src/screens/store_select_screen.dart:197,225` |
| `get_store_categories` | `p_store_id` | `packages/alhai_auth/lib/src/screens/store_select_screen.dart:354` |
| `get_store_products` | `p_store_id` | `packages/alhai_auth/lib/src/screens/store_select_screen.dart:388` |
| `apply_stock_deltas` | `p_org_id, p_store_id, p_deltas` | `packages/alhai_sync/lib/src/strategies/stock_delta_sync.dart:77` |

### 3. Supabase Auth

| العملية | الملف |
|---------|------|
| `auth.currentUser` | `packages/alhai_auth/lib/src/screens/store_select_screen.dart:188,221` |
| `auth.currentSession` | `packages/alhai_auth/lib/src/screens/splash_screen.dart:105` |
| `auth.currentSession?.accessToken` | `packages/alhai_ai/lib/src/services/ai_api_service.dart:63` |
| `auth.signInWithOtp(phone)` | `packages/alhai_auth/lib/src/providers/auth_providers.dart:314` |
| `auth.verifyOTP(phone, token)` | `packages/alhai_auth/lib/src/providers/auth_providers.dart:334` |
| `auth.signOut()` | `packages/alhai_auth/lib/src/providers/auth_providers.dart:296,381` |

### 4. Supabase Realtime (WebSocket)

| القناة | الجداول | الملف |
|--------|---------|------|
| `sync_{tableName}` | products, categories, orders, notifications, shifts, inventory_movements | `packages/alhai_sync/lib/src/realtime_listener.dart:112` |

### 5. AI Server (FastAPI) - REST API

| نقطة النهاية | الطريقة | الوصف |
|-------------|---------|------|
| `GET /health` | GET | فحص صحة الخادم |
| `POST /ai/forecast` | POST | التنبؤ بالمبيعات |
| `POST /ai/pricing` | POST | التسعير الذكي |
| `POST /ai/fraud` | POST | كشف الاحتيال |
| `POST /ai/basket` | POST | تحليل سلة المشتريات |
| `POST /ai/recommendations` | POST | توصيات العملاء |
| `POST /ai/inventory` | POST | المخزون الذكي |
| `POST /ai/competitor` | POST | تحليل المنافسين |
| `POST /ai/reports` | POST | التقارير الذكية |
| `POST /ai/staff` | POST | تحليل الموظفين |
| `POST /ai/recognize` | POST | التعرف على المنتجات |
| `POST /ai/sentiment` | POST | تحليل المشاعر |
| `POST /ai/returns` | POST | التنبؤ بالمرتجعات |
| `POST /ai/promotions` | POST | تصميم العروض |
| `POST /ai/chat` | POST | الدردشة مع البيانات |
| `POST /ai/assistant` | POST | المساعد الذكي |

### 6. Edge Functions

| الدالة | الطريقة | الملف |
|--------|---------|------|
| `upload-product-images` | POST | `supabase/functions/upload-product-images/index.ts` |
| `public-products` | GET | `supabase/functions/public-products/index.ts` |

### 7. خدمات خارجية

| الخدمة | نقطة النهاية | الملف |
|--------|-------------|------|
| WaSender API | `POST /send-message` | `packages/alhai_auth/lib/src/services/whatsapp_otp_service.dart:261` |
| Auth API (Dio) | `POST /auth/refresh` | `alhai_core/lib/src/networking/interceptors/auth_interceptor.dart:131` |
| Auth API (Dio) | `POST /auth/send-otp` | `alhai_core/lib/src/repositories/impl/auth_repository_impl.dart:29` |
| Auth API (Dio) | `POST /auth/verify-otp` | `alhai_core/lib/src/repositories/impl/auth_repository_impl.dart:39` |

---

## النتائج التفصيلية

---

### 1. حقن SQL في عمليات المزامنة المحلية

**التصنيف:** حرج

**الوصف:** استخدام اسماء الجداول والاعمدة مباشرة في جمل SQL بدون تعقيم (sanitization). اسماء الجداول تاتي من بيانات المزامنة ويمكن ان تحتوي على كود ضار.

**الملفات والاسطر المتاثرة:**

**ملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\realtime_listener.dart`
```dart
// سطر 200-205
await _db.customStatement(
  'INSERT INTO $tableName (${columns.join(', ')}) '
  'VALUES ($placeholders) '
  'ON CONFLICT(id) DO UPDATE SET $updates',
  columns.map((c) => record[c]).toList(),
);
```

**ملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\pull_strategy.dart`
```dart
// سطر 196-214
batch.customStatement(
  'DELETE FROM $tableName WHERE id = ?',
  [record['id']],
);
// ...
batch.customStatement(
  'INSERT INTO $tableName (${columns.join(', ')}) '
  'VALUES ($placeholders) '
  'ON CONFLICT(id) DO UPDATE SET $updates',
  columns.map((c) => record[c]).toList(),
);
```

**ملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\bidirectional_strategy.dart`
```dart
// سطر 323-325, 336-345, 503-508
await _db.customStatement(
  'DELETE FROM $tableName WHERE id = ?',
  [recordId],
);
```

**ملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\initial_sync.dart`
```dart
// سطر 285-290
batch.customStatement(
  'INSERT INTO $tableName (${columns.join(', ')}) '
  'VALUES ($placeholders) '
  'ON CONFLICT(id) DO UPDATE SET $updates',
  columns.map((c) => record[c]).toList(),
);
```

**ملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\stock_delta_sync.dart`
```dart
// سطر 230-237
await _db.customStatement(
  'UPDATE products SET stock_qty = ?, synced_at = ? WHERE id = ?',
  [newStock, DateTime.now().toUtc().toIso8601String(), productId],
);
```

**المخاطر:** اسماء الجداول والاعمدة (`$tableName`, `${columns.join(', ')}`) مستقاة من بيانات الشبكة (Supabase response). رغم ان القيم تمرر كمعاملات (parameterized)، اسماء الجداول والاعمدة نفسها عرضة للحقن.

---

### 2. CORS مفتوح بالكامل في Edge Functions

**التصنيف:** حرج

**الوصف:** ملف `_shared/cors.ts` يسمح بالوصول من اي نطاق (`*`).

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\_shared\cors.ts`
```typescript
// سطر 1-5
export const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-correlation-id, x-user-id, x-store-id',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
};
```

**المخاطر:** اي موقع ويب يمكنه ارسال طلبات الى Edge Functions واستخدام بيانات المصادقة المسروقة.

---

### 3. حقن محتمل في فلتر البحث بدالة public-products

**التصنيف:** حرج

**الوصف:** متغير البحث `search` يُدرج مباشرة في فلتر `.or()` بدون تعقيم.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\public-products\index.ts`
```typescript
// سطر 116
query = query.or(`name.ilike.%${search}%,barcode.eq.${search},sku.eq.${search}`);
```

**المخاطر:** يمكن للمهاجم ارسال قيم بحث خبيثة تغير منطق الاستعلام عبر حقن اوامر PostgREST مثل:
```
search=test%,name.is.null)--
```

---

### 4. كشف عنوان Supabase URL في الكود المصدري

**التصنيف:** حرج

**الوصف:** عنوان Supabase URL مكتوب بشكل صريح (hardcoded) في ملف الاعدادات.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\config.py`
```python
# سطر 11
supabase_url: str = "https://jtgwboqushihwvvsdtud.supabase.co"
```

**المخاطر:** كشف عنوان المشروع يسهل استهدافه. يجب ان ياتي حصريا من متغيرات البيئة.

---

### 5. عدم وجود مهلة زمنية (Timeout) لاستدعاءات Supabase

**التصنيف:** حرج

**الوصف:** جميع استدعاءات `supabase.from().select()` و `supabase.rpc()` و `supabase.from().upsert()` لا تحتوي على اي مهلة زمنية. اذا تاخر السيرفر، سيعلق التطبيق بالكامل.

**الملفات المتاثرة:**
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\sync_api_service.dart` (كل العمليات)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\org_sync_service.dart` (كل العمليات)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\push_strategy.dart` (سطر 159-162)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\pull_strategy.dart` (سطر 155-157)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\bidirectional_strategy.dart` (سطر 224-227, 412-443)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\initial_sync.dart` (سطر 250-268)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\stock_delta_sync.dart` (سطر 77-84)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\screens\store_select_screen.dart` (سطر 197, 225, 354, 388)

**المخاطر:** انقطاع الاتصال او بطء السيرفر سيجمد الواجهة. Supabase SDK الافتراضي لا يحدد مهلة.

---

### 6. عدم التحقق من حجم بيانات الاستجابة

**التصنيف:** متوسط

**الوصف:** المزامنة الاولية (`InitialSync`) تحمل جداول كاملة بصفحات 500 سجل بدون حد اقصى، مما قد يؤدي لاستهلاك الذاكرة.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\initial_sync.dart`
```dart
// سطر 56
static const int pageSize = 500;

// سطر 216-238 - حلقة بدون حد اقصى
while (hasMore) {
  final records = await _fetchPage(...);
  // لا يوجد حد اقصى لعدد الصفحات
}
```

**المخاطر:** متجر لديه ملايين السجلات سيستهلك كل الذاكرة المتاحة اثناء المزامنة الاولية.

---

### 7. غياب التحقق من النوع (Type Safety) في استجابات RPC

**التصنيف:** متوسط

**الوصف:** استجابات `supabase.rpc()` تُعامل كـ `dynamic` ويتم تحويلها مباشرة بدون التحقق من الشكل.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\screens\store_select_screen.dart`
```dart
// سطر 197-200
final response = await supabase.rpc('get_my_stores');
final storesList = response as List? ?? [];
// لا يوجد تحقق من شكل كل عنصر

// سطر 203-213
return storesList.asMap().entries.map((entry) {
  final s = entry.value as Map<String, dynamic>;
  return BranchData(
    id: s['id'] as String,  // قد يفشل اذا كان null
    name: s['name'] as String? ?? '',
    // ...
  );
}).toList();
```

**المخاطر:** اي تغيير في شكل الاستجابة سيسبب انهيار التطبيق بـ `TypeError`.

---

### 8. Exponential Backoff بدون حد اقصى في SyncEngine

**التصنيف:** متوسط

**الوصف:** `SyncEngine` يعيد المحاولة كل 30 ثانية بدون اي backoff تصاعدي عند الفشل المتكرر.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\sync_engine.dart`
```dart
// سطر 123
static const Duration syncInterval = Duration(seconds: 30);

// سطر 336-341
_periodicTimer = Timer.periodic(syncInterval, (_) {
  if (_connectivity.isOnline && !_isLocked) {
    syncNow();  // يحاول كل 30 ثانية حتى لو فشلت المحاولات السابقة
  }
});
```

**ملاحظة:** رغم ان `PushStrategy` لديها backoff جيد (سطر 185-189)، المحرك المركزي لا يطبق ذلك.

**المخاطر:** اغراق السيرفر بطلبات متكررة عند حدوث خطأ مستمر (مثل مشكلة RLS).

---

### 9. عدم التحقق من صلاحية الجلسة في Realtime Listener

**التصنيف:** متوسط

**الوصف:** `RealtimeListener` لا يتحقق من صلاحية الجلسة (session validity) ولا يتعامل مع انتهاء الـ JWT اثناء الاستماع.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\realtime_listener.dart`
```dart
// سطر 86-103
Future<void> start({
  required String orgId,
  required String storeId,
}) async {
  // لا يوجد تحقق من الجلسة
  // لا يوجد اعادة اتصال عند انتهاء الـ JWT
  _isActive = true;
  for (final tableName in watchedTables) {
    await _subscribeToTable(tableName);
  }
}
```

**المخاطر:** عند انتهاء الـ JWT، ستتوقف الاحداث بصمت بدون اعلام المستخدم.

---

### 10. خطر تسريب معلومات الخطأ في الانتاج

**التصنيف:** متوسط

**الوصف:** خادم AI يكشف تفاصيل الخطأ في وضع Debug فقط، لكن Edge Functions تكشف رسائل الخطأ دائما.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\upload-product-images\index.ts`
```typescript
// سطر 99-105
} catch (error) {
    console.error('Upload error:', error)
    return new Response(
        JSON.stringify({ error: 'Upload failed', details: error.message }),
        // error.message قد يحتوي على تفاصيل حساسة
        { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
}
```

**ملف AI Server (جيد):** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\main.py`
```python
# سطر 56-58 - جيد: يخفي التفاصيل في الانتاج
"detail": str(exc) if settings.debug else "حدث خطأ غير متوقع",
```

---

### 11. عدم وجود Rate Limiting في AI API Client

**التصنيف:** متوسط

**الوصف:** عميل `AiApiService` في Flutter لا يحتوي على اي تحديد لمعدل الطلبات من جانب العميل.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\services\ai_api_service.dart`
```dart
// لا يوجد rate limiting في اي من الـ 15 نقطة نهاية
// مثال سطر 207-221
Future<Map<String, dynamic>> getSalesForecast({...}) async {
  return _post('/ai/forecast', {...});
  // يمكن استدعاؤها بشكل غير محدود
}
```

**ملاحظة:** خادم AI لا يحتوي ايضا على rate limiting middleware، فقط `public-products` Edge Function لديها rate limiting.

---

### 12. تكرار كود التنظيف (cleanPayload) في عدة ملفات

**التصنيف:** متوسط

**الوصف:** دالة `_cleanPayload` منسوخة في 4 ملفات مع اختلافات طفيفة.

**الملفات:**
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\sync_api_service.dart:72-82`
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\org_sync_service.dart:144-149`
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\push_strategy.dart:174-182`
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\bidirectional_strategy.dart:511-517`

**المخاطر:** تحديث في مكان واحد دون الاخرين يسبب تعارض في البيانات المرسلة.

---

### 13. عدم التحقق من حجم الصور قبل الرفع

**التصنيف:** متوسط

**الوصف:** `ImageService` لا يتحقق من حجم الصورة الاصلية قبل معالجتها.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\alhai_core\lib\src\services\image_service.dart`
```dart
// سطر 22-30
Future<ProductImageUrls> uploadProductImage({...}) async {
  try {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    // لا يوجد تحقق من الحجم - قد تكون 100MB
    // decodeImage لصورة كبيرة قد تستهلك كل الذاكرة
```

**المخاطر:** رفع صورة كبيرة جدا (مثلا 50MB+) سيستهلك كل ذاكرة الجهاز عند فك التشفير.

---

### 14. Edge Function upload-product-images بدون CORS Headers

**التصنيف:** متوسط

**الوصف:** دالة `upload-product-images` لا تضيف CORS headers في الاستجابة، مما يعني انها لن تعمل من تطبيق ويب.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\upload-product-images\index.ts`
```typescript
// سطر 86-98
return new Response(
    JSON.stringify({...}),
    { headers: { 'Content-Type': 'application/json' } }
    // لا يوجد corsHeaders
)
```

**مقارنة مع public-products (جيد):**
```typescript
// يستخدم corsHeaders في كل استجابة
{ headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
```

---

### 15. غياب Retry Logic في استدعاءات Supabase المباشرة

**التصنيف:** منخفض

**الوصف:** استدعاءات `supabase.rpc()` في `store_select_screen.dart` لا تحتوي على اعادة محاولة.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\screens\store_select_screen.dart`
```dart
// سطر 197 - بدون retry
final response = await supabase.rpc('get_my_stores');
```

**ملاحظة:** AI API Service لديها retry ممتاز (سطر 98-131). Supabase sync strategies لديها retry عبر sync_queue.

---

### 16. تسريب المفتاح الخاص في وضع التطوير (AI API)

**التصنيف:** منخفض

**الوصف:** عنوان خادم AI في وضع التطوير يكشف بنية الشبكة الداخلية.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\services\ai_api_service.dart`
```dart
// سطر 21-23
const String _kAiServerUrl = kDebugMode
    ? 'http://10.0.2.2:8000' // Android emulator -> host
    : 'https://ai.alhai.app'; // Production
```

**المخاطر:** منخفض - `kDebugMode` يمنع ظهوره في الانتاج. لكن يفضل نقل العناوين لمتغيرات البيئة.

---

### 17. عدم وجود API Versioning

**التصنيف:** منخفض

**الوصف:** لا يوجد ترقيم اصدارات في اي من نقاط النهاية.

**الملفات المتاثرة:**
- AI Server: `/ai/forecast` بدون `/v1/ai/forecast`
- Edge Functions: بدون ترقيم
- RPC Functions: بدون ترقيم

**المخاطر:** تحديث API سيكسر جميع العملاء القدامى بدون فترة انتقالية.

---

### 18. عدم تشفير Cache في AI API Service

**التصنيف:** منخفض

**الوصف:** `AiApiService` يحفظ نتائج AI في `SharedPreferences` بنص عادي.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\services\ai_api_service.dart`
```dart
// سطر 161-171
Future<void> _persistCache(String key, Map<String, dynamic> data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = jsonEncode({
      'data': data,  // بيانات AI تجارية حساسة بنص عادي
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString('ai_cache_$key', cacheData);
  }
}
```

**المخاطر:** بيانات تحليلية تجارية مخزنة بدون تشفير يمكن قراءتها من تطبيقات اخرى.

---

### 19. PendingOperationsManager يفقد العمليات عند اعادة التشغيل

**التصنيف:** منخفض

**الوصف:** `PendingOperationsManager` في `OfflineManager` يحفظ العمليات في الذاكرة فقط.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\offline\offline_manager.dart`
```dart
// سطر 286
final List<OfflineOperation> _operations = [];
// في الذاكرة فقط - تضيع عند اعادة التشغيل
```

**ملاحظة:** نظام sync_queue في قاعدة البيانات يحفظ العمليات بشكل دائم، لذا الخطر محدود. لكن العمليات المسجلة عبر `PendingOperationsManager` تضيع.

---

### 20. ConnectivityService يستخدم API قديم

**التصنيف:** منخفض

**الوصف:** `ConnectivityService` يستخدم `ConnectivityResult` المفرد بدلا من `List<ConnectivityResult>` الجديد في connectivity_plus 6.x.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\connectivity_service.dart`
```dart
// سطر 10
StreamSubscription<ConnectivityResult>? _subscription;
// connectivity_plus 6.x يرجع List<ConnectivityResult>
```

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\offline\offline_manager.dart`
```dart
// سطر 106
StreamSubscription<ConnectivityResult>? _subscription;
```

**المخاطر:** قد لا يتوافق مع الاصدارات الاحدث من connectivity_plus.

---

### 21. غياب Health Check للخدمات في SyncEngine

**التصنيف:** منخفض

**الوصف:** `SyncEngine` لا يفحص صحة Supabase قبل بدء المزامنة.

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\sync_engine.dart`
```dart
// سطر 188-209 - syncNow()
// يتحقق فقط من الاتصال بالانترنت وليس من توفر Supabase
if (_connectivity.isOffline) {
  return SyncEngineResult(success: false, errors: ['Device is offline']);
}
// لا يفحص هل Supabase متاح فعلا
```

---

## نقاط القوة الملاحظة

| النقطة | التفاصيل |
|--------|---------|
| بنية المزامنة | نظام مزامنة متقدم ب4 استراتيجيات (Pull/Push/Bidirectional/StockDelta) مع metadata tracking |
| Delta Sync للمخزون | حل ذكي لمشكلة تعارض المخزون بين اجهزة POS متعددة مع fallback |
| المصادقة | تعدد مسارات المصادقة (Supabase Auth + WhatsApp OTP + Local PIN) مع session monitoring |
| OTP Security | تشفير OTP بـ HMAC-SHA256 + salt + مقارنة ثابتة الوقت + rate limiting |
| Certificate Pinning | دعم SSL pinning في `SecureHttpClient` مع reject bad certificates في Release mode |
| Auth Interceptor | تجديد الـ token تلقائيا مع Completer لمنع التجديد المتزامن |
| Logging Interceptor | تسجيل شامل مع اخفاء البيانات الحساسة (masking) و correlation IDs |
| AI API Caching | نظام cache ذكي (memory + persistent) مع fallback عند عدم الاتصال |
| Edge Function Security | `public-products` يحتوي على rate limiting وتحقق من المتجر النشط |
| RPC Security | دوال RPC تستخدم `SECURITY DEFINER` مع فحص عضوية المتجر |
| AI Server Auth | تحقق JWT + فحص عضوية المتجر عبر `store_members` في كل طلب AI |
| Conflict Resolution | نظام حل تعارضات مرن (LastWriteWins / LocalWins / DeltaMerge) حسب نوع الجدول |
| Offline Support | دعم كامل للعمل بدون اتصال مع sync queue وautmatic reconnect |

---

## التوصيات مع اولوية التنفيذ

### اولوية حرجة (خلال اسبوع)

| # | التوصية | المشكلة |
|---|---------|---------|
| 1 | اضافة قائمة بيضاء (whitelist) لاسماء الجداول في جمل SQL الديناميكية | حقن SQL #1 |
| 2 | تقييد CORS في Edge Functions لنطاقات `alhai.app` و `alhai.sa` فقط | CORS مفتوح #2 |
| 3 | تعقيم متغير `search` في `public-products` باستخدام regex للحروف والارقام فقط | حقن بحث #3 |
| 4 | نقل عنوان Supabase URL من الكود الى متغيرات البيئة حصريا | كشف URL #4 |
| 5 | اضافة timeout لجميع استدعاءات Supabase (30 ثانية كحد اقصى) | غياب Timeout #5 |

**تنفيذ مقترح للمشكلة #1:**
```dart
// اضافة whitelist في sync_api_service.dart
static const _allowedTables = {
  'products', 'categories', 'customers', 'sales', 'sale_items',
  'orders', 'order_items', 'expenses', 'returns', 'purchases',
  // ... باقي الجداول
};

void _validateTableName(String tableName) {
  if (!_allowedTables.contains(tableName)) {
    throw ArgumentError('Invalid table name: $tableName');
  }
}
```

### اولوية عالية (خلال اسبوعين)

| # | التوصية | المشكلة |
|---|---------|---------|
| 6 | اضافة حد اقصى لعدد الصفحات في المزامنة الاولية (مثلا 200 صفحة) | حجم البيانات #6 |
| 7 | استخدام كائنات DTOs (Data Transfer Objects) مع تحقق Freezed لاستجابات RPC | Type Safety #7 |
| 8 | اضافة exponential backoff في SyncEngine عند الفشل المتكرر | Backoff #8 |
| 9 | فحص صلاحية الجلسة وتجديد JWT في RealtimeListener | جلسة Realtime #9 |
| 10 | اضافة CORS headers لدالة upload-product-images | CORS #14 |

### اولوية متوسطة (خلال شهر)

| # | التوصية | المشكلة |
|---|---------|---------|
| 11 | اخفاء `error.message` في استجابات Edge Functions في الانتاج | تسريب معلومات #10 |
| 12 | اضافة rate limiting في AI API client (مثلا 10 طلبات/دقيقة) | Rate Limiting #11 |
| 13 | توحيد `_cleanPayload` في مكان واحد واستيرادها | تكرار كود #12 |
| 14 | اضافة حد اقصى لحجم الصور (مثلا 10MB) قبل المعالجة | حجم الصور #13 |

### اولوية منخفضة (خلال 3 اشهر)

| # | التوصية | المشكلة |
|---|---------|---------|
| 15 | اضافة ترقيم اصدارات API (v1/v2) | Versioning #17 |
| 16 | تشفير cache بيانات AI في SharedPreferences | Cache تشفير #18 |
| 17 | تحديث ConnectivityService لـ connectivity_plus 6.x | API قديم #20 |
| 18 | اضافة health check لـ Supabase قبل المزامنة | Health Check #21 |

---

## التقييم النهائي

### التقييم: **6.5 / 10**

| الجانب | التقييم | ملاحظات |
|--------|---------|--------|
| بنية المزامنة | 9/10 | ممتازة - 4 استراتيجيات + delta sync + offline queue |
| معالجة الاخطاء | 7/10 | جيدة في sync، ضعيفة في RPC calls |
| المصادقة | 8/10 | متعددة المسارات مع session monitoring جيد |
| امان API | 5/10 | CORS مفتوح، حقن SQL محتمل، بيانات مكشوفة |
| Type Safety | 5/10 | ضعيف في RPC، جيد في Drift DAOs |
| Timeout/Retry | 6/10 | ممتاز في AI API، غائب في Supabase calls |
| Rate Limiting | 5/10 | موجود فقط في Edge Function واحدة + WhatsApp OTP |
| التوثيق | 8/10 | تعليقات عربية ممتازة في كود المزامنة |
| الاختبارات | 7/10 | تغطية جيدة في sync و auth مع mock helpers |
| الهيكلية | 8/10 | فصل ممتاز بين الاستراتيجيات والطبقات |

### الخلاصة

منصة الحي تمتلك بنية مزامنة API متقدمة تفوق معظم مشاريع POS. نظام المزامنة بالاستراتيجيات الاربع (Pull/Push/Bidirectional/StockDelta) مع offline support ممتاز. المصادقة متعددة المسارات وOTP security قوي.

المشاكل الرئيسية تتركز في:
1. **الامان**: CORS مفتوح + حقن SQL محتمل في اسماء الجداول + كشف بيانات حساسة
2. **المتانة**: غياب timeout في Supabase calls + type safety ضعيف في RPC responses
3. **قابلية التوسع**: غياب API versioning + rate limiting محدود

معالجة المشاكل الـ5 الحرجة ستصل بالتقييم الى 8/10.
