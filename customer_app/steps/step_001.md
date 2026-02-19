# Customer App - Step 001: Project Foundation

> **المرحلة:** Phase 0 | **المدة:** 3-4 أيام | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس المشروع مع:
- إعداد Flutter project structure
- تكوين Riverpod للـ DI
- إعداد GoRouter للـ Navigation (80 route)
- تكوين Supabase client

---

## 📋 المهام

### SETUP-001: Project setup + DI + Router (8h)

```bash
cd customer_app
flutter pub get

# إضافة الحزم الأساسية
flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add flutter_secure_storage
```

**الملفات المطلوبة:**
- `lib/main.dart` - Entry point
- `lib/core/router/router.dart` - GoRouter مع 80 route
- `lib/core/providers/providers.dart` - Riverpod providers

### SETUP-002: Supabase + Models (8h)

```bash
flutter pub add supabase_flutter
```

**الملفات المطلوبة:**
- `lib/core/supabase/supabase_client.dart`
- `lib/models/` - Generated models

**Models الأساسية:**
- `GlobalCustomer`
- `CustomerAccount`
- `Store`
- `Order`, `OrderItem`
- `Product`

---

## ✅ معايير الإنجاز

- [ ] `flutter run` يعمل بدون أخطاء
- [ ] Riverpod providers تعمل
- [ ] GoRouter navigation يعمل
- [ ] Supabase client يتصل بنجاح

---

## 📚 المراجع

- [PROD.json](../PROD.json) - Tasks: SETUP-001, SETUP-002
- [CUSTOMER_APP_SPEC.md](../CUSTOMER_APP_SPEC.md) - Database Schema
