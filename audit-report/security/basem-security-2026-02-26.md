# تقرير التدقيق الأمني الشامل - منصة الحي (Alhai Platform)

**التاريخ:** 2026-02-26
**المدقق:** Basem Security Audit
**النسخة:** 1.0
**النطاق:** جميع الحزم والتطبيقات والخادم الخلفي (Backend)
**عدد ملفات Dart المفحوصة:** 1343+
**عدد ملفات SQL المفحوصة:** 10

---

## ملخص تنفيذي

منصة الحي (Alhai Platform) تُظهر مستوى أمني **جيد إلى جيد جداً** في معظم المجالات الأمنية الأساسية. الفريق اتبع ممارسات أمنية محترفة في عدة نقاط حساسة مثل: تخزين التوكنات في `flutter_secure_storage`، تشفير PIN باستخدام PBKDF2 مع Salt، تطبيق Row Level Security (RLS) شامل على جميع جداول Supabase (22 جدولاً)، واستخدام `SECURITY DEFINER` مع `SET search_path` في الدوال الحساسة.

ومع ذلك، تم اكتشاف عدد من الثغرات التي تتراوح بين الحرجة والمنخفضة، أبرزها: ثغرة SQL Injection محتملة في Edge Function، وثغرة XSS في توليد فواتير HTML، وسياسة CORS مفتوحة بالكامل (`*`) في Supabase Edge Functions.

### التقييم العام: 7.5 / 10

---

## جدول ملخص النتائج

| التصنيف | العدد | الوصف |
|---------|-------|-------|
| حرج | 3 | ثغرات تتطلب إصلاحاً فورياً |
| متوسط | 7 | ثغرات تتطلب إصلاحاً في الأسبوعين القادمين |
| منخفض | 6 | تحسينات أمنية مستحسنة |
| **المجموع** | **16** | |

---

## النتائج التفصيلية

---

### 1. حقن SQL (SQL Injection)

#### حرج: ثغرة SQL Injection في Edge Function `public-products`

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\public-products\index.ts`
**السطر:** 116

```typescript
query = query.or(`name.ilike.%${search}%,barcode.eq.${search},sku.eq.${search}`);
```

**المشكلة:** متغير `search` يأتي مباشرة من `url.searchParams.get('search')` (سطر 21) ويتم تضمينه في استعلام Supabase بدون أي تنظيف (sanitization). رغم أن مكتبة Supabase JS عادةً تتعامل مع الـ parameterization، فإن استخدام `query.or()` مع template literals قد يسمح بتمرير أنماط PostgREST خبيثة مثل تعديل شروط الـ filter أو حقن عوامل تصفية إضافية.

**التأثير:** يمكن للمهاجم التلاعب بنتائج البحث أو كشف بيانات غير مصرح بها من جدول products.

**التوصية:**
```typescript
// تنظيف المدخل قبل الاستخدام
const sanitizedSearch = search.replace(/[%_\\]/g, '\\$&');
query = query.or(`name.ilike.%${sanitizedSearch}%,barcode.eq.${sanitizedSearch},sku.eq.${sanitizedSearch}`);
```

**التصنيف:** حرج

---

#### منخفض: استخدام `customStatement` مع بيانات مُنظفة

**الملفات المتأثرة:**
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\pull_strategy.dart` (أسطر 196-213)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\strategies\bidirectional_strategy.dart` (أسطر 323, 503)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_sync\lib\src\realtime_listener.dart` (أسطر 200, 211)
- `C:\Users\basem\OneDrive\Desktop\Alhai\apps\admin\lib\screens\inventory\damaged_goods_screen.dart` (سطر 209)
- `C:\Users\basem\OneDrive\Desktop\Alhai\apps\admin\lib\screens\purchases\supplier_return_screen.dart` (أسطر 200, 216)
- `C:\Users\basem\OneDrive\Desktop\Alhai\apps\admin_lite\lib\providers\approval_providers.dart` (أسطر 90, 124)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_pos\lib\src\screens\pos\kiosk_screen.dart` (سطر 174)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\fts\products_fts.dart` (أسطر 23-74)

**المشكلة:** يتم استخدام `customStatement` و `customSelect` في عدة أماكن. الإيجابي أن معظم هذه الاستعلامات تستخدم **parameterized queries** (`?` مع `Variable.withString`). ومع ذلك، في `pull_strategy.dart` (سطر 209):

```dart
batch.customStatement(
  'INSERT INTO $tableName (${columns.join(', ')}) '
  'VALUES ($placeholders) '
  'ON CONFLICT(id) DO UPDATE SET $updates',
  columns.map((c) => record[c]).toList(),
);
```

متغيرات `tableName` و `columns` تأتي من بيانات السيرفر. إذا تم اختراق السيرفر، يمكن حقن أسماء جداول/أعمدة خبيثة. هذا خطر نظري لأن البيانات تأتي من Supabase (مصدر موثوق نسبياً).

**ملاحظة إيجابية:** البحث في FTS يُنظف الاستعلام بشكل ممتاز:
```dart
// products_fts.dart - سطر 214-217
var cleaned = query
    .trim()
    .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ');
```

**التصنيف:** منخفض

---

### 2. حماية XSS (Cross-Site Scripting)

#### حرج: ثغرة XSS في توليد فواتير HTML

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\alhai_services\lib\src\services\receipt_service.dart`
**الأسطر:** 109-131

```dart
buffer.writeln('<p>${settings!.receiptHeader}</p>');   // سطر 110
buffer.writeln('<h2>${store.name}</h2>');               // سطر 112
buffer.writeln('<p>${store.address}</p>');              // سطر 113
buffer.writeln('<p>هاتف: ${store.phone}</p>');          // سطر 114
buffer.writeln('<p>رقم الفاتورة: ${order.displayNumber}</p>'); // سطر 120
buffer.writeln('<p>الكاشير: $cashierName</p>');         // سطر 122
buffer.writeln('<span>${item.name}</span>');            // سطر 129
```

**المشكلة:** يتم تضمين بيانات من قاعدة البيانات (اسم المتجر، العنوان، اسم المنتج، اسم الكاشير، رأس/تذييل الفاتورة) مباشرة في HTML بدون أي تنظيف. إذا احتوت أي من هذه القيم على `<script>` أو أكواد HTML خبيثة، سيتم تنفيذها عند عرض الفاتورة.

**التأثير:** يمكن لمسؤول متجر خبيث حقن JavaScript في اسم المتجر أو رأس الفاتورة، مما يؤدي إلى سرقة بيانات عند عرض الفاتورة في متصفح أو WebView.

**التوصية:** استخدام `InputSanitizer.sanitizeHtml()` الموجود في المشروع:
```dart
buffer.writeln('<h2>${InputSanitizer.sanitizeHtml(store.name)}</h2>');
```

**ملاحظة إيجابية:** المشروع يحتوي على مُنظف HTML شامل في:
`C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_shared_ui\lib\src\core\validators\input_sanitizer.dart`

لكنه غير مُستخدم في `receipt_service.dart`.

**التصنيف:** حرج

---

#### منخفض: بناء JSON يدوي في kiosk_screen

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_pos\lib\src\screens\pos\kiosk_screen.dart`
**السطر:** 173

```dart
final itemsJson = '[${_cart.map((i) => '{"productId":"${i.productId}","name":"${i.name}","qty":${i.qty},"price":${i.price}}').join(',')}]';
```

**المشكلة:** بناء JSON يدوياً بدلاً من استخدام `jsonEncode`. إذا احتوى اسم المنتج على `"` أو `\`، سينكسر الـ JSON أو يُحدث سلوكاً غير متوقع.

**التوصية:** استخدام `jsonEncode`:
```dart
final itemsJson = jsonEncode(_cart.map((i) => {
  'productId': i.productId, 'name': i.name, 'qty': i.qty, 'price': i.price
}).toList());
```

**التصنيف:** منخفض

---

### 3. حماية CSRF

**الملف:** لا يوجد ملف خاص بـ CSRF

**المشكلة:** لا يوجد حماية CSRF مُطبقة بشكل صريح. المشروع يعتمد على Supabase Auth (JWT tokens في headers) مما يوفر حماية ضمنية ضد CSRF (لأن التوكن يُرسل في `Authorization` header وليس في cookies). لكن إذا تم استخدام cookies لاحقاً، ستحتاج إلى حماية صريحة.

**التصنيف:** منخفض (الحماية الحالية كافية بسبب استخدام Bearer tokens)

---

### 4. المصادقة (Authentication)

#### متوسط: إنشاء توكنات محلية بدون توقيع تشفيري

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\providers\auth_providers.dart`
**الأسطر:** 258-267

```dart
const uuid = Uuid();
final localAccessToken = 'session_${uuid.v4()}';
final localRefreshToken = 'refresh_${uuid.v4()}';

await SecureStorageService.saveTokens(
  accessToken: localAccessToken,
  refreshToken: localRefreshToken,
  expiry: expiry,
);
```

**المشكلة:** عند التحقق المحلي من OTP عبر WhatsApp (`verifyLocalOtp`)، يتم إنشاء توكنات محلية باستخدام UUID فقط. هذه التوكنات ليست JWT حقيقية وليست موقعة تشفيرياً، مما يعني:
1. لا يمكن للسيرفر التحقق من صحتها
2. أي شخص لديه وصول لـ Secure Storage يمكنه تزوير توكن
3. لا يوجد ارتباط بجلسة Supabase الحقيقية

**التأثير:** في الوضع المحلي (بدون Supabase)، يمكن تجاوز المصادقة بإنشاء توكن UUID يدوياً.

**التوصية:** ربط المصادقة المحلية دائماً بجلسة Supabase حقيقية عبر `signInWithOtp` أو استخدام HMAC لتوقيع التوكنات المحلية.

**التصنيف:** متوسط

---

#### ملاحظات إيجابية على المصادقة:

1. **تدفق OTP عبر Supabase Auth** (`sendSupabaseOtp` / `verifySupabaseOtp`) مُطبق بشكل صحيح (أسطر 310-372)
2. **مراقبة الجلسة** مع تحقق كل دقيقة وتجديد تلقائي للتوكن (أسطر 433-443)
3. **تسجيل أحداث الأمان** شامل عبر `SecurityLogger` (20+ نوع حدث)
4. **تنظيف كامل عند تسجيل الخروج** (مسح SecureStorage + إيقاف المراقبة + تسجيل خروج Supabase)

---

### 5. التفويض (Authorization) و Row Level Security

#### ملاحظات إيجابية (ممتازة):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\supabase_init.sql`

1. **RLS مُفعل على جميع الـ 22 جدول** (أسطر 744-767):
```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
-- ... (20 جدول آخر)
```

2. **دوال تحقق آمنة** مع `SECURITY DEFINER` و `SET search_path`:
```sql
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin');
$$;
```

3. **فصل الصلاحيات** بشكل ممتاز:
   - `is_store_member()` - للقراءة (cashier/manager/owner)
   - `is_store_admin()` - للكتابة (manager/owner + super_admin)
   - `is_super_admin()` - للعمليات الإدارية

4. **حماية تغيير الأدوار** عبر trigger `prevent_direct_role_update()` (أسطر 544-556) ودالة RPC مُقيدة `update_user_role()` (أسطر 630-683)

5. **REVOKE شامل** للعمليات الحساسة (أسطر 720-738):
```sql
REVOKE ALL ON public.role_audit_log FROM anon, authenticated;
REVOKE UPDATE ON public.stock_adjustments FROM authenticated, anon;
REVOKE DELETE ON public.stock_adjustments FROM authenticated, anon;
```

6. **حماية تغيير store_id** عبر trigger (أسطر 558-569)

7. **تشديد صلاحيات الكتابة** في الهجرة `20260223_tighten_rls_write_policies.sql`:
   - تم تحويل `is_store_member` إلى `is_store_admin` لعمليات INSERT/UPDATE/DELETE

#### متوسط: سياسة القراءة العامة للمتاجر

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\supabase_init.sql`
**الأسطر:** 803-805

```sql
CREATE POLICY "stores_public_read_active" ON public.stores FOR SELECT
USING (is_active = true);
```

**المشكلة:** أي مستخدم مجهول (`anon`) يمكنه قراءة بيانات جميع المتاجر النشطة بما فيها رقم الهاتف والبريد الإلكتروني والعنوان. قد يكون هذا مقصوداً لتطبيق العملاء، لكنه يكشف بيانات تجارية حساسة.

**التوصية:** تقييد الأعمدة المرئية للعامة عبر View أو إخفاء الأعمدة الحساسة (tax_number, commercial_reg, email) من السياسة العامة.

**التصنيف:** متوسط

---

### 6. أمان API

#### حرج: سياسة CORS مفتوحة في Edge Functions

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\_shared\cors.ts`
**الأسطر:** 1-5

```typescript
export const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-correlation-id, x-user-id, x-store-id',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
};
```

**المشكلة:** `Access-Control-Allow-Origin: *` يسمح لأي موقع ويب بإرسال طلبات API مما يُسهل هجمات CSRF وسرقة البيانات من المتصفح. هذا خطير بشكل خاص لأن الـ headers المسموحة تشمل `authorization` و `apikey`.

**التأثير:** أي موقع خبيث يمكنه إرسال طلبات مُصادق عليها نيابة عن المستخدم إذا كان مسجلاً الدخول.

**التوصية:**
```typescript
export const corsHeaders = {
    'Access-Control-Allow-Origin': 'https://your-app-domain.com',
    // أو قائمة محددة من الأصول المسموحة
};
```

**ملاحظة إيجابية:** خادم AI (`ai_server/main.py`) يستخدم CORS مُقيد بشكل صحيح:
```python
allow_origins=settings.cors_origins,  # من ملف .env
```

**التصنيف:** حرج

---

#### متوسط: headers حساسة مكشوفة في CORS

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\_shared\cors.ts`
**السطر:** 3

```typescript
'Access-Control-Allow-Headers': '... x-user-id, x-store-id',
```

**المشكلة:** السماح بـ `x-user-id` و `x-store-id` كـ custom headers قد يسمح بتزوير الهوية إذا اعتمد أي كود على هذه الـ headers بدلاً من JWT.

**التوصية:** إزالة `x-user-id` و `x-store-id` واستخدام JWT لاستخراج الهوية.

**التصنيف:** متوسط

---

### 7. التشفير

#### ملاحظات إيجابية:

1. **تشفير PIN باستخدام PBKDF2** (100,000 تكرار، Salt 32 بايت):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\pin_service.dart`
**الأسطر:** 258-295

```dart
const int kPbkdf2Iterations = 100000;
const int kSaltLength = 32;
const int kDerivedKeyLength = 32;
```

2. **مقارنة ثابتة الوقت** لمنع هجمات التوقيت:
```dart
// pin_service.dart سطر 306-313
static bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}
```

3. **تشفير OTP باستخدام HMAC-SHA256 مع Salt عشوائي**:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\services\whatsapp_otp_service.dart`
**الأسطر:** 419-423

4. **توليد مفاتيح آمنة** باستخدام `Random.secure()`:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\secure_storage_service.dart`
**الأسطر:** 213-217

```dart
static String _generateSecureKey(int length) {
  final random = Random.secure();
  final values = List<int>.generate(length, (_) => random.nextInt(256));
  return base64Url.encode(values);
}
```

5. **ترحيل PIN القديم** من SHA256 إلى PBKDF2 (نظام إصدارات):
```dart
// pin_service.dart سطر 52
static const int _currentVersion = 2; // v1 = SHA256, v2 = PBKDF2
```

---

### 8. التخزين الآمن

#### ملاحظات إيجابية (ممتازة):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\secure_storage_service.dart`

1. **استخدام `flutter_secure_storage`** مع إعدادات أمنية قوية:
```dart
static const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,  // تشفير كامل على Android
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,  // حماية iOS Keychain
  ),
);
```

2. **جميع البيانات الحساسة** (tokens, PIN hash, OTP data, session expiry) تُخزن في SecureStorage وليس SharedPreferences

#### متوسط: بيانات غير حساسة في SharedPreferences بشكل صحيح

**الملفات المتأثرة:**
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\providers\theme_provider.dart` (سطر 60, 86)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\src\locale_provider.dart` (سطر 142, 168)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_shared_ui\lib\src\providers\cashier_mode_provider.dart` (سطر 55, 64)

**الحالة:** SharedPreferences يُستخدم فقط لتفضيلات غير حساسة (اللغة، الثيم، وضع الكاشير) وهذا صحيح. لا توجد بيانات حساسة في SharedPreferences.

**التصنيف:** لا توجد مشكلة

---

### 9. إدارة التوكنات (Token Management)

#### ملاحظات إيجابية:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\session_manager.dart`

1. **مدة جلسة محدودة** (30 دقيقة) مع تجديد تلقائي:
```dart
static const sessionDuration = Duration(minutes: 30);
static const tokenRefreshBuffer = Duration(minutes: 5);
```

2. **تخزين منفصل** لـ Access Token و Refresh Token و Session Expiry

3. **تنظيف كامل** عند انتهاء الجلسة أو تسجيل الخروج:
```dart
static Future<void> clearSession() async {
  await Future.wait([
    _storage.delete(key: _keyAccessToken),
    _storage.delete(key: _keyRefreshToken),
    _storage.delete(key: _keySessionExpiry),
    _storage.delete(key: _keyUserId),
    _storage.delete(key: _keyStoreId),
  ]);
}
```

4. **Cache في الذاكرة** للسرعة مع تحديث فوري عند التغيير

#### متوسط: عدم التحقق من صحة JWT على العميل

**المشكلة:** التوكنات تُخزن وتُرسل لكن لا يتم التحقق من صحتها (signature validation) على العميل. هذا سلوك مقبول لأن التحقق يتم على السيرفر (Supabase)، لكن يُفضل إضافة فحص أولي لانتهاء صلاحية JWT محلياً لتجنب طلبات فاشلة.

**التصنيف:** متوسط (منخفض الأولوية)

---

### 10. تحديد معدل الطلبات (Rate Limiting)

#### ملاحظات إيجابية:

1. **Rate Limiting لـ OTP** (client-side):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\services\whatsapp_otp_service.dart`
- 10 طلبات إرسال في الساعة (`maxSendRequestsPerHour`)
- 3 محاولات تحقق (`maxVerifyAttempts`)
- 60 ثانية بين عمليات إعادة الإرسال (`resendCooldownSeconds`)
- تأخير 100ms ضد brute-force (سطر 349)

2. **Rate Limiting لـ PIN** (client-side):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\pin_service.dart`
- 5 محاولات قبل القفل (`kMaxPinAttempts`)
- قفل 15 دقيقة (`kLockoutDuration`)

3. **Rate Limiting في Edge Function**:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\public-products\index.ts` (أسطر 4-8)
- 100 طلب في الدقيقة لكل IP + store_id

#### متوسط: Rate Limiting على العميل فقط لـ OTP

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\security\otp_service.dart`
**الأسطر:** 10-18 (التعليق التوثيقي يعترف بالمشكلة)

```dart
/// Rate Limiting هنا يعمل على مستوى Client فقط!
/// يمكن تجاوزه بإعادة تثبيت التطبيق أو مسح البيانات.
///
/// للحماية الكاملة، يجب تطبيق Rate Limiting على مستوى الـ Server أيضاً
```

**المشكلة:** Rate Limiting لـ OTP و PIN يعمل على الـ client فقط ويمكن تجاوزه بمسح بيانات التطبيق. التعليقات في الكود تعترف بهذه المشكلة لكن لم يتم تنفيذ الحل الخادمي.

**التوصية:** تفعيل Rate Limiting على مستوى Supabase (Redis أو Edge Function middleware).

**التصنيف:** متوسط

---

### 11. تكوين CORS

#### حرج: CORS مفتوح (مذكور سابقاً في القسم 6)

#### إيجابي: خادم AI مُقيد بشكل صحيح

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\config.py`
**الأسطر:** 23-28

```python
allowed_origins: str = "http://localhost:3000,http://localhost:8080"

@property
def cors_origins(self) -> list[str]:
    return [o.strip() for o in self.allowed_origins.split(",")]
```

---

### 12. إدارة الجلسات

#### ملاحظات إيجابية:

1. **مراقبة مستمرة** للجلسة كل دقيقة
2. **4 حالات واضحة** للجلسة: `valid`, `needsRefresh`, `expired`, `notAuthenticated`
3. **تجديد تلقائي** قبل 5 دقائق من الانتهاء
4. **تنظيف شامل** عند الانتهاء

#### منخفض: عدم وجود حد أقصى لعدد الجلسات المتزامنة

**المشكلة:** لا يوجد آلية لتتبع عدد الأجهزة المسجلة في نفس الوقت. يمكن لحساب واحد أن يكون مسجلاً على عدد غير محدود من الأجهزة.

**التوصية:** إضافة جدول `active_sessions` وتحديد حد أقصى (مثلاً 3 أجهزة).

**التصنيف:** منخفض

---

### 13. الأسرار المُضمنة في الكود (Hardcoded Secrets)

#### متوسط: عنوان Supabase URL مكشوف في ملف Python

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\config.py`
**السطر:** 11

```python
supabase_url: str = "https://jtgwboqushihwvvsdtud.supabase.co"
```

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\.env.example`
**السطر:** 2

```
SUPABASE_URL=https://jtgwboqushihwvvsdtud.supabase.co
```

**المشكلة:** عنوان مشروع Supabase مكشوف كقيمة افتراضية في `config.py` وفي `.env.example`. رغم أن Supabase URL ليس سراً بحد ذاته (لأنه يُستخدم مع anon key)، إلا أن كشفه يُسهل استهداف المشروع.

**ملاحظة إيجابية:** جميع المفاتيح الحساسة في Flutter تُمرر عبر `String.fromEnvironment` ولا تُضمن في الكود:

```dart
// supabase_config.dart
static const String url = String.fromEnvironment('SUPABASE_URL');
static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// whatsapp_config.dart
static const String apiToken = String.fromEnvironment('WASENDER_API_TOKEN');
```

#### إيجابي: `.gitignore` يحمي ملفات البيئة

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\.gitignore`
**الأسطر:** 30-35

```
.env
.env.local
.env.*.local
*.key
*.pem
```

**التصنيف:** متوسط

---

#### متوسط: معرّف متجر افتراضي مُضمن في الكود

**الملفات المتأثرة:**
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\providers\auth_providers.dart` (سطر 22)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\providers\ai_assistant_providers.dart` (سطر 76)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\providers\ai_chat_with_data_providers.dart` (سطر 53)
- `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\providers\ai_basket_analysis_providers.dart` (سطر 22)

```dart
const String kDefaultStoreId = 'b10f215e-2c70-4832-a37e-a42a74406a8d';
// ...
final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
```

**المشكلة:** يتم استخدام `store_demo_001` كقيمة احتياطية في عدة أماكن بحزمة AI. إذا لم يتم تعيين `currentStoreIdProvider`، يتم استخدام معرّف ثابت قد يسمح بالوصول لبيانات متجر آخر.

**التوصية:** رمي استثناء بدلاً من استخدام قيمة افتراضية:
```dart
final storeId = ref.read(currentStoreIdProvider) ?? (throw StateError('Store ID not set'));
```

**التصنيف:** متوسط

---

### 14. تنظيف المدخلات (Input Sanitization)

#### ملاحظات إيجابية (جيد جداً):

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_shared_ui\lib\src\core\validators\input_sanitizer.dart`

المشروع يحتوي على مُنظف مدخلات شامل يغطي:
1. **تنظيف XSS** (`sanitizeHtml`) - أسطر 28-34
2. **تنظيف SQL** (`sanitizeForDb`) - أسطر 43-57
3. **تنظيف Shell** (`sanitizeForShell`) - أسطر 61-64
4. **تنظيف Path Traversal** (`sanitizePath`) - أسطر 67-78
5. **تنظيف أسماء الملفات** (`sanitizeFilename`) - أسطر 81-92
6. **تنظيف URL** (`sanitizeUrl`) - أسطر 95-105 (يمنع `javascript:`, `data:`, `vbscript:`)
7. **تنظيف الهاتف** (`sanitizePhone`) - سطر 121
8. **تنظيف البريد** (`sanitizeEmail`) - سطر 127
9. **كشف المحتوى الخطر** (`containsDangerousContent`) - أسطر 164-186
10. **Extension methods** لسهولة الاستخدام (`String.sanitizedHtml`, `String.sanitizedForDb`, إلخ)

#### منخفض: عدم إجبار استخدام المُنظف في كل مكان

**المشكلة:** رغم وجود `InputSanitizer` الشامل، لا يوجد آلية لإجبار استخدامه. بعض الأماكن (مثل `receipt_service.dart`) لا تستخدمه.

**التوصية:** إنشاء lint rule أو wrapper للـ Text widgets يُجبر على تنظيف المدخلات من المستخدم.

**التصنيف:** منخفض

---

### 15. تثبيت الشهادات (Certificate Pinning)

#### ملاحظات إيجابية:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_auth\lib\src\core\network\secure_http_client.dart`

1. **Certificate Pinning مُطبق** باستخدام SHA-256 fingerprint (أسطر 83-107):
```dart
static void _applyCertificatePinning(Dio dio, String fingerprint) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      final certFingerprint = _getCertificateFingerprint(cert);
      final isValid = certFingerprint.toLowerCase() ==
          fingerprint.toLowerCase().replaceAll(':', '');
      return isValid;
    };
    return client;
  };
}
```

2. **Fingerprints من Environment Variables** (لا تُضمن في الكود):
```dart
static const String supabase = String.fromEnvironment('SUPABASE_CERT_FINGERPRINT');
static const String wasender = String.fromEnvironment('WASENDER_CERT_FINGERPRINT');
```

3. **رفض الشهادات غير الموثوقة** في Release mode بدون fingerprint:
```dart
if (kReleaseMode) {
  _rejectBadCertificates(dio);  // رفض كل شهادة مشكوك فيها
}
```

4. **Retry مع Exponential Backoff** (1s, 2s, 4s):
```dart
final delayMs = 1000 * (1 << retryCount);
```

#### متوسط: Certificate Pinning لا يعمل على الويب

**السطر:** 62

```dart
if (!kIsWeb) {
  // Certificate Pinning فقط للـ native platforms
```

**المشكلة:** Certificate Pinning غير مُطبق على منصة الويب بسبب قيود المتصفح. هذا قيد تقني معروف لكن يترك نسخة الويب أقل أماناً.

**التصنيف:** متوسط (قيد تقني، لا يوجد حل عملي)

---

## ملخص أمني إضافي

### حماية قاعدة البيانات (Supabase)

| الجدول | RLS | سياسات القراءة | سياسات الكتابة | REVOKE |
|--------|-----|---------------|---------------|--------|
| users | نعم | self + superadmin | self + superadmin | - |
| stores | نعم | public(active) + member + admin | owner + superadmin | - |
| store_members | نعم | self + member + admin | admin + superadmin | store_id |
| products | نعم | member | admin | store_id |
| categories | نعم | member | admin | - |
| orders | نعم | customer + member | customer(created) + member | - |
| order_items | نعم | via order | member(created) | - |
| role_audit_log | نعم | superadmin only | REVOKED | ALL |
| stock_adjustments | نعم | member | admin | UPDATE, DELETE |
| activity_logs | نعم | admin | member(INSERT only) | UPDATE, DELETE |
| shifts | نعم | cashier(own) + member | member(self) + admin | - |

### نقاط القوة الأمنية

1. **فصل الملفات الحساسة**: `supabase_owner_only.sql` منفصل عن الهجرات العادية
2. **حماية ضد RLS Recursion**: `fix_rls_recursion.sql` يستخدم `SECURITY DEFINER` functions
3. **Trigger لمنع تغيير store_id** على الجداول الحساسة
4. **نظام تدقيق** (`role_audit_log`, `activity_logs`) مع حماية من الحذف
5. **حماية المخزون** عبر trigger `deduct_stock_on_order_confirm` مع `FOR UPDATE` lock
6. **pgcrypto** مُفعل لتوليد UUID آمن

---

## التوصيات مرتبة حسب الأولوية

### أولوية فورية (هذا الأسبوع)

| # | التوصية | الملف المتأثر | التصنيف |
|---|---------|--------------|---------|
| 1 | إصلاح CORS: تغيير `*` إلى أصول محددة | `supabase/functions/_shared/cors.ts` | حرج |
| 2 | تنظيف `search` parameter في Edge Function | `supabase/functions/public-products/index.ts:116` | حرج |
| 3 | استخدام `InputSanitizer.sanitizeHtml()` في `receipt_service` | `alhai_services/lib/src/services/receipt_service.dart` | حرج |

### أولوية عالية (أسبوعين)

| # | التوصية | الملف المتأثر | التصنيف |
|---|---------|--------------|---------|
| 4 | إضافة Rate Limiting على السيرفر لـ OTP | Supabase Edge Function جديدة | متوسط |
| 5 | ربط المصادقة المحلية بجلسة Supabase حقيقية | `auth_providers.dart:258-267` | متوسط |
| 6 | تقييد الأعمدة المرئية في سياسة المتاجر العامة | `supabase_init.sql:803` | متوسط |
| 7 | إزالة `x-user-id` و `x-store-id` من CORS headers | `cors.ts:3` | متوسط |
| 8 | إزالة Supabase URL الافتراضي من `config.py` | `ai_server/config.py:11` | متوسط |
| 9 | استبدال `store_demo_001` بـ StateError | حزمة `alhai_ai` | متوسط |
| 10 | إضافة فحص JWT expiry محلي | `auth_providers.dart` | متوسط |

### أولوية متوسطة (شهر)

| # | التوصية | الملف المتأثر | التصنيف |
|---|---------|--------------|---------|
| 11 | استخدام `jsonEncode` بدل بناء JSON يدوي | `kiosk_screen.dart:173` | منخفض |
| 12 | تقييد أسماء الجداول في sync strategies | `pull_strategy.dart:209` | منخفض |
| 13 | إضافة حد أقصى للجلسات المتزامنة | جدول جديد `active_sessions` | منخفض |
| 14 | إنشاء lint rule لإجبار InputSanitizer | `analysis_options.yaml` | منخفض |
| 15 | إضافة CSP headers لنسخة الويب | `web/index.html` | منخفض |
| 16 | تدوير Certificate fingerprints تلقائياً | CI/CD pipeline | منخفض |

---

## التقييم النهائي

| المجال | التقييم (من 10) | ملاحظات |
|--------|-----------------|---------|
| SQL Injection | 8/10 | Drift parameterized queries ممتاز، Edge Function تحتاج إصلاح |
| XSS Protection | 6/10 | InputSanitizer ممتاز لكن غير مُستخدم في كل مكان |
| CSRF Protection | 8/10 | Bearer tokens توفر حماية ضمنية جيدة |
| Authentication | 8/10 | Supabase Auth + OTP + Biometric + PIN |
| Authorization / RLS | 9/10 | شامل ومُحكم مع دوال تحقق آمنة |
| API Security | 5/10 | CORS `*` مشكلة كبيرة |
| Encryption | 9/10 | PBKDF2 + HMAC-SHA256 + SecureStorage |
| Secure Storage | 9/10 | flutter_secure_storage مع إعدادات مثالية |
| Token Management | 8/10 | جلسات محدودة + تجديد تلقائي + تنظيف |
| Rate Limiting | 7/10 | موجود لكن client-side فقط |
| CORS | 4/10 | مفتوح بالكامل في Edge Functions |
| Session Management | 8/10 | مراقبة + تجديد + تنظيف |
| Hardcoded Secrets | 8/10 | fromEnvironment ممتاز، URL مكشوف واحد |
| Input Sanitization | 7/10 | شامل لكن غير مُجبر |
| Certificate Pinning | 8/10 | مُطبق على native، غير متاح على web |

### **التقييم العام: 7.5 / 10**

المشروع يُظهر وعياً أمنياً عالياً مع تطبيق ممتاز في معظم المجالات. الإصلاحات الثلاثة الحرجة (CORS, Edge Function SQL, Receipt XSS) ستُرفع التقييم إلى **8.5/10** أو أعلى.

---

*تم إعداد هذا التقرير بتاريخ 2026-02-26 ويُغطي حالة الكود في وقت الفحص.*
