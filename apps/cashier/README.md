# Cashier - POS App / تطبيق الكاشير

Al-HAI Cashier is the point-of-sale application used by cashiers in Alhai grocery stores. It is designed for 100 % offline operation with background sync to Supabase, ZATCA Phase-2 e-invoicing, and multi-language support.

## Who Uses This / من يستخدمه

Store cashiers operating the checkout register on tablets or web browsers.

---

## Prerequisites / المتطلبات

| Tool | Version |
|------|---------|
| Flutter | >= 3.27 |
| Dart | >= 3.6 |
| Melos | latest (`dart pub global activate melos`) |
| Node.js | >= 18 (for E2E Playwright tests only) |

---

## Local Setup / الإعداد المحلي

```bash
# 1. Clone the repo and move to the root
git clone <repo-url> && cd Alhai

# 2. Install Melos globally
dart pub global activate melos

# 3. Bootstrap the monorepo (resolves all path dependencies)
melos bootstrap

# 4. Set environment variables
#    Create a .dart_define.env file or pass values via --dart-define flags.
#    Required variables:
#      SUPABASE_URL=https://<project>.supabase.co
#      SUPABASE_ANON_KEY=<your-anon-key>

# 5. Run the app (web)
cd apps/cashier
flutter run -d chrome

# 6. Run the app (Android)
flutter run
```

---

## Build Commands / اوامر البناء

```bash
# Development (web)
flutter run -d chrome

# Production APK
flutter build apk
# or via Melos from repo root:
melos run build:cashier:apk

# Production Web
flutter build web
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
apps/cashier/
  lib/
    core/           # Constants, services (Sentry, clock validation)
    di/             # Dependency injection setup
    router/         # GoRouter configuration
    screens/        # UI screens (onboarding, POS, reports)
    services/       # Printing stubs, session manager
    ui/             # Shared UI components
    widgets/        # Reusable widgets
    main.dart       # Entry point
  e2e/              # Playwright E2E tests
  test/             # Dart unit / widget tests
  assets/data/      # Seed data
```

### Key Shared Packages

| Package | Purpose |
|---------|---------|
| `alhai_core` | Domain models, Supabase config |
| `alhai_database` | Drift local DB, DAOs, migrations |
| `alhai_sync` | Offline-first sync engine |
| `alhai_pos` | POS business logic, cart, receipts |
| `alhai_zatca` | ZATCA Phase-2 e-invoicing |
| `alhai_auth` | Authentication, secure storage |
| `alhai_l10n` | Localization (6 languages) |
| `alhai_design_system` | Theme, tokens, shared widgets |
| `alhai_shared_ui` | Cross-app UI components |
| `alhai_reports` | Report generation |

---

## E2E Tests (Playwright) / اختبارات شاملة

Requires Node.js and the web build to be served locally.

```bash
# Install Node dependencies
npm install

# Run by priority level
npm run test:critical        # Critical cashier flows
npm run test:high            # High-priority modules
npm run test:medium          # Medium-priority modules
npm run test:cashier:all     # All priority groups
npm run test:full            # Dart unit tests + all Playwright tests
```

### PowerShell Runners

```powershell
.\scripts\run-cashier-tests.ps1 -Priority all -BaseUrl http://localhost:5000
.\scripts\run-cashier-full-suite.ps1 -BaseUrl http://localhost:5000
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
