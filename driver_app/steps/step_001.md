# Driver App - Step 001: Project Foundation

> **المرحلة:** Phase 0 | **المدة:** 1 أسبوع | **الأولوية:** P0

---

## 🎯 الهدف

تجهيز أساس المشروع مع:
- إعداد Flutter + Riverpod + GoRouter
- إعداد Supabase + Models
- تهيئة 6 لغات
- تكامل Google Maps SDK
- إعداد FCM + APNs

---

## 📋 المهام

### SETUP-001: Project setup (6h)

```bash
cd driver_app
flutter pub get

flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add hive hive_flutter
```

### SETUP-002: Supabase + Models (6h)

```bash
flutter pub add supabase_flutter
```

**Models الجديدة:**
- `Shift` - الورديات
- `DriverEarnings` - الأرباح
- `DeliveryProof` - إثبات التسليم
- `Achievement` - الإنجازات

### SETUP-003: Multi-language (8h)

```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl
```

**6 ملفات لغة:**
- `app_ar.arb` (RTL)
- `app_en.arb`
- `app_ur.arb` (RTL)
- `app_hi.arb`
- `app_id.arb`
- `app_bn.arb`

### SETUP-004: Google Maps (8h)

```bash
flutter pub add google_maps_flutter
flutter pub add google_maps_flutter_web
```

**APIs المطلوبة:**
- Maps SDK
- Directions API
- Geocoding API

### SETUP-005: Notifications (4h)

```bash
flutter pub add firebase_messaging
flutter pub add flutter_local_notifications
```

---

## ✅ معايير الإنجاز

- [ ] `flutter run` يعمل
- [ ] Supabase متصل
- [ ] 6 لغات تعمل
- [ ] الخريطة تظهر
- [ ] الإشعارات تصل

---

## 📚 المراجع

- [PROD.json](../PROD.json) - SETUP-001 to SETUP-005
- [DRIVER_SPEC.md](../DRIVER_SPEC.md) - Tech Stack
