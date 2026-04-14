# Admin Dashboard / لوحة تحكم الادارة

Al-HAI Admin Dashboard is the full management system for Alhai grocery store owners. It provides 123 screens covering every aspect of store operations: inventory, staff, sales analytics, AI insights, POS management, and reporting.

## Who Uses This / من يستخدمه

Store owners and managers who need complete control over their grocery store operations. Web-first, designed for desktop browsers.

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

# 5. Run the app (web - recommended)
cd apps/admin
flutter run -d chrome
```

---

## Build Commands / اوامر البناء

The admin dashboard uses `--no-tree-shake-icons` because it references Material icons dynamically across 123 screens.

```bash
# Development (web)
flutter run -d chrome

# Production Web
flutter build web --no-tree-shake-icons
# or via Melos from repo root:
melos run build:admin:web

# Production APK (if needed)
flutter build apk
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
apps/admin/
  lib/
    core/           # App-level constants, helpers
    di/             # Dependency injection (GetIt)
    providers/      # Riverpod providers
    router/         # GoRouter with 123 screen routes
    screens/        # All management screens
    ui/             # Admin-specific UI components
    main.dart       # Entry point
  test/             # Dart unit / widget tests
  assets/
    images/         # App images
    branding/       # App icon, launcher assets
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
| `alhai_pos` | POS business logic |
| `alhai_ai` | AI feature integration |
| `alhai_reports` | Report generation |

---

## Code Generation / توليد الكود

Some packages use `build_runner` for Drift, Injectable, or Freezed:

```bash
# From repo root
melos run codegen

# Or from this app directory
dart run build_runner build --delete-conflicting-outputs
```

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
