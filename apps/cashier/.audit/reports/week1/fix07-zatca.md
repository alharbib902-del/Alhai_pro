# Fix 07 — تطبيق ZATCA الفوترة الإلكترونية (🔴 حرج)
# الوقت: 20-30 ساعة | الأولوية: 7 (مخالفة قانونية)

أنت مطور خبير في أنظمة الفوترة الإلكترونية السعودية ومتطلبات ZATCA المرحلة الثانية.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات مطلوبة لـ ZATCA
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. أضف المكتبات
```bash
flutter pub add qr_flutter pointycastle asn1lib crypto
```

### 2. أنشئ lib/services/zatca/ مع:
- `zatca_tlv_encoder.dart` — ترميز TLV (Tag 1-5: اسم البائع، الرقم الضريبي، التاريخ، الإجمالي، الضريبة)
- `zatca_qr_service.dart` — إنشاء QR Code data من TLV → Base64
- `vat_calculator.dart` — حساب ضريبة 15% (calculateVat, addVat, removeVat)

### 3. أضف QR Code في شاشة الإيصال
ابحث عن شاشة الإيصال:
```bash
find . -name "*receipt*" -o -name "*invoice*" | grep -E "\.dart$" | head -10
```
أضف `QrImageView` مع بيانات ZATCA.

### 4. تأكد من وجود كل الحقول المطلوبة في الفاتورة:
- اسم البائع ✓
- الرقم الضريبي ✓
- تاريخ ووقت الفاتورة ✓
- إجمالي الفاتورة ✓
- مبلغ ضريبة القيمة المضافة (15%) ✓
- QR Code ✓

### 5. اكتب اختبارات TLV
أنشئ `test/unit/zatca_tlv_test.dart` للتحقق من صحة الترميز.

سجّل التغييرات في: `.audit/fixes/fix07-log.md`
ابدأ فوراً. لا تسأل أسئلة.
