# Admin Lite / الادارة المبسطة

Al-HAI Admin Lite is a lightweight mobile-first companion for store owners who need quick access to monitoring, approvals, reports, and AI insights without the full 123-screen admin dashboard.

## Who Uses This / من يستخدمه

Store owners and managers on mobile devices who need fast approvals, daily summaries, and AI-powered insights on the go.

---

## Prerequisites / المتطلبات

| Tool | Version |
|------|---------|
| Flutter | >= 3.27 |
| Dart | >= 3.6 |
| Melos | latest (`dart pub global activate melos`) |

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

# 5. Run on a connected device or emulator
cd apps/admin_lite
flutter run

# 6. Or run on web for quick testing
flutter run -d chrome
```

---

## Build Commands / اوامر البناء

```bash
# Development (mobile emulator)
flutter run

# Development (web)
flutter run -d chrome

# Production APK
flutter build apk
# or via Melos from repo root:
melos run build:lite:apk

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

---

## Project Structure / هيكل المشروع

```
apps/admin_lite/
  lib/
    core/           # App-level constants, helpers
    di/             # Dependency injection (GetIt)
    providers/      # Riverpod providers
    router/         # GoRouter configuration
    screens/        # Monitoring, approval, report screens
    ui/             # Lite-specific UI components
    main.dart       # Entry point
  test/             # Dart unit / widget tests
  assets/
    images/         # App images
```

### Key Shared Packages

| Package | Purpose |
|---------|---------|
| `alhai_core` | Domain models, Supabase config |
| `alhai_database` | Drift local DB, DAOs, migrations |
| `alhai_design_system` | Theme, tokens, shared widgets |
| `alhai_l10n` | Localization (6 languages) |
| `alhai_auth` | Authentication, secure storage |
| `alhai_shared_ui` | Cross-app UI components |
| `alhai_ai` | AI feature integration |
| `alhai_reports` | Report generation |

---

## Running Tests / تشغيل الاختبارات

```bash
# Dart unit & widget tests
flutter test

# With coverage
flutter test --coverage

# Via Melos (from repo root)
melos run test
```
