# Driver App / تطبيق المناديب

Delivery driver application for Alhai grocery stores. Drivers use it to receive orders, navigate to delivery locations, capture delivery proof (photo + signature + code), track earnings, and communicate with customers via in-app chat with auto-translation.

## Who Uses This / من يستخدمه

Delivery drivers working for Alhai-powered grocery stores on iOS and Android.

---

## Prerequisites / المتطلبات

| Tool | Version |
|------|---------|
| Flutter | >= 3.27 |
| Dart | >= 3.6 |
| Melos | latest (`dart pub global activate melos`) |
| Google Maps API Key | Required for navigation / route features |

---

## Local Setup / الإعداد المحلي

```bash
# 1. Clone the repo and move to the root
git clone <repo-url> && cd Alhai

# 2. Install Melos globally
dart pub global activate melos

# 3. Bootstrap the monorepo
melos bootstrap

# 4. Set environment variables
#    Required: SUPABASE_URL, SUPABASE_ANON_KEY
#    Pass via --dart-define or .dart_define.env
#    For maps: add your Google Maps API key in
#      android/app/src/main/AndroidManifest.xml
#      ios/Runner/AppDelegate.swift

# 5. Run on a connected device or emulator
cd driver_app
flutter run
```

---

## Build Commands / اوامر البناء

```bash
# Development (mobile emulator)
flutter run

# Production APK
flutter build apk
# or via Melos from repo root:
melos run build:driver:apk

# Production iOS
flutter build ios
```

---

## Environment Variables / متغيرات البيئة

Pass these via `--dart-define` or a `.dart_define.env` file:

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anonymous key |
| `SENTRY_DSN` | No | Sentry error-tracking DSN |

Google Maps API key and Firebase config are set in platform-specific files.

---

## Project Structure / هيكل المشروع

```
driver_app/
  lib/
    core/           # App-level constants, config
    di/             # Dependency injection (GetIt + Injectable)
    features/       # Feature modules (deliveries, earnings, chat, etc.)
    shared/         # Shared utilities, widgets
    main.dart       # Entry point
  test/             # Dart unit / widget tests
  assets/
    images/         # App images
    icons/          # App icons
```

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `alhai_core` | Domain models, Supabase config |
| `alhai_design_system` | Theme, tokens, shared widgets |
| `flutter_riverpod` | State management |
| `go_router` | Navigation / routing |
| `supabase_flutter` | Backend connectivity, real-time |
| `google_maps_flutter` | Map display, route visualization |
| `geolocator` | GPS tracking |
| `flutter_polyline_points` | Route polyline rendering |
| `flutter_background_service` | Background location tracking |
| `camera` | Delivery proof photos |
| `signature` | Signature capture on delivery |
| `firebase_messaging` | Push notifications for new orders |

---

## Code Generation / توليد الكود

This app uses Injectable and Riverpod generators:

```bash
dart run build_runner build --delete-conflicting-outputs
# or from repo root:
melos run codegen
```

---

## Running Tests / تشغيل الاختبارات

```bash
flutter test
flutter test --coverage
```

---

---

# Driver App - Navigation Guide / دليل التنقل

**Platform:** Mobile Only (iOS + Android)

---

## Overview / نظرة عامة

The Driver App is a professional application for delivery drivers to manage deliveries and earnings.

- **Screens**: 18
- **Languages**: 6 (Arabic, English, Urdu, Hindi, Indonesian, Bengali)
- **Integration**: admin_pos, customer_app, alhai_core
- **Payment Models**: Salary, Commission, Hybrid

---

## Documentation Structure / هيكل التوثيق

### Strategic Documents
- `DRIVER_VISION.md` - Product vision and goals
- `PRD_FINAL.md` - Complete requirements (18 screens)

### Technical Documents
- `DRIVER_SPEC.md` - Technical specifications
- `DRIVER_API_CONTRACT.md` - API documentation
- `DRIVER_ARCHITECTURE.md` - System architecture
- `DRIVER_UX_WIREFRAMES.md` - UI/UX designs

### Supporting Documents (steps/)
- `steps/VISION_AND_ANALYSIS.md` - Initial analysis
- `steps/SUMMARY.md` - Executive summary
- `steps/FINANCIAL_AND_OPERATIONS.md` - Operational details

---

## Integration Points / نقاط التكامل

### With admin_pos:
- Owner creates driver accounts
- Assigns stores and shifts
- Sets payment models
- Views live location and reports

### With customer_app:
- Receives delivery orders
- Updates order status
- In-app chat with customers
- Shares live location

### With alhai_core:
- Uses Delivery model
- Uses Order model
- Uses DeliveryStatus enum
- Adds new models (Shift, Earnings)

---

## Key Features / الميزات الرئيسية

### P0 (Must-Have):
- Multi-store support
- Accept/Reject orders with voice/text reasons
- GPS tracking and navigation
- Delivery proof (code + photo + signature)
- Multi-language (6 languages)
- In-app chat with auto-translation
- Commission/Salary system
- Daily/Weekly reports

### P1 (Should-Have):
- Shift management
- AI-powered smart accept
- Route optimization
- Quick messages
- Earnings breakdown

---

## Screens Breakdown (18) / تقسيم الشاشات

| Phase | Screens |
|-------|---------|
| Auth | Language Selection, Login, Profile Setup |
| Dashboard | Home Dashboard, Active Deliveries, Shift Schedule, Earnings Summary |
| Orders | New Order, Order Details, Navigation/Map, Delivery Proof |
| Communication | Chat, Quick Messages |
| Reports | Daily Summary, Weekly Report, Monthly Earnings |
| Settings | Profile and Preferences, Help and Support |

---

## Multi-Language Support / دعم متعدد اللغات

1. Arabic
2. English
3. Urdu
4. Hindi
5. Bahasa Indonesia
6. Bengali

Features: Auto-translation for chat, voice-to-text translation, RTL layout support.

---

## Payment Models / نماذج الدفع

| Model | Description |
|-------|-------------|
| Salary-Based | Fixed monthly salary + small per-delivery bonus |
| Commission-Based | Per-delivery commission + incentive bonuses |
| Hybrid | Base salary + commission + performance bonuses |
