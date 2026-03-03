# Fix 01 — إصلاح أخطاء التجميع (🔴 حرج)
# الوقت: 2-3 ساعات | الأولوية: 1 (يمنع البناء)

أنت مطور Flutter خبير. المشروع فيه 16 خطأ تجميع يمنع البناء. أصلح كل الأخطاء.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- ممنوع حذف ملفات أو تغيير البنية
- ممنوع إضافة مكتبات جديدة

## المهام

### 1. اكتشف جميع الأخطاء
```bash
flutter analyze 2>&1 | grep -E "error •|Error:" | head -30
```

### 2. إصلاح أخطاء int/double mismatch
ابحث عن كل الأماكن التي يتم فيها تمرير int حيث يُتوقع double والعكس:
```bash
grep -rn "\.toDouble()\|\.toInt()\|as double\|as int" lib/ | head -30
```
- أصلح بإضافة `.toDouble()` حيث يلزم
- لا تستخدم `as double` (unsafe) — استخدم `.toDouble()` دائماً

### 3. إصلاح ambiguous extensions
ابحث عن extensions متعارضة وحدّدها بالاسم الكامل.

### 4. إصلاح جميع الـ 69 تحذير (warnings) بعد إصلاح الأخطاء
```bash
flutter analyze 2>&1 | grep "warning •" | head -70
```

### 5. تحقق من النجاح
```bash
flutter analyze 2>&1 | grep -c "error"
# يجب أن تكون النتيجة 0
```

## قواعد
- كل إصلاح يجب أن يكون minimal — لا تُعدّ refactor
- شغّل `flutter analyze` بعد كل مجموعة إصلاحات
- سجّل كل تغيير في ملف: `.audit/fixes/fix01-log.md`

ابدأ فوراً. لا تسأل أسئلة.
