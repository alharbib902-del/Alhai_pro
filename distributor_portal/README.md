# Distributor Portal / بوابة الموزعين

B2B web portal for wholesalers and distributors to sell products to Alhai-powered grocery stores. Distributors manage their product catalogs, wholesale pricing, orders, invoices, and delivery scheduling through a desktop browser interface.

## Who Uses This / من يستخدمه

Wholesalers and distributors who supply products to grocery stores on the Alhai platform. Web-only, designed for desktop browsers.

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
cd distributor_portal
flutter run -d chrome
```

---

## Build Commands / اوامر البناء

This is a web-only app. The build uses `--no-tree-shake-icons` for dynamic icon references.

```bash
# Development (web)
flutter run -d chrome

# Production Web
flutter build web --no-tree-shake-icons
# or via Melos from repo root:
melos run build:distributor:web
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
distributor_portal/
  lib/
    core/           # App-level constants, config
    data/           # Data layer, repositories
    di/             # Dependency injection (GetIt + Injectable)
    providers/      # Riverpod providers
    screens/        # All portal screens (25 total)
    ui/             # Portal-specific UI components
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
| `alhai_l10n` | Localization |
| `flutter_riverpod` | State management |
| `go_router` | Navigation / routing |
| `supabase_flutter` | Backend connectivity |
| `fl_chart` | Charts for analytics dashboard |
| `web` | Web platform interop |

---

## Screens Overview (25) / نظرة على الشاشات

| Category | Screens |
|----------|---------|
| Core (8) | Login, Dashboard, Product Catalog, Add/Edit Product, Orders List, Order Details, Analytics |
| Management (7) | Bulk Offers, Offers List, Stores Directory, Store Details, Inventory, Pricing Tiers, Categories |
| Finance (5) | Invoices, Invoice Details, Payments, Payment Details, Financial Reports |
| Settings (5) | Company Profile, Team Members, Delivery Zones, Notifications, Help and Support |

---

## Integration Points / نقاط التكامل

- **super_admin**: Approval process, platform fees, featured listings
- **admin_pos**: Receive wholesale orders, update order status, send invoices
- **cashier**: Delivery confirmation, split payment processing

---

## Running Tests / تشغيل الاختبارات

```bash
flutter test
flutter test --coverage
```
