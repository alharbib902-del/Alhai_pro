# C-4 Money Migration — Planning Document

**Branch:** `plan/c4-money-migration-20260421` (forked from `e00e158`)
**Session type:** PLANNING ONLY — zero code, zero SQL, zero Supabase execution
**Created:** 2026-04-21
**Status:** DRAFT — awaiting user review before commit

---

## Purpose

Transform the vague backlog item *"C-4 Money Migration (ZATCA critical, double → int cents)"* into a concrete executable plan. Every section below is actionable in a future fresh-mind session without re-analysis.

## TL;DR recommendation

**Do NOT execute a full double → int-cents migration in a single session.** The scope is significantly larger than initial estimate (300+ Dart files, 60+ Drift columns across 22 tables, 148 SQL column references, 250 test files). Instead, adopt **Option B — per-domain phased migration** over 4–5 dedicated sessions, starting with a new `Money` wrapper type in `alhai_core` as a ZERO-impact foundation. Details in §5.

**Pre-execution blocker:** this plan must first be reviewed against current production data distribution (any rows with values like `99.995`?). A read-only data-shape audit query is included in §6 Appendix; running it is prerequisite for approving any of the execution approaches.

---

## 1. Current state audit (Phase 1 findings)

### 1.1 Dart-side footprint

| Surface | Count | Notes |
|---|---|---|
| `.dart` files with money-field matches | **200+ (grep cap)** — actual likely 250–300 | Across all apps, packages, customer_app, driver_app, distributor_portal |
| Test `.dart` files with money terms | **250** | Hardcoded doubles in fixtures/expectations |
| Drift `RealColumn()` money fields | **60+ across 22 tables** | See §1.4 below |
| `alhai_core` freezed models referencing money doubles | **11 models** | `order`, `refund`, `cart`, `analytics`, `debt`, `customer_account`, `purchase_order`, `product`, `cash_movement`, `create/update_product_params`, product DTOs |
| `alhai_zatca` money-encoding sites | **7** | 4 TLV (`zatca_tlv_encoder.dart:50,53,85,86`) + 3 XML `_fmtAmount` helpers (`invoice_line_builder.dart:198`, `tax_total_builder.dart:130`, `ubl_invoice_builder.dart:493`) |
| `decimal`/`rational`/`fixed_point` package usage | **0** | No existing precision library. All "decimal: true" hits are Flutter `TextInputType.numberWithOptions(decimal: true)` — unrelated |
| Existing `.round()`/`.truncate()` for money in POS/cashier | **0 sites** | Float math runs raw — confirms precision hazards real |

### 1.2 Drift schema (alhai_database)

`schemaVersion = 37` (confirmed in `packages/alhai_database/lib/src/app_database.dart:135`).

Migration infrastructure:
- `MigrationStrategy` has pre-migration backup + integrity check (lines 176–250)
- `onUpgrade(from, to)` dispatches per-version migrations
- v24..v37 are "RLS/RPC/server-only — no client-side migration" (line 563)
- v38 would be the next available client-side slot

**All 22 tables with money `RealColumn` fields** (verified — do NOT treat as exhaustive, re-run the grep at execution time):

| Table | RealColumns (money-like) |
|---|---|
| `accounts_table.dart` | `balance`, `creditLimit` |
| `daily_summaries_table.dart` | `totalSalesAmount`, `totalOrdersAmount`, `totalRefundsAmount`, `totalExpenses`, `cashTotal`, `cardTotal`, `creditTotal`, `netProfit` |
| `discounts_table.dart` | `value`, `minPurchase`, `maxDiscount` (twice — two table classes) |
| `expenses_table.dart` | `amount` |
| `held_invoices_table.dart` | `subtotal`, `discount`, `total` |
| `invoices_table.dart` | `subtotal`, `discount`, `taxRate`, `taxAmount`, `total`, `amountPaid`, `amountDue` |
| `orders_table.dart` | `subtotal`, `taxAmount`, `deliveryFee`, `discount`, `total` |
| `order_items_table.dart` | `unitPrice`, `discount`, `taxRate`, `taxAmount`, `total` (plus `quantity` — NOT money but same double type) |
| `organizations_table.dart` | `amount` |
| `org_products_table.dart` | `defaultPrice`, `costPrice` |
| `products_table.dart` | `price`, `costPrice` |
| `purchases_table.dart` | `subtotal`, `tax`, `discount`, `total`, `unitCost`, `total` (items) |
| `returns_table.dart` | `totalRefund`, `unitPrice`, `refundAmount` |
| `loyalty_table.dart` | `saleAmount`, `rewardValue`, `minPurchase` |
| `sales_table.dart` | `subtotal`, `discount`, `tax`, `total`, `amountReceived`, `changeAmount`, `cashAmount`, `cardAmount`, `creditAmount` |
| `sale_items_table.dart` | `unitPrice`, `costPrice`, `subtotal`, `discount`, `total` |
| `shifts_table.dart` | `openingCash`, `closingCash`, `expectedCash`, `difference`, `totalSalesAmount`, `totalRefundsAmount`, `amount` (movements) |
| `suppliers_table.dart` | `balance` |
| `transactions_table.dart` | `amount`, `balanceAfter` |

**Non-money `RealColumn` fields** (must NOT be changed — they are quantities/coordinates):
- `customers_table`: `lat`, `lng` (GPS coordinates)
- `orders_table`: `deliveryLat`, `deliveryLng`
- `inventory_movements_table`: `qty`, `previousQty`, `newQty`
- `products_table`: `stockQty`, `minQty`, `onlineMaxQty`, `onlineReservedQty`, `minAlertQty`, `reorderQty`, `turnoverRate`
- `purchases_table`: `qty`, `receivedQty` (items), also `onlineMaxQty`, `minAlertQty`, `reorderQty` in `org_products`
- `stock_deltas_table`: `quantityChange`
- `loyalty_rewards`: `minPurchase` is money but `quantity`-like
- `returns_table`: `qty`

**Gotcha:** `order_items.quantity` is `RealColumn` — may be fractional (weighed goods). **NOT money. Leave as-is.**

### 1.3 Supabase SQL schema

**148 total REAL/NUMERIC/DOUBLE PRECISION occurrences** in `supabase/migrations/*.sql` and `supabase/*.sql`.

Two type families in use today:
- `DOUBLE PRECISION` (older migrations, fix_compatibility.sql, rls_policies.sql)
- `NUMERIC(12,2)` (v14 onwards — precedent for mixed types exists)

Example live coverage (non-exhaustive sample from grep):
- `fix_compatibility.sql:165–484` — 12 DOUBLE PRECISION columns across order_items, shifts, suppliers, discounts, returns, refunds, sales_table, purchases_table, loyalty_rewards
- `20260305_v14_org_products_online_orders.sql:24-25` — `default_price NUMERIC(12,2)`, `cost_price NUMERIC(12,2)`
- `20260305_v15_invoices.sql:35-38` — 4 DOUBLE PRECISION columns on invoices
- `20260404_v25_create_missing_tables.sql` — additional tables

Full inventory requires the §6 discovery query; treat the above as a spot-check.

### 1.4 ZATCA-specific money handling (the critical-path finding)

**4 TLV encoding sites** (`packages/alhai_zatca/lib/src/qr/zatca_tlv_encoder.dart`):
- Line 50, 53, 85, 86 — all call `.toStringAsFixed(2)` on a `double` parameter
- Format expected by ZATCA: UTF-8 string of 2-decimal amount (e.g., `"100.00"`, `"1150.50"`)

**3 XML `_fmtAmount(double) => value.toStringAsFixed(2)` helpers**:
- `invoice_line_builder.dart:198`
- `tax_total_builder.dart:130`
- `ubl_invoice_builder.dart:493`

**VAT calculator:** `packages/alhai_zatca/lib/src/qr/vat_calculator.dart` — works on doubles; tests at `test/xml/invoice_line_builder_test.dart:457` already assert behavior at edge `99.999 → "100.00"` (line 457 comment). Tests depend on double arithmetic semantics.

**Critical insight for ZATCA compliance:** the QR code TLV and the XML amount strings MUST be consistent, and they MUST match what ZATCA's validator expects. The current `toStringAsFixed(2)` on doubles uses banker's rounding (round-half-to-even). If we switch to `int cents` model, the conversion site becomes `(cents / 100).toStringAsFixed(2)` which is equivalent, OR we can format directly from cents with `${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}` which is bit-exact.

**Hazard:** intermediate computations — like `discountAmount * 0.15` for VAT — produce floats that must be rounded consistently. Any migration MUST lock down the rounding rule (`ROUND_HALF_EVEN` vs `ROUND_HALF_UP`) and apply it at every amount-write site. ZATCA's reference implementations use `ROUND_HALF_UP` by default; current Dart `toStringAsFixed` uses round-half-to-even.

### 1.5 Sync pipeline money handling

`packages/alhai_sync/lib/src/strategies/push_strategy.dart` — direct `.upsert()` of whatever is in Drift. If Drift is double and Supabase is DOUBLE PRECISION, no conversion needed. Any type mismatch introduces a conversion hazard — so Drift and Supabase must migrate in lockstep.

No sync-level money coercion currently exists. This is both good (no hidden layer to fix) and bad (no abstraction to centralize the int-cents conversion — must be done everywhere).

---

## 2. Scope map (Phase 2 findings)

### 2.1 Domain classification

#### Invoice-critical (ZATCA compliance)
**Hit list — must migrate in lockstep:**
- `sales_table` — subtotal, discount, tax, total, cashAmount, cardAmount, creditAmount, amountReceived, changeAmount
- `sale_items_table` — unitPrice, subtotal, discount, total, costPrice
- `invoices_table` — subtotal, discount, taxRate (%, NOT money), taxAmount, total, amountPaid, amountDue
- `held_invoices_table` — subtotal, discount, total
- `returns_table` — totalRefund, unitPrice, refundAmount
- `orders_table` — subtotal, taxAmount, deliveryFee, discount, total
- `order_items_table` — unitPrice, discount, taxAmount, total

**Callers (Dart code that writes these):**
- `packages/alhai_pos/lib/src/services/sale_service.dart`
- `packages/alhai_pos/lib/src/services/invoice_service.dart`
- `packages/alhai_pos/lib/src/services/zatca_service.dart`
- `customer_app/lib/features/checkout/data/orders_datasource.dart`
- `packages/alhai_database/lib/src/daos/sales_dao.dart`
- `packages/alhai_database/lib/src/daos/invoices_dao.dart`
- `packages/alhai_database/lib/src/daos/orders_dao.dart`
- Dozens of cashier/admin screens displaying these values

**Cross-system:** ZATCA TLV encoder + XML builders (see §1.4) read the same money values. Their format must remain `"NNN.NN"` exactly.

#### Product catalog
- `products_table` — price, costPrice
- `org_products_table` — defaultPrice, costPrice
- `discounts_table` — value, minPurchase, maxDiscount

Impact: read-heavy. Changing these changes POS cart math → ripples to invoice/sales via sale_service.

#### Shifts + cash flow (financial controls)
- `shifts_table` — openingCash, closingCash, expectedCash, difference, totalSalesAmount, totalRefundsAmount
- Cash movements — amount
- `daily_summaries_table` — totalSales, totalOrders, totalRefunds, totalExpenses, cashTotal, cardTotal, creditTotal, netProfit
- `accounts_table` — balance, creditLimit
- `transactions_table` — amount, balanceAfter
- `suppliers_table` — balance
- `organizations_table` — amount

Impact: these feed reports and dashboards. Precision errors here cascade into shift close mismatches (the very bug that makes this migration P0).

#### Analytics (derived, not source of truth)
- `packages/alhai_reports/lib/src/services/reports_service.dart`
- All `*_report_screen.dart` in `alhai_reports`
- `packages/alhai_shared_ui/lib/src/providers/dashboard_providers.dart`
- `super_admin/lib/data/models/sa_analytics_model.dart`

Most of these SELECT from the tables above and compute aggregates. If source tables become int-cents, these must either (a) also be int-cents internally, OR (b) convert at read time. Option (a) is simpler.

#### Legacy/less-critical (can migrate last)
- `loyalty_table` — saleAmount, rewardValue, minPurchase
- `expenses_table` — amount
- `purchases_table` / `purchase_items` — subtotal, tax, discount, total, unitCost
- `distributor_portal` pricing — standalone

### 2.2 Dependency graph (migration ordering)

```
products / org_products                    ← start (low write frequency)
   │
   ▼
sale_items / order_items / return_items    ← tight dependency on products
   │
   ▼
sales / orders / returns / invoices        ← aggregates of items
   │
   ▼
shifts / daily_summaries                   ← aggregates of sales
   │
   ▼
accounts / transactions / suppliers        ← aggregates + external
   │
   ▼
analytics / reports                        ← read-only
```

**ZATCA encoding sites are leaf nodes** — they read money values and serialize. If we feed them int-cents, they format. If we feed them doubles, they format. The encoder is the last thing we touch; in fact, introducing a `Money` wrapper type (see §3 Option B) can make it invisible to the encoder.

### 2.3 Test fixture impact

**250 test files** reference money terms. Full-repo grep-and-update will be tedious. Approaches:
1. Mechanical: run a `Money(cents: N)` constructor wrapper over integer-literal fixtures
2. Create `Money.fromDouble(double d)` as a bridge factory for test compatibility during migration
3. Update each test domain alongside its production migration phase

Test types by count:
- `apps/cashier/test/` — ~80 test files with money terms (heaviest)
- `packages/alhai_database/test/` — ~40 DAO tests
- `packages/alhai_pos/test/` — ~20
- `customer_app/test/` — ~8
- `packages/alhai_zatca/test/` — ~15 (CRITICAL — any regression here is ZATCA compliance failure)
- Others scattered

---

## 3. Migration approach options (Phase 3 analysis)

### Option A — Big Bang (single migration)

**Scope:** one branch, one Drift v38 migration, one set of Supabase migrations (v56+), one commit sweep rewrites all 200+ Dart files, single full-repo test run.

| Attribute | Value |
|---|---|
| Estimated execution time | **3–5 full days** (40+ hours) of focused work |
| Number of migrations | 1 Drift (v38) + ~8 Supabase (grouped by domain or one monolith) |
| Number of commits | 1 per file group (~15 commits) or one mega-commit |
| Risk profile | **VERY HIGH** — any bug affects all money handling simultaneously |
| Rollback complexity | Impossible without full DB restore — each table's int/double rollback is ~150 lines |
| ZATCA safety | Single test run determines pass/fail; no incremental confidence |
| Review burden | Unreviewable in practice (~5000 lines changed) |
| Blast radius if wrong | Catastrophic — ZATCA compliance, shift close, reports, POS all break together |

**Verdict:** NOT recommended. Scope is too large for atomic execution. Any single bug (rounding rule mismatch, missed call site, test-fixture mistake) wastes the whole session.

### Option B — Per-Domain Phased (RECOMMENDED)

**Scope:** break into 4–5 dedicated sessions, each scoped to one domain of §2.1. Each session = 1 domain's Drift tables + matching Supabase migration + callers + tests + commit set.

**Session breakdown:**

| # | Session | Scope | Est. time | Deliverable |
|---|---|---|---|---|
| 0 | **Foundation** | Add `Money` wrapper type in `alhai_core` (int-cents backed, format helpers, arithmetic, JSON codec). Zero impact on existing code. | 2–3 hrs | `alhai_core/lib/src/money/money.dart` + tests + 0 table changes |
| 1 | **Product catalog** | products, org_products, discounts. Callers in cashier POS + admin price mgmt. | 4–6 hrs | Drift v38 + Supabase v56 + ~30 files |
| 2 | **Invoice core** | sales, sale_items, orders, order_items, invoices, held_invoices, returns. Touches ZATCA encoder. | 8–10 hrs | Drift v39 + Supabase v57 + ~80 files + zatca_zandbox_test full run |
| 3 | **Shifts & cash** | shifts, daily_summaries, accounts, transactions, suppliers, cash_movements | 4–6 hrs | Drift v40 + Supabase v58 + ~40 files |
| 4 | **Analytics cleanup** | reports, dashboard providers, super_admin, analytics models | 3–4 hrs | No schema change (read-only) + ~30 files |

**Total:** ~25–30 hours across 4–5 sessions spread over 1–2 weeks.

| Attribute | Value |
|---|---|
| Risk profile | **MEDIUM** — per-session blast radius is contained to one domain |
| Rollback complexity | Low per session — each session has its own migration + commit set |
| ZATCA safety | Session 2 specifically is the ZATCA-critical one; fully tested in isolation |
| Review burden | Each session ~500–1000 lines — reviewable |
| Transient state | Between sessions, some tables are int-cents and others are doubles. Mitigated by §4 Risk R3. |

**Verdict:** RECOMMENDED. The "Foundation" session (Session 0) is especially valuable — it costs almost nothing and provides a clean `Money` API that later sessions build on.

### Option C — Dual-Write Shadow Migration

**Scope:** for each money column, add a new `*_cents INTEGER` column alongside. Dual-write both fields for a verification window. Switch readers gradually. Drop old columns last.

**Phases:**
1. ADD COLUMN `*_cents INT` to all 22 tables (1 Supabase migration, idempotent IF NOT EXISTS)
2. Update all write sites to populate both columns
3. Run verification queries for N weeks: `WHERE ROUND(legacy_amount * 100) <> legacy_cents` → should be 0 rows
4. Flip readers one domain at a time
5. DROP old columns after all readers flipped

| Attribute | Value |
|---|---|
| Estimated execution time | **4–6 weeks calendar** (dual-write period) — probably 20 hrs of actual coding |
| Number of migrations | 3 Supabase (ADD, partial DROP per domain, final cleanup) + 1–2 Drift |
| Risk profile | **LOW** — both data paths valid during transition |
| Rollback complexity | Trivial — just stop reading new column |
| ZATCA safety | Very high — can run both encoders in parallel and diff results |
| Operational complexity | HIGH — requires monitoring + dev discipline (every new write site must dual-write) |
| Review burden | Distributed over many small PRs |
| Long-term maintenance | Long transient period, easy to forget the second migration |

**Verdict:** Too complex for a small team. Dual-write is the right answer for production databases with millions of rows and regulatory compliance pressure. Alhai's ZATCA compliance pressure is real, but the data volume (tables with 0 rows or low row counts — confirmed by recent C-9 Phase D finding of 0 rows across the wildcard-dropped tables) does NOT justify dual-write's operational overhead.

---

## 4. Risk matrix (Phase 4)

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Rounding-rule mismatch (banker's vs half-up) produces ZATCA validation failures | **HIGH** | **CRITICAL** | Session 0 Money type MUST define ONE canonical rounding rule. All call sites use Money methods, never raw double ops. ZATCA integration tests run every session. |
| R2 | Precision loss in conversion — existing rows like `99.995` round to `9999` cents (down) but `10000` (up) under different rules | **MEDIUM** | **HIGH** | Prerequisite: run §6 discovery query to find any row with fractional-cent values. Decide round-up vs round-down in writing BEFORE any migration runs. |
| R3 | Transient mixed-type state between Option B sessions — DAOs reading int-cents from sales but double from invoices | **MEDIUM** | **MEDIUM** | Each Session N adds `Money.fromCents` / `Money.fromDouble` factory + updates DAOs to convert at the boundary. Callers always see `Money`. When a table migrates, its DAO flips which factory it uses. |
| R4 | Sync pipeline between Drift (int) and Supabase (int) — straightforward if in sync. But if Drift is v38+ while Supabase is legacy, every push is corrupted. | **HIGH** | **CRITICAL** | Drift migration MUST apply strictly AFTER Supabase migration succeeds. Lock ordering: (1) Supabase ALTER, (2) verify, (3) Drift onUpgrade runs on next app start. |
| R5 | Test fixture churn — hundreds of tests with hardcoded doubles in test factories | **CERTAIN** | **LOW** | Add `Money.fromDouble` helper; use `replace_all` Edits where fixture patterns are mechanical. Budget test-update time into each session. |
| R6 | `order_items.quantity` and similar `RealColumn` non-money fields accidentally migrated | **MEDIUM** | **MEDIUM** | Per-column allowlist in each migration. Do NOT use regex-based "convert all RealColumn" sweep. Explicit column list per session. |
| R7 | Multi-currency assumption violated (today SAR-only, but schema has `currency_code` fields) | **LOW** | **MEDIUM** | Current state: all invoices are SAR. Document assumption in Money type: "Money is SAR-fixed until explicit multi-currency requirement." Store currency_code as TEXT separately. |
| R8 | `fix_compatibility.sql` double columns present in live DB but NOT in migration history → hard to enumerate truthfully | **HIGH** | **MEDIUM** | Prerequisite discovery query runs against LIVE `information_schema.columns` (not migration files). Use live DB as source of truth, per A-5 lesson. |
| R9 | ZATCA invoice archival — signed XML already stored references the old double values. Regeneration from int-cents must produce byte-identical XML. | **MEDIUM → LOW once D4 confirms 0 rows** | **CRITICAL if rows exist** | Per D4: Appendix B audit in Session 0 determines risk. If 0 rows, downgrade to LOW. If \>0 rows, STOP and build regression suite before Session 2 proceeds. |
| R10 | `decimal: true` Flutter TextInput accepts user entries like "3.999". Input validation must match cents granularity. | **MEDIUM** | **LOW** | Input widget: after parsing, `Money.parseInput` rounds to 2dp. Document in widget wrapper. |

---

## 5. Recommendation + execution checklist (Phase 5)

### Recommendation: **Option B (per-domain phased), starting with Session 0 Foundation**

Rationale:
- Option A's atomicity benefit is overwhelmed by its review/debug cost
- Option C's dual-write safety is wasted at current data volumes
- Option B matches the project's established pattern (C-9 Phases A → B → C → C-continuation → D) — the user's muscle memory and tooling are already aligned with this cadence

### Prerequisites (MUST be satisfied before Session 0 begins coding)

- [ ] Run §6 Appendix A discovery query on production Supabase. Save output as `docs/sessions/c4-schema-snapshot-<date>.md`.
- [ ] Run §6 Appendix B data-shape audit query. Interpret per D4:
  - 0 rows with fractional cents → proceed; mark R9 downgrade to LOW
  - \>0 rows → STOP, build historical-invoice regression suite before any Session 2 work
- [ ] Confirm current production is **SAR-only** — per D2, this is the assumed state; `Money` type still carries currencyCode for future extensibility
- [ ] Confirm ZATCA integration tests pass on current `main` (baseline — target: 100% pass on `packages/alhai_zatca` + cashier zatca_sandbox tests)
- [ ] **Set up branch-based staging Supabase project per D3** (~1 hr):
  - Use Supabase branching (https://supabase.com/docs/guides/deployment/branching)
  - Document connection URL + credentials in `docs/sessions/staging-supabase.md`
  - Verify branch can accept SQL Editor migrations
  - Every session from here onwards applies migrations to staging FIRST, validates, THEN to production
- [ ] Backup live DB (user runs manually via Supabase dashboard)

### Session 0 execution checklist (Foundation — the prerequisite session)

**Goal:** add `Money` wrapper in `alhai_core` with ZERO impact on existing code. After Session 0, nothing changes in production or Drift or Supabase — only a new class is available.

- [ ] Add `alhai_core/lib/src/money/money.dart` — freezed class wrapping `int cents` + `String currencyCode` (per D2)
  - `const Money.fromCents(int cents, {String currencyCode = 'SAR'})`
  - `const Money.sar(int cents)` — convenience constructor for the common case
  - `factory Money.fromDouble(double d, {String currencyCode = 'SAR'})` — MUST use ROUND_HALF_UP per D1 (NOT Dart's default round-half-to-even). Unit-test against ZATCA sample values.
  - `factory Money.parseUserInput(String s, {String currencyCode = 'SAR'})` — for text fields; internally delegates to fromDouble
  - `String toDisplayString()` — e.g., "99.99" (no currency symbol; caller adds locale formatting)
  - `String toZatcaString()` — e.g., "99.99" (identical to toDisplayString but named for intent — ZATCA TLV/XML serialization sites call this to signal semantic locking)
  - `double toDouble()` — escape hatch for legacy call sites during transition (Sessions 1–4); deprecate and remove by end of Session 4
  - Arithmetic: `+`, `-`, `*` (int scalar), `percent(double)` for VAT. All arithmetic REJECTS mixed currencyCode at runtime (per D2) via assert or ArgumentError.
  - Comparison: `==`, `<`, `>`, `<=`, `>=`, `isZero`, `isPositive` (mixed-currency comparisons also rejected)
  - JSON codec: `toJson() → {"cents": N, "currency": "SAR"}`, `fromJson(Map)` — preserves int-cents AND currencyCode for sync extensibility

- [ ] Add `alhai_core/test/money/money_test.dart` — comprehensive tests:
  - Construction: fromCents, sar, fromDouble, parseUserInput (both with default and explicit currencyCode)
  - Rounding — ROUND_HALF_UP verified (per D1):
    - `Money.fromDouble(99.995) === Money.fromCents(10000)` (NOT 9999)
    - `Money.fromDouble(99.994) === Money.fromCents(9999)`
    - `Money.fromDouble(-99.995) === Money.fromCents(-10000)` (half-away-from-zero)
  - ZATCA sample values: pick 5–10 canonical ZATCA test fixtures (e.g., 100.00, 115.00, 345.00, 1150.50 from `packages/alhai_zatca/test/integration/zatca_sandbox_test.dart`) — verify `Money.fromDouble(x).toZatcaString() === old toStringAsFixed(x, 2)` for each
  - Arithmetic precision: `Money.fromCents(33) * 3 === Money.fromCents(99)` not 98.99...
  - Mixed-currency rejection: `Money.sar(100) + Money.fromCents(100, currencyCode: 'USD')` throws ArgumentError (per D2)
  - Serialization: JSON round-trip preserves cents AND currencyCode
  - Formatting: toDisplayString for common values

- [ ] Commit 1: `feat(alhai_core): add Money wrapper type for future int-cents migration — C-4 foundation`

- [ ] Run `flutter test alhai_core` — must pass 100%
- [ ] Run `flutter analyze alhai_core/lib` — must be clean
- [ ] Run `flutter test apps/cashier`, `customer_app`, `packages/alhai_database`, `packages/alhai_zatca` — baselines preserved (0 regressions — nothing should change; Money is additive)

- [ ] Dual-log update per established pattern (canonical + in-repo byte-identical)

- [ ] STOP for user backup push

### Session 1+ skeleton (per-domain, reusable template)

For each domain session (1 through 4):

- [ ] Branch `fix/c4-money-session-N-<domain>-<date>` forked from previous session's HEAD
- [ ] **PRE:** run discovery queries against live DB to confirm column list unchanged since plan was written
- [ ] Supabase migration `vN_c4_money_cents_<domain>.sql`:
  - Add new `*_cents INTEGER NOT NULL DEFAULT 0` columns alongside existing `*`
  - UPDATE new columns: `SET col_cents = (col * 100)::INT` — but only where data exists; use `ROUND(col * 100)::INT` for fractional safety
  - Flip primary key of reads from app code to new columns (later)
  - OR: directly `ALTER ... TYPE INTEGER USING ROUND(col * 100)::INT` if 0 rows in domain tables (check first)
- [ ] Drift migration `vN+1` in `app_database.dart`: onUpgrade from N to N+1 changes `RealColumn` → `IntColumn` for the affected columns. Data backfill via Drift `customStatement`.
- [ ] Update all callers (DAOs, services, screens) to use `Money` type
- [ ] Update test fixtures in this domain
- [ ] Run the 4 flutter test apps — 0 regressions required
- [ ] ZATCA integration test MUST PASS (critical for Session 2 especially)
- [ ] Per-commit: Supabase migration, then Drift migration, then code, then tests, then log
- [ ] Mini-checkpoint + STOP for backup push

### STOP conditions (rollback triggers during any session)

- Flutter test baseline drop of more than 0 tests
- Analyzer regression
- ZATCA integration test failure (especially Session 2)
- Supabase migration returns error (any 42xxx Postgres error)
- User-reported data discrepancy after staging deploy

### Time budget

| Session | Estimated time | Cumulative | Notes |
|---|---|---|---|
| 0 (Foundation) | 3–4 hrs (was 2–3, +1 hr for staging setup per D3) | 4 hrs | Half-day; can overlap other work |
| 1 (Product catalog) | 4–6 hrs | 10 hrs | Half-day |
| 2 (Invoice core — ZATCA) | 8–10 hrs | 20 hrs | **Full dedicated day, no other work** — per D5 |
| 3 (Shifts & cash) | 4–6 hrs | 26 hrs | Half-day |
| 4 (Analytics cleanup) | 3–4 hrs | 30 hrs | Half-day |

Per D5: target 2 sessions per week, spread across ~2 calendar weeks. Session 2 (ZATCA-critical) gets a full dedicated day with no parallel work. If an unforeseen ZATCA audit deadline surfaces mid-migration, re-evaluate ordering — base plan assumes no such pressure.

**Staging validation:** per D3, every session's migrations run against the staging Supabase branch first. Budget ~30 min per session for staging validation before promoting to production (already included in per-session estimates above).

---

## 6. Appendix — Discovery queries

### Appendix A — Live schema discovery (run in Supabase SQL Editor before Session 0)

```sql
-- A1: Every money-like column across all public tables
SELECT
  table_name,
  column_name,
  data_type,
  numeric_precision,
  numeric_scale,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    data_type IN ('real', 'double precision', 'numeric')
    OR column_name ~* '(price|total|amount|tax|discount|subtotal|cost|vat|fee|balance|paid|due|refund|change|cashback|commission|tip)'
  )
ORDER BY table_name, ordinal_position;

-- A2: Row counts per money-bearing table (helps prioritize sessions)
SELECT 'sales'         AS t, COUNT(*) FROM public.sales
UNION ALL SELECT 'sale_items',     COUNT(*) FROM public.sale_items
UNION ALL SELECT 'orders',         COUNT(*) FROM public.orders
UNION ALL SELECT 'order_items',    COUNT(*) FROM public.order_items
UNION ALL SELECT 'invoices',       COUNT(*) FROM public.invoices
UNION ALL SELECT 'returns',        COUNT(*) FROM public.returns
UNION ALL SELECT 'products',       COUNT(*) FROM public.products
UNION ALL SELECT 'shifts',         COUNT(*) FROM public.shifts
UNION ALL SELECT 'transactions',   COUNT(*) FROM public.transactions
UNION ALL SELECT 'accounts',       COUNT(*) FROM public.accounts
UNION ALL SELECT 'daily_summaries',COUNT(*) FROM public.daily_summaries
UNION ALL SELECT 'expenses',       COUNT(*) FROM public.expenses
ORDER BY 1;
```

### Appendix B — Data-shape audit (PREREQUISITE before any execution session)

Objective: find any row with fractional-cent precision that would be ambiguous under rounding.

```sql
-- B1: Find invoices with non-cents-clean total
SELECT 'invoices.total' AS where_found, id, total
  FROM public.invoices
 WHERE total IS NOT NULL
   AND (total * 100) <> ROUND(total * 100)
 LIMIT 20;

-- B2: Same for sales
SELECT 'sales.total' AS where_found, id, total
  FROM public.sales
 WHERE total IS NOT NULL
   AND (total * 100) <> ROUND(total * 100)
 LIMIT 20;

-- B3: Same for products.price
SELECT 'products.price' AS where_found, id, price
  FROM public.products
 WHERE price IS NOT NULL
   AND (price * 100) <> ROUND(price * 100)
 LIMIT 20;

-- B4: Aggregate — count of imprecise rows per table
SELECT 'invoices' AS t, COUNT(*) FROM public.invoices WHERE total IS NOT NULL AND (total * 100) <> ROUND(total * 100)
UNION ALL SELECT 'sales',       COUNT(*) FROM public.sales        WHERE total IS NOT NULL AND (total * 100) <> ROUND(total * 100)
UNION ALL SELECT 'orders',      COUNT(*) FROM public.orders       WHERE total IS NOT NULL AND (total * 100) <> ROUND(total * 100)
UNION ALL SELECT 'order_items', COUNT(*) FROM public.order_items  WHERE total IS NOT NULL AND (total * 100) <> ROUND(total * 100)
UNION ALL SELECT 'sale_items',  COUNT(*) FROM public.sale_items   WHERE total IS NOT NULL AND (total * 100) <> ROUND(total * 100)
UNION ALL SELECT 'products',    COUNT(*) FROM public.products     WHERE price IS NOT NULL AND (price * 100) <> ROUND(price * 100)
ORDER BY 1;
```

**Decision rule based on B4 results:**
- All zeros → safe to migrate via `ROUND(col * 100)::INT`
- Any non-zero count → stop. Decide: round-half-up everywhere, OR keep legacy rows as-is and only enforce cents on new rows. Depends on finance/audit requirements.

### Appendix C — Drift migration sketch (Session 1 template)

Pattern for Drift `onUpgrade` from v37 → v38:

```dart
// apps/packages/alhai_database/lib/src/app_database.dart — onUpgrade
// inside the switch(targetVersion) in onUpgrade
case 38:
  // Session 1: products catalog money → int cents
  await m.customStatement('''
    CREATE TABLE products_new AS SELECT
      id, org_id, store_id, name, sku, barcode,
      CAST(ROUND(price * 100) AS INTEGER) AS price,
      CAST(ROUND(cost_price * 100) AS INTEGER) AS cost_price,
      -- ... other columns unchanged ...
    FROM products;
  ''');
  await m.customStatement('DROP TABLE products;');
  await m.customStatement('ALTER TABLE products_new RENAME TO products;');
  // Repeat for org_products, discounts
  break;
```

*(Exact shape depends on Drift's generated code — placeholder only; verify against Drift documentation before execution.)*

### Appendix D — Rollback shape

Per-session rollback DDL goes into the migration comment block:

```sql
/*
-- Rollback for Session N
BEGIN;
-- Revert column types + values
ALTER TABLE products ADD COLUMN price_dbl DOUBLE PRECISION;
UPDATE products SET price_dbl = price / 100.0;
ALTER TABLE products DROP COLUMN price;
ALTER TABLE products RENAME COLUMN price_dbl TO price;
COMMIT;
*/
```

---

## 7. Decisions locked

All five open questions resolved 2026-04-21 before committing this plan. Decisions below are binding for execution sessions.

### D1. Rounding policy — ROUND_HALF_UP
- `Money.fromDouble(double d)` MUST use `ROUND_HALF_UP` (the ZATCA reference rounding rule, and the official standard for SAR invoicing).
- Do NOT rely on Dart's default `toStringAsFixed` which uses round-half-to-even (banker's) — implement rounding explicitly on the int-cents boundary.
- Implementation sketch: `final raw = d * 100; return Money.fromCents((raw + (raw >= 0 ? 0.5 : -0.5)).floor());` — or use a unit-tested helper that is verified against ZATCA sample cases.
- **Closes R1.**

### D2. Multi-currency — SAR-only today, currency-aware from day 1
- `Money` type carries a `String currencyCode` field from the first commit, defaulting to `'SAR'` everywhere.
- All arithmetic operators REJECT mixed-currency operands at runtime (`assert(a.currencyCode == b.currencyCode)` or throw `ArgumentError`).
- `Money.sar(int cents)` convenience constructor for the overwhelmingly common case.
- JSON codec: `{"cents": 9999, "currency": "SAR"}` — extensible without schema break when USD/AED arrives.
- Supabase schema: keep `currency_code TEXT` columns where present; do NOT consolidate into Money — the Dart Money type owns it client-side, the DB column owns it server-side.
- **Future-proof but zero multi-currency logic runs today** — rejecting mixed currencies is ENOUGH until the roadmap surfaces a real need.

### D3. Staging Supabase — create branch-based staging as Session 0 prerequisite
- Alhai currently has **no staging Supabase project**. Running Session 2 (ZATCA invoice core) against production without dry-run is unacceptable risk.
- **Prerequisite addition:** use [Supabase branching](https://supabase.com/docs/guides/deployment/branching) — create a branch from production, `supabase link` it locally, apply each session's migrations against the branch first, validate with real-ish data, then promote to production.
- Treat this setup as a **Session 0 sub-task** (~1 hr of Supabase configuration + documentation).
- Document the branch URL + connection string in a new file `docs/sessions/staging-supabase.md` during Session 0.

### D4. Historical invoice regression — defer, confirm with Appendix B
- Alhai is a new product; there are likely few-to-zero signed invoices persisted from prior ZATCA submissions.
- **Definitive check:** Session 0 runs Appendix B data-shape audit against live DB. Result interpretation:
  - 0 rows with fractional cents → no historical regression suite needed; skip the extra scope
  - \>0 rows with fractional cents → STOP, add a regression suite that replays N historical invoices against both old (double) and new (cents) encoders and diffs the resulting XML byte-for-byte before Session 2 proceeds
- **R9 remains CRITICAL** until Appendix B confirms empty. Downgrade to LOW only after verification.

### D5. Cadence — 4–5 sessions over ~2 weeks, no immediate ZATCA audit pressure
- Target 2 sessions per week, one focused workday each.
- Session 2 (ZATCA core) gets a full dedicated day with no other work.
- Sessions 0, 1, 3, 4 can be half-day or overlap with other backlog.
- **Rejects Option A outright** — no time pressure justifies big-bang risk.
- If an unforeseen ZATCA audit deadline surfaces mid-migration, re-evaluate ordering — but base plan assumes no such pressure.

---

## 8. Post-plan artifacts expected

When all 5 sessions complete:
- 1 new `Money` type in `alhai_core`
- 4 Drift migrations (v38, v39, v40, and maybe v41 for cleanup)
- ~4 Supabase migrations (v56–v59)
- ~200 Dart file edits (cumulative)
- ~250 test file edits (cumulative)
- 10+ commits across sessions
- 1 accumulated log section per session
- Full ZATCA integration test pass at every session boundary
- Prod DB at cents-only state, double columns fully removed

Future auditability: each session produces a reviewable PR with scope limited to one domain.

---

*End of C-4 Money Migration planning document.*
