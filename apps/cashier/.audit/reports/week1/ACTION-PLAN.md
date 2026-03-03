# ═══════════════════════════════════════════════════════════════════
# 🛠️ خطة العمل التنفيذية — إصلاح تطبيق Cashier
# ═══════════════════════════════════════════════════════════════════
# 📅 التاريخ: 2026-03-01
# 📊 المرجع: تقرير المراجعة الشاملة (56 مشكلة)
# ⏱️ المدة المتوقعة: 4 أسابيع
# 🎯 الهدف: رفع التقييم من 4.5/10 إلى 8+/10
# ═══════════════════════════════════════════════════════════════════

---

# 📋 جدول المحتويات

1. [الأسبوع 1: إصلاحات حرجة — فك حظر البناء + سلامة البيانات](#week1)
2. [الأسبوع 2: ZATCA + الطباعة + النسخ الاحتياطي](#week2)
3. [الأسبوع 3: الاختبارات + الأمان](#week3)
4. [الأسبوع 4: البنية التحتية + التحسينات](#week4)
5. [سكربت التشغيل التلقائي](#auto-script)

---

# ═══════════════════════════════════════════════════════════════════
# 🔴 الأسبوع 1: إصلاحات حرجة (فك حظر البناء + سلامة البيانات)
# الوقت المتوقع: 25-35 ساعة
# ═══════════════════════════════════════════════════════════════════

---

## 📁 الملف: `week1/fix01-compilation-errors.md`

```markdown
# Fix 01 — إصلاح أخطاء التجميع (🔴 حرج)
# الوقت: 2-3 ساعات | الأولوية: 1 (يمنع البناء)

أنت مطور Flutter خبير. المشروع فيه 16 خطأ تجميع يمنع البناء.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- ممنوع حذف ملفات أو تغيير البنية
- ممنوع إضافة مكتبات جديدة

## المهام

### 1. اكتشف جميع الأخطاء
```bash
cd apps/cashier && flutter analyze 2>&1 | grep -E "error •|Error:" | head -30
```

### 2. إصلاح أخطاء int/double mismatch
ابحث عن كل الأماكن التي يتم فيها تمرير `int` حيث يُتوقع `double` والعكس:
```bash
grep -rn "\.toDouble()\|\.toInt()\|as double\|as int" lib/ | head -30
```
- أصلح بإضافة `.toDouble()` حيث يلزم
- لا تستخدم `as double` (unsafe) — استخدم `.toDouble()` دائماً

### 3. إصلاح ambiguous extensions
ابحث عن extensions متعارضة:
```bash
grep -rn "extension " lib/ | head -20
```
- حدّد Extension بالاسم الكامل حيث يوجد تعارض
- مثال: بدل `value.toCurrency()` استخدم `CurrencyExtension(value).toCurrency()`

### 4. تحقق من النجاح
```bash
flutter analyze 2>&1 | grep -c "error"
# يجب أن تكون النتيجة 0
```

## قاعدة ذهبية
- كل إصلاح يجب أن يكون minimal — لا تُعدّ refactor
- شغّل `flutter analyze` بعد كل مجموعة إصلاحات
- سجّل كل تغيير في ملف: `.audit/fixes/fix01-log.md`
```

---

## 📁 الملف: `week1/fix02-financial-transactions.md`

```markdown
# Fix 02 — حماية المعاملات المالية بـ Atomic Transactions (🔴 حرج)
# الوقت: 4-6 ساعات | الأولوية: 2 (سلامة البيانات المالية)

أنت مطور خبير في قواعد البيانات و Drift ORM. المعاملات المالية حالياً غير atomic — يمكن أن تفشل جزئياً وتتلف البيانات.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- ممنوع حذف ملفات أو تغيير schema قاعدة البيانات
- ممنوع إضافة مكتبات جديدة

## المهام

### 1. اكتشف جميع العمليات المالية غير المحمية
```bash
# ابحث عن insertTransaction, updateBalance, insertPayment بدون transaction()
grep -rn "insertTransaction\|updateBalance\|insertPayment\|insertRefund\|updateStock\|insertOrder" lib/ --include="*.dart" | head -40

# ابحث عن الشاشات التي تنفذ عمليات متعددة متتالية
grep -rn -A5 "await.*insert\|await.*update\|await.*delete" lib/features/ --include="*.dart" | grep -B2 "await" | head -60
```

### 2. لف كل مجموعة عمليات مالية بـ transaction
لكل شاشة فيها عمليات مالية متتالية:

**قبل (خطر):**
```dart
await _db.transactionsDao.insertTransaction(transaction);
await _db.balanceDao.updateBalance(storeId, amount);
await _db.stockDao.updateStock(productId, -quantity);
```

**بعد (آمن):**
```dart
await _db.transaction(() async {
  await _db.transactionsDao.insertTransaction(transaction);
  await _db.balanceDao.updateBalance(storeId, amount);
  await _db.stockDao.updateStock(productId, -quantity);
});
```

### 3. أضف rollback handling
```dart
try {
  await _db.transaction(() async {
    // ... العمليات
  });
  // نجاح — أظهر رسالة نجاح
} catch (e) {
  // فشل — كل العمليات ملغاة تلقائياً
  // أظهر رسالة خطأ للمستخدم
  debugPrint('Transaction failed: $e');
  _showErrorDialog('فشلت العملية. يرجى المحاولة مرة أخرى.');
}
```

### 4. الشاشات المستهدفة (تحقق من كل واحدة)
ابحث في هذه الشاشات وأصلحها:
- شاشة البيع / الدفع (checkout)
- شاشة الاسترجاع (refund)
- شاشة تعديل المخزون (stock adjustment)
- شاشة المصروفات (expenses)
- أي شاشة أخرى فيها أكثر من عملية DB متتالية

### 5. التحقق
```bash
# تأكد إنه ما في عمليات مالية بدون transaction
grep -rn "insertTransaction\|insertPayment\|insertRefund" lib/ --include="*.dart" | grep -v "transaction(" | grep -v "test" | grep -v "//"
# يجب أن تكون النتيجة فارغة
```

## سجّل التغييرات في: `.audit/fixes/fix02-log.md`
```

---

## 📁 الملف: `week1/fix03-idempotency.md`

```markdown
# Fix 03 — إضافة Idempotency Keys (🔴 حرج)
# الوقت: 2-3 ساعات | الأولوية: 3 (منع المعاملات المكررة)

أنت مطور Flutter خبير. حالياً معرّفات المعاملات تُنشأ بـ `DateTime.now().millisecondsSinceEpoch` مما يسمح بمعاملات مكررة عند الضغط المزدوج.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبة `uuid` إذا غير موجودة

## المهام

### 1. تحقق من مكتبة uuid
```bash
grep "uuid" pubspec.yaml
# إذا غير موجودة:
flutter pub add uuid
```

### 2. ابحث عن جميع أماكن إنشاء معرّفات المعاملات
```bash
grep -rn "TXN-\|DateTime.now().millisecondsSinceEpoch\|transactionId\|orderId\|paymentId" lib/ --include="*.dart" | grep -v test | head -30
```

### 3. استبدل بـ UUID
**قبل:**
```dart
final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
```

**بعد:**
```dart
import 'package:uuid/uuid.dart';
const _uuid = Uuid();
// ...
final transactionId = 'TXN-${_uuid.v4()}';
```

### 4. أضف حماية الضغط المزدوج في أزرار الدفع
```bash
grep -rn "onPressed.*pay\|onPressed.*checkout\|onPressed.*submit" lib/ --include="*.dart" | head -20
```

لكل زر دفع/إرسال:
```dart
bool _isProcessing = false;

Future<void> _handlePayment() async {
  if (_isProcessing) return; // منع الضغط المزدوج
  setState(() => _isProcessing = true);
  try {
    await _processPayment();
  } finally {
    if (mounted) setState(() => _isProcessing = false);
  }
}

// في الـ UI:
ElevatedButton(
  onPressed: _isProcessing ? null : _handlePayment,
  child: _isProcessing
    ? const CircularProgressIndicator()
    : const Text('ادفع'),
)
```

## سجّل التغييرات في: `.audit/fixes/fix03-log.md`
```

---

## 📁 الملف: `week1/fix04-error-states.md`

```markdown
# Fix 04 — إضافة Error States لجميع الشاشات (🔴 حرج)
# الوقت: 8-12 ساعة | الأولوية: 4 (تجربة المستخدم + تشخيص المشاكل)

أنت مطور Flutter خبير في UX. حالياً 47 شاشة فيها try/catch صامت بدون أي تنبيه للمستخدم.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إنشاء widgets مشتركة جديدة في shared_ui

## المهام

### 1. أنشئ Error Widget مشترك
أنشئ ملف `packages/shared_ui/lib/widgets/error_state_widget.dart`:
```dart
import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 2. أنشئ Empty State Widget
أنشئ ملف `packages/shared_ui/lib/widgets/empty_state_widget.dart`:
```dart
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
```

### 3. ابحث عن كل try/catch الصامت وأصلحه
```bash
# ابحث عن catch فارغ أو بـ debugPrint فقط
grep -rn -A3 "catch (e" lib/features/ --include="*.dart" | grep -B1 "debugPrint\|// \|print\|{$" | head -60
```

لكل شاشة:
**قبل:**
```dart
try {
  final data = await repository.getData();
  setState(() => _items = data);
} catch (e) {
  debugPrint('Error: $e');
}
```

**بعد:**
```dart
try {
  setState(() => _isLoading = true);
  final data = await repository.getData();
  setState(() { _items = data; _error = null; });
} catch (e) {
  setState(() => _error = 'حدث خطأ في تحميل البيانات');
  debugPrint('Error: $e');
} finally {
  setState(() => _isLoading = false);
}

// في build():
if (_error != null)
  ErrorStateWidget(message: _error!, onRetry: _loadData)
else if (_isLoading)
  const Center(child: CircularProgressIndicator())
else if (_items.isEmpty)
  EmptyStateWidget(message: 'لا توجد بيانات')
else
  ListView.builder(...)
```

### 4. ابدأ بالشاشات الأهم (حسب الأولوية)
1. شاشة البيع (POS الرئيسية)
2. شاشة المنتجات
3. شاشة المبيعات/التقارير
4. شاشة المخزون
5. شاشة العملاء
6. شاشة الإعدادات
7. باقي الشاشات

## سجّل التغييرات في: `.audit/fixes/fix04-log.md`
```

---

## 📁 الملف: `week1/fix05-crash-reporting.md`

```markdown
# Fix 05 — تكامل Crash Reporting مع Sentry (🔴 حرج)
# الوقت: 4-6 ساعات | الأولوية: 5 (رؤية أخطاء الإنتاج)

أنت مطور Flutter خبير في المراقبة والـ observability.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبة sentry_flutter

## المهام

### 1. أضف sentry_flutter
```bash
flutter pub add sentry_flutter
```

### 2. عدّل main.dart
ابحث عن `main.dart`:
```bash
find . -name "main.dart" -path "*/lib/*" | head -5
```

عدّله ليكون:
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.environment = const String.fromEnvironment('ENV', defaultValue: 'development');
      options.tracesSampleRate = 0.3;
      options.enableAutoPerformanceTracing = true;
      options.attachScreenshot = true;
      options.sendDefaultPii = false; // لا ترسل بيانات شخصية
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### 3. استبدل debugPrint في error handlers بـ Sentry.captureException
```bash
grep -rn "debugPrint.*error\|debugPrint.*Error\|debugPrint.*fail" lib/ --include="*.dart" | head -30
```

**قبل:**
```dart
} catch (e) {
  debugPrint('Error: $e');
}
```

**بعد:**
```dart
} catch (e, stackTrace) {
  Sentry.captureException(e, stackTrace: stackTrace);
  debugPrint('Error: $e');
}
```

### 4. عدّل runZonedGuarded الموجود
```bash
grep -rn "runZonedGuarded\|FlutterError.onError" lib/ --include="*.dart"
```

تأكد إن الـ global error handler يرسل لـ Sentry:
```dart
FlutterError.onError = (details) {
  Sentry.captureException(details.exception, stackTrace: details.stack);
};
```

### 5. أضف الـ DSN في build arguments
في ملف التوثيق أو README أضف:
```bash
# للتشغيل مع Sentry
flutter run --dart-define=SENTRY_DSN=https://xxx@sentry.io/yyy --dart-define=ENV=development
```

## سجّل التغييرات في: `.audit/fixes/fix05-log.md`
```

---

## 📁 الملف: `week1/fix06-audit-trail.md`

```markdown
# Fix 06 — تفعيل Audit Trail للعمليات المالية (🔴 حرج)
# الوقت: 6-8 ساعات | الأولوية: 6 (سجل العمليات المالية)

أنت مطور خبير في أنظمة المحاسبة. `AuditLogDao` موجود في المشروع لكن غير مستخدم.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- ممنوع تغيير schema قاعدة البيانات (AuditLog table موجود)

## المهام

### 1. اكتشف AuditLogDao الموجود
```bash
find . -name "*audit*" -o -name "*AuditLog*" | head -10
cat $(find . -name "*audit_log_dao*" -path "*/lib/*" | head -1)
```

### 2. أنشئ AuditService مركزي
أنشئ `lib/services/audit_service.dart`:
```dart
import 'package:your_package/database/daos/audit_log_dao.dart';

enum AuditAction {
  sale, refund, stockAdjustment, expense,
  productCreate, productUpdate, productDelete,
  customerCreate, customerUpdate,
  login, logout, settingsChange,
}

class AuditService {
  final AuditLogDao _dao;
  
  AuditService(this._dao);
  
  Future<void> log({
    required AuditAction action,
    required String userId,
    required String storeId,
    String? entityId,
    String? entityType,
    Map<String, dynamic>? details,
  }) async {
    await _dao.insertLog(
      action: action.name,
      userId: userId,
      storeId: storeId,
      entityId: entityId,
      entityType: entityType,
      details: details != null ? jsonEncode(details) : null,
      timestamp: DateTime.now(),
    );
  }
}
```

### 3. سجّل AuditService في GetIt
```bash
grep -rn "GetIt\|getIt\|serviceLocator" lib/ --include="*.dart" | grep "register" | head -10
```
أضف:
```dart
getIt.registerSingleton<AuditService>(AuditService(getIt<AuditLogDao>()));
```

### 4. أضف audit logging لكل عملية مالية
ابحث في شاشات البيع والدفع والاسترجاع:
```bash
grep -rn "insertTransaction\|insertPayment\|insertRefund\|updateStock" lib/features/ --include="*.dart" | head -20
```

بعد كل عملية ناجحة:
```dart
await _db.transaction(() async {
  await _db.transactionsDao.insertTransaction(transaction);
  await _db.balanceDao.updateBalance(storeId, amount);
  
  // سجّل في audit trail
  await _auditService.log(
    action: AuditAction.sale,
    userId: currentUserId,
    storeId: storeId,
    entityId: transaction.id,
    entityType: 'transaction',
    details: {'amount': amount, 'items': itemCount},
  );
});
```

## سجّل التغييرات في: `.audit/fixes/fix06-log.md`
```

---

# ═══════════════════════════════════════════════════════════════════
# 🟠 الأسبوع 2: ZATCA + الطباعة + النسخ الاحتياطي
# الوقت المتوقع: 50-70 ساعة
# ═══════════════════════════════════════════════════════════════════

---

## 📁 الملف: `week2/fix07-zatca.md`

```markdown
# Fix 07 — تطبيق ZATCA الفوترة الإلكترونية (🔴 حرج)
# الوقت: 20-30 ساعة | الأولوية: 7 (مخالفة قانونية)

أنت مطور خبير في أنظمة الفوترة الإلكترونية السعودية ومتطلبات ZATCA المرحلة الثانية.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات مطلوبة لـ ZATCA
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. أضف المكتبات المطلوبة
```bash
flutter pub add qr_flutter    # لإنشاء QR Code
flutter pub add pointycastle  # للتشفير
flutter pub add asn1lib       # لترميز ASN1
flutter pub add crypto         # للـ hashing
```

### 2. أنشئ ZATCA TLV Encoder
أنشئ `lib/services/zatca/zatca_tlv_encoder.dart`:
```dart
/// يُرمّز بيانات الفاتورة بتنسيق TLV حسب متطلبات ZATCA
/// Tag-Length-Value format
class ZatcaTlvEncoder {
  /// Tags المطلوبة:
  /// 1 = اسم البائع (Seller Name)
  /// 2 = الرقم الضريبي (VAT Registration Number)
  /// 3 = تاريخ ووقت الفاتورة (Invoice Timestamp)
  /// 4 = إجمالي الفاتورة مع الضريبة (Invoice Total with VAT)
  /// 5 = مبلغ الضريبة (VAT Amount)
  
  static List<int> encode({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final bytes = <int>[];
    bytes.addAll(_encodeTlv(1, utf8.encode(sellerName)));
    bytes.addAll(_encodeTlv(2, utf8.encode(vatNumber)));
    bytes.addAll(_encodeTlv(3, utf8.encode(timestamp.toIso8601String())));
    bytes.addAll(_encodeTlv(4, utf8.encode(totalWithVat.toStringAsFixed(2))));
    bytes.addAll(_encodeTlv(5, utf8.encode(vatAmount.toStringAsFixed(2))));
    return bytes;
  }
  
  static List<int> _encodeTlv(int tag, List<int> value) {
    return [tag, value.length, ...value];
  }
  
  static String toBase64(List<int> tlvBytes) {
    return base64Encode(Uint8List.fromList(tlvBytes));
  }
}
```

### 3. أنشئ QR Code Generator
أنشئ `lib/services/zatca/zatca_qr_service.dart`:
```dart
class ZatcaQrService {
  final String sellerName;
  final String vatNumber;
  
  ZatcaQrService({required this.sellerName, required this.vatNumber});
  
  String generateQrData({
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final tlvBytes = ZatcaTlvEncoder.encode(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );
    return ZatcaTlvEncoder.toBase64(tlvBytes);
  }
}
```

### 4. أضف QR Code في شاشة الفاتورة/الإيصال
ابحث عن شاشة الإيصال:
```bash
find . -name "*receipt*" -o -name "*invoice*" | grep -E "\.dart$" | head -10
```

أضف QR Code widget:
```dart
QrImageView(
  data: _zatcaQrService.generateQrData(
    timestamp: transaction.createdAt,
    totalWithVat: transaction.total,
    vatAmount: transaction.vatAmount,
  ),
  version: QrVersions.auto,
  size: 150,
)
```

### 5. تأكد من وجود الحقول المطلوبة في الفاتورة
حسب ZATCA يجب أن تحتوي الفاتورة على:
- [ ] اسم البائع
- [ ] الرقم الضريبي
- [ ] تاريخ ووقت الفاتورة
- [ ] إجمالي الفاتورة
- [ ] مبلغ ضريبة القيمة المضافة (15%)
- [ ] QR Code

### 6. أضف حساب الضريبة إذا غير موجود
```bash
grep -rn "vat\|VAT\|tax\|ضريب" lib/ --include="*.dart" | head -20
```

```dart
class VatCalculator {
  static const double vatRate = 0.15; // 15% VAT
  
  static double calculateVat(double amount) => amount * vatRate;
  static double addVat(double amount) => amount * (1 + vatRate);
  static double removeVat(double amountWithVat) => amountWithVat / (1 + vatRate);
}
```

## سجّل التغييرات في: `.audit/fixes/fix07-log.md`
```

---

## 📁 الملف: `week2/fix08-printing.md`

```markdown
# Fix 08 — تكامل الطباعة الحقيقية ESC/POS (🔴 حرج)
# الوقت: 16-24 ساعة | الأولوية: 8 (POS بدون طباعة غير قابل للاستخدام)

أنت مطور Flutter خبير في أنظمة POS وتكامل الطابعات الحرارية.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات الطباعة
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. أضف مكتبات الطباعة
```bash
flutter pub add esc_pos_utils
flutter pub add esc_pos_bluetooth  # للبلوتوث
flutter pub add esc_pos_printer    # للشبكة
# لأجهزة Sunmi المدمجة:
flutter pub add sunmi_printer_plus
```

### 2. أنشئ Print Service abstraction
أنشئ `lib/services/printing/print_service.dart`:
```dart
abstract class PrintService {
  Future<bool> connect();
  Future<void> disconnect();
  Future<bool> printReceipt(ReceiptData data);
  Future<bool> openCashDrawer();
  Future<bool> get isConnected;
}

class ReceiptData {
  final String storeName;
  final String storeAddress;
  final String vatNumber;
  final String receiptNumber;
  final DateTime date;
  final List<ReceiptItem> items;
  final double subtotal;
  final double vatAmount;
  final double total;
  final double? cashReceived;
  final double? change;
  final String paymentMethod;
  final String? qrCodeData; // ZATCA QR
  
  // ... constructor
}
```

### 3. أنشئ ESC/POS Receipt Builder
أنشئ `lib/services/printing/receipt_builder.dart`:
```dart
class ReceiptBuilder {
  static List<int> build(ReceiptData data) {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    
    // Header
    bytes += generator.text(data.storeName,
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text(data.storeAddress, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('الرقم الضريبي: ${data.vatNumber}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();
    
    // Items
    for (final item in data.items) {
      bytes += generator.row([
        PosColumn(text: item.name, width: 6),
        PosColumn(text: '${item.quantity}x', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: item.total.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    
    bytes += generator.hr();
    
    // Totals
    bytes += generator.row([
      PosColumn(text: 'المجموع الفرعي', width: 6),
      PosColumn(text: data.subtotal.toStringAsFixed(2), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'ضريبة القيمة المضافة (15%)', width: 6),
      PosColumn(text: data.vatAmount.toStringAsFixed(2), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'الإجمالي', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: '${data.total.toStringAsFixed(2)} SAR', width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    
    // QR Code (ZATCA)
    if (data.qrCodeData != null) {
      bytes += generator.qrcode(data.qrCodeData!);
    }
    
    bytes += generator.feed(3);
    bytes += generator.cut();
    
    return bytes;
  }
}
```

### 4. ربط الطباعة بشاشة الدفع
ابحث عن شاشة الدفع:
```bash
find . -name "*checkout*" -o -name "*payment*" -o -name "*pos*" | grep -E "\.dart$" | grep -i "screen\|page" | head -10
```

بعد نجاح الدفع:
```dart
// بعد حفظ المعاملة بنجاح
final receiptData = ReceiptData(
  storeName: store.name,
  // ... fill data
  qrCodeData: zatcaQrService.generateQrData(...),
);
await printService.printReceipt(receiptData);
```

### 5. أنشئ شاشة إعدادات الطابعة الفعلية
اربط الإعدادات الموجودة بالطابعة الحقيقية:
- اكتشاف الطابعات (بلوتوث/شبكة/USB)
- اختبار الطباعة
- حفظ الطابعة المفضلة

## سجّل التغييرات في: `.audit/fixes/fix08-log.md`
```

---

## 📁 الملف: `week2/fix09-backup.md`

```markdown
# Fix 09 — تنفيذ النسخ الاحتياطي الفعلي (🔴 حرج)
# الوقت: 12-16 ساعة | الأولوية: 9 (خطر فقدان البيانات)

أنت مطور Flutter خبير في إدارة البيانات والنسخ الاحتياطي.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. ابحث عن كود النسخ الاحتياطي الوهمي
```bash
grep -rn "backup\|Backup\|restore\|Restore\|Future.delayed" lib/ --include="*.dart" | head -20
```

### 2. أنشئ Backup Service حقيقي
أنشئ `lib/services/backup/backup_service.dart`:
```dart
class BackupService {
  final AppDatabase _db;
  
  BackupService(this._db);
  
  /// تصدير قاعدة البيانات كملف
  Future<File> exportDatabase() async {
    final dbFile = File(await _db.databasePath);
    final backupDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupFile = File('${backupDir.path}/backup_$timestamp.db');
    return dbFile.copy(backupFile.path);
  }
  
  /// تصدير كـ JSON (أكثر مرونة)
  Future<File> exportAsJson() async {
    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'products': await _db.productsDao.getAllProducts(),
      'categories': await _db.categoriesDao.getAllCategories(),
      'transactions': await _db.transactionsDao.getAllTransactions(),
      'customers': await _db.customersDao.getAllCustomers(),
      // ... باقي الجداول
    };
    
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));
    return file;
  }
  
  /// استيراد من JSON
  Future<void> importFromJson(File file) async {
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    
    await _db.transaction(() async {
      // امسح البيانات القديمة
      // أدخل البيانات الجديدة
      // ... لكل جدول
    });
  }
  
  /// مشاركة النسخة الاحتياطية
  Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles([XFile(backupFile.path)],
      subject: 'نسخة احتياطية - Cashier');
  }
}
```

### 3. استبدل الكود الوهمي بالحقيقي
ابحث عن `Future.delayed` في سياق النسخ الاحتياطي واستبدله:
```bash
grep -rn "Future.delayed" lib/ --include="*.dart" | head -10
```

### 4. أضف جدولة تلقائية (اختياري)
```dart
// في main.dart أو AppLifecycleObserver
// نسخ احتياطي تلقائي كل 24 ساعة
```

## سجّل التغييرات في: `.audit/fixes/fix09-log.md`
```

---

## 📁 الملف: `week2/fix10-privacy-policy.md`

```markdown
# Fix 10 — إضافة سياسة الخصوصية وحذف البيانات (🔴 حرج)
# الوقت: 4-6 ساعات | الأولوية: 10 (مخالفة PDPL + متطلبات المتاجر)

أنت خبير قانوني تقني متخصص في أنظمة حماية البيانات السعودية (PDPL).

## الصلاحيات
- إنشاء ملفات جديدة
- تعديل شاشات الإعدادات

## المهام

### 1. أنشئ شاشة سياسة الخصوصية
أنشئ `lib/features/settings/privacy_policy_screen.dart` تتضمن:
- ما البيانات المُجمّعة
- كيف تُستخدم
- كيف تُخزّن وتُحمى
- حقوق المستخدم (الوصول، التصحيح، الحذف)
- معلومات التواصل

### 2. أنشئ آلية حذف بيانات العملاء
أنشئ `lib/services/data_deletion_service.dart`:
```dart
class DataDeletionService {
  Future<void> deleteCustomerData(String customerId) async {
    await _db.transaction(() async {
      await _db.customersDao.deleteCustomer(customerId);
      await _db.ordersDao.anonymizeCustomerOrders(customerId);
      // لا تحذف المعاملات المالية — غيّر الاسم لـ "عميل محذوف"
    });
    
    await _auditService.log(
      action: AuditAction.customerDataDeletion,
      entityId: customerId,
    );
  }
  
  Future<void> exportCustomerData(String customerId) async {
    // تصدير كل بيانات العميل كـ JSON
  }
}
```

### 3. أضف رابط سياسة الخصوصية في الإعدادات وشاشة التسجيل

## سجّل التغييرات في: `.audit/fixes/fix10-log.md`
```

---

# ═══════════════════════════════════════════════════════════════════
# 🟡 الأسبوع 3: الاختبارات + الأمان
# الوقت المتوقع: 40-50 ساعة
# ═══════════════════════════════════════════════════════════════════

---

## 📁 الملف: `week3/fix11-unit-tests.md`

```markdown
# Fix 11 — كتابة Unit Tests لمنطق الأعمال (🔴 حرج)
# الوقت: 20-30 ساعة | الأولوية: 11

أنت مهندس جودة (QA) خبير في Flutter testing.

## الصلاحيات
- إنشاء ملفات test جديدة فقط
- قراءة كل ملفات المشروع
- ممنوع تعديل كود الإنتاج

## المهام

### 1. اكتب اختبارات لمنطق السلة (Cart Logic)
أنشئ `test/unit/cart_test.dart`:
```dart
group('Cart Logic', () {
  test('إضافة منتج للسلة', ...);
  test('زيادة الكمية', ...);
  test('إنقاص الكمية', ...);
  test('حذف منتج من السلة', ...);
  test('حساب المجموع الفرعي', ...);
  test('حساب الضريبة 15%', ...);
  test('حساب الإجمالي مع الضريبة', ...);
  test('سلة فارغة ترجع صفر', ...);
  test('كمية سالبة ترمي خطأ', ...);
  test('منتج بسعر صفر', ...);
  test('تطبيق خصم نسبي', ...);
  test('تطبيق خصم مبلغ ثابت', ...);
  test('خصم أكبر من المجموع', ...);
});
```

### 2. اختبارات الدفع (Payment Logic)
أنشئ `test/unit/payment_test.dart`:
```dart
group('Payment Logic', () {
  test('دفع نقدي — حساب الباقي', ...);
  test('دفع نقدي — مبلغ أقل من المطلوب', ...);
  test('دفع بطاقة — المبلغ الكامل', ...);
  test('دفع مقسّم — نقدي + بطاقة', ...);
  test('استرجاع كامل', ...);
  test('استرجاع جزئي', ...);
});
```

### 3. اختبارات الضريبة (VAT/Tax)
أنشئ `test/unit/vat_test.dart`:
```dart
group('VAT Calculator', () {
  test('15% على 100 = 15', ...);
  test('إجمالي مع ضريبة 100 = 115', ...);
  test('استخراج الضريبة من إجمالي 115 = 15', ...);
  test('صفر ريال = صفر ضريبة', ...);
  test('تقريب الكسور', ...);
});
```

### 4. اختبارات المخزون (Stock)
أنشئ `test/unit/stock_test.dart`:
```dart
group('Stock Management', () {
  test('خصم كمية بعد البيع', ...);
  test('إضافة كمية بعد الاسترجاع', ...);
  test('تنبيه المخزون المنخفض', ...);
  test('منع بيع منتج بمخزون صفر', ...);
});
```

### 5. اختبارات ZATCA TLV
أنشئ `test/unit/zatca_tlv_test.dart`:
```dart
group('ZATCA TLV Encoder', () {
  test('ترميز TLV صحيح', ...);
  test('Base64 output matches ZATCA format', ...);
  test('كل الحقول المطلوبة موجودة', ...);
});
```

### 6. شغّل الاختبارات وتحقق
```bash
flutter test test/unit/ --reporter expanded
```

## سجّل التغييرات في: `.audit/fixes/fix11-log.md`
```

---

## 📁 الملف: `week3/fix12-security.md`

```markdown
# Fix 12 — إصلاحات الأمان (🟡 مهم)
# الوقت: 12-16 ساعة | الأولوية: 12

أنت خبير أمن تطبيقات.

## المهام

### 1. إضافة Session Timeout
```bash
grep -rn "timeout\|Timeout\|inactivity\|idle" lib/ --include="*.dart" | head -10
```
أنشئ `lib/services/session_manager.dart` مع قفل تلقائي بعد 15 دقيقة.

### 2. إصلاح Multi-tenancy leaks
```bash
# ابحث عن استعلامات بدون storeId
grep -rn "select\|SELECT\|getAllProducts\|getAllOrders\|getAll" lib/ --include="*.dart" | grep -v "storeId\|store_id" | head -20
```
أضف `storeId` filter لكل استعلام.

### 3. إضافة LIMIT للاستعلامات الثقيلة
```bash
grep -rn "getAll\|findAll\|select(" lib/ --include="*.dart" | grep -v "limit\|LIMIT" | head -20
```
أضف `.limit(50)` أو pagination.

### 4. إصلاح demo-store fallback
```bash
grep -rn "demo-store\|demo_store" lib/ --include="*.dart" | head -15
```
استبدل بـ throw exception أو redirect to login.

### 5. إضافة Logout مع تنظيف الجلسة
```bash
grep -rn "logout\|signOut\|logOut" lib/ --include="*.dart" | head -10
```
تأكد إنه يمسح: tokens, cache, session data.

### 6. حماية debugPrint في release
```bash
grep -rn "debugPrint\|print(" lib/ --include="*.dart" | grep -v test | wc -l
```
لف كل debugPrint بـ `kDebugMode`:
```dart
if (kDebugMode) debugPrint('...');
```

## سجّل التغييرات في: `.audit/fixes/fix12-log.md`
```

---

# ═══════════════════════════════════════════════════════════════════
# 🟢 الأسبوع 4: البنية التحتية + التحسينات
# الوقت المتوقع: 30-40 ساعة
# ═══════════════════════════════════════════════════════════════════

---

## 📁 الملف: `week4/fix13-cicd.md`

```markdown
# Fix 13 — إنشاء CI/CD Pipeline (🟡 مهم)
# الوقت: 6-8 ساعات | الأولوية: 13

أنت DevOps engineer خبير في GitHub Actions و Flutter.

## المهام

### 1. أنشئ `.github/workflows/ci.yml`
```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-web:
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
```

### 2. أنشئ فصل البيئات
أنشئ `lib/config/environment.dart`:
```dart
enum Environment { development, staging, production }

class AppConfig {
  static late Environment environment;
  static late String supabaseUrl;
  static late String supabaseAnonKey;
  static late String sentryDsn;
  
  static void initialize() {
    environment = Environment.values.byName(
      const String.fromEnvironment('ENV', defaultValue: 'development'));
    // ...
  }
}
```

## سجّل التغييرات في: `.audit/fixes/fix13-log.md`
```

---

## 📁 الملف: `week4/fix14-cart-persistence.md`

```markdown
# Fix 14 — حفظ السلة محلياً (🟡 مهم)
# الوقت: 4-6 ساعات | الأولوية: 14

أنت مطور Flutter خبير.

## المهام

### 1. أضف جدول draft_orders في DB (أو استخدم الموجود)
```bash
grep -rn "draft\|Draft\|cart\|Cart" lib/ --include="*.dart" | head -20
```

### 2. احفظ السلة تلقائياً عند كل تعديل
```dart
// في Cart Provider/Controller
void _autoSave() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(seconds: 2), () {
    _db.draftOrdersDao.saveDraft(currentCart);
  });
}
```

### 3. استعد السلة عند فتح التطبيق
```dart
Future<void> restoreCart() async {
  final draft = await _db.draftOrdersDao.getLatestDraft();
  if (draft != null) {
    // اعرض dialog: "يوجد سلة سابقة، هل تريد استعادتها؟"
  }
}
```

## سجّل التغييرات في: `.audit/fixes/fix14-log.md`
```

---

## 📁 الملف: `week4/fix15-connectivity.md`

```markdown
# Fix 15 — مراقبة الاتصال + مؤشر Offline (🟡 مهم)
# الوقت: 3-4 ساعات | الأولوية: 15

## المهام

### 1. أضف مكتبة connectivity
```bash
flutter pub add connectivity_plus
```

### 2. أنشئ ConnectivityService
### 3. أضف banner في أعلى الشاشة عند انقطاع الإنترنت
### 4. تفعيل SyncQueue الموجود عند عودة الاتصال

## سجّل التغييرات في: `.audit/fixes/fix15-log.md`
```

---

## 📁 الملف: `week4/fix16-rtl-fixes.md`

```markdown
# Fix 16 — إصلاح مشاكل RTL (🟡 مهم)
# الوقت: 4-6 ساعات | الأولوية: 16

## المهام

### 1. استبدل EdgeInsets.only بـ EdgeInsetsDirectional
```bash
grep -rn "EdgeInsets.only\|EdgeInsets.fromLTRB" lib/ --include="*.dart" | wc -l
```
استبدل الكل:
- `EdgeInsets.only(left:` → `EdgeInsetsDirectional.only(start:`
- `EdgeInsets.only(right:` → `EdgeInsetsDirectional.only(end:`

### 2. استبدل Alignment.centerLeft/Right
```bash
grep -rn "Alignment.centerLeft\|Alignment.centerRight\|Alignment.topLeft\|Alignment.topRight" lib/ --include="*.dart"
```

### 3. تحقق من الأيقونات الاتجاهية
أيقونات السهم يجب أن تنعكس في RTL.

## سجّل التغييرات في: `.audit/fixes/fix16-log.md`
```

---

## 📁 الملف: `week4/fix17-confirmation-dialogs.md`

```markdown
# Fix 17 — إضافة Confirmation Dialogs (🟡 مهم)
# الوقت: 2-3 ساعات | الأولوية: 17

## المهام

### 1. أنشئ ConfirmationDialog widget مشترك
### 2. أضفه قبل كل:
- حذف منتج
- حذف عميل
- استرجاع معاملة
- تعديل مخزون
- مسح السلة
- تسجيل خروج

```bash
grep -rn "delete\|Delete\|remove\|Remove\|حذف" lib/features/ --include="*.dart" | grep "onPressed\|onTap" | head -20
```

## سجّل التغييرات في: `.audit/fixes/fix17-log.md`
```

---

## 📁 الملف: `week4/fix18-soft-delete.md`

```markdown
# Fix 18 — تحويل Hard Delete إلى Soft Delete (🟡 مهم)
# الوقت: 4-6 ساعات | الأولوية: 18

## المهام

### 1. أضف عمود `deleted_at` للجداول المطلوبة
### 2. عدّل DAOs لتصفية السجلات المحذوفة
### 3. عدّل دوال الحذف لتحديث `deleted_at` بدل الحذف الفعلي

## سجّل التغييرات في: `.audit/fixes/fix18-log.md`
```

---

# ═══════════════════════════════════════════════════════════════════
# 🚀 سكربت التشغيل — شغّل كل إصلاح في Terminal منفصل
# ═══════════════════════════════════════════════════════════════════

## التشغيل السريع (كل أمر في Terminal منفصل)

```powershell
# ═══ الأسبوع 1 (4 terminals بالتوازي) ═══

# Terminal 1: أخطاء التجميع + Idempotency
cd C:\Users\basem\OneDrive\Desktop\Alhai\apps\cashier
claude --dangerously-skip-permissions (Get-Content .audit\week1\fix01-compilation-errors.md -Raw)

# Terminal 2: المعاملات المالية + Audit Trail
cd C:\Users\basem\OneDrive\Desktop\Alhai\apps\cashier
claude --dangerously-skip-permissions (Get-Content .audit\week1\fix02-financial-transactions.md -Raw)

# Terminal 3: Error States
cd C:\Users\basem\OneDrive\Desktop\Alhai\apps\cashier
claude --dangerously-skip-permissions (Get-Content .audit\week1\fix04-error-states.md -Raw)

# Terminal 4: Crash Reporting
cd C:\Users\basem\OneDrive\Desktop\Alhai\apps\cashier
claude --dangerously-skip-permissions (Get-Content .audit\week1\fix05-crash-reporting.md -Raw)
```

```powershell
# ═══ الأسبوع 2 (3 terminals بالتوازي) ═══

# Terminal 1: ZATCA
claude --dangerously-skip-permissions (Get-Content .audit\week2\fix07-zatca.md -Raw)

# Terminal 2: الطباعة
claude --dangerously-skip-permissions (Get-Content .audit\week2\fix08-printing.md -Raw)

# Terminal 3: النسخ الاحتياطي + سياسة الخصوصية
claude --dangerously-skip-permissions (Get-Content .audit\week2\fix09-backup.md -Raw)
```

```powershell
# ═══ الأسبوع 3 (2 terminals بالتوازي) ═══

# Terminal 1: Unit Tests
claude --dangerously-skip-permissions (Get-Content .audit\week3\fix11-unit-tests.md -Raw)

# Terminal 2: Security Fixes
claude --dangerously-skip-permissions (Get-Content .audit\week3\fix12-security.md -Raw)
```

```powershell
# ═══ الأسبوع 4 (3 terminals بالتوازي) ═══

# Terminal 1: CI/CD + البيئات
claude --dangerously-skip-permissions (Get-Content .audit\week4\fix13-cicd.md -Raw)

# Terminal 2: Cart + Connectivity
claude --dangerously-skip-permissions (Get-Content .audit\week4\fix14-cart-persistence.md -Raw)

# Terminal 3: RTL + Dialogs + Soft Delete
claude --dangerously-skip-permissions (Get-Content .audit\week4\fix16-rtl-fixes.md -Raw)
```

---

# ═══════════════════════════════════════════════════════════════════
# 📊 ملخص الخطة
# ═══════════════════════════════════════════════════════════════════

| الأسبوع | عدد الإصلاحات | الساعات | النتيجة المتوقعة |
|---------|--------------|---------|-----------------|
| 1 | 6 إصلاحات حرجة | 25-35 | التطبيق يبني + بيانات آمنة |
| 2 | 4 إصلاحات حرجة | 50-70 | ZATCA + طباعة + backup |
| 3 | 2 إصلاحات مهمة | 30-45 | اختبارات + أمان |
| 4 | 6 إصلاحات مهمة | 20-30 | بنية تحتية + تحسينات |
| **الإجمالي** | **18 إصلاح** | **125-180 ساعة** | **تقييم 8+/10** |
