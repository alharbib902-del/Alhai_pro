# Schema Alignment Plan: Drift v23 → v37

**Status:** PLAN ONLY — no code changes. Review before implementation.
**Author:** Schema team
**Date:** 2026-04-17
**Scope:** Bring the local Drift schema (`alhai_database`) forward so it mirrors the Supabase state after migrations v24 through v37.

---

## 1. Current state

| Item | Value | Source |
|------|-------|--------|
| Drift `schemaVersion` | **23** | `packages/alhai_database/lib/src/app_database.dart:135` |
| Drift table files | **39** table files under `packages/alhai_database/lib/src/tables/` (excluding `tables.dart` barrel) | `packages/alhai_database/lib/src/tables/` |
| Latest Supabase migration | **v37** (`20260416_v37_rpc_auth_hardening.sql`, `20260416_v37_fix_distributor_rls_profiles_reference.sql`) | `supabase/migrations/` |
| Synced table whitelist | **46 tables** | `packages/alhai_sync/lib/src/sync_table_validator.dart:4-50` |
| New ZATCA constraint migration | v38 (this repo, `supabase/migrations/20260417_v38_zatca_nullability.sql`) | Part 1 deliverable |

### Synced tables (authoritative list)
From `sync_table_validator.dart:4-50` — the 46 tables that cross the Drift ⇄ Supabase boundary:
`stores, users, categories, products, customers, suppliers, sales, sale_items, orders, order_items, order_status_history, purchases, purchase_items, returns, return_items, accounts, transactions, inventory_movements, expenses, expense_categories, shifts, pos_terminals, notifications, discounts, coupons, promotions, loyalty_points, loyalty_transactions, loyalty_rewards, settings, organizations, org_members, user_stores, favorites, drivers, customer_addresses, product_expiry, whatsapp_templates, whatsapp_messages, roles, daily_summaries, org_products, stock_transfers, stock_deltas, invoices`.

> Note: `cash_movements`, `audit_log`, `held_invoices`, `feature_flags`, `sa_plans`, `stock_takes` exist in Drift and/or Supabase but are **not** in the sync whitelist — they are local-only or server-only.

---

## 2. Gap inventory — per-version breakdown (v24 → v37)

| Version | File | Category | Tables touched | Drift equivalent exists? | Drift change needed |
|---------|------|----------|----------------|--------------------------|---------------------|
| v24 | `20260404_v24_add_shift_id_to_sales.sql` | ALTER | `sales` — add `shift_id` | Yes (Drift already has `shiftId` per the file header comment) | None — Drift was the source of truth |
| v25 | `20260404_v25_create_missing_tables.sql` | CREATE | `returns`, `return_items`, `cash_movements`, `audit_log`, `daily_summaries` | Yes for returns/daily_summaries; Drift has `audit_log_table.dart`; `cash_movements` lives inside `shifts_table.dart` | None structural — columns aligned in v29 |
| v26 | `20260404_v26_fix_rls_policies.sql` | RLS only | `sales`, `sale_items`, `customers`, ... | n/a (RLS is server-side) | None |
| v27 | `20260404_v27_create_remaining_tables.sql` | CREATE | `inventory_movements`, `accounts`, `transactions`, `held_invoices`, `favorites`, `whatsapp_messages` | Yes — all six have Drift table files | None structural |
| v28 | `20260404_v28_create_missing_rpcs.sql` | RPC only | — | n/a (RPCs are server-side) | None |
| v29 | `20260404_v29_align_drift_supabase_columns.sql` | ALTER | `shifts`, `returns`, `return_items`, `audit_log`, `daily_summaries`, `cash_movements`, `organizations`, `org_products` | Columns came FROM Drift | None — Drift was the source; verify diffs |
| v30 | `20260404_v30_final_schema_alignment.sql` | ALTER + triggers | `customer_addresses`, `product_expiry`, `stock_takes`, `stock_transfers`, `customers`, `expenses`, `purchases`, `shifts`, `suppliers`, `notifications`, `loyalty_points`, `whatsapp_templates` — add `updated_at` / `org_id` | Partial: Drift may already have `updatedAt`/`orgId` on most; `stock_takes` / `stock_transfers` need verification | Potential ADD COLUMN for any that are MISSING in Drift (likely already there; **must diff per §3**) |
| v31 | `20260404_v31_sa_plans_table.sql` | CREATE | `sa_plans` (server-only) | No | None — server-only table, not synced |
| v32 | `20260410_v32_fix_remaining_rls_policies.sql` | RLS only | — | n/a | None |
| v33 | `20260411_v33_close_remaining_rls_tables.sql` | RLS only | — | n/a | None |
| v34 | `20260412_v34_feature_flags_table.sql` | CREATE | `feature_flags` (server-only read-all) | No | None — not in sync whitelist; client reads via RPC/direct query |
| v35 | `20260413_v35_audit_log_table.sql` | CREATE | `audit_log` — **server-side shape differs** from Drift's `audit_log_table.dart` (UUID PK, `actor_id`, `target_type`, `before`/`after` JSONB) | Drift has a different-shaped `audit_log` (TEXT PK, `entity_type`, `entity_id`, `details`) | **Conflict.** Two tables share the same name but have different schemas. This is a naming collision, not a sync gap. Plan: rename Supabase's v35 table to `sa_audit_log`, or rename Drift's local audit table. See Risk §5. |
| v36 | `20260414_v36_super_admin_rls.sql` | RLS only | — | n/a | None |
| v37a | `20260416_v37_fix_distributor_rls_profiles_reference.sql` | RLS only | — | n/a | None |
| v37b | `20260416_v37_rpc_auth_hardening.sql` | RPC only | — | n/a | None |

**Net conclusion:** the large majority of v24–v37 is RLS/RPC hardening (server-only). The **only structural Drift work** is:
1. v29/v30 column reconciliation (mostly already-present columns — needs per-table diff).
2. v35 audit_log collision (naming, not columns).
3. Any drift discovered while auditing per §3.

---

## 3. Per-table column-by-column diff (must be populated during implementation)

This is the **action template**. Each entry must be filled in by running `drift_dev schema dump` against the current Drift output and comparing to the Supabase definition (`information_schema.columns`). The rows below are the ones v29 explicitly flagged as drift — those **must** be verified first.

### 3.1 `shifts` (v29)
| Column | Drift | Supabase (post-v29) | Action |
|--------|-------|---------------------|--------|
| `org_id` | Present (verify in `shifts_table.dart`) | `TEXT` | Verify — if missing in Drift, ADD |
| `terminal_id` | Present | `TEXT` | Verify |
| `cashier_name` | Present | `TEXT` | Verify |
| `total_sales` | `IntColumn` | `INTEGER DEFAULT 0` | Verify |
| `total_sales_amount` | `RealColumn` | `DOUBLE PRECISION DEFAULT 0` | Verify |
| `total_refunds` | `IntColumn` | `INTEGER DEFAULT 0` | Verify |
| `total_refunds_amount` | `RealColumn` | `DOUBLE PRECISION DEFAULT 0` | Verify |
| `difference` | `RealColumn` nullable | `DOUBLE PRECISION` | Verify |
| `synced_at` | `DateTimeColumn` nullable | `TIMESTAMPTZ` | Verify |

### 3.2 `returns` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `org_id`, `return_number`, `customer_name`, `total_refund` | (verify `returns_table.dart`) | Added in v29 | Verify each |

### 3.3 `return_items` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `org_id`, `product_name`, `refund_amount` | (verify) | Added in v29 | Verify each |

### 3.4 `audit_log` (v29 + v35)
| Column | Drift (`audit_log_table.dart`) | Supabase (post-v29 v25 shape) | Supabase (v35 shape) | Action |
|--------|-------------------------------|-------------------------------|----------------------|--------|
| **schema collision** | TEXT PK, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `user_name`, `old_value`, `new_value`, `description`, `device_info` | Same as Drift (v25 + v29) | UUID PK, `actor_id`, `actor_email`, `target_type`, `before`/`after` JSONB | **Rename one side.** Recommend renaming v35's Super-Admin table to `sa_audit_log` in a follow-up Supabase migration; no Drift change needed. |

### 3.5 `daily_summaries` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `org_id` | verify | `TEXT` | Verify |
| `total_orders_amount` | verify | `DOUBLE PRECISION DEFAULT 0` | Verify |
| `total_sales_count` | verify (Drift has `totalSales` INT) | `INTEGER DEFAULT 0` | **Naming mismatch** — Drift uses `total_sales` (INT, count semantics); Supabase v29 adds `total_sales_count` alongside existing `total_sales` (DOUBLE, money). Decide canonical name and align. |

### 3.6 `cash_movements` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `org_id`, `reference` | verify (lives in `shifts_table.dart`) | Added in v29 | Verify each |

### 3.7 `organizations` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `status` | verify | `TEXT DEFAULT 'trial'` | Verify |
| `company_type` | verify | `TEXT DEFAULT 'agency'` | Verify |

### 3.8 `org_products` (v29)
| Column | Drift | Supabase | Action |
|--------|-------|----------|--------|
| `synced_at` | verify | `TIMESTAMPTZ` | Verify |

### 3.9 v30 bidirectional-sync columns
Tables with possible new `updated_at` / `org_id` requirements (v30):
`customer_addresses`, `product_expiry`, `stock_takes`, `stock_transfers`. Drift `stock_takes_table.dart` and `stock_transfers_table.dart` exist — verify each has `updatedAt` and `orgId` columns. If absent, ADD.

> **Note:** This section is a *template*. The implementation ticket must actually run `information_schema` vs `drift_dev schema dump` and populate every row with a concrete `Drift = present|missing|typed-differently` verdict before writing migration code.

---

## 4. Proposed Drift migration sequence

Drift `schemaVersion` must advance **23 → 37** in 14 discrete steps so that `onUpgrade` can replay a linear history. The migration step function at `app_database.dart:204-242` already loops `for (var version = from + 1; version <= to; version++) { _runMigrationStep(m, version); }` — every new version must get a `case N:` branch in `_runMigrationStep`.

| Drift v | Mirrors Supabase | Concrete `onUpgrade` actions |
|---------|------------------|------------------------------|
| v24 | v24 | No-op (Drift already had `sales.shift_id`). Record the step so the version pointer advances. |
| v25 | v25 | No-op for Drift (returns/return_items/cash_movements/audit_log/daily_summaries already defined locally). Version bump only. |
| v26 | v26 | No-op (server RLS). |
| v27 | v27 | No-op for Drift (all six tables already exist locally). |
| v28 | v28 | No-op (RPCs). |
| v29 | v29 | **`m.addColumn(...)` for every cell in §3 that the diff confirms is MISSING.** Non-destructive. |
| v30 | v30 | `m.addColumn(...)` for any missing `updated_at` / `org_id` on `customer_addresses`, `product_expiry`, `stock_takes`, `stock_transfers`. |
| v31 | v31 | No-op (server-only `sa_plans`). |
| v32 | v32 | No-op (RLS). |
| v33 | v33 | No-op (RLS). |
| v34 | v34 | No-op in Drift — `feature_flags` is not synced; if the app wants a local cache, add a separate Drift table later (not in scope here). |
| v35 | v35 | **Decision point (Risk §5).** If `audit_log` is renamed on the Supabase side to `sa_audit_log`, Drift is no-op. If Drift has to rename its local table, use `m.renameTable(...)` — **destructive for downstream DAOs**. |
| v36 | v36 | No-op (RLS). |
| v37 | v37 | No-op (RLS + RPCs). |

**Key insight:** **most of v24–v37 is server-only**. The practical Drift work is concentrated in v29/v30 column additions plus the v35 naming decision. Net: **≈2 steps of real schema change, 12 steps of version-bump-and-record**.

### Destructive-change audit
| Proposed change | Destructive? | Data migration needed |
|-----------------|--------------|------------------------|
| `m.addColumn` (v29/v30) with defaults for nullable TEXT/REAL | No | None |
| Renaming Drift's `audit_log` table (if v35 path chosen) | **Yes** | Copy existing rows to the new name; update every DAO import; regenerate `.g.dart` |
| Type change on `daily_summaries.total_sales` (INT vs DOUBLE) | **Yes** | Requires temp column + backfill + drop; see §5 Risk |

---

## 5. Risk register

| # | Risk | Severity | Affected | Mitigation |
|---|------|----------|----------|------------|
| 1 | **`audit_log` naming collision** between Drift (POS audit) and Supabase v35 (Super Admin audit). Sync of either direction will push rows with the wrong shape. | **High** | `admin_lite` app (Super Admin audit), any POS app writing local audit rows | Rename Supabase's v35 table to `sa_audit_log` in a v38/v39 follow-up migration; keep Drift's audit_log untouched. This is the path that minimises client churn. |
| 2 | **`daily_summaries.total_sales` semantic mismatch** — Drift treats it as an INT count; Supabase v25 defined it as `DOUBLE PRECISION` (money); v29 added `total_sales_count` to disambiguate. Sync writes from a client that believes it's a count will land as a money value server-side. | **High** | Cashier/Admin apps that write daily summaries | Pick a canonical shape (recommend `total_sales_count INT` + `total_sales_amount DOUBLE`), add a temporary column, backfill, then drop the ambiguous one. Sequence across two Drift/Supabase migrations. |
| 3 | **Backward-compat for old clients** — users on builds pinned to Drift v23 will not understand new columns added server-side. Supabase writes succeed (extra columns OK), but reads from Drift require the client to know the new schema. | Medium | Any client shipped before the `schemaVersion` bump | Gate v23→v37 jump behind a forced-update release flag; the existing downgrade guard at `app_database.dart:157-165` blocks rollback, so this is a one-way migration. |
| 4 | **Pre-migration backup pressure** — `backupService.createPreMigrationBackup` runs once per `onUpgrade` call. A 23→37 single-step upgrade creates exactly one backup, not 14. On large POS databases, the first boot after the app update may take seconds. | Low | POS app on large devices | Time this in QA on a realistic device with ≥50k invoices. |
| 5 | **Trigger drift** — v30 adds several `set_*_updated_at` triggers in Postgres. Drift has no equivalent; the app relies on application-level `updated_at` assignment. This is fine as long as clients always set it, but silent trigger-based bumps server-side may desync the `updated_at` monotonicity check used by the pull sync. | Medium | `pull_sync_service.dart` (ordering key) | Audit pull sync to confirm server `updated_at` is the authoritative ordering source; document explicitly in `DRIFT_SUPABASE_SCHEMA_MAPPING.md`. |
| 6 | **NOT VALID constraint in v38** (this repo's Part 1 migration) is unchecked for pre-existing rows. If any POS app was ever allowed to `status='issued'` without ZATCA data, VALIDATE will fail the table scan. | Medium | Historical invoices | Run the §0 diagnostic block in v38 during deploy; remediate before VALIDATE. |

### Per-app write map (for impact radius)
| App | Writes to |
|-----|-----------|
| POS cashier | `sales`, `sale_items`, `invoices`, `shifts`, `cash_movements`, `held_invoices`, `audit_log` (Drift), `returns`, `return_items`, `daily_summaries`, `inventory_movements` |
| Admin | `products`, `categories`, `customers`, `suppliers`, `purchases`, `org_members`, `stores`, `settings`, `discounts`, `promotions` |
| Admin Lite (Super Admin) | `audit_log` (Supabase v35 shape), `subscriptions`, `sa_plans`, `feature_flags` |
| Driver | `orders`, `order_status_history` |
| Customer | `orders`, `customer_addresses`, `favorites` |
| Distributor portal | `org_products`, `stock_transfers`, `stock_deltas` |

---

## 6. Testing strategy

### 6.1 Drift schema tests
- Generate a schema snapshot at v23 (current `HEAD`): `dart run drift_dev schema dump lib/src/app_database.dart drift_schemas/`.
- For each new version 24..37, after the migration code is written, run `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/ --data-classes --companions`.
- Add a `schema_migration_test.dart` that verifies every pair (v23→v24, v24→v25, ..., v36→v37) using `verifier.migrateAndValidate(db, N)`. Reference: Drift docs "Verifying migrations".

### 6.2 Sync round-trip tests
For each touched table in §3:
1. Insert a row locally via the DAO.
2. Trigger push → assert Supabase REST call succeeds with 200/201.
3. Clear local row, trigger pull → assert row reappears with matching column values.
4. Assert `updated_at` ordering is monotonic post-round-trip.

### 6.3 Manual smoke tests
- Cashier: open cash drawer → close shift → verify `shifts.total_sales_amount`, `difference`, `total_refunds` sync correctly.
- Cashier: issue an invoice → assert `invoices.zatca_hash/qr/uuid` populate before `status='issued'` is persisted (Part 1 v38 constraint verification).
- Admin Lite: perform a privileged mutation → verify row appears in `audit_log` (whichever shape is canonical post-rename).
- Distributor portal: push an org_products update → verify local cache refresh.

---

## 7. Rollout order

| Step | Action | Can ship independently? | Release type |
|------|--------|-------------------------|--------------|
| 1 | v38 Supabase ZATCA constraint (this repo's Part 1) | Yes — no client change | Patch |
| 2 | v39 Supabase: rename v35 `audit_log` → `sa_audit_log` | Yes — server only; update admin_lite read path in the same release | Minor |
| 3 | Drift `schemaVersion` 23 → 37, with `case` branches for v24..v37 | **No** — this is a forced-upgrade release for every app | **Major** (forced update) |
| 4 | Follow-up Drift v38: mirror the new Supabase v38 ZATCA check locally as a Drift `CHECK` via raw SQL in `onUpgrade` | Yes, after step 3 lands | Minor |
| 5 | Optional: `daily_summaries` canonicalisation (Risk §2) — temp column + backfill + drop | **Sequential after step 3** and requires a data-migration runbook | Major |

**Sequencing constraint:** steps 3 and 5 cannot overlap — both touch the same migration history. Steps 1, 2, and 4 can run in any order relative to step 3 because they are server-only or additive.

**Minimum viable path to clear the v23→v37 debt without forcing a major release:** ship step 1 now (v38 constraint), ship step 2 next (audit_log rename) — Drift stays on v23 until the team is ready for the forced-update release in step 3.

---

## 8. Open questions for reviewer

1. Is the `daily_summaries.total_sales` semantic mismatch a real bug today, or has one side been silently renamed already? Needs a query against production data before we plan the rename.
2. For the `audit_log` collision, does `admin_lite` already write to the v35 shape? If yes, how do we migrate in-flight rows when we rename to `sa_audit_log`?
3. Do we want Drift to mirror the Supabase v38 CHECK constraint locally (as a raw SQL `CHECK` in `onUpgrade`), or do we rely on the server alone? Mirroring gives offline protection but requires a `m.customStatement(...)` at Drift v24+1.
