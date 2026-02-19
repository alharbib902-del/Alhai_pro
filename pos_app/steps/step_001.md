# POS App - Step 001: Project Foundation

> **المرحلة:** Phase 0 | **المدة:** 2-3 أيام | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس المشروع مع:
- إعداد Flutter project structure
- تكوين Riverpod للـ DI
- إعداد GoRouter للـ Navigation
- تكوين Drift للـ Local Database

---

## 📋 المهام

### SETUP-001: Project setup + DI + Router (8h)

```bash
# 1. التأكد من إعدادات المشروع
cd pos_app
flutter pub get

# 2. إضافة الحزم الأساسية
flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add flutter_secure_storage
```

**الملفات المطلوبة:**
- `lib/main.dart` - Entry point
- `lib/core/router/router.dart` - GoRouter configuration
- `lib/core/providers/providers.dart` - Riverpod providers

### SETUP-002: Drift setup + Models (8h)

```bash
# إضافة Drift
flutter pub add drift sqlite3_flutter_libs
flutter pub add drift_dev build_runner --dev
```

**الملفات المطلوبة:**
- `lib/core/database/database.dart` - Database class
- `lib/core/database/tables/` - Table definitions
- `lib/core/database/daos/` - Data Access Objects

---

## ✅ معايير الإنجاز

- [ ] `flutter run` يعمل بدون أخطاء
- [ ] Riverpod providers تعمل
- [ ] GoRouter navigation يعمل
- [ ] Drift database تُنشئ وتُقرأ بيانات

---

## 📚 المراجع

- [PROD.json](../PROD.json) - Tasks: SETUP-001, SETUP-002
- [POS_APP_SPEC.md](../POS_APP_SPEC.md) - Database Schema
