# Deployment Guide — Alhai Platform

> **تنبيه:** تأكد من عدم commit أي ملفات `.env` أو مفاتيح أو keystores إلى المستودع.

## Overview

Alhai (حي) is a grocery delivery platform consisting of 3 client-facing applications:

| Application | Platform | Build Tool | Deploy Target |
|------------|----------|-----------|---------------|
| **Customer App** (حي — عميل) | Android + iOS | Flutter 3.x | Play Store + App Store |
| **Driver App** (حي — سائق) | Android + iOS | Flutter 3.x | Play Store + App Store |
| **Distributor Portal** (بوابة الموزّعين) | Web | Flutter Web | Netlify / Vercel / Cloudflare Pages |

**Backend:** Supabase (PostgreSQL + Auth + Storage + Edge Functions)
**Error Monitoring:** Sentry (per-app projects)
**Push Notifications:** Firebase Cloud Messaging (future)
**E-Invoicing:** ZATCA Phase 2 integration

---

## Prerequisites

### Required Accounts

| Service | Purpose | Cost | Setup Guide |
|---------|---------|------|-------------|
| [Supabase](https://supabase.com) | Database, Auth, Storage | Free → Pro ($25/mo) | [SUPABASE_PRODUCTION.md](./SUPABASE_PRODUCTION.md) |
| [Sentry](https://sentry.io) | Error monitoring | Free tier available | Create 3 projects (customer, driver, distributor) |
| [Google Play Console](https://play.google.com/console) | Android distribution | $25 one-time | [CUSTOMER_APP_DEPLOY.md](./CUSTOMER_APP_DEPLOY.md) |
| [Apple Developer](https://developer.apple.com) | iOS distribution | $99/year | [CUSTOMER_APP_DEPLOY.md](./CUSTOMER_APP_DEPLOY.md) |
| [Netlify](https://netlify.com) | Web hosting | Free tier available | [DISTRIBUTOR_PORTAL_DEPLOY.md](./DISTRIBUTOR_PORTAL_DEPLOY.md) |
| [Firebase](https://firebase.google.com) | Push notifications | Free tier | Future setup |

### Required Tools (Development Machine)

```bash
# Flutter SDK (latest stable)
flutter --version
# Expected: Flutter 3.x.x

# Java 17 (for Android builds)
java -version
# Expected: openjdk 17.x.x

# Xcode 15+ (macOS only, for iOS builds)
xcodebuild -version

# CocoaPods (macOS only)
pod --version

# Android SDK (via Android Studio)
# Required: SDK 34, Build Tools 34.x.x
```

---

## Environment Setup

All applications use `--dart-define-from-file=.env` for configuration. See [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md) for the complete variable reference.

**Quick setup:**
```bash
# 1. Copy the example env file for each app
cp customer_app/.env.example customer_app/.env
cp driver_app/.env.example driver_app/.env
cp distributor_portal/.env.example distributor_portal/.env

# 2. Fill in real values (NEVER commit .env files)
# Edit each .env with your Supabase URL, anon key, Sentry DSN, etc.
```

---

## Build Commands

### Customer App

```bash
# Development
cd customer_app
flutter run --dart-define-from-file=.env

# Release APK (Android)
flutter build apk --release --dart-define-from-file=.env

# Release AAB (Android — for Play Store)
flutter build appbundle --release --dart-define-from-file=.env

# iOS (macOS only)
flutter build ios --release --dart-define-from-file=.env
```

### Driver App

```bash
# Development
cd driver_app
flutter run --dart-define-from-file=.env

# Release APK (Android)
flutter build apk --release --dart-define-from-file=.env

# Release AAB (Android — for Play Store)
flutter build appbundle --release --dart-define-from-file=.env

# iOS (macOS only)
flutter build ios --release --dart-define-from-file=.env
```

### Distributor Portal

```bash
# Development
cd distributor_portal
flutter run -d chrome --dart-define-from-file=.env

# Release (Web)
flutter build web --release --dart-define-from-file=.env
# Output: build/web/
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] All environment variables configured (see [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md))
- [ ] Supabase project upgraded to Pro plan
- [ ] Supabase RLS policies audited
- [ ] Sentry projects created with real DSNs
- [ ] Certificate pinning fingerprints generated and configured
- [ ] Android keystores generated and secured
- [ ] iOS certificates and provisioning profiles created
- [ ] ZATCA environment set to `production` (not `sandbox`)
- [ ] Privacy Policy and Terms of Service published and linked
- [ ] Account deletion feature tested (App Store/Play Store requirement)
- [ ] Firebase projects created with `google-services.json` / `GoogleService-Info.plist`

### Post-Deployment

- [ ] Smoke test all critical flows (registration, ordering, delivery, invoicing)
- [ ] Sentry receiving error reports correctly
- [ ] ZATCA invoice submission working
- [ ] Push notifications delivering (when implemented)
- [ ] Monitoring dashboards configured
- [ ] Backup strategy verified

---

## Detailed Guides

| Guide | Description |
|-------|-------------|
| [CUSTOMER_APP_DEPLOY.md](./CUSTOMER_APP_DEPLOY.md) | Android + iOS deployment for Customer App |
| [DRIVER_APP_DEPLOY.md](./DRIVER_APP_DEPLOY.md) | Android + iOS deployment for Driver App |
| [DISTRIBUTOR_PORTAL_DEPLOY.md](./DISTRIBUTOR_PORTAL_DEPLOY.md) | Web deployment for Distributor Portal |
| [SUPABASE_PRODUCTION.md](./SUPABASE_PRODUCTION.md) | Supabase production configuration |
| [ENVIRONMENT_VARIABLES.md](./ENVIRONMENT_VARIABLES.md) | All environment variables reference |

---

## Cost Estimate (Monthly)

| Service | Plan | Cost (USD) |
|---------|------|-----------|
| Supabase | Pro | $25/mo |
| Sentry | Free/Team | $0–$26/mo |
| Netlify | Free/Pro | $0–$19/mo |
| Apple Developer | Annual | ~$8.25/mo ($99/yr) |
| Google Play | One-time | $25 (one-time) |
| Firebase | Free (Spark) | $0 |
| **Total (minimum)** | | **~$33/mo** |

---

*Last updated: April 16, 2026*
