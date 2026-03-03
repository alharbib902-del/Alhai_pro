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
grep -rn "insertTransaction\|updateBalance\|insertPayment\|insertRefund\|updateStock\|insertOrder" lib/ --include="*.dart" | head -40
grep -rn -A5 "await.*insert\|await.*update\|await.*delete" lib/features/ --include="*.dart" | grep -B2 "await" | head -60
```

### 2. لف كل مجموعة عمليات مالية بـ transaction
كل مكان فيه أكثر من عملية DB متتالية في سياق مالي يجب أن يكون:
```dart
await _db.transaction(() async {
  await _db.transactionsDao.insertTransaction(transaction);
  await _db.balanceDao.updateBalance(storeId, amount);
  await _db.stockDao.updateStock(productId, -quantity);
});
```

### 3. أضف rollback handling مع error dialog للمستخدم

### 4. الشاشات المستهدفة (تحقق من كل واحدة)
- شاشة البيع / الدفع (checkout)
- شاشة الاسترجاع (refund)
- شاشة تعديل المخزون (stock adjustment)
- شاشة المصروفات (expenses)
- أي شاشة أخرى فيها أكثر من عملية DB متتالية

### 5. التحقق
```bash
grep -rn "insertTransaction\|insertPayment\|insertRefund" lib/ --include="*.dart" | grep -v "transaction(" | grep -v "test" | grep -v "//"
# يجب أن تكون النتيجة فارغة
```

سجّل التغييرات في: `.audit/fixes/fix02-log.md`
ابدأ فوراً. لا تسأل أسئلة.
