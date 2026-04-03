# Alhai Platform / منصة الحي

**Smart Grocery POS Platform** -- Multi-tenant SaaS ecosystem for grocery stores in Saudi Arabia.

Built with Flutter (monorepo), Supabase (PostgreSQL), and an offline-first architecture that lets cashiers operate without internet.

---

## Architecture Overview / نظرة عامة على البنية

```
                         +-------------------------+
                         |      Supabase Cloud      |
                         |  PostgreSQL + Auth + RLS  |
                         |   Realtime + Storage      |
                         +------------+------------+
                                      |
                          REST / Realtime / RPC
                                      |
        +-----------------------------+-----------------------------+
        |              |              |              |              |
   +---------+   +---------+   +-----------+   +--------+   +----------+
   | Cashier |   |  Admin  |   | Admin Lite|   |Customer|   |  Driver  |
   |  (POS)  |   |  (Web)  |   |  (Mobile) |   |  App   |   |   App    |
   +---------+   +---------+   +-----------+   +--------+   +----------+
        |              |              |              |              |
        +--------------+--------------+--------------+--------------+
                                      |
                    +-----------------+-----------------+
                    |     Shared Packages (monorepo)    |
                    |  core | database | sync | auth    |
                    |  pos  | reports | shared_ui | l10n|
                    |  zatca | ai | design_system       |
                    +-----------------------------------+
                                      |
                         +------------+------------+
                         |   Drift (SQLite/WASM)   |
                         |    Local offline DB      |
                         +-------------------------+
```

---

## Quick Start / البدء السريع

### Prerequisites

| Tool       | Version    | Notes                          |
|------------|------------|--------------------------------|
| Flutter    | >= 3.27    | `flutter --version`            |
| Dart       | >= 3.4     | Bundled with Flutter           |
| Melos      | >= 6.2     | `dart pub global activate melos` |
| Java JDK   | 17         | For Android builds             |
| Node.js    | >= 18      | For E2E tests (Playwright)     |

### Setup

```bash
# 1. Clone the repository
git clone <repo-url> && cd Alhai

# 2. Install Melos globally
dart pub global activate melos

# 3. Bootstrap all packages (resolves dependencies)
melos bootstrap

# 4. Generate code (Drift tables, Injectable, Freezed)
melos run codegen

# 5. Run the cashier app (web)
cd apps/cashier && flutter run -d chrome

# 6. Run the admin app (web)
cd apps/admin && flutter run -d chrome
```

### Environment Variables

Pass these via `--dart-define` at build time:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ENV=development|staging|production
SENTRY_DSN=your-sentry-dsn         # optional
```

---

## Applications / التطبيقات

| App              | Path                    | Platform              | User            | Screens | Description                                  |
|------------------|-------------------------|-----------------------|-----------------|---------|----------------------------------------------|
| **Cashier (POS)**| `apps/cashier/`         | Web, Desktop, Tablet  | Cashier         | 79      | Point of sale, offline-first, split payments  |
| **Admin**        | `apps/admin/`           | Web, Mobile, Desktop  | Store Owner     | 106     | Full store management, reports, B2B ordering  |
| **Admin Lite**   | `apps/admin_lite/`      | Mobile                | Store Owner     | 28      | Quick decisions, AI auto-reorder              |
| **Customer App** | `customer_app/`         | Mobile (iOS/Android)  | Customer        | 40      | Online grocery ordering and delivery          |
| **Driver App**   | `driver_app/`           | Mobile (iOS/Android)  | Delivery Driver | 18      | Delivery management, GPS tracking             |
| **Distributor**  | `distributor_portal/`   | Web                   | Wholesaler      | 25      | B2B marketplace, bulk pricing                 |
| **Super Admin**  | `super_admin/`          | Web                   | Platform Owner  | 52      | Tenant management, platform analytics         |

---

## Shared Packages / الحزم المشتركة

| Package              | Path                              | Description                                              |
|----------------------|-----------------------------------|----------------------------------------------------------|
| `alhai_core`         | `alhai_core/`                     | Models, repository interfaces, DI (get_it), networking   |
| `alhai_database`     | `packages/alhai_database/`        | Drift (SQLite/WASM) tables, DAOs, FTS5, seeders          |
| `alhai_sync`         | `packages/alhai_sync/`            | Offline-first sync engine (Drift <-> Supabase)           |
| `alhai_auth`         | `packages/alhai_auth/`            | Login, OTP, store selection, session management           |
| `alhai_pos`          | `packages/alhai_pos/`             | POS screens, cart, payments, returns, receipts            |
| `alhai_reports`      | `packages/alhai_reports/`         | Sales, inventory, profit, tax, VAT, ZATCA reports        |
| `alhai_shared_ui`    | `packages/alhai_shared_ui/`       | Shared screens (dashboard, customers, inventory, etc.)   |
| `alhai_ai`           | `packages/alhai_ai/`              | AI screens: forecasting, fraud detection, smart pricing   |
| `alhai_l10n`         | `packages/alhai_l10n/`            | Localization -- 7 languages (AR, EN, UR, HI, ID, BN, FIL)|
| `alhai_zatca`        | `packages/alhai_zatca/`           | ZATCA Phase 2 e-invoicing: XML, digital signing, API     |
| `alhai_design_system`| `alhai_design_system/`            | Theme, colors, typography, reusable UI components        |
| `alhai_services`     | `alhai_services/`                 | Printing, export, barcode, WhatsApp services             |

---

## Tech Stack / التقنيات

| Layer          | Technology                                                    |
|----------------|---------------------------------------------------------------|
| **Frontend**   | Flutter 3.x (all platforms), Dart 3.4+                        |
| **State**      | Riverpod (UI state) + get_it/Injectable (DI)                  |
| **Local DB**   | Drift 2.14 (SQLite native, WASM for web), SQLCipher encryption|
| **Remote DB**  | Supabase (PostgreSQL 15, RLS, Realtime, Edge Functions)       |
| **Auth**       | Supabase Auth (phone OTP, email background)                   |
| **Storage**    | Cloudflare R2 (product images, multi-size)                    |
| **Routing**    | GoRouter 13                                                   |
| **Search**     | FTS5 (full-text search on products)                           |
| **E-invoicing**| ZATCA Phase 2 (XML UBL 2.1, digital signing)                 |
| **CI/CD**      | GitHub Actions (analyze, test, build Android/iOS/Web, deploy) |
| **AI Server**  | FastAPI + OpenAI (Railway deployment)                         |
| **Payments**   | mada, Visa, Mastercard, cash, credit, split payments          |

---

## Melos Commands / اوامر Melos

```bash
melos bootstrap              # Install all dependencies
melos run analyze             # Run flutter analyze across workspace
melos run test                # Run tests in all packages
melos run test:coverage       # Run tests with coverage reporting
melos run test:responsive     # Run responsive/golden layout tests
melos run format              # Format all code
melos run format:check        # Check formatting (CI mode)
melos run codegen             # Run build_runner (Drift, Injectable, Freezed)
melos run fix                 # Apply dart fix suggestions
melos run clean               # Flutter clean all packages
melos run deps:check          # Check outdated dependencies

# Build commands
melos run build:cashier:apk   # Build Cashier Android APK
melos run build:admin:web     # Build Admin Web
melos run build:lite:apk      # Build Admin Lite APK
melos run build:all           # Build all apps
```

---

## Project Structure / هيكل المشروع

```
Alhai/
+-- apps/
|   +-- admin/                # Store management app (web + mobile)
|   +-- admin_lite/           # Lightweight admin (mobile only)
|   +-- cashier/              # POS app (web + desktop)
+-- customer_app/             # Customer ordering app (mobile)
+-- driver_app/               # Delivery driver app (mobile)
+-- distributor_portal/       # B2B wholesaler portal (web)
+-- super_admin/              # Platform management (web)
+-- alhai_core/               # Core models, interfaces, DI
+-- alhai_design_system/      # Design system, theme, components
+-- alhai_services/           # Shared services (print, export)
+-- packages/
|   +-- alhai_database/       # Drift tables, DAOs, seeders
|   +-- alhai_sync/           # Sync engine (offline <-> cloud)
|   +-- alhai_auth/           # Authentication screens + providers
|   +-- alhai_pos/            # POS feature screens
|   +-- alhai_reports/        # Report screens
|   +-- alhai_shared_ui/      # Shared UI screens + widgets
|   +-- alhai_ai/             # AI-powered features
|   +-- alhai_l10n/           # Localization (7 languages)
|   +-- alhai_zatca/          # ZATCA e-invoicing compliance
+-- supabase/
|   +-- supabase_init.sql     # Base schema
|   +-- migrations/           # Incremental DB migrations (v14-v20)
+-- .github/workflows/        # CI/CD pipelines
+-- docs/                     # Architecture, deployment, DB docs
+-- melos.yaml                # Monorepo workspace config
```

---

## Documentation / التوثيق

| Document                                      | Description                                |
|-----------------------------------------------|--------------------------------------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)  | System architecture and design decisions   |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)      | Build, deploy, and environment setup guide |
| [docs/DATABASE.md](docs/DATABASE.md)          | Database schema, RLS, sync system          |
| [docs/06-architecture.md](docs/06-architecture.md) | Detailed Arabic architecture document |
| [docs/02-database.md](docs/02-database.md)    | Detailed Arabic database document          |

---

## License

Proprietary -- All Rights Reserved.
