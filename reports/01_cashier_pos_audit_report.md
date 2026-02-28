# 📋 تقرير مراجعة تطبيق الكاشير (POS)
## منصة الحي - Alhai Platform
### تاريخ التقرير: 28 فبراير 2026
### المسار: apps/cashier
### النسخة: 1.0.0+1

---

## 📊 ملخص تنفيذي

تطبيق الكاشير هو تطبيق Flutter مبني بهيكلة معمارية جيدة يعتمد على نظام الحزم المشتركة (monorepo) مع فصل واضح بين الطبقات عبر حزم `alhai_core`، `alhai_design_system`، `alhai_database`، `alhai_pos`، و`alhai_services`. التطبيق يدعم العمل بدون إنترنت (offline-first) باستخدام Drift/SQLite مع مزامنة عبر Supabase. البنية التحتية للاختبارات ممتازة (mock helpers, factories) لكن التغطية الفعلية سطحية. المشاكل الرئيسية تتمركز في: **نصوص مكتوبة يدوياً (hardcoded strings) في ~90% من الشاشات**، **غياب كامل لدعم الوصولية (Accessibility)**، **عمليات محاكاة (stubs) غير مكتملة في عدة شاشات حرجة**، و**ثغرات في التحقق من المدخلات الرقمية**. نقاط القوة تشمل الهيكلة المعمارية النظيفة، دعم العمل بدون إنترنت، تشفير قاعدة البيانات، واستخدام نظام التصميم الموحد.

---

## 📈 لوحة المؤشرات

| المحور | التقييم | الحرجة 🔴 | المتوسطة 🟡 | البسيطة 🟢 |
|--------|---------|-----------|-------------|------------|
| جودة الكود والهيكلة | 7/10 | 2 | 5 | 4 |
| الأمان | 6/10 | 3 | 4 | 3 |
| الأداء والتحسين | 7/10 | 1 | 4 | 3 |
| واجهة وتجربة المستخدم | 6/10 | 2 | 5 | 3 |
| **الإجمالي** | **6.5/10** | **8** | **18** | **13** |

---

## 📊 إحصائيات الكود

| المؤشر | القيمة |
|--------|--------|
| إجمالي ملفات Dart (lib/) | 53 |
| إجمالي ملفات Dart (مع tests) | 107 |
| إجمالي الأسطر | 38,711 |
| عدد الاختبارات (ملفات) | 51 |
| نسبة التغطية التقديرية | ~5% (سطحية - فقط rendering smoke tests) |
| عدد TODO/FIXME | 1 (`coupon_code_screen.dart:177`) |
| عدد الملفات الكبيرة (>300 سطر) | 29 ملف |
| عدد الملفات الكبيرة جداً (>700 سطر) | 9 ملفات |
| عدد print/debugPrint statements | 3 (في `create_invoice_screen.dart` و `backup_screen.dart`) |
| عدد الشاشات | 44 شاشة |
| عدد العمليات المحاكاة (stubs) | 8+ عمليات |
| Semantics widgets | 0 (غياب كامل) |

---

## 🔴 المشاكل الحرجة (يجب إصلاحها فوراً)

### [CRT-001] عمليات مالية محاكاة (Stub) في بيئة الإنتاج
- **المحور:** Code Quality / Security
- **الوكيل:** Agent 1.1 + Agent 1.2
- **الملفات والأسطر:**
  - `lib/screens/customers/create_invoice_screen.dart:841-874` - حفظ الفاتورة محاكاة بـ `Future.delayed`
  - `lib/screens/sales/exchange_screen.dart:596-598` - عملية الاستبدال محاكاة
  - `lib/screens/payment/split_refund_screen.dart:596-603` - عملية الإرجاع المقسم محاكاة
  - `lib/screens/payment/split_receipt_screen.dart` - الطباعة محاكاة
  - `lib/screens/inventory/stock_take_screen.dart` - `_saveCount` لا يفعل شيئاً
  - `lib/screens/offers/coupon_code_screen.dart` - `_applyCoupon` لا يطبق فعلياً
- **الوصف:** عدة عمليات مالية حرجة (إنشاء فواتير، استبدال بضاعة، إرجاع مبالغ، تطبيق كوبونات، حفظ الجرد) تستخدم `Future.delayed` كمحاكاة ولا تحفظ البيانات فعلياً في قاعدة البيانات. هذه العمليات ستفقد البيانات إذا وصلت للإنتاج.
- **الكود المُشكل:**
```dart
// create_invoice_screen.dart:841
Future<void> _saveInvoice(bool finalize) async {
  setState(() => _isSubmitting = true);
  // ... validation ...
  await Future.delayed(const Duration(seconds: 1)); // ⚠️ محاكاة!
  // لا يوجد حفظ فعلي في قاعدة البيانات
}
```
- **التأثير:** فقدان بيانات مالية حرجة - الفواتير والاستبدالات والإرجاعات لن تُسجل
- **الحل المقترح:** استبدال كل `Future.delayed` بعمليات فعلية عبر الـ DAO المناسب مع تغليف بـ database transaction
- **الجهد المقدر:** 3-5 أيام

---

### [CRT-002] مفتاح تشفير قاعدة البيانات مكشوف على الويب
- **المحور:** Security
- **الوكيل:** Agent 1.2
- **الملف:** `lib/main.dart:118-127`
- **الوصف:** على منصة الويب، يُخزَّن مفتاح تشفير قاعدة البيانات في `SharedPreferences` (أي `localStorage`) بدون تشفير. هذا يجعل التشفير بلا فائدة على الويب لأن أي JavaScript يمكنه قراءة المفتاح.
- **الكود المُشكل:**
```dart
if (kIsWeb) {
  final prefs = await SharedPreferences.getInstance();
  var key = prefs.getString('secure_storage_$keyName');
  if (key == null) {
    final values = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    key = base64Url.encode(values);
    await prefs.setString('secure_storage_$keyName', key); // ⚠️ نص عادي!
  }
  return key;
}
```
- **التأثير:** بيانات المبيعات والعملاء والمخزون يمكن قراءتها على الويب
- **الحل المقترح:** استخدام Web Crypto API عبر `dart:js_interop` لتخزين المفتاح في IndexedDB مشفر، أو استخدام `SubtleCrypto.deriveKey` مع كلمة مرور المستخدم
- **الجهد المقدر:** 2 أيام

---

### [CRT-003] توليد معرّفات المنتجات بالمللي ثانية - خطر تكرار
- **المحور:** Code Quality / Data Integrity
- **الوكيل:** Agent 1.1
- **الملف:** `lib/data/repositories/local_products_repository.dart:115`
- **الوصف:** يستخدم `DateTime.now().millisecondsSinceEpoch.toString()` لتوليد معرّفات المنتجات. إذا تم إنشاء منتجين في نفس المللي ثانية (سيناريو واقعي عند الاستيراد الجماعي)، سيحدث تكرار في المعرّف وفقدان بيانات.
- **الكود المُشكل:**
```dart
final newId = DateTime.now().millisecondsSinceEpoch.toString();
```
- **التأثير:** فقدان منتجات عند الإنشاء المتزامن أو الاستيراد الجماعي
- **الحل المقترح:**
```dart
import 'package:uuid/uuid.dart';
final newId = const Uuid().v4();
```
- **الجهد المقدر:** 30 دقيقة

---

### [CRT-004] نقل المخزون بين الفروع لا يُنشئ حركة استلام
- **المحور:** Security / Data Integrity
- **الوكيل:** Agent 1.2
- **الملف:** `lib/screens/inventory/transfer_inventory_screen.dart:540-570`
- **الوصف:** عند نقل مخزون من فرع لآخر، يتم إنشاء حركة `transfer_out` فقط بدون حركة `transfer_in` مقابلة في الفرع المستقبل. هذا يسبب عدم تطابق في أرصدة المخزون بين الفروع.
- **التأثير:** فقدان مخزون ظاهري - المنتجات تُخصم من فرع ولا تُضاف للآخر
- **الحل المقترح:** إنشاء حركتين في transaction واحد: `transfer_out` + `transfer_in` مع ربطهما بمعرّف نقل مشترك
- **الجهد المقدر:** 4 ساعات

---

### [CRT-005] استلام البضاعة بدون transaction wrapping
- **المحور:** Security / Data Integrity
- **الوكيل:** Agent 1.2
- **الملف:** `lib/screens/purchases/cashier_receiving_screen.dart:585-595`
- **الوصف:** عملية استلام البضاعة تُحدّث المخزون لكل منتج بشكل منفصل في حلقة متتالية. إذا فشل تحديث منتج في المنتصف، تكون البيانات غير متسقة - بعض المنتجات مُحدّثة وبعضها لا.
- **الكود المُشكل:**
```dart
for (final item in _items) {
  try {
    await _db.inventoryDao.insertMovement(/* ... */);
  } catch (_) {
    // ⚠️ الخطأ يُبتلع بصمت والحلقة تستمر
  }
}
```
- **التأثير:** عدم تطابق المخزون مع أوامر الشراء
- **الحل المقترح:** تغليف كل العمليات في `_db.transaction(() async { ... })` مع rollback عند أي فشل
- **الجهد المقدر:** 2 ساعات

---

### [CRT-006] GoRouter debug logging مفعّل دائماً
- **المحور:** Security
- **الوكيل:** Agent 1.2
- **الملف:** `lib/router/cashier_router.dart:180`
- **الوصف:** `debugLogDiagnostics: true` مفعّل بدون شرط `kDebugMode`. في بيئة الإنتاج، يطبع كل تفاصيل التنقل والمسارات والبارامترات في console.
- **الكود المُشكل:**
```dart
return GoRouter(
  debugLogDiagnostics: true, // ⚠️ يجب أن يكون مشروطاً
  // ...
);
```
- **الحل المقترح:**
```dart
debugLogDiagnostics: kDebugMode,
```
- **الجهد المقدر:** 5 دقائق

---

### [CRT-007] لا يوجد تحقق من الصلاحيات لتغيير الأسعار
- **المحور:** Security
- **الوكيل:** Agent 1.2
- **الملف:** `lib/screens/products/edit_price_screen.dart`
- **الوصف:** أي كاشير يمكنه الدخول لشاشة تعديل الأسعار وتغيير سعر أي منتج بدون أي تحقق من الصلاحيات أو موافقة المدير.
- **التأثير:** تلاعب بالأسعار من قبل كاشير غير مخوّل
- **الحل المقترح:** إضافة فحص `userRoleProvider` والسماح فقط للمدير/المشرف، أو طلب PIN المدير قبل التعديل
- **الجهد المقدر:** 4 ساعات

---

### [CRT-008] غياب كامل لدعم الوصولية (Accessibility)
- **المحور:** UI/UX
- **الوكيل:** Agent 1.4
- **الملفات:** جميع الـ 44 شاشة
- **الوصف:** لا يوجد أي استخدام لـ `Semantics`، `MergeSemantics`، `ExcludeSemantics`، أو `semanticLabel` في أي شاشة من شاشات التطبيق. `GestureDetector` يُستخدم بكثرة بدون `Tooltip` أو وصف. الرسومات المخصصة (`CustomPaint` في التقارير) بدون وصف نصي.
- **التأثير:** التطبيق غير قابل للاستخدام لذوي الاحتياجات الخاصة، وقد يخالف معايير الوصولية المحلية
- **الحل المقترح:** إضافة `Semantics` widgets للعناصر التفاعلية والرسومات، `Tooltip` لجميع الأيقونات، `semanticLabel` للأزرار والمؤشرات
- **الجهد المقدر:** 5-7 أيام

---

## 🟡 المشاكل المتوسطة (يجب إصلاحها قريباً)

### [MED-001] نصوص مكتوبة يدوياً (Hardcoded Strings) في ~90% من الشاشات
- **المحور:** UI/UX / i18n
- **الوكيل:** Agent 1.4
- **الملفات:** 40+ شاشة من أصل 44
- **الوصف:** رغم وجود نظام ترجمة `AppLocalizations` مُستخدم في بعض الشاشات، إلا أن ~90% من الشاشات تحتوي على نصوص إنجليزية أو عربية مكتوبة مباشرة في الكود بدلاً من استخدام مفاتيح الترجمة. الأسوأ هي الشاشات التي تخلط بين `l10n` ونصوص يدوية.
- **أبرز الملفات:**
  - `cashier_purchase_request_screen.dart` - عربي يدوي بالكامل (~20 نص)
  - `cashier_receiving_screen.dart` - عربي يدوي بالكامل (~15 نص)
  - `denomination_counter_widget.dart` - عربي يدوي بالكامل (~10 نصوص)
  - `receipt_settings_screen.dart` - إنجليزي يدوي (~20 نص)
  - `custom_report_screen.dart` - إنجليزي يدوي (~15 نص)
- **أفضل الشاشات ترجمةً:** `reprint_receipt_screen.dart`، `sales_history_screen.dart`، `daily_summary_screen.dart`، `onboarding_screen.dart`
- **التأثير:** التطبيق غير قابل للترجمة لأي لغة أخرى كما هو
- **الجهد المقدر:** 3-4 أيام

---

### [MED-002] ابتلاع صامت للأخطاء عند تحميل البيانات
- **المحور:** Code Quality / UX
- **الوكيل:** Agent 1.1 + Agent 1.4
- **الملفات:** جميع الشاشات تقريباً
- **الوصف:** كل الشاشات تلتقط الأخطاء عند تحميل البيانات وتتجاهلها بصمت (`catch (e) { setState(() => _isLoading = false); }`). لا يظهر أي رسالة خطأ للمستخدم عند فشل التحميل. المستخدم يرى شاشة فارغة بدون توضيح.
- **الكود النموذجي:**
```dart
try {
  final data = await _db.ordersDao.getOrders(storeId);
  setState(() { _orders = data; _isLoading = false; });
} catch (e) {
  if (mounted) setState(() => _isLoading = false);
  // ⚠️ لا رسالة خطأ للمستخدم!
}
```
- **الحل المقترح:** إضافة متغير `_error` وعرض حالة خطأ واضحة مع زر إعادة المحاولة
- **الجهد المقدر:** 2-3 أيام

---

### [MED-003] تحميل جميع البيانات في الذاكرة بدون Pagination
- **المحور:** Performance
- **الوكيل:** Agent 1.3
- **الملفات:**
  - `lib/screens/reports/custom_report_screen.dart:108` - يحمل كل الطلبات
  - `lib/screens/reports/payment_reports_screen.dart` - يحمل كل الطلبات
  - `lib/screens/payment/payment_history_screen.dart` - يحمل كل الطلبات
  - `lib/screens/sales/sales_history_screen.dart:56` - يحمل كل الطلبات (أول 100)
- **الوصف:** شاشات التقارير والسجلات تحمل جميع الطلبات في الذاكرة ثم تفلترها في Dart. لمتجر بآلاف العمليات اليومية، هذا سيسبب بطء شديد واستهلاك ذاكرة مرتفع.
- **الكود المُشكل:**
```dart
// custom_report_screen.dart
final allOrders = await _db.ordersDao.getOrders(storeId);
// ثم يفلتر في Dart بدلاً من الاستعلام المباشر
final filtered = allOrders.where((o) => o.createdAt.isAfter(startDate)).toList();
```
- **الحل المقترح:** إضافة استعلامات بنطاق تاريخ في الـ DAO: `getOrdersByDateRange(storeId, from, to)` مع pagination
- **الجهد المقدر:** 2 أيام

---

### [MED-004] فحص N+1 في شاشة الفئات
- **المحور:** Performance
- **الوكيل:** Agent 1.3
- **الملف:** `lib/screens/products/cashier_categories_screen.dart:64-71`
- **الوصف:** لكل فئة منتجات، يتم تنفيذ استعلام منفصل `getProductsByCategory` بشكل متتالي. لـ 50 فئة مثلاً، ينتج 51 استعلام (1 للفئات + 50 للمنتجات).
- **الحل المقترح:** إضافة استعلام مجمّع `getProductCountsByCategories(storeId)` في الـ DAO يُرجع `Map<String, int>`
- **الجهد المقدر:** 3 ساعات

---

### [MED-005] شاشات المخزون تسمح بمخزون سالب
- **المحور:** Security / Business Logic
- **الوكيل:** Agent 1.2
- **الملفات:**
  - `lib/screens/inventory/remove_inventory_screen.dart`
  - `lib/screens/inventory/wastage_screen.dart`
  - `lib/screens/inventory/edit_inventory_screen.dart`
  - `lib/screens/inventory/transfer_inventory_screen.dart`
- **الوصف:** شاشات إزالة المخزون والهدر والتعديل والنقل لا تتحقق من أن الكمية المطلوبة لا تتجاوز الكمية الحالية. يمكن إدخال كمية أكبر من المتاح مما يسبب مخزون سالب.
- **الحل المقترح:** مقارنة الكمية المُدخلة مع `product.stockQty` قبل الحفظ مع رسالة تحذير واضحة
- **الجهد المقدر:** 4 ساعات

---

### [MED-006] عدم وجود debounce على البحث في عدة شاشات
- **المحور:** Performance
- **الوكيل:** Agent 1.3
- **الملفات:**
  - `lib/screens/payment/payment_history_screen.dart` - لا debounce
  - `lib/screens/products/print_barcode_screen.dart` - لا debounce
  - `lib/screens/sales/exchange_screen.dart` - لا debounce
  - `lib/screens/inventory/remove_inventory_screen.dart` - لا debounce
  - `lib/screens/inventory/wastage_screen.dart` - لا debounce
  - `lib/screens/inventory/transfer_inventory_screen.dart` - لا debounce
- **الوصف:** 6 شاشات تنفذ استعلام قاعدة بيانات مع كل حرف يُكتب في حقل البحث بدون debounce. هذا يضغط على قاعدة البيانات ويسبب بطء.
- **ملاحظة:** الشاشات التالية تطبق debounce بشكل صحيح (300ms): `create_invoice_screen.dart`، `add_inventory_screen.dart`
- **الحل المقترح:** إضافة `Timer` بـ 300ms debounce كما في `create_invoice_screen.dart`
- **الجهد المقدر:** 2 ساعات

---

### [MED-007] أيقونات لا تنعكس في RTL
- **المحور:** UI/UX
- **الوكيل:** Agent 1.4
- **الملفات:** 10+ شاشات
- **الوصف:** استخدام `Icons.arrow_back_rounded` و `Icons.chevron_right_rounded` مباشرة بدلاً من `Icons.adaptive.arrow_back` أو استخدام `Directionality`-aware icons. في واجهة RTL (العربية)، سهم الرجوع يجب أن يشير لليمين.
- **الحل المقترح:** استبدال بـ `Icons.adaptive.arrow_back` أو استخدام `Directionality.of(context)` لعكس الأيقونات
- **الجهد المقدر:** 2 ساعات

---

### [MED-008] عدم وجود تأكيد قبل العمليات الحرجة
- **المحور:** UX / Security
- **الوكيل:** Agent 1.4 + Agent 1.2
- **الملفات:**
  - `lib/screens/inventory/remove_inventory_screen.dart` - بدون تأكيد
  - `lib/screens/inventory/wastage_screen.dart` - بدون تأكيد
  - `lib/screens/inventory/edit_inventory_screen.dart` - بدون تأكيد
  - `lib/screens/inventory/transfer_inventory_screen.dart` - بدون تأكيد
  - `lib/screens/inventory/stock_take_screen.dart` - بدون تأكيد على Finalize
  - `lib/screens/customers/new_transaction_screen.dart` - بدون تأكيد
- **الوصف:** عمليات حرجة مثل إزالة المخزون والهدر وتسجيل الديون تنفذ مباشرة بدون حوار تأكيد
- **الحل المقترح:** إضافة `showDialog` للتأكيد مع ملخص العملية قبل التنفيذ
- **الجهد المقدر:** 3 ساعات

---

### [MED-009] عدم وجود حد أعلى للمدخلات الرقمية
- **المحور:** Security
- **الوكيل:** Agent 1.2
- **الملفات:** جميع شاشات المخزون والعملاء والمالية
- **الوصف:** حقول الكميات والمبالغ ومعدل الفائدة والضريبة تقبل أي قيمة رقمية بدون حد أعلى. يمكن إدخال كمية 999,999 أو معدل فائدة 99,999%.
- **الحل المقترح:** إضافة `max` validation على كل حقل رقمي حسب السياق (مثلاً: كمية ≤ 10,000، مبلغ ≤ 1,000,000)
- **الجهد المقدر:** 3 ساعات

---

### [MED-010] إدارة الحالة مختلطة بين GetIt و Riverpod
- **المحور:** Code Quality / Architecture
- **الوكيل:** Agent 1.1
- **الملفات:** جميع الشاشات
- **الوصف:** كل الشاشات تستخدم `GetIt.I<AppDatabase>()` للوصول المباشر لقاعدة البيانات بدلاً من استخدام Riverpod providers. هذا يخلط بين نمطين لإدارة التبعيات ويصعّب الاختبار والـ mocking.
- **الحل المقترح:** إنشاء Riverpod providers للـ database وإزالة الاعتماد المباشر على GetIt في طبقة الـ UI
- **الجهد المقدر:** 3-5 أيام

---

### [MED-011] ملف الراوتر كبير جداً (1331 سطر)
- **المحور:** Code Quality
- **الوكيل:** Agent 1.1
- **الملف:** `lib/router/cashier_router.dart`
- **الوصف:** ملف واحد يحتوي على جميع تعريفات المسارات (~80 route) و auth guard و redirect logic و error page. يصعب صيانته وفهمه.
- **الحل المقترح:** تقسيم إلى ملفات منفصلة: `pos_routes.dart`، `settings_routes.dart`، `inventory_routes.dart`، `auth_guard.dart`
- **الجهد المقدر:** 4 ساعات

---

### [MED-012] باغ وظيفي: معاينة الإيصال لا تتحدث في الوقت الحقيقي
- **المحور:** UX (Bug)
- **الوكيل:** Agent 1.4
- **الملف:** `lib/screens/settings/receipt_settings_screen.dart`
- **الوصف:** حقول Header/Footer في إعدادات الإيصال لا تحتوي على `onChanged` callback يستدعي `setState`. المعاينة لا تتحدث أثناء الكتابة وتتحدث فقط عند تغيير إعداد آخر (toggle).
- **الحل المقترح:** إضافة `onChanged: (_) => setState(() {})` لحقلي Header و Footer
- **الجهد المقدر:** 15 دقيقة

---

### [MED-013] تخزين البيانات بسلاسل مفصولة بأنابيب (pipe-separated)
- **المحور:** Code Quality / Data Integrity
- **الوكيل:** Agent 1.1
- **الملفات:**
  - `lib/screens/settings/add_payment_device_screen.dart`
  - `lib/screens/settings/printer_settings_screen.dart`
  - `lib/screens/settings/payment_devices_screen.dart`
- **الوصف:** بيانات أجهزة الدفع والطابعات تُخزن كسلاسل مفصولة بـ `|` (مثل `'name|type|method|testPassed'`). إذا احتوى أي حقل على `|` تنكسر البيانات.
- **الحل المقترح:** استخدام JSON serialization أو جدول قاعدة بيانات مخصص
- **الجهد المقدر:** 4 ساعات

---

### [MED-014] فتح الوردية بمعرّف كاشير 'unknown'
- **المحور:** Security
- **الوكيل:** Agent 1.2
- **الملف:** `lib/screens/shifts/shift_open_screen.dart`
- **الوصف:** عند فتح الوردية، إذا لم يكن المستخدم مُصادقاً، يتم استخدام `cashierId: user?.id ?? 'unknown'` كبديل. هذا يسمح بفتح وردية بدون مستخدم حقيقي.
- **الحل المقترح:** منع فتح الوردية إذا كان `user == null`، وإعادة التوجيه لتسجيل الدخول
- **الجهد المقدر:** 30 دقيقة

---

### [MED-015] عمليات حسابية بالعملة باستخدام double
- **المحور:** Code Quality / Financial
- **الوكيل:** Agent 1.1
- **الملف:** `lib/widgets/cash/denomination_counter_widget.dart`
- **الوصف:** حسابات العملة (ريال/هلالات) تستخدم `double` مما يسبب أخطاء دقة (مثل `0.25 * 3 = 0.7500000000000001`).
- **الحل المقترح:** استخدام `int` (هلالات) أو مكتبة `decimal`
- **الجهد المقدر:** 2 ساعات

---

### [MED-016] اختبارات لمنطق أعمال وهمي (Fake Business Logic Tests)
- **المحور:** Code Quality / Testing
- **الوكيل:** Agent 1.1
- **الملف:** `test/helpers/test_helpers.dart`
- **الوصف:** 5 مجموعات اختبار (`runReceiptPdfTests`, `runZatcaComplianceTests`, `runMultiTenantTests`, `runWhatsAppTests`, `runDeliveryTests`) تحتوي على 34 اختبار تختبر فقط هياكل بيانات محلية (`Map`, `String`) ولا تختبر أي كود إنتاج فعلي. هذا يعطي إحساساً زائفاً بالتغطية.
- **التأثير:** تقارير التغطية مُضللة - تُظهر اختبارات ناجحة بدون تغطية حقيقية
- **الحل المقترح:** إعادة كتابة الاختبارات لاستدعاء الخدمات الحقيقية من `alhai_pos` package
- **الجهد المقدر:** 3-5 أيام

---

### [MED-017] اختبارات التكامل وهمية (placeholder)
- **المحور:** Code Quality / Testing
- **الوكيل:** Agent 1.1
- **الملف:** `integration_test/offline_sync_test.dart`
- **الوصف:** 3 اختبارات تكامل كلها تحتوي فقط على `expect(true, isTrue)` - لا تختبر أي شيء فعلي
- **الجهد المقدر:** 2-3 أيام لتنفيذ الاختبارات الحقيقية

---

### [MED-018] كوبون يتم التحقق منه بالاسم لا بالرمز
- **المحور:** Security / Business Logic
- **الوكيل:** Agent 1.2
- **الملف:** `lib/screens/offers/coupon_code_screen.dart`
- **الوصف:** التحقق من الكوبون يتم بمقارنة `name.toUpperCase() == code` بدلاً من حقل رمز كوبون مخصص. هذا غير آمن وهش.
- **الحل المقترح:** إضافة حقل `couponCode` في جدول الخصومات واستخدامه للبحث
- **الجهد المقدر:** 2 ساعات

---

## 🟢 المشاكل البسيطة والتحسينات المقترحة

### [LOW-001] ألوان hardcoded خارج نظام التصميم
- **المحور:** UI/UX
- **الملف:** `lib/widgets/cash/denomination_counter_widget.dart:112,257,278`
- **الوصف:** استخدام ألوان مثل `Color(0xFF1A8FE3)` و `Color(0xFF1E1E2E)` بدلاً من tokens من `alhai_design_system`
- **الجهد المقدر:** 1 ساعة

### [LOW-002] `onChanged: (_) => setState(() {})` متكرر في كل الشاشات
- **المحور:** Performance
- **الوصف:** نمط يسبب إعادة بناء كاملة للويدجت مع كل حرف. بديل أفضل: `ValueListenableBuilder` أو `TextEditingController` listener مع `setState` محدود
- **الجهد المقدر:** 3 أيام (تدريجي)

### [LOW-003] اسم التطبيق hardcoded في 4 أماكن
- **المحور:** i18n
- **الملفات:** `main.dart:233`، `cashier_shell.dart:255,338,362`
- **الوصف:** `'Al-HAI Cashier'` مكتوب مباشرة بدلاً من l10n
- **الجهد المقدر:** 15 دقيقة

### [LOW-004] Emojis في الكود المصدري
- **المحور:** Code Quality
- **الملفات:** `cash_in_out_screen.dart:358`، `shift_close_screen.dart:457`
- **الوصف:** `'عد العملات 🪙'` - emoji في كود المصدر بدلاً من l10n
- **الجهد المقدر:** 10 دقائق

### [LOW-005] `CustomPainter.shouldRepaint` يعود `true` دائماً
- **المحور:** Performance
- **الملف:** `lib/screens/reports/payment_reports_screen.dart:588`
- **الوصف:** `_PieChartPainter.shouldRepaint` يعود `true` دائماً مما يسبب إعادة رسم غير ضرورية
- **الجهد المقدر:** 15 دقيقة

### [LOW-006] `initialTotal` parameter غير مُستخدم
- **المحور:** Code Quality
- **الملف:** `lib/widgets/cash/denomination_counter_widget.dart`
- **الوصف:** البارامتر `initialTotal` يُمرر للويدجت لكن لا يُستخدم فعلياً لملء العدادات
- **الجهد المقدر:** 30 دقيقة

### [LOW-007] تنسيق التاريخ يدوي وغير محلي
- **المحور:** i18n
- **الملفات:** 5+ شاشات في الإعدادات والورديات
- **الوصف:** استخدام `'$day/$month/$year'` بدلاً من `DateFormat` من `intl` package
- **الجهد المقدر:** 1 ساعة

### [LOW-008] مسارات hardcoded بدلاً من AppRoutes constants
- **المحور:** Code Quality
- **الملفات:** `cashier_router.dart` (6 مسارات)، `payment_devices_screen.dart`، 4 شاشات ورديات (`'/notifications'`)
- **الوصف:** بعض المسارات مكتوبة كنصوص بدلاً من استخدام ثوابت `AppRoutes`
- **الجهد المقدر:** 1 ساعة

### [LOW-009] `debugPrint` في كود الإنتاج
- **المحور:** Code Quality
- **الملفات:** `create_invoice_screen.dart` (سطران)، `backup_screen.dart:258`، `exchange_screen.dart:73`
- **الوصف:** 4 عبارات `debugPrint` يجب إزالتها أو استبدالها بـ logger
- **الجهد المقدر:** 15 دقيقة

### [LOW-010] عدم التحقق من صيغة IP وPort
- **المحور:** Code Quality
- **الملف:** `lib/screens/settings/add_payment_device_screen.dart`
- **الوصف:** حقل IP Address يتحقق فقط من عدم الفراغ، وحقل Port لا يتحقق من النطاق (1-65535)
- **الجهد المقدر:** 30 دقيقة

### [LOW-011] SupabaseConfig مكرر محتمل
- **المحور:** Code Quality
- **الملف:** `lib/core/config/supabase_config.dart`
- **الوصف:** يوجد `SupabaseConfig` محلي ومستورد من `alhai_core`. قد يسبب تعارض shadowing
- **الجهد المقدر:** 30 دقيقة (فحص وإزالة المكرر)

### [LOW-012] _AuthNotifier مكرر بين التطبيقات
- **المحور:** Code Quality
- **الملف:** `lib/router/cashier_router.dart:96-100`
- **الوصف:** نمط `_AuthNotifier` مكرر في routers الكاشير والأدمن (مُشار إليه في تعليق M144)
- **الجهد المقدر:** 2 ساعات (استخراج لحزمة مشتركة)

### [LOW-013] بيانات وهمية في شاشات العروض
- **المحور:** Code Quality
- **الملفات:** `bundle_deals_screen.dart` (أسعار وهمية `* 1.4`)، `coupon_code_screen.dart` (كوبونات وهمية)
- **الوصف:** بيانات محاكاة في شاشات المستخدم النهائي
- **الجهد المقدر:** 2 ساعات

---

## 📁 ملفات مفقودة أو لم يتمكن الوكيل من الوصول إليها

| الملف/المجلد | السبب |
|-------------|-------|
| `.env` / `.dart_define.env` | غير موجود (جيد - المفاتيح تُمرر عبر `--dart-define`) |
| `lib/screens/settings/cashier_settings_screen.dart` (remove_inventory تكرار) | مقروء بنجاح |
| `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` | في حزمة خارجية - لم يُقرأ في هذه المراجعة |
| `packages/alhai_database/lib/src/daos/*` | في حزمة خارجية - لم تُقرأ |
| Coverage report | لا يوجد أمر `flutter test --coverage` مُنفذ |

---

## ✅ نقاط القوة

1. **هيكلة معمارية ممتازة (Monorepo):** فصل واضح بين الحزم (`alhai_core`, `alhai_database`, `alhai_pos`, `alhai_design_system`, `alhai_services`, `alhai_l10n`, `alhai_auth`, `alhai_sync`, `alhai_shared_ui`, `alhai_reports`) مما يسمح بإعادة الاستخدام عبر التطبيقات.

2. **دعم العمل بدون إنترنت (Offline-First):** استخدام Drift/SQLite محلي مع مزامنة Supabase، ودعم WASM على الويب عبر `drift_worker.dart`. هيكلة `LocalProductsRepository` و `LocalCategoriesRepository` تطبق Repository Pattern بشكل نظيف.

3. **تشفير قاعدة البيانات:** استخدام `FlutterSecureStorage` على الأجهزة الأصلية لتخزين مفتاح التشفير مع توليد عشوائي آمن (`Random.secure()`).

4. **بنية اختبار تحتية ممتازة:** 28 mock DAO مُعدة، 8 factory methods لبيانات اختبار واقعية بالعربية، `setupMockDatabase()` مع بارامترات اختيارية، `createTestWidget()` مع دعم RTL والترجمة تلقائياً.

5. **نظام تصميم موحد:** استخدام `alhai_design_system` بشكل متسق في معظم الشاشات (`AppColors`, `AppTypography`, `AppSizes`, `AppDurations`, `AppCurves`).

6. **حارس المصادقة (Auth Guard):** نظام redirect شامل في GoRouter يتحقق من Onboarding → Auth → Store Selection → POS.

7. **تهيئة متوازية:** `Future.wait` في `main.dart` يُهيئ Firebase, Supabase, DB key, SharedPreferences بالتوازي مما يسرّع بدء التطبيق.

8. **CSV parsing في isolate:** استخدام `compute()` لتحليل CSV في background isolate يمنع تجميد واجهة المستخدم.

9. **نظام Responsive:** دعم Desktop (sidebar) و Mobile (drawer) مع breakpoints واضحة.

10. **Input sanitization في quick_add_product:** استخدام `FormValidators` و `InputSanitizer.sanitize()`, `sanitizeDecimal()`, `sanitizeNumeric()` - نموذج يجب تعميمه.

11. **لا توجد أسرار مكشوفة:** Supabase URL و Anon Key يُمرران عبر `--dart-define` بدون قيم افتراضية.

12. **لا توجد عبارات `print()`:** التطبيق نظيف من `print()` (فقط بضع `debugPrint` محدودة).

---

## 📋 خطة الإصلاح المقترحة (مرتبة بالأولوية)

| # | الأولوية | المشكلة | الرمز | الجهد | التأثير |
|---|----------|---------|-------|-------|---------|
| 1 | 🔴 حرجة | عمليات مالية محاكاة (stubs) | CRT-001 | 3-5 أيام | فقدان بيانات مالية |
| 2 | 🔴 حرجة | لا صلاحيات لتغيير الأسعار | CRT-007 | 4 ساعات | تلاعب بالأسعار |
| 3 | 🔴 حرجة | نقل مخزون بدون حركة استلام | CRT-004 | 4 ساعات | فقدان مخزون |
| 4 | 🔴 حرجة | استلام بضاعة بدون transaction | CRT-005 | 2 ساعات | عدم تطابق مخزون |
| 5 | 🔴 حرجة | معرّف منتج بالمللي ثانية | CRT-003 | 30 دقيقة | تكرار معرّفات |
| 6 | 🔴 حرجة | GoRouter debug logging | CRT-006 | 5 دقائق | تسريب معلومات |
| 7 | 🔴 حرجة | مفتاح DB على الويب | CRT-002 | 2 أيام | بيانات مكشوفة |
| 8 | 🔴 حرجة | غياب Accessibility | CRT-008 | 5-7 أيام | عدم امتثال |
| 9 | 🟡 متوسطة | مخزون سالب مسموح | MED-005 | 4 ساعات | أخطاء مخزون |
| 10 | 🟡 متوسطة | ابتلاع أخطاء صامت | MED-002 | 2-3 أيام | تجربة سيئة |
| 11 | 🟡 متوسطة | Hardcoded strings | MED-001 | 3-4 أيام | لا ترجمة |
| 12 | 🟡 متوسطة | تحميل كل البيانات | MED-003 | 2 أيام | بطء |
| 13 | 🟡 متوسطة | لا debounce على البحث | MED-006 | 2 ساعات | ضغط DB |
| 14 | 🟡 متوسطة | أيقونات لا تنعكس RTL | MED-007 | 2 ساعات | مظهر |
| 15 | 🟡 متوسطة | لا تأكيد قبل عمليات حرجة | MED-008 | 3 ساعات | أخطاء بشرية |
| 16 | 🟡 متوسطة | GetIt + Riverpod مختلطين | MED-010 | 3-5 أيام | صعوبة صيانة |
| 17 | 🟡 متوسطة | حد أعلى للمدخلات | MED-009 | 3 ساعات | تلاعب |
| 18 | 🟡 متوسطة | باغ معاينة الإيصال | MED-012 | 15 دقيقة | باغ وظيفي |
| 19 | 🟡 متوسطة | pipe-separated storage | MED-013 | 4 ساعات | كسر بيانات |
| 20 | 🟡 متوسطة | فتح وردية بـ 'unknown' | MED-014 | 30 دقيقة | ثغرة |
| 21 | 🟡 متوسطة | حسابات عملة بـ double | MED-015 | 2 ساعات | أخطاء دقة |
| 22 | 🟡 متوسطة | اختبارات وهمية | MED-016 | 3-5 أيام | تغطية زائفة |
| 23 | 🟡 متوسطة | اختبارات تكامل فارغة | MED-017 | 2-3 أيام | لا تغطية |
| 24 | 🟡 متوسطة | كوبون بالاسم | MED-018 | 2 ساعات | ثغرة |
| 25 | 🟡 متوسطة | ملف راوتر كبير | MED-011 | 4 ساعات | صعوبة صيانة |

**الإجمالي التقديري:** ~25-35 يوم عمل

---

## 🔚 خاتمة

تطبيق الكاشير مبني على أساس هندسي متين مع هيكلة monorepo احترافية ودعم ممتاز للعمل بدون إنترنت. البنية التحتية للاختبارات جاهزة لكنها تحتاج لاختبارات حقيقية. **الأولوية القصوى** يجب أن تكون:

1. **استبدال العمليات المحاكاة (stubs) بعمليات فعلية** - وهذا هو الخطر الأكبر حالياً لأن عمليات مالية حرجة لا تُحفظ فعلياً
2. **إضافة فحوصات الصلاحيات** - خاصة لتغيير الأسعار وعمليات المخزون
3. **إصلاح سلامة البيانات** - نقل المخزون واستلام البضاعة بـ database transactions

التحسينات متوسطة الأولوية (الترجمة، الوصولية، الأداء) يمكن جدولتها على مدى الأسابيع القادمة. بشكل عام، التطبيق في حالة **جيدة هيكلياً لكنه يحتاج لاستكمال التنفيذ** في عدة مناطق حرجة قبل الإطلاق الإنتاجي.

---

*تم إنشاء هذا التقرير بواسطة Lead Audit Agent - منصة الحي*
*تاريخ الإنشاء: 28 فبراير 2026*
