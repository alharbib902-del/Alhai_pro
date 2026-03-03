# Fix 13 — CI/CD + Environment Separation Log
**Date:** 2026-03-01
**Status:** Complete

## Summary
Created GitHub Actions CI/CD pipelines, environment configuration, and developer tooling for the Alhai monorepo.

## Tasks

### 1. CI Workflow — CREATED
**File:** `.github/workflows/ci.yml`
- Triggers on push/PR to `main` and `develop`
- Concurrency control (cancels in-progress runs on same branch)
- 3-stage pipeline:
  1. **Analyze** — `flutter analyze` + `dart format --set-exit-if-changed`
  2. **Test** — `flutter test` across all packages (depends on analyze)
  3. **Build Web** — builds cashier web app (depends on test), uploads artifact

### 2. Release Workflow — CREATED
**File:** `.github/workflows/release.yml`
- Triggers on version tags (`v*`) or manual dispatch with environment choice
- Injects secrets via `--dart-define` (SENTRY_DSN, SUPABASE_URL, SUPABASE_ANON_KEY)
- Build + Deploy stages with environment-aware artifact naming
- Deploy step is a placeholder — ready for Firebase/S3/Vercel config

### 3. Environment Config — CREATED
**File:** `apps/cashier/lib/config/environment.dart`
- `AppEnvironment` class with `dev`, `staging`, `production` environments
- Reads from `--dart-define=ENV=dev` at compile time
- Exposes: `isDev`, `isStaging`, `isProduction`
- Exposes: `supabaseUrl`, `supabaseAnonKey`, `sentryDsn` from dart-defines
- Helper flags: `enableDebugLogs`, `enableSentry`, `appName`

### 4. .env.example — CREATED
**File:** `apps/cashier/.env.example`
- Template with all required environment variables
- No real values — safe for version control

### 5. .gitignore Updated
**File:** `apps/cashier/.gitignore`
- Added `.env`, `.env.local`, `.env.*.local` to ignore list

### 6. Makefile — CREATED
**File:** `apps/cashier/Makefile`
- `make run` — run Chrome dev
- `make build-web` — production web build
- `make build-web-staging` — staging web build
- `make build-apk` — production APK
- `make test` / `make analyze` / `make format` / `make clean` / `make codegen`

## Files Created
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `apps/cashier/lib/config/environment.dart`
- `apps/cashier/.env.example`
- `apps/cashier/Makefile`

## Files Modified
- `apps/cashier/.gitignore` — added .env exclusion
