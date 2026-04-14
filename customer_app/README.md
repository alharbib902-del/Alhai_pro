# Customer App / تطبيق العملاء

Customer-facing mobile application for Alhai grocery stores. Customers use it to browse products, place orders, track deliveries, locate stores on a map, and manage their loyalty points.

## Who Uses This / من يستخدمه

End customers of Alhai-powered grocery stores on iOS and Android.

---

## Prerequisites / المتطلبات

| Tool | Version |
|------|---------|
| Flutter | >= 3.27 |
| Dart | >= 3.6 |
| Melos | latest (`dart pub global activate melos`) |
| Google Maps API Key | Required for store locator / map features |

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
cd customer_app
flutter run

# 6. Or run on web for quick layout testing
flutter run -d chrome
```

---

## Build Commands / اوامر البناء

```bash
# Development (mobile emulator)
flutter run

# Production APK
flutter build apk
# or via Melos from repo root:
melos run build:customer:apk

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

Google Maps API key is configured in platform-specific manifest files, not via dart-define.

---

## Project Structure / هيكل المشروع

```
customer_app/
  lib/
    core/           # App-level constants, config
    di/             # Dependency injection (GetIt + Injectable)
    features/       # Feature modules (auth, catalog, orders, etc.)
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
| `supabase_flutter` | Backend connectivity |
| `google_maps_flutter` | Store locator, map features |
| `geolocator` | User location services |
| `firebase_messaging` | Push notifications |
| `cached_network_image` | Product image caching |
| `dio` | HTTP client for API calls |

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

# Documentation Index / فهرس التوثيق

**Project**: Alhai Customer App
**Version**: 1.0
**Date**: 2026-01-15
**Status**: Ready for Development

---

## Documentation Structure / هيكل التوثيق

### 1. **PRD_FINAL.md** - المرجع الرئيسي

The primary development reference containing 80 screens with a Route Dictionary, Status Models (Order / Payment / Credit), Acceptance Criteria for P0 screens, a Development Checklist, and QA Critical Paths.

### 2. **CUSTOMER_APP_SPEC.md**

Technical specifications and scenarios: Multi-Store Architecture, Database Schema, User Flows, RLS Policies, and code examples.

### 3. **CUSTOMER_APP_VISION.md**

Vision and advanced features: User Journey (3 ways to link to the store), Loyalty Points (4 tiers), Smart Chat (6 languages + AI translation), and 25+ professional features.

### 4. **CUSTOMER_API_CONTRACT.md**

API contract: Base URLs, Authentication, all major Endpoints, Request/Response examples, and Error handling.

### 5. **CUSTOMER_UX_WIREFRAMES.md**

UI wireframes for critical P0 screens, Design System guidelines, and design priorities.

---

## Recommended Workflow / سير العمل المقترح

### For Developers:
1. Read `PRD_FINAL.md` first for the full plan
2. Review `CUSTOMER_APP_SPEC.md` for technical details
3. Use `CUSTOMER_API_CONTRACT.md` for API integration
4. Follow the Route Dictionary in PRD for implementation

### For Designers:
1. Start with `CUSTOMER_UX_WIREFRAMES.md`
2. Check screen requirements in `PRD_FINAL.md`
3. Review `CUSTOMER_APP_VISION.md` for inspiration

### For QA:
1. Read Acceptance Criteria in `PRD_FINAL.md`
2. Review User Flows in `CUSTOMER_APP_SPEC.md`
3. Follow QA Critical Paths in PRD

---

## Quick Stats / احصائيات سريعة

- **Total Screens**: 80
- **P0 (Critical)**: 30 screens (37.5%)
- **P1 (Core)**: 44 screens (55%)
- **P2 (Enhancement)**: 6 screens (7.5%)
