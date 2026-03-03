# Fix 03 — إضافة Idempotency Keys + حماية الضغط المزدوج (🔴 حرج)
# الوقت: 2-3 ساعات | الأولوية: 3

أنت مطور Flutter خبير. معرّفات المعاملات حالياً بـ DateTime.now().millisecondsSinceEpoch مما يسمح بمعاملات مكررة.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبة uuid إذا غير موجودة

## المهام
1. أضف مكتبة uuid: `flutter pub add uuid`
2. ابحث واستبدل كل `TXN-${DateTime.now().millisecondsSinceEpoch}` بـ UUID
3. أضف حماية الضغط المزدوج (_isProcessing flag) لكل أزرار الدفع
4. عطّل الزر أثناء المعالجة وأظهر CircularProgressIndicator

```bash
grep -rn "TXN-\|DateTime.now().millisecondsSinceEpoch\|transactionId\|orderId" lib/ --include="*.dart" | grep -v test | head -30
grep -rn "onPressed.*pay\|onPressed.*checkout\|onPressed.*submit" lib/ --include="*.dart" | head -20
```

سجّل التغييرات في: `.audit/fixes/fix03-log.md`
ابدأ فوراً. لا تسأل أسئلة.
