# Super Admin / المشرف العام

Platform-level super admin dashboard for complete control over the entire Alhai ecosystem. Manages all stores, users, subscriptions, commissions, feature flags, system health, and provides advanced analytics with AI insights.

## Who Uses This / من يستخدمه

The platform owner and operations team who oversee all Alhai-powered stores. Web-only, designed for desktop browsers.

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

# 5. Run the app (web only)
cd super_admin
flutter run -d chrome
```

---

## Build Commands / اوامر البناء

This is a web-only app. The build uses `--no-tree-shake-icons` for dynamic icon references across 45 screens.

```bash
# Development (web)
flutter run -d chrome

# Production Web
flutter build web --no-tree-shake-icons
# or via Melos from repo root:
melos run build:super-admin:web
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
super_admin/
  lib/
    core/           # App-level constants, config
    data/           # Data layer, repositories
    di/             # Dependency injection (GetIt + Injectable)
    providers/      # Riverpod providers
    screens/        # All dashboard screens (45 total)
    ui/             # Admin-specific UI components
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
| `alhai_auth` | Authentication, secure storage |
| `alhai_l10n` | Localization |
| `flutter_riverpod` | State management |
| `go_router` | Navigation / routing |
| `supabase_flutter` | Backend connectivity |
| `fl_chart` | Charts for analytics dashboards |
| `data_table_2` | Advanced data tables |

Note: This project uses `fl_chart` (MIT license) for all charting. Do not add Syncfusion -- see the license policy comment in `pubspec.yaml`.

---

## Screens Overview (45) / نظرة على الشاشات

| Category | Count | Examples |
|----------|-------|---------|
| Core Dashboard | 12 | God View, Platform Analytics, Real-time Map, Revenue Dashboard |
| Management | 10 | Stores Approval Queue, Subscription Plans, Feature Flags, Roles |
| Support | 8 | Support Tickets, System Logs, Database Monitor, Security Dashboard |
| Analytics | 10 | Cohort Analysis, Funnel Analysis, Geographic Analytics, Custom Reports |
| Advanced | 5 | AI Insights, Automation Rules, Integrations Hub, Experiments |

---

## Integration Points / نقاط التكامل

This dashboard manages all other apps in the ecosystem:
- **admin**: All owner accounts and stores
- **admin_lite**: Mobile session monitoring
- **customer_app**: Platform metrics
- **driver_app**: Driver performance
- **cashier**: Cashier activity
- **distributor_portal**: Distributor approvals, platform fees

---

## Running Tests / تشغيل الاختبارات

```bash
flutter test
flutter test --coverage
```
