# Fix 16 — RTL + Confirmation Dialogs + Soft Delete (🟡 مهم)
# الوقت: 10-15 ساعة | الأولوية: 16

أنت مطور Flutter خبير في التطبيقات العربية.

## المهام — RTL
1. استبدل كل EdgeInsets.only بـ EdgeInsetsDirectional:
```bash
grep -rn "EdgeInsets.only\|EdgeInsets.fromLTRB" lib/ --include="*.dart" | wc -l
```
- left → start, right → end

2. استبدل Alignment.centerLeft/Right بـ AlignmentDirectional

3. تحقق من الأيقونات الاتجاهية (أسهم)

## المهام — Confirmation Dialogs
4. أنشئ ConfirmationDialog widget مشترك
5. أضفه قبل: حذف منتج/عميل، استرجاع، تعديل مخزون، مسح السلة، تسجيل خروج

## المهام — Soft Delete
6. أضف عمود deleted_at للجداول: products, customers, categories
7. عدّل DAOs لتصفية المحذوفات
8. عدّل دوال الحذف لتحديث deleted_at

سجّل التغييرات في: `.audit/fixes/fix16-log.md`
ابدأ فوراً. لا تسأل أسئلة.
