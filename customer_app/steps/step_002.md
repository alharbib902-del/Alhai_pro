# Customer App - Step 002: Design System + Location

> **المرحلة:** Phase 0 | **المدة:** 2-3 أيام | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- Design System (ألوان، خطوط، مسافات)
- Location Services (GPS, permissions)
- Localization (AR/EN + RTL)

---

## 📋 المهام

### SETUP-003: Design System (12h)

**الألوان من UX Wireframes:**
```dart
// lib/core/theme/colors.dart
class AppColors {
  static const primary = Color(0xFF2EA043);    // Green
  static const secondary = Color(0xFF0969DA);  // Blue
  static const error = Color(0xFFCF222E);      // Red
  static const warning = Color(0xFFBF8700);    // Orange
  static const success = Color(0xFF1A7F37);    // Dark Green
  
  // Light Mode
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF6F8FA);
  
  // Dark Mode
  static const backgroundDark = Color(0xFF0D1117);
  static const surfaceDark = Color(0xFF161B22);
}
```

**الخطوط:**
```yaml
# pubspec.yaml
fonts:
  - family: Tajawal
    fonts:
      - asset: assets/fonts/Tajawal-Regular.ttf
      - asset: assets/fonts/Tajawal-Medium.ttf
      - asset: assets/fonts/Tajawal-Bold.ttf
```

### SETUP-004: Location Services (8h)

```bash
flutter pub add geolocator
flutter pub add geocoding
```

**الملفات:**
- `lib/core/services/location_service.dart`
- Permission handling (iOS Info.plist, Android manifest)

### SETUP-005: Localization (4h)

```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl
```

**الملفات:**
- `lib/l10n/app_ar.arb`
- `lib/l10n/app_en.arb`

---

## ✅ معايير الإنجاز

- [ ] Theme يعمل (Light + Dark)
- [ ] خط Tajawal يظهر بشكل صحيح
- [ ] GPS Permission يعمل
- [ ] Location service يجلب الموقع
- [ ] RTL يعمل للعربية
- [ ] Language switch يعمل

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-003, SETUP-004, SETUP-005
- [CUSTOMER_UX_WIREFRAMES.md](../CUSTOMER_UX_WIREFRAMES.md) - Design System
