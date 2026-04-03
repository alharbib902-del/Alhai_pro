# Architecture / البنية المعمارية

System architecture document for the Alhai Platform.

---

## 1. Monorepo Structure / هيكل المستودع

The project uses **Melos** to manage a Flutter monorepo. All apps share common packages, reducing duplication and ensuring consistency.

```
Alhai/
+-- melos.yaml                     # Workspace configuration
+-- apps/
|   +-- cashier/                   # POS app (79 screens)
|   +-- admin/                     # Store management (106 screens)
|   +-- admin_lite/                # Lightweight admin (28 screens)
+-- customer_app/                  # Customer ordering (40 screens)
+-- driver_app/                    # Delivery driver (18 screens)
+-- distributor_portal/            # B2B wholesaler (25 screens)
+-- super_admin/                   # Platform management (52 screens)
+-- alhai_core/                    # Core: models, interfaces, DI
+-- alhai_design_system/           # Theme, typography, components
+-- alhai_services/                # Print, export, barcode services
+-- packages/
|   +-- alhai_database/            # Drift tables, DAOs, FTS5
|   +-- alhai_sync/                # Sync engine
|   +-- alhai_auth/                # Auth screens and providers
|   +-- alhai_pos/                 # POS feature screens
|   +-- alhai_reports/             # Report screens
|   +-- alhai_shared_ui/           # Shared UI screens and widgets
|   +-- alhai_ai/                  # AI-powered feature screens
|   +-- alhai_l10n/                # Localization (7 languages)
|   +-- alhai_zatca/               # ZATCA e-invoicing
+-- supabase/                      # Cloud schema and migrations
+-- .github/workflows/             # CI/CD pipelines
```

### Path Dependency Convention

Apps under `apps/` reference packages with `../../` prefixes. Root-level apps (`customer_app/`, `driver_app/`, etc.) use `../` prefixes. Melos resolves all paths automatically via the `packages` glob in `melos.yaml`.

---

## 2. Package Dependency Graph / مخطط التبعيات

```
+-------------------+     +-------------------+     +-------------------+
|   cashier (POS)   |     |   admin (web)     |     |   admin_lite      |
+--------+----------+     +--------+----------+     +--------+----------+
         |                         |                          |
         v                         v                          v
+-------------------+     +-------------------+     +-------------------+
|   alhai_pos       |     | alhai_shared_ui   |     | alhai_shared_ui   |
|   alhai_reports   |     | alhai_reports     |     +--------+----------+
|   alhai_shared_ui |     | alhai_ai          |              |
+--------+----------+     +--------+----------+              |
         |                         |                          |
         +------------+------------+--------------------------+
                      |
                      v
         +------------+------------+
         |      alhai_auth         |
         |      alhai_l10n         |
         |      alhai_zatca        |
         +------------+------------+
                      |
                      v
         +------------+------------+
         |      alhai_core         |  <-- Models, Repos, DI, Networking
         +------------+------------+
                      |
                      v
         +------------+------------+
         |    alhai_database       |  <-- Drift tables, DAOs, FTS5
         +------------+------------+
                      |
                      v
         +------------+------------+
         |      alhai_sync         |  <-- Sync engine (offline <-> Supabase)
         +-------------------------+
```

**Key rules:**
- `alhai_core` has zero Flutter UI dependencies; it holds models, repository interfaces, and DI setup.
- `alhai_database` depends only on `alhai_core`.
- `alhai_sync` depends on `alhai_database` and `supabase_flutter`.
- UI packages (`alhai_pos`, `alhai_shared_ui`, `alhai_reports`, `alhai_ai`) depend on `alhai_core`, `alhai_database`, and optionally `alhai_sync`.
- Apps compose these packages and provide routing via GoRouter.

---

## 3. Data Flow -- Offline-First / تدفق البيانات

The system follows an **offline-first** pattern. All reads and writes go to the local Drift database first. The sync engine pushes changes to Supabase when connectivity is available.

```
User Action
    |
    v
+---+---+ Screen / Widget (Riverpod Consumer)
    |
    v
+---+---+ Provider (StateNotifier / AsyncNotifier)
    |
    v
+---+---+ Repository (alhai_core interface)
    |
    +-----> Local DataSource (Drift DAO)  ---> SQLite/WASM
    |                |
    |                v
    |       sync_queue table
    |                |
    |                v (when online)
    +-----> Sync Engine (alhai_sync)
                     |
                     v
              Supabase (PostgreSQL)
                     |
                     v (Realtime subscription)
              Other devices get updates
```

### Sync Queue

Every local write (INSERT, UPDATE, DELETE) enqueues a record in the `sync_queue` table with:
- `table_name` -- which table was modified
- `record_id` -- UUID of the record
- `operation` -- create / update / delete
- `payload` -- JSON snapshot of the record
- `created_at` -- timestamp for ordering

The sync engine processes the queue in order, calling Supabase RPC functions or REST endpoints. On success, the queue entry is deleted. On conflict, the `conflict_resolver` applies last-write-wins or custom merge logic.

### Pull Sync

On app start (and periodically), the sync engine pulls records from Supabase that have `updated_at > last_sync_at`. The `sync_metadata` table tracks per-table sync timestamps.

### Realtime

For critical tables (orders, deliveries), Supabase Realtime subscriptions push changes instantly to connected clients. The `realtime_listener.dart` handles these events.

---

## 4. State Management / ادارة الحالة

| Concern            | Technology       | Location                              |
|--------------------|------------------|---------------------------------------|
| UI State           | Riverpod 2.x     | `providers/` in each package          |
| Dependency Injection| get_it + Injectable | `alhai_core/lib/src/di/`           |
| Local Persistence  | Drift (SQLite)   | `packages/alhai_database/`            |
| Secure Storage     | flutter_secure_storage | Auth tokens, PIN                |
| Preferences        | SharedPreferences | Non-sensitive settings                |

### Riverpod Pattern

Screens use `ConsumerWidget` or `ConsumerStatefulWidget`. Providers are defined in the package that owns the feature:

```dart
// packages/alhai_shared_ui/lib/src/providers/products_provider.dart
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(getIt<ProductsDao>());
});
```

### get_it + Injectable

Service registration happens at app startup. Each app calls `configureDependencies()` which registers DAOs, repositories, and services:

```dart
// alhai_core/lib/src/di/injection.dart
@InjectableInit()
void configureDependencies() => getIt.init();
```

---

## 5. Database / قاعدة البيانات

### Local (Drift)

- **Location:** `packages/alhai_database/lib/src/`
- **Tables:** 41 Drift table definitions in `tables/`
- **DAOs:** Data Access Objects in `daos/` for typed queries
- **FTS5:** Full-text search on products (`fts/products_fts.dart`)
- **Schema version:** v13 (with migration callbacks for each version)
- **Encryption:** SQLCipher via `sqlcipher_flutter_libs`
- **Web:** WASM-based Drift for browser environments

### Remote (Supabase / PostgreSQL)

- **Base schema:** `supabase/supabase_init.sql` (24 tables, 10 enums, 7 triggers)
- **Migrations:** `supabase/migrations/` (v14 through v20)
- **RLS:** Row Level Security on every table (see `docs/DATABASE.md`)
- **RPC functions:** Stored procedures for batch operations, role changes, inventory

See [docs/DATABASE.md](DATABASE.md) for full schema documentation.

---

## 6. ZATCA Compliance / الامتثال لهيئة الزكاة والضريبة

The `alhai_zatca` package implements Saudi Arabia ZATCA Phase 2 e-invoicing requirements:

| Component             | File                                       | Purpose                          |
|-----------------------|--------------------------------------------|----------------------------------|
| XML Generation        | `lib/src/zatca_xml_builder.dart`           | UBL 2.1 XML invoice generation   |
| Digital Signing       | `lib/src/zatca_signer.dart`                | ECDSA signing with SHA-256       |
| QR Code               | `lib/src/zatca_qr_generator.dart`          | TLV-encoded QR for receipts      |
| API Integration       | `lib/src/zatca_api_client.dart`            | Submit invoices to ZATCA portal  |
| Compliance Validation | `lib/src/zatca_validator.dart`             | Pre-submission validation        |

**Dependencies:** `pointycastle` (crypto), `xml` (generation), `asn1lib` (certificate handling).

**Flow:**
1. Sale completed -> Invoice data assembled
2. XML generated per UBL 2.1 spec
3. Document hash computed (SHA-256)
4. Signed with store's ECDSA private key
5. QR code generated with TLV encoding (seller, VAT, timestamp, totals, hash)
6. Submitted to ZATCA API (or queued if offline)

---

## 7. Multi-Tenant Isolation / عزل المستأجرين

The platform is multi-tenant. Each tenant is an **organization** (`organizations` table) that owns one or more **stores**.

### Isolation Layers

| Layer       | Mechanism                                                    |
|-------------|--------------------------------------------------------------|
| **Database**| Every table has `org_id` and/or `store_id` columns           |
| **RLS**     | PostgreSQL Row Level Security policies filter by `store_id`  |
| **Auth**    | `store_members` table maps users to stores with roles        |
| **App**     | After login, user selects a store; all queries scoped to it  |

### Key RLS Helper Functions

```sql
is_super_admin()        -- Returns true if current user is super_admin
is_store_member(store_id) -- Returns true if user belongs to the store
is_store_admin(store_id)  -- Returns true if user is owner/manager of the store
```

### Role Hierarchy

```
super_admin  -- Platform-level, manages all tenants
  +-- store_owner  -- Owns one or more stores
        +-- manager  -- Store manager, most admin rights
              +-- cashier  -- POS access, limited write
```

Role changes are enforced via RPC (`update_user_role`) with an audit log. Direct UPDATE on the `role` column is blocked by a trigger.

---

## 8. Security Model / نموذج الامن

| Aspect              | Implementation                                                |
|---------------------|---------------------------------------------------------------|
| **Authentication**  | Supabase Auth with phone OTP (primary) + email (background)  |
| **Authorization**   | RLS policies on every table; helper functions check roles     |
| **Local DB**        | SQLCipher encryption (AES-256) for on-device data             |
| **Secure Storage**  | `flutter_secure_storage` for auth tokens and PIN              |
| **PIN Protection**  | 4-digit PIN for manager approval and sensitive operations     |
| **API Keys**        | Passed via `--dart-define` at build time, never in source     |
| **Web Security**    | X-Frame-Options: DENY, CSP meta tags                         |
| **Obfuscation**     | `--obfuscate --split-debug-info` on release builds            |
| **Audit Trail**     | `activity_logs` table records all sensitive operations         |
| **Role Enforcement**| Trigger prevents direct role column updates; RPC required     |

---

## 9. Localization / التعريب

The `alhai_l10n` package provides translations for 7 languages:

| Code | Language    |
|------|-------------|
| `ar` | Arabic (primary, RTL) |
| `en` | English     |
| `ur` | Urdu (RTL)  |
| `hi` | Hindi       |
| `id` | Indonesian  |
| `bn` | Bengali     |
| `fil`| Filipino    |

ARB files live in `packages/alhai_l10n/lib/l10n/`. Generated files are in `generated/`. All user-facing strings use `AppLocalizations.of(context)`.

---

## 10. AI Features / ميزات الذكاء الاصطناعي

The `alhai_ai` package provides 16 AI-powered screens, backed by a FastAPI server (`ai_server/`) deployed on Railway:

- Sales Forecasting
- Smart Pricing (demand elasticity)
- Smart Inventory (EOQ, ABC analysis)
- Fraud Detection
- Customer Recommendations
- Basket Analysis (association rules)
- Competitor Analysis
- Sentiment Analysis
- Return Prediction
- Promotion Designer
- Staff Analytics
- Smart Reports
- Chat with Data (natural language queries)
- Product Recognition (OCR)
- AI Assistant (general purpose)

The AI server integrates with OpenAI and provides endpoints that the Flutter app consumes via `alhai_core`'s Dio HTTP client.
