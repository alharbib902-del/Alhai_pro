# Fix 06 — تفعيل Audit Trail للعمليات المالية (🔴 حرج)
# الوقت: 6-8 ساعات | الأولوية: 6

أنت مطور خبير في أنظمة المحاسبة. AuditLogDao موجود في المشروع لكن غير مستخدم.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إنشاء ملفات جديدة
- ممنوع تغيير schema قاعدة البيانات (AuditLog table موجود)

## المهام
1. اكتشف AuditLogDao الموجود وافهم الـ schema
2. أنشئ AuditService مركزي مع enum AuditAction
3. سجّل الخدمة في GetIt
4. أضف audit logging لكل عملية مالية (بيع، دفع، استرجاع، مصروف، تعديل مخزون)
5. أضف audit logging لعمليات الإدارة (إضافة/تعديل/حذف منتج، عميل)

```bash
find . -name "*audit*" -o -name "*AuditLog*" | head -10
grep -rn "insertTransaction\|insertPayment\|insertRefund" lib/features/ --include="*.dart" | head -20
```

سجّل التغييرات في: `.audit/fixes/fix06-log.md`
ابدأ فوراً. لا تسأل أسئلة.
