# Fix 12 — إصلاحات الأمان الشاملة (🟡 مهم)
# الوقت: 12-16 ساعة | الأولوية: 12

أنت خبير أمن تطبيقات Flutter.

## الصلاحيات
- قراءة وتعديل ملفات .dart فقط
- يمكنك إنشاء ملفات جديدة

## المهام

### 1. Session Timeout — قفل تلقائي بعد 15 دقيقة عدم نشاط
أنشئ `lib/services/session_manager.dart`

### 2. إصلاح Multi-tenancy leaks
```bash
grep -rn "select\|getAllProducts\|getAllOrders\|getAll" lib/ --include="*.dart" | grep -v "storeId\|store_id" | head -20
```
أضف storeId filter لكل استعلام.

### 3. إضافة LIMIT للاستعلامات الثقيلة
```bash
grep -rn "getAll\|findAll" lib/ --include="*.dart" | grep -v "limit\|LIMIT" | head -20
```

### 4. إصلاح demo-store fallback
```bash
grep -rn "demo-store\|demo_store" lib/ --include="*.dart" | head -15
```
استبدل بـ throw exception أو redirect to login.

### 5. إضافة Logout مع تنظيف الجلسة الكاملة
تأكد يمسح: tokens, cache, session data, local state.

### 6. حماية debugPrint في release
```bash
grep -rn "debugPrint\|print(" lib/ --include="*.dart" | grep -v test | wc -l
```
لف كل debugPrint بـ kDebugMode guard.

### 7. إزالة debugLogDiagnostics من GoRouter
```bash
grep -rn "debugLogDiagnostics" lib/ --include="*.dart"
```

سجّل التغييرات في: `.audit/fixes/fix12-log.md`
ابدأ فوراً. لا تسأل أسئلة.
