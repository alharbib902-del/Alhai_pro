# Fix 09 — النسخ الاحتياطي الفعلي + سياسة الخصوصية

## التاريخ: 2026-03-01

---

## 1. BackupManager — نسخ احتياطي حقيقي

### الملف: `lib/core/services/backup_manager.dart` (جديد)

**ما تم:**
- إنشاء `BackupManager` يربط `AppDatabase` بعمليات النسخ/الاستعادة الفعلية
- `exportAsJson(storeId)` — يصدّر كل جداول المتجر كـ JSON (30+ جدول)
- `importFromJson(jsonString)` — يستورد من JSON داخل transaction مع ترتيب FK
- `validateBackup(jsonString)` — تحقق سريع من صلاحية ملف النسخة
- يدعم: products, categories, sales, sale_items, customers, customer_addresses, accounts, transactions, inventory_movements, stock_transfers, orders, order_items, returns, return_items, shifts, cash_movements, suppliers, purchases, purchase_items, expenses, expense_categories, discounts, coupons, promotions, settings, held_invoices, loyalty_points, favorites, notifications, daily_summaries

**تفاصيل فنية:**
- الاستيراد يتم داخل `transaction()` — إما ينجح كله أو لا شيء
- ترتيب الاستعادة يراعي FK constraints (الجداول الأم أولاً)
- `INSERT OR REPLACE` لمنع التعارضات
- نتائج: `BackupBundle` (مع حجم وعدد صفوف) و `RestoreReport`

---

## 2. تحديث BackupScreen — استبدال الكود الوهمي

### الملف: `lib/screens/settings/backup_screen.dart` (تعديل)

**ما تغير:**
- ❌ حذف `Future.delayed(3 seconds)` الوهمي من `_performBackup`
- ❌ حذف `Future.delayed(4 seconds)` الوهمي من `_performRestore`
- ❌ حذف القيم الافتراضية الوهمية (12 backups, 45.8 MB)
- ✅ `_performBackup` يستخدم `BackupManager.exportAsJson()` فعلياً
- ✅ بعد النسخ يظهر dialog مع خيار نسخ JSON للحافظة
- ✅ `_performRestore` يطلب لصق JSON من الحافظة + `BackupManager.importFromJson()`
- ✅ التحقق من صلاحية الملف قبل الاستعادة
- ✅ حفظ حجم النسخة الفعلي في الإعدادات
- ✅ عرض "No backup yet" عند عدم وجود نسخة سابقة

---

## 3. DataDeletionService — حذف بيانات العملاء

### الملف: `lib/core/services/data_deletion_service.dart` (جديد)

**ما تم:**
- `deleteCustomerData(customerId)`:
  - إخفاء هوية العميل في المبيعات/الطلبات ("عميل محذوف")
  - حذف: حسابات، عناوين، إشعارات، نقاط ولاء، معاملات ولاء
  - حذف سجل العميل نهائياً
  - كل شيء داخل transaction

- `anonymizeCustomerData(customerId)`:
  - تغيير الاسم لـ "عميل محذوف"
  - مسح: الهاتف، البريد، العنوان، المدينة، الرقم الضريبي، الملاحظات
  - تعطيل الحساب (is_active = false)
  - حذف العناوين
  - إخفاء الهوية في المبيعات/الطلبات

- `exportCustomerData(customerId)`:
  - تصدير كل بيانات العميل كـ JSON
  - يشمل: بيانات العميل، العناوين، المبيعات، عناصر المبيعات، الطلبات، المرتجعات، الحسابات، الولاء

---

## 4. شاشة سياسة الخصوصية

### الملف: `lib/screens/settings/privacy_policy_screen.dart` (جديد)

**المحتوى:**
- مقدمة عن الالتزام بالخصوصية
- البيانات المُجمّعة (متجر، منتجات، مبيعات، عملاء، موظفين، جهاز)
- كيف نستخدم البيانات (لا بيع، لا إعلانات)
- حماية البيانات (تخزين محلي، تشفير، مصادقة، 100% offline)
- حقوق المستخدم (وصول، تصحيح، حذف، تصدير، إلغاء)
- قسم حذف البيانات
- معلومات التواصل
- يدعم: RTL عربي، dark/light، responsive

---

## 5. ربط سياسة الخصوصية

### الملفات المعدلة:
- `packages/alhai_shared_ui/.../routes.dart` — إضافة `settingsPrivacy = '/settings/privacy'`
- `lib/router/cashier_router.dart` — إضافة route + import
- `lib/screens/settings/cashier_settings_screen.dart` — إضافة tile في شبكة الإعدادات
- `lib/screens/onboarding/onboarding_screen.dart` — رابط سياسة الخصوصية قبل أزرار التنقل

---

## ملخص الملفات

| الملف | النوع | الوصف |
|---|---|---|
| `lib/core/services/backup_manager.dart` | جديد | خدمة النسخ الاحتياطي الحقيقية |
| `lib/core/services/data_deletion_service.dart` | جديد | خدمة حذف/إخفاء/تصدير بيانات العميل |
| `lib/screens/settings/privacy_policy_screen.dart` | جديد | شاشة سياسة الخصوصية |
| `lib/screens/settings/backup_screen.dart` | تعديل | استبدال الكود الوهمي بالحقيقي |
| `lib/screens/settings/cashier_settings_screen.dart` | تعديل | إضافة tile سياسة الخصوصية |
| `lib/router/cashier_router.dart` | تعديل | إضافة route سياسة الخصوصية |
| `lib/screens/onboarding/onboarding_screen.dart` | تعديل | رابط سياسة الخصوصية |
| `packages/alhai_shared_ui/.../routes.dart` | تعديل | إضافة route constant |
