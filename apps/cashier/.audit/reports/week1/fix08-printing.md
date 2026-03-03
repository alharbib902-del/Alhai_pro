# Fix 08 — تكامل الطباعة الحقيقية ESC/POS (🔴 حرج)
# الوقت: 16-24 ساعة | الأولوية: 8

أنت مطور Flutter خبير في أنظمة POS وتكامل الطابعات الحرارية.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات الطباعة
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. أضف مكتبات الطباعة
```bash
flutter pub add esc_pos_utils esc_pos_bluetooth esc_pos_printer sunmi_printer_plus
```

### 2. أنشئ lib/services/printing/ مع:
- `print_service.dart` — abstract class مع connect/disconnect/printReceipt/openCashDrawer
- `bluetooth_print_service.dart` — implementation للبلوتوث
- `network_print_service.dart` — implementation للشبكة
- `sunmi_print_service.dart` — implementation لأجهزة Sunmi
- `receipt_builder.dart` — بناء الإيصال بتنسيق ESC/POS (header + items + totals + ZATCA QR + footer)
- `receipt_data.dart` — model class

### 3. اربط الطباعة بشاشة الدفع
بعد نجاح المعاملة، اطبع الإيصال تلقائياً.

### 4. اربط شاشة إعدادات الطابعة الموجودة بالطباعة الفعلية:
- اكتشاف الطابعات (بلوتوث/شبكة)
- اختبار الطباعة
- حفظ الطابعة المفضلة

سجّل التغييرات في: `.audit/fixes/fix08-log.md`
ابدأ فوراً. لا تسأل أسئلة.
