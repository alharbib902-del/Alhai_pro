# تقرير تدقيق التحقق من المدخلات - منصة الحي الذكي (Alhai Platform)

**التاريخ:** 2026-02-26
**المدقق:** باسم
**النموذج:** Claude Opus 4.6
**النطاق:** جميع حزم المنصة (1343+ ملف Dart)

---

## ملخص تنفيذي

تمتلك منصة الحي الذكي **نظام تحقق مركزي متقدم ومصمم بشكل احترافي** في حزمة `alhai_shared_ui` يغطي معظم أنواع المدخلات الشائعة (هاتف، بريد إلكتروني، أسعار، باركود، IBAN، رقم ضريبي، سجل تجاري). كما يوجد نظام تحقق موازي في `alhai_design_system` يوفر validators و input formatters إضافية. النظامان مصممان بمعايير أمان عالية تشمل حماية من XSS وSQL Injection وPath Traversal.

**ومع ذلك، هناك ثغرات في التطبيق الفعلي:**
- بعض الشاشات تستخدم التحقق البسيط (`isEmpty` فقط) بدلا من المركزي
- وجود استدعاءات `int.parse()` و `double.parse()` بدون `try-catch` قد تسبب انهيار التطبيق
- بعض النماذج لا تطبق `InputSanitizer` قبل الحفظ في قاعدة البيانات
- نظام التحقق من كلمة المرور موجود لكن لا يفرض القوة الافتراضية

### التقييم العام: 7.5 / 10

---

## جدول ملخص بالارقام

| المقياس | القيمة |
|---------|--------|
| اجمالي ملفات Dart | 1343+ |
| ملفات التحقق المركزية | 9 ملفات |
| ملفات الاختبار للتحقق | 8 ملفات (318 حالة اختبار) |
| النماذج التي تستخدم FormKey | 9 شاشات |
| الشاشات التي تستخدم InputSanitizer | 11 شاشة |
| استدعاءات int.parse غير الامنة | 22 موقع |
| استدعاءات double.parse غير الامنة | 14 موقع |
| استدعاءات DateTime.parse غير الامنة | 30+ موقع |

### توزيع المشاكل

| التصنيف | العدد |
|---------|-------|
| حرج | 4 |
| متوسط | 8 |
| منخفض | 7 |
| **المجموع** | **19** |

---

## النتائج التفصيلية

---

### 1. نظام التحقق المركزي (نقاط القوة)

#### 1.1 بنية ValidationResult الموحدة

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/validation_result.dart`

```dart
// سطر 10-46
class ValidationResult {
  final bool isValid;
  final String? errorAr;
  final String? errorEn;
  final String? errorCode;
  // ...
  const ValidationResult.failure({
    required String messageAr,
    required String messageEn,
    String? code,
  });
}
```

**تقييم:** ممتاز - رسائل خطا ثنائية اللغة مع اكواد تتبع.

#### 1.2 التحقق من البريد الالكتروني

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/email_validator.dart`

```dart
// سطر 14-17
static final RegExp _emailPattern = RegExp(
  r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
  r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
  r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
);
```

**تقييم:** جيد جدا - يتبع RFC 5322 مع فحص الطول (254 حرف)، فحص domain، فحص TLD، وقائمة المزودين المؤقتين.

#### 1.3 التحقق من الهاتف السعودي

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/phone_validator.dart`

```dart
// سطر 17-26
static final RegExp _mobilePattern = RegExp(r'^05\d{8}$');
static final RegExp _mobileWithCountryPattern = RegExp(r'^(\+966|00966)5\d{8}$');
static final RegExp _landlinePattern = RegExp(r'^01\d{7}$');
```

**تقييم:** جيد - يدعم الصيغة المحلية والدولية والهاتف الثابت مع دوال تنسيق.

#### 1.4 التحقق من الاسعار والكميات

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/price_validator.dart`

```dart
// سطر 15-22
static const int maxDecimalPlaces = 2;
static const double maxPrice = 1000000.0;
static const double minPrice = 0.0;
```

**تقييم:** ممتاز - يتحقق من: القيم السالبة، الصفر، الحد الاقصى، المنازل العشرية، مع دعم `tryParse` الامن.

#### 1.5 التحقق من الباركود

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/barcode_validator.dart`

**تقييم:** ممتاز - يدعم EAN-13, EAN-8, UPC-A, Code 128 مع checksum verification حقيقي.

#### 1.6 التحقق من IBAN السعودي

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/iban_validator.dart`

**تقييم:** ممتاز - يتحقق من MOD 97 checksum، رمز البنك، الطول (24 حرف)، مع قائمة البنوك السعودية.

#### 1.7 تنظيف المدخلات (InputSanitizer)

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/input_sanitizer.dart`

```dart
// سطر 28-34 - HTML Sanitization
static String sanitizeHtml(String input) {
  var result = input;
  for (final entry in _htmlEntities.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

// سطر 43-57 - DB Sanitization
static String sanitizeForDb(String input) {
  var result = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  result = result
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "''")
      // ...
}

// سطر 164-186 - كشف المحتوى الخطر
static bool containsDangerousContent(String input) {
  // فحص scripts, SQL injection patterns
}
```

**تقييم:** جيد جدا - يغطي XSS, SQL Injection, Command Injection, Path Traversal مع extension methods سهلة الاستخدام.

#### 1.8 تنسيق المدخلات (Input Formatters)

**الملف:** `alhai_design_system/lib/src/utils/input_formatters.dart`

**تقييم:** ممتاز - formatters متخصصة للهاتف السعودي، العملة، الكمية، OTP مع حماية من overflow.

---

### 2. المشاكل الحرجة

---

#### 2.1 استخدام `double.parse()` بدون try-catch في حفظ المنتجات

**التصنيف:** حرج

**الملف:** `apps/admin/lib/screens/products/product_form_screen.dart`

```dart
// سطر 742
price: double.parse(priceText),

// سطر 771
price: drift.Value(double.parse(priceText)),
```

**الملف:** `apps/cashier/lib/screens/products/quick_add_product_screen.dart`

```dart
// سطر 526-527
final price = double.parse(_priceController.text);
final quantity = int.parse(_quantityController.text);
```

**المشكلة:** اذا فشل التحقق من النموذج لسبب ما (race condition، تعديل برمجي للنص) فان `double.parse` و `int.parse` ستطلقان `FormatException` وقد يتعطل التطبيق. الشاشة تستخدم `_formKey.currentState!.validate()` قبل ذلك، لكن هذا لا يحمي 100% من الاخطاء.

**التوصية:** استبدال `double.parse` بـ `double.tryParse` مع قيمة افتراضية:
```dart
final price = double.tryParse(priceText) ?? 0.0;
```

---

#### 2.2 استخدام `int.parse()` بدون try-catch في تحليل الوقت

**التصنيف:** حرج

**الملف:** `alhai_core/lib/src/models/store.dart`

```dart
// سطر 62
return int.parse(parts[0]) * 60 + int.parse(parts[1]);
```

**المشكلة:** تحليل وقت العمل (HH:MM) يستخدم `int.parse` مباشرة. اذا كانت البيانات من قاعدة البيانات تالفة او بصيغة غير متوقعة، سيتعطل التطبيق. الدالة تتحقق من `parts.length != 2` لكن لا تتحقق من ان القيم ارقام صالحة.

**التوصية:**
```dart
final hours = int.tryParse(parts[0]);
final minutes = int.tryParse(parts[1]);
if (hours == null || minutes == null) return null;
return hours * 60 + minutes;
```

---

#### 2.3 استخدام `DateTime.parse()` بدون try-catch في 30+ موقع

**التصنيف:** حرج

**الملفات المتاثرة:**
- `alhai_core/lib/src/dto/products/product_response.dart` (سطر 65-66)
- `alhai_core/lib/src/dto/auth/auth_response.dart` (سطر 36)
- `alhai_core/lib/src/dto/auth/auth_tokens_response.dart` (سطر 27)
- `alhai_core/lib/src/dto/suppliers/supplier_response.dart` (سطر 52-53)
- `alhai_core/lib/src/dto/stores/store_response.dart` (سطر 62-63)
- `alhai_core/lib/src/dto/purchases/purchase_order_response.dart` (سطر 71-74)
- `alhai_core/lib/src/services/sync_queue_service.g.dart` (سطر 20-82)
- `packages/alhai_sync/lib/src/strategies/bidirectional_strategy.dart` (سطر 371-386)
- `alhai_services/lib/src/services/backup_service.dart` (سطر 149)
- `packages/alhai_shared_ui/lib/src/widgets/common/user_feedback.dart` (سطر 38)

**المشكلة:** `DateTime.parse()` تطلق `FormatException` اذا كان النص غير صالح. في حالة البيانات القادمة من API خارجي او قاعدة بيانات، قد تكون القيم تالفة.

**التوصية:** استخدام `DateTime.tryParse()` مع fallback:
```dart
createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
```

---

#### 2.4 عدم تنظيف المدخلات في receiving_goods_screen

**التصنيف:** حرج

**الملف:** `apps/admin/lib/screens/purchases/receiving_goods_screen.dart`

```dart
// سطر 590-591
'receivedBy': _receiverNameController.text.trim(),
'receiveNotes': _notesController.text.trim(),
```

**المشكلة:** البيانات تُحفظ في قاعدة البيانات بدون اي تنظيف (sanitization). اسم المستلم والملاحظات يمكن ان تحتوي على محتوى خطر. بالمقارنة، شاشة الموردين (`supplier_form_screen.dart`) تستخدم `InputSanitizer.sanitize()` بشكل صحيح.

**التوصية:** اضافة `InputSanitizer.sanitize()` قبل الحفظ:
```dart
'receivedBy': InputSanitizer.sanitize(_receiverNameController.text.trim()),
'receiveNotes': InputSanitizer.sanitize(_notesController.text.trim()),
```

---

### 3. المشاكل المتوسطة

---

#### 3.1 التحقق البسيط في quick_add_product_screen بدلا من المركزي

**التصنيف:** متوسط

**الملف:** `apps/cashier/lib/screens/products/quick_add_product_screen.dart`

```dart
// سطر 206-207 - التحقق من الاسم
validator: (v) =>
    (v == null || v.isEmpty) ? l10n.requiredField : null,

// سطر 350-353 - التحقق من السعر
validator: (v) {
  if (v == null || v.isEmpty) return l10n.requiredField;
  if (double.tryParse(v) == null) return l10n.enterValidAmount;
  return null;
},

// سطر 394-397 - التحقق من الكمية
validator: (v) {
  if (v == null || v.isEmpty) return l10n.requiredField;
  if (int.tryParse(v) == null) return l10n.enterValidAmount;
  return null;
},
```

**المشكلة:** التحقق من الاسم لا يتحقق من:
- الحد الاقصى للطول
- المحتوى الخطر (XSS/Injection)
- الاحرف المسموحة

التحقق من السعر لا يتحقق من:
- القيم السالبة
- القيمة صفر
- الحد الاقصى
- عدد المنازل العشرية

**التوصية:** استخدام `FormValidators.requiredField()` و `FormValidators.price()` من النظام المركزي بدلا من التحقق اليدوي.

---

#### 3.2 حقل الباركود بدون validator في quick_add_product_screen

**التصنيف:** متوسط

**الملف:** `apps/cashier/lib/screens/products/quick_add_product_screen.dart`

```dart
// سطر 275-283
child: TextFormField(
  controller: _barcodeController,
  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
  decoration: _inputDecoration(
    l10n.barcode,
    Icons.qr_code_rounded,
    isDark,
  ),
  // لا يوجد validator!
),
```

**المشكلة:** حقل الباركود في شاشة الاضافة السريعة ليس له اي تحقق. بينما في `product_form_screen.dart` يستخدم `FormValidators.barcode(required: false)` بشكل صحيح.

**التوصية:** اضافة `validator: FormValidators.barcode(required: false)`.

---

#### 3.3 عدم تنظيف المدخلات في quick_add_product_screen

**التصنيف:** متوسط

**الملف:** `apps/cashier/lib/screens/products/quick_add_product_screen.dart`

```dart
// سطر 533
name: _nameController.text.trim(),
// سطر 535-536
barcode: Value(_barcodeController.text.isNotEmpty
    ? _barcodeController.text.trim() : null),
```

**المشكلة:** الاسم والباركود يُحفظان بدون تنظيف. بالمقارنة، `product_form_screen.dart` يستخدم `InputSanitizer.sanitize()` (سطر 727).

---

#### 3.4 حقل الملاحظات بدون حد اقصى او فحص محتوى خطر في receiving_goods_screen

**التصنيف:** متوسط

**الملف:** `apps/admin/lib/screens/purchases/receiving_goods_screen.dart`

```dart
// سطر 526-537
TextFormField(
  controller: _notesController,
  maxLines: 3,
  decoration: InputDecoration(
    labelText: 'ملاحظات الاستلام',
    // ...
  ),
  // لا يوجد validator او maxLength!
),
```

**المشكلة:** حقل الملاحظات ليس له حد اقصى للطول ولا فحص للمحتوى الخطر.

**التوصية:** اضافة `validator: FormValidators.notes(maxLength: 500)` و `maxLength: 500`.

---

#### 3.5 كلمة المرور لا تفرض قوة افتراضية

**التصنيف:** متوسط

**الملف:** `alhai_design_system/lib/src/utils/validators.dart`

```dart
// سطر 185-219
static String? password(
  String? value, {
  int minLength = 8,
  bool requireUppercase = false,   // غير مفعل افتراضيا!
  bool requireLowercase = false,   // غير مفعل افتراضيا!
  bool requireDigit = false,       // غير مفعل افتراضيا!
  bool requireSpecialChar = false, // غير مفعل افتراضيا!
  String? errorMessage,
}) {
```

**المشكلة:** جميع متطلبات القوة الافتراضية معطلة (`false`). هذا يعني ان كلمة مرور مثل `"12345678"` ستمر بنجاح اذا لم يتم تفعيل المتطلبات صراحة عند الاستدعاء. النظام حاليا يستخدم OTP عبر WhatsApp لكن قد يُضاف تسجيل دخول بكلمة مرور لاحقا.

**التوصية:** تغيير القيم الافتراضية لتكون `true` لتفرض قوة كلمة مرور معقولة افتراضيا:
```dart
bool requireUppercase = true,
bool requireDigit = true,
```

---

#### 3.6 شاشة تسجيل الدخول تتحقق من طول الرقم فقط (< 9 ارقام)

**التصنيف:** متوسط

**الملف:** `packages/alhai_auth/lib/src/screens/login_screen.dart`

```dart
// سطر 94-98
final phoneDigits = _phoneController.text.replaceAll(' ', '');
if (phoneDigits.length < 9) {
  setState(() => _error = l10n?.pleaseEnterValidPhone ?? 'يرجى إدخال رقم جوال صحيح');
  return;
}
```

**المشكلة:** التحقق يعتمد فقط على الطول (>= 9 ارقام) بدون استخدام `PhoneValidator.validateMobile()` الذي يتحقق من ان الرقم يبدأ بـ 05 ويتبع الصيغة السعودية الصحيحة. مع ذلك، النظام يدعم دول الخليج الاخرى (الامارات، الكويت، البحرين، قطر، عُمان) لذا التحقق المرن مقبول جزئيا.

**التوصية:** اضافة تحقق اضافي بناء على الدولة المختارة:
```dart
if (_selectedCountry == CountryData.saudiArabia) {
  final result = PhoneValidator.validateMobile('0$phoneDigits');
  if (!result.isValid) { ... }
}
```

---

#### 3.7 عدم وجود فحص XSS في حقل البحث الفوري

**التصنيف:** متوسط

**الملف:** `packages/alhai_pos/lib/src/widgets/pos/instant_search.dart`

```dart
// سطر 18-23
final lowerQuery = query.toLowerCase();
return products.where((p) {
  return p.name.toLowerCase().contains(lowerQuery) ||
         (p.barcode?.toLowerCase().contains(lowerQuery) ?? false) ||
         p.id.toLowerCase().contains(lowerQuery);
}).toList();
```

**المشكلة:** نص البحث يُستخدم مباشرة بدون تنظيف. مع ان البحث يتم في الذاكرة المحلية (وليس في SQL)، فان عرض نص البحث في واجهة المستخدم بدون تنظيف قد يسبب مشاكل عرض.

**التوصية:** تنظيف نص البحث من الاحرف الخاصة عبر `InputSanitizer.sanitize()`.

---

#### 3.8 عدم تطبيق containsDangerousContent بشكل واسع

**التصنيف:** متوسط

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/input_sanitizer.dart`

**المشكلة:** دالة `containsDangerousContent` تُستخدم فقط في 5 ملفات:
1. `form_validators.dart` (requiredField, name, notes)
2. `input_sanitizer.dart` (التعريف)
3. `input_sanitizer_test.dart` (الاختبار)
4. `customer_detail_screen.dart`
5. `instant_search.dart`

بينما يوجد العديد من الشاشات التي تقبل مدخلات نصية بدون فحص المحتوى الخطر.

---

### 4. المشاكل المنخفضة

---

#### 4.1 نظامان متوازيان للتحقق

**التصنيف:** منخفض

**المشكلة:** يوجد نظامان للتحقق:
1. **`packages/alhai_shared_ui/lib/src/core/validators/`** - نظام مركزي شامل مع `ValidationResult`
2. **`alhai_design_system/lib/src/utils/validators.dart`** - `AlhaiValidators` مع تحقق مستقل

هذا قد يسبب ارتباكا للمطورين حول اي نظام يستخدمون. مثلا:
- `AlhaiValidators.saudiPhone()` يختلف قليلا عن `PhoneValidator.validateMobile()`
- `AlhaiValidators.email()` يختلف في نمط regex عن `EmailValidator.validate()`

**التوصية:** توحيد النظامين في نظام واحد مركزي، او اضافة توثيق واضح عن اي واحد يُستخدم ومتى.

---

#### 4.2 نمط regex البريد الالكتروني مختلف بين النظامين

**التصنيف:** منخفض

**الملف 1:** `packages/alhai_shared_ui/lib/src/core/validators/email_validator.dart` (سطر 14-17)
```dart
r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
```

**الملف 2:** `alhai_design_system/lib/src/utils/validators.dart` (سطر 70-72)
```dart
r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$'
```

**المشكلة:** النظام الاول يسمح بـ 61 حرف لكل جزء من domain، بينما الثاني يسمح بـ 253 حرف. النظام الاول يتحقق ايضا من TLD ونطاقات مؤقتة بينما الثاني لا يفعل ذلك.

---

#### 4.3 تحقق اسم المستلم في receiving_goods_screen بسيط جدا

**التصنيف:** منخفض

**الملف:** `apps/admin/lib/screens/purchases/receiving_goods_screen.dart`

```dart
// سطر 510-514
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'اسم المستلم مطلوب';
  }
  return null;
},
```

**المشكلة:** لا يتحقق من الحد الاقصى للطول، لا يتحقق من الاحرف المسموحة، لا يتحقق من المحتوى الخطر. يجب استخدام `FormValidators.name()` بدلا من ذلك.

---

#### 4.4 حد الدين الافتراضي ثابت في الكود

**التصنيف:** منخفض

**الملف:** `packages/alhai_pos/lib/src/widgets/pos/inline_payment.dart`

```dart
// سطر 146
const creditLimit = 500.0; // الحد الافتراضي
```

**المشكلة:** حد الدين ثابت في الكود (500 ريال) بدلا من قراءته من الاعدادات. هذا ليس مشكلة تحقق مباشرة لكنه يؤثر على منطق التحقق من حد الائتمان.

---

#### 4.5 SQL Injection detector قد يعطي false positives

**التصنيف:** منخفض

**الملف:** `packages/alhai_shared_ui/lib/src/core/validators/input_sanitizer.dart`

```dart
// سطر 177-181
final sqlPattern = RegExp(
  r'(--|;|\bor\b|\band\b|\bunion\b|\bselect\b|\bdrop\b|\bdelete\b|\binsert\b|\bupdate\b)',
  caseSensitive: false,
);
```

**المشكلة:** الكلمات `or`, `and`, `select`, `update`, `delete` شائعة في النصوص العربية والانجليزية. مثلا:
- "Choose one **or** more" سيُعتبر محتوى خطر
- "Please **select** a category" سيُعتبر محتوى خطر
- اسم منتج مثل "**Select** Premium Coffee" سيُرفض

مع ذلك، الحماية الاساسية من Drift (parameterized queries) موجودة وكافية لحماية قاعدة البيانات.

**التوصية:** تحسين النمط ليبحث عن تركيبات SQL كاملة بدلا من كلمات مفردة.

---

#### 4.6 Rate Limiting على مستوى Client فقط في OTP

**التصنيف:** منخفض

**الملف:** `packages/alhai_auth/lib/src/security/otp_service.dart`

```dart
// سطر 12-18 (تحذير موثق)
/// Rate Limiting هنا يعمل على مستوى Client فقط!
/// يمكن تجاوزه بإعادة تثبيت التطبيق أو مسح البيانات.
///
/// للحماية الكاملة، يجب تطبيق Rate Limiting على مستوى الـ Server
```

**المشكلة:** التحذير موثق بشكل جيد في الكود. Rate limiting محلي يمكن تجاوزه. ومع ذلك، فان النظام يستخدم Supabase OTP كخيار اول مما يوفر حماية على مستوى الخادم.

---

#### 4.7 خدمة PIN - PBKDF2 iterations قد تكون مبالغ فيها على الموبايل

**التصنيف:** منخفض

**الملف:** `packages/alhai_auth/lib/src/security/pin_service.dart`

```dart
// سطر 33
const int kPbkdf2Iterations = 100000;
```

**المشكلة:** 100,000 تكرار قد تسبب بطئا ملحوظا على الاجهزة القديمة (1-3 ثوان). ومع ذلك، هذا يوفر حماية ممتازة ضد هجمات brute force، ويتم استخدام constant-time comparison (سطر 306-313) لمنع timing attacks.

---

### 5. نقاط القوة المميزة

---

#### 5.1 اغطية اختبار شاملة للتحقق

**الملفات:** `packages/alhai_shared_ui/test/core/validators/`

| ملف الاختبار | عدد الحالات |
|---|---|
| `price_validator_test.dart` | 50 |
| `input_sanitizer_test.dart` | 75 |
| `form_validators_test.dart` | 67 |
| `phone_validator_test.dart` | 30 |
| `barcode_validator_test.dart` | 30 |
| `email_validator_test.dart` | 28 |
| `iban_validator_test.dart` | 24 |
| `validation_result_test.dart` | 14 |
| **المجموع** | **318** |

هذا تغطية اختبار ممتازة لنظام التحقق المركزي.

---

#### 5.2 تنظيف المدخلات مطبق في الشاشات الرئيسية

الشاشات التالية تستخدم `InputSanitizer` بشكل صحيح:

| الشاشة | الملف |
|---|---|
| نموذج المنتج (Admin) | `apps/admin/lib/screens/products/product_form_screen.dart` |
| نموذج الموردين | `apps/admin/lib/screens/suppliers/supplier_form_screen.dart` |
| اعدادات المتجر | `apps/admin/lib/screens/settings/store_settings_screen.dart` |
| ادارة الاصناف | `apps/admin/lib/screens/products/categories_screen.dart` |
| تفاصيل العميل | `packages/alhai_shared_ui/lib/src/screens/customers/customer_detail_screen.dart` |
| قائمة العملاء | `packages/alhai_shared_ui/lib/src/screens/customers/customers_screen.dart` |
| قائمة المنتجات | `packages/alhai_shared_ui/lib/src/screens/products/products_screen.dart` |
| قائمة الطلبات | `packages/alhai_shared_ui/lib/src/screens/orders/orders_screen.dart` |
| الفواتير | `packages/alhai_shared_ui/lib/src/screens/invoices/invoices_screen.dart` |
| المخزون | `packages/alhai_shared_ui/lib/src/screens/inventory/inventory_screen.dart` |
| البيع السريع | `packages/alhai_pos/lib/src/screens/pos/quick_sale_screen.dart` |

---

#### 5.3 حماية امنية متقدمة في خدمة PIN

**الملف:** `packages/alhai_auth/lib/src/security/pin_service.dart`

- PBKDF2 مع Salt عشوائي (32 بايت) - سطر 249-254
- 100,000 تكرار - سطر 33
- Constant-time comparison ضد timing attacks - سطر 306-313
- حد اقصى 5 محاولات مع قفل 15 دقيقة - سطر 18-21
- ترحيل تلقائي من SHA256 القديم لـ PBKDF2 - سطر 181-189
- تخزين امن عبر SecureStorageService - سطر 84-88

---

#### 5.4 حماية الباركود من Buffer Overflow

**الملف:** `packages/alhai_pos/lib/src/widgets/pos/barcode_listener.dart`

```dart
// سطر 76-80
// Buffer overflow protection
if (_buffer.length > 50) {
  _buffer.clear();
  _lastKeyTime = null;
  return;
}

// سطر 98-99
// Sanitize: only allow alphanumeric and hyphens
final barcode = raw.replaceAll(RegExp(r'[^a-zA-Z0-9\-]'), '');
```

حماية ممتازة من buffer overflow وتنظيف المدخلات قبل الاستخدام.

---

#### 5.5 التحقق من OTP

**الملف:** `packages/alhai_auth/lib/src/widgets/otp_input_field.dart`

- ارقام فقط (`FilteringTextInputFormatter.digitsOnly`)
- خانة واحدة لكل حقل (`maxLength: 1`)
- تنظيف اللصق من الحافظة (`replaceAll(RegExp(r'[^0-9]'), '')`)
- اتجاه LTR دائم للارقام (`TextDirection.ltr`)

---

## التوصيات مع اولوية التنفيذ

### اولوية عالية (يجب تنفيذها فورا)

| # | التوصية | الملفات المتاثرة | الجهد |
|---|---------|-----------------|-------|
| 1 | استبدال `double.parse()` بـ `double.tryParse()` في حفظ المنتجات | `product_form_screen.dart`, `quick_add_product_screen.dart` | منخفض |
| 2 | استبدال `int.parse()` بـ `int.tryParse()` في تحليل الوقت | `store.dart` | منخفض |
| 3 | اضافة `InputSanitizer.sanitize()` في `receiving_goods_screen.dart` | 1 ملف | منخفض |
| 4 | استبدال `DateTime.parse()` بـ `DateTime.tryParse()` في DTOs | 10+ ملفات | متوسط |

### اولوية متوسطة (خلال اسبوعين)

| # | التوصية | الملفات المتاثرة | الجهد |
|---|---------|-----------------|-------|
| 5 | استخدام `FormValidators` المركزي في `quick_add_product_screen.dart` | 1 ملف | منخفض |
| 6 | اضافة validator لحقل الباركود في `quick_add_product_screen.dart` | 1 ملف | منخفض |
| 7 | اضافة validator و maxLength لحقل الملاحظات في `receiving_goods_screen.dart` | 1 ملف | منخفض |
| 8 | تحسين تحقق رقم الجوال في `login_screen.dart` بناء على الدولة المختارة | 1 ملف | منخفض |
| 9 | تفعيل متطلبات قوة كلمة المرور الافتراضية | 1 ملف | منخفض |

### اولوية منخفضة (خلال شهر)

| # | التوصية | الملفات المتاثرة | الجهد |
|---|---------|-----------------|-------|
| 10 | توحيد نظامي التحقق (`alhai_shared_ui` و `alhai_design_system`) | عدة ملفات | عالي |
| 11 | تحسين نمط كشف SQL Injection لتقليل false positives | 1 ملف | متوسط |
| 12 | اضافة `containsDangerousContent` فحص في جميع حقول الادخال النصية | عدة ملفات | متوسط |
| 13 | قراءة حد الدين من الاعدادات بدلا من الكود الثابت | 1 ملف | منخفض |

---

## خلاصة

منصة الحي الذكي تمتلك **بنية تحتية ممتازة** للتحقق من المدخلات مع:
- نظام مركزي شامل يغطي جميع الانواع الشائعة
- 318 حالة اختبار للتحقق
- حماية امنية متقدمة (PBKDF2, sanitization, timing-safe comparison)
- دعم ثنائي اللغة (عربي/انجليزي) في رسائل الخطا

**التحدي الرئيسي** هو ضمان استخدام هذا النظام المركزي **بشكل متسق** في جميع الشاشات. بعض الشاشات تستخدم تحققا بسيطا بدلا من المركزي، وبعض المواقع تستخدم `parse()` بدلا من `tryParse()` الامنة.

**النصيحة الاستراتيجية:** انشاء lint rule مخصص يمنع استخدام `int.parse()`, `double.parse()`, `DateTime.parse()` ويفرض استخدام البدائل الامنة (`tryParse`) في جميع الملفات.
