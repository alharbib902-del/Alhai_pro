# Fix 09 — تنفيذ النسخ الاحتياطي الفعلي + سياسة الخصوصية (🔴 حرج)
# الوقت: 16-22 ساعة | الأولوية: 9

أنت مطور Flutter خبير في إدارة البيانات.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إضافة مكتبات
- يمكنك إنشاء ملفات جديدة

## المهام — النسخ الاحتياطي

### 1. ابحث عن كود النسخ الوهمي واستبدله
```bash
grep -rn "backup\|Backup\|Future.delayed" lib/ --include="*.dart" | head -20
```

### 2. أنشئ BackupService حقيقي مع:
- exportDatabase() — نسخ ملف DB
- exportAsJson() — تصدير كل الجداول كـ JSON
- importFromJson() — استيراد من JSON (داخل transaction)
- shareBackup() — مشاركة عبر Share sheet
- scheduleAutoBackup() — جدولة يومية

### 3. اربطه بشاشة الإعدادات الموجودة

## المهام — سياسة الخصوصية

### 4. أنشئ شاشة سياسة الخصوصية (عربي) تتضمن:
- البيانات المُجمّعة وكيف تُستخدم وتُحمى
- حقوق المستخدم (وصول، تصحيح، حذف)

### 5. أنشئ DataDeletionService مع:
- deleteCustomerData(customerId) — حذف بيانات العميل
- anonymizeCustomerOrders(customerId) — تغيير الاسم لـ "عميل محذوف" في المعاملات
- exportCustomerData(customerId) — تصدير كل بيانات العميل

### 6. أضف رابط سياسة الخصوصية في الإعدادات وشاشة التسجيل

سجّل التغييرات في: `.audit/fixes/fix09-log.md`
ابدأ فوراً. لا تسأل أسئلة.
