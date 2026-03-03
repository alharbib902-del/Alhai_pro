# Fix 11 — اختبارات الوحدة (Unit Tests)

## التاريخ: 2026-03-01

---

## ملخص النتائج

| ملف الاختبار | عدد الاختبارات | النتيجة |
|---|---|---|
| `test/unit/vat_test.dart` | 33 | ✅ 33/33 نجح |
| `test/unit/zatca_tlv_test.dart` | 29 | ✅ 29/29 نجح |
| `test/unit/payment_test.dart` | 22 | ✅ 22/22 نجح |
| `test/unit/stock_test.dart` | 26 | ⚠️ خطأ compile موجود مسبقاً |
| `test/unit/cart_test.dart` | 24 | ⚠️ خطأ compile موجود مسبقاً |
| **المجموع** | **134** | **84 نجح، 50 لم يُترجَم** |

---

## 1. اختبارات السلة (Cart Tests)

### الملف: `test/unit/cart_test.dart` (جديد)

**الاختبارات:**
- `PosCartItem`: السعر الفعلي، السعر المخصص، الإجمالي، الكمية الافتراضية، JSON roundtrip
- `CartState`: السلة الفارغة، المجموع الفرعي/الكلي، عدد العناصر، خصم (ثابت، نسبة، صفر)
- `CartState` حالات طرفية: سعر صفري، كمية كبيرة، copyWith، clearCustomer
- `HeldInvoice`: وصف (اسم > عميل > عدد)، JSON roundtrip

**الحالة:** ⚠️ لم يُترجَم — خطأ `PaymentMethod` مستورد من مكانين + `isDesktop`/`ResponsiveBuilder` تعارض في `alhai_pos` (مشكلة موجودة مسبقاً في المشروع)

---

## 2. اختبارات الدفع (Payment Tests)

### الملف: `test/unit/payment_test.dart` (جديد)

**الاختبارات (22/22 نجح ✅):**
- الدفع النقدي: المبلغ الدقيق، الباقي، مبلغ غير كافٍ، مبالغ كسرية
- الدفع بالبطاقة: المبلغ الدقيق، مبالغ كسرية
- الدفع المقسّم: نقد+بطاقة، تقسيم غير متساوٍ، تقسيم ثلاثي، مبلغ غير كافٍ
- المرتجعات: كامل، جزئي (صنف واحد، تقليل كمية)، سقف المبلغ الأصلي، VAT
- التحقق: مبلغ سلبي، إجمالي صفري، مبالغ صغيرة، معاملة كبيرة

---

## 3. اختبارات ضريبة القيمة المضافة (VAT Tests)

### الملف: `test/unit/vat_test.dart` (جديد)

**الاختبارات (33/33 نجح ✅):**
- `calculateVat`: 15% على 100/200/1/0/33.33/0.01/999999، نسب مخصصة 5%/10%/0%
- `addVat`: 100→115, 200→230, 0→0, نسبة مخصصة, كسور
- `removeVat`: 115→100, 230→200, 0→0, 57.5→50, roundtrip
- `extractVat`: من 115→15, 230→30, 0→0, 57.5→7.5, تحقق المجموع
- `breakdown`: بدون خصم، مع خصم، خصم كامل، نسبة مخصصة، مجمّع، تقريب، مبالغ POS شائعة

---

## 4. اختبارات المخزون (Stock Tests)

### الملف: `test/unit/stock_test.dart` (جديد)

**الاختبارات:**
- `isLowStock`: عند/تحت/فوق الحد الأدنى، كلاهما صفر، حالات طرفية
- `isOutOfStock`: مخزون صفري/موجب
- خصم المخزون: أساسي، بيع كل المخزون، كشف النقص، مخزون صفري
- إضافة المخزون: استلام، مرتجعات، إضافة لمخزون صفري
- تنبيهات المخزون المنخفض: حدود الحد الأدنى، فحص بعد البيع
- منع البيع: trackInventory + مخزون صفري، بدون تتبع، كمية أكبر من المتاح
- `profitMargin`: حساب صحيح، costPrice null/صفر، هامش سالب

**الحالة:** ⚠️ لم يُترجَم — خطأ `encodeWebP` في `alhai_core/lib/src/services/image_service.dart` (مشكلة موجودة مسبقاً)

---

## 5. اختبارات ZATCA TLV (موجود مسبقاً)

### الملف: `test/unit/zatca_tlv_test.dart` (موجود — لم يُعدَّل)

**الاختبارات (29/29 نجح ✅):**
- `ZatcaTlvEncoder`: encode, decode, Base64, Arabic, amounts, TLV tags
- `ZatcaQrService`: QR generation, VAT number validation, formatting
- `VatCalculator`: basic calculations (subset)

---

## أخطاء Compile الموجودة مسبقاً (ليست من ملفات الاختبار)

### 1. تعارض `PaymentMethod` في `alhai_pos`
```
alhai_pos/lib/src/screens/pos/payment_screen.dart:21:1
'PaymentMethod' is imported from both 'alhai_core' and 'alhai_database'
```

### 2. تعارض `isDesktop`/`isMobile`/`ResponsiveBuilder` في `alhai_pos`
```
alhai_pos/lib/src/screens/pos/pos_screen.dart
'isDesktop' defined in multiple extensions: alhai_design_system + alhai_shared_ui
'ResponsiveBuilder' imported from both packages
```

### 3. خطأ `encodeWebP` في `alhai_core`
```
alhai_core/lib/src/services/image_service.dart:36:15
Method not found: 'encodeWebP'
```

**ملاحظة:** هذه الأخطاء موجودة في كود الإنتاج وليس في ملفات الاختبار. ملفات الاختبار تستورد فقط الوحدات المطلوبة، لكن `flutter test` يُترجم كل شجرة التبعيات.

---

## أمر التشغيل

```bash
# تشغيل الاختبارات الناجحة
flutter test test/unit/vat_test.dart --no-pub --reporter expanded
flutter test test/unit/zatca_tlv_test.dart --no-pub --reporter expanded
flutter test test/unit/payment_test.dart --no-pub --reporter expanded

# هذه تفشل بسبب أخطاء compile موجودة مسبقاً
flutter test test/unit/stock_test.dart --no-pub --reporter expanded
flutter test test/unit/cart_test.dart --no-pub --reporter expanded
```

---

## ملخص الملفات

| الملف | النوع | الوصف |
|---|---|---|
| `test/unit/cart_test.dart` | جديد | اختبارات السلة والفاتورة المعلقة |
| `test/unit/payment_test.dart` | جديد | اختبارات الدفع والمرتجعات |
| `test/unit/vat_test.dart` | جديد | اختبارات ضريبة القيمة المضافة |
| `test/unit/stock_test.dart` | جديد | اختبارات المخزون والتنبيهات |
| `test/unit/zatca_tlv_test.dart` | موجود | لم يُعدَّل (29 اختبار شامل) |
