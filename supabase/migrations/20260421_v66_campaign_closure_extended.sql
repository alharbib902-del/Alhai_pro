-- =============================================================================
-- Migration v66: Campaign Closure — Extended cleanup (wildcard + anon + Gen 2)
-- =============================================================================
-- Branch:   fix/campaign-closure-audit
-- Date:     2026-04-21
-- Type:     Additive (4 CREATE Gen 3) + subtractive (13 DROP). Two-step atomic.
-- Scope:    6 tables (shifts, settings, products, stores, favorites,
--           held_invoices), 17 statements total (4 CREATE + 13 DROP).
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Closure audit for the wildcard-cleanup campaign (which had claimed "33/33
-- complete" after v65) surfaced a non-trivial set of residuals that the
-- original Phase 1 audit from 2026-04-22 missed:
--   1. Two more Gen 1 wildcards NOT in the Phase 1 list of 33:
--        settings."Allow authenticated full access"
--        shifts."Allow authenticated full access"
--   2. Four "anon_read_*" policies with qual=true (functional anon wildcards
--      — S-0 severity in the v58 classification):
--        anon_read_products, anon_read_stores, anon_read_settings, anon_read_users
--   3. Four "authenticated_read_*" policies with qual=true:
--        authenticated_read_products/stores/settings/users
--   4. Six dead Gen 2 `store_isolation` policies using single-store scalar
--      get_user_store_id() (dominated by multi-store Gen 3 via PERMISSIVE OR):
--        favorites, held_invoices, products, settings, stores, users
--
-- v66 closes items 1-3 and 4 for all tables EXCEPT `users` — see Section
-- "EXPLICITLY DEFERRED" below. After v66, zero wildcards or qual=true
-- policies remain on 6 of the 7 affected tables. `users` stays on a wildcard
-- state pending a dedicated PII session.
--
-- -----------------------------------------------------------------------------
-- WHY Phase 1 MISSED THESE
-- -----------------------------------------------------------------------------
-- The 2026-04-22 audit (commit 1ea56b4) enumerated wildcards by policyname
-- exact-match on `"Allow authenticated full access"`. That found 33 entries.
-- It did not catch:
--   - policies with DIFFERENT names that still evaluate qual=true
--     (anon_read_*, authenticated_read_* — same mechanical effect as
--     a wildcard, different cosmetic shape)
--   - tables that had a qual=true wildcard under the expected canonical name
--     but were simply not enumerated in the 33-item list (settings, shifts
--     — likely a scoping mistake in the audit's Discovery 2)
--
-- Same "live DB as source of truth" lesson applies: pg_policies scan with
-- qual=true predicate catches everything, regardless of policyname patterns.
--
-- -----------------------------------------------------------------------------
-- EXPLICITLY DEFERRED — `users` table
-- -----------------------------------------------------------------------------
-- `users` has parallel structure to the 6 cleaned tables:
--   - anon_read_users (S-0 PII leak — most critical of all 4 anon reads)
--   - authenticated_read_users (over-permissive)
--   - store_isolation (dead Gen 2, single-store scalar)
-- Plus only `users_self_select` as real Gen 3 (auth_uid = auth.uid()).
--
-- Dropping anon/auth/Gen 2 on users now would leave ONLY self-select as
-- the SELECT path. Consequences:
--   - Super-admin cross-org reads break (sa_users_datasource).
--   - Cashier sync of user data for coworker visibility breaks (alhai_sync
--     pull_strategy includes `users` table).
--   - Admin app staff listing breaks.
-- These require design decisions (tenancy model: store-scoped? org-scoped?
-- mixed?) and careful cross-app smoke testing beyond this closure session.
--
-- `users` is therefore queued for a dedicated PII session. Until then, the
-- wildcards remain active — a known PII exposure, documented here for
-- backlog visibility. Cost of deferral: ~24h more of PII exposure (already
-- live for weeks). Benefit: avoid a broken-users-table rollback scenario.
--
-- -----------------------------------------------------------------------------
-- PHASE A INVESTIGATION EVIDENCE
-- -----------------------------------------------------------------------------
-- Drift schema tenancy confirmed store-scoped:
--   shifts.store_id:   text NOT NULL (from shifts_table.dart)
--   settings.store_id: text NOT NULL (from settings_table.dart)
--
-- Live policy inventory (Q-ext 2026-04-21):
--   favorites (4):      favorites_{select,insert,delete} + store_isolation dead
--   held_invoices (4):  held_invoices_{select,insert,delete} + store_isolation dead
--   products (10):      products_{select,insert,update,delete} + staff variants
--                       + store_isolation dead + anon_read + authenticated_read
--   settings (8):       settings_{select,insert,update,delete}
--                       + store_isolation dead + wildcard + anon_read + auth_read
--   shifts (1):         ONLY wildcard — ZERO Gen 3 beneath (🔴 bootstrap required)
--   stores (8):         stores_{delete,insert,update,member_select,owner_select}
--                       + store_isolation dead + anon_read + auth_read
--   users (4):          users_self_select + store_isolation dead + anon_read
--                       + auth_read (DEFERRED)
--
-- Cross-app usage for super_admin bypass sizing:
--   - products: read cross-org by sa_stores_datasource.dart:96-99 (store
--     usage stats) → needs `products_super_admin` bypass.
--   - stores:   read cross-org by sa_stores_datasource.dart throughout
--     → needs `stores_super_admin` bypass.
--   - shifts:   read cross-org possible for analytics → `shifts_super_admin`
--     added proactively (pattern: same as v64 subscriptions, v65 sales).
--   - settings: no super_admin direct access detected → NO bypass added.
--
-- Helper functions (all hardened in v50, verified in v64/v65):
--   has_store_access(text) → boolean  (multi-store via get_user_store_ids())
--   is_super_admin() → boolean        (users.role = 'super_admin')
--
-- Row counts: not queried this session — 6 tables mix of tenant data and
-- test data, all under Gen 3 after apply; data preservation implicit.
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED (split across two user-gated atomic steps)
-- -----------------------------------------------------------------------------
-- Step 1 (additive — 4 CREATE) applied to Supabase production on
--   2026-04-21 via SQL Editor. Fail-safe by design — additive policies
--   widen access only when is_super_admin() or has_store_access() return
--   true. Wildcards remained active as safety net between Step 1 and Step 2.
--
-- Step 2 (subtractive — 13 DROP) applied immediately after.
-- V-POST-FINAL returned 26 policies across the 6 tables (matching the
-- expected shape exactly). V-POST-WILDCARDS returned zero rows (no
-- wildcards, no anon_read, no authenticated_read, no dead Gen 2 remain
-- on the 6 tables).
--
-- -----------------------------------------------------------------------------
-- CAMPAIGN CONTEXT
-- -----------------------------------------------------------------------------
-- Wildcard-cleanup campaign post-v66 (fuller accounting, replacing the
-- premature "33/33 complete" claim from v65):
--   v58 —  2 S-0 anon wildcards (sales, sale_items)
--   v59 — 12 policies on 6 financial tables (W1)
--   v60 —  4 policies on 3 identity tables (W2 scope-reduced)
--   v61 — 21 policies on 10 operational tables + customers anon (W4)
--   v62 —  3 policies on categories (W5 scope-reduced)
--   v63 —  1 policy on sync_queue (vestigial)
--   v64 —  5 statements: 2 bypass + 3 wildcards (Platform Admin RLS)
--   v65 — 12 statements: 6 Gen 3 + 6 drops (Wildcard Gen 3 Bootstrap)
--   v66 — 17 statements: 4 bypass/Gen 3 + 13 drops (Closure Audit Extended)
--
-- After v66: ~50 total wildcard/qual=true residuals resolved across all
-- policy families on 6 tables. `users` table remains — the sole known PII
-- anon-read leak still live. All other public.* tables are now
-- tenant-isolated or platform-admin gated.
-- =============================================================================


-- =============================================================================
-- V-PRE — Starting baseline (expected: 35 rows on affected tables)
-- =============================================================================
--
-- SELECT tablename, policyname, cmd, roles,
--        LEFT(qual, 150) AS qual_trunc, LEFT(with_check, 150) AS with_check_trunc
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename IN ('shifts', 'settings', 'products', 'stores',
--                     'favorites', 'held_invoices')
-- ORDER BY tablename, cmd, policyname;
--
-- Expected: 4+4+10+8+1+8 = 35 rows.


-- =============================================================================
-- APPLY BLOCK STEP 1 — CREATE 4 Gen 3 / bypass policies (additive, fail-safe)
-- =============================================================================
BEGIN;

-- --------------------------------------------------------------------------
-- shifts: Gen 3 bootstrap — zero policies existed beyond the wildcard.
-- Mirror the canonical v65 pattern (sales_store_access + sales_super_admin).
-- --------------------------------------------------------------------------
CREATE POLICY shifts_store_access ON public.shifts
  FOR ALL TO public
  USING (public.has_store_access(store_id))
  WITH CHECK (public.has_store_access(store_id));

CREATE POLICY shifts_super_admin ON public.shifts
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- --------------------------------------------------------------------------
-- products: super_admin bypass (sa_stores_datasource reads products
-- cross-org for store usage stats).
-- --------------------------------------------------------------------------
CREATE POLICY products_super_admin ON public.products
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- --------------------------------------------------------------------------
-- stores: super_admin bypass (sa_stores_datasource reads stores
-- cross-org for platform management).
-- --------------------------------------------------------------------------
CREATE POLICY stores_super_admin ON public.stores
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

COMMIT;


-- =============================================================================
-- V1-POST — Confirm 4 new policies live; old policies still present
-- =============================================================================
--
-- Expected: 39 rows (35 baseline + 4 new). Re-run the V-PRE query verbatim.
-- Between Step 1 and Step 2, wildcards remain active → app access unaffected.


-- =============================================================================
-- APPLY BLOCK STEP 2 — DROP 13 residual policies (subtractive)
-- =============================================================================
BEGIN;

-- -------------------------------- 2 Gen 1 wildcards -----------------------
DROP POLICY "Allow authenticated full access" ON public.settings;
DROP POLICY "Allow authenticated full access" ON public.shifts;

-- -------------------------------- 3 anon_read S-0s ------------------------
-- (users.anon_read_users intentionally NOT dropped — deferred PII session)
DROP POLICY "anon_read_products" ON public.products;
DROP POLICY "anon_read_stores"   ON public.stores;
DROP POLICY "anon_read_settings" ON public.settings;

-- -------------------------------- 3 authenticated_read over-permissive ---
-- (users.authenticated_read_users intentionally NOT dropped — same reason)
DROP POLICY "authenticated_read_products" ON public.products;
DROP POLICY "authenticated_read_stores"   ON public.stores;
DROP POLICY "authenticated_read_settings" ON public.settings;

-- -------------------------------- 5 dead Gen 2 store_isolation -----------
-- (users.store_isolation intentionally NOT dropped — same reason)
DROP POLICY "store_isolation" ON public.favorites;
DROP POLICY "store_isolation" ON public.held_invoices;
DROP POLICY "store_isolation" ON public.products;
DROP POLICY "store_isolation" ON public.stores;
DROP POLICY "store_isolation" ON public.settings;

COMMIT;


-- =============================================================================
-- V2-POST-A — Confirm 26 policies total, correctly shaped (expected: 26)
-- =============================================================================
--
-- Expected distribution:
--   favorites       (3): favorites_{select,insert,delete}
--   held_invoices   (3): held_invoices_{select,insert,delete}
--   products        (8): products_{select,insert,update,delete} + staff
--                        variants + products_super_admin
--   settings        (4): settings_{select,insert,update,delete}
--   shifts          (2): shifts_store_access, shifts_super_admin
--   stores          (6): stores_{delete,insert,update,member_select,
--                        owner_select} + stores_super_admin


-- =============================================================================
-- V2-POST-WILDCARDS — Confirm zero wildcards/pseudo-wildcards on 6 tables
-- =============================================================================
--
-- SELECT tablename, policyname, roles
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename IN ('shifts', 'settings', 'products', 'stores',
--                     'favorites', 'held_invoices')
--   AND (qual = 'true' OR policyname ILIKE '%full access%'
--        OR policyname ILIKE 'anon_read%'
--        OR policyname ILIKE 'authenticated_read%'
--        OR policyname = 'store_isolation');
--
-- Expected: 0 rows.


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction (inverts v66 in one transaction)
-- =============================================================================
-- ⚠️  WARNING: Restoring the wildcards + anon_read + auth_read + Gen 2 dead
--     policies re-opens broad cross-tenant access. Only for emergency rollback.
--
-- BEGIN;
--
-- -- Restore 2 Gen 1 wildcards.
-- CREATE POLICY "Allow authenticated full access" ON public.settings
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.shifts
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
--
-- -- Restore 3 anon_read (S-0 equivalents).
-- CREATE POLICY "anon_read_products" ON public.products
--   FOR SELECT TO anon USING (true);
-- CREATE POLICY "anon_read_stores"   ON public.stores
--   FOR SELECT TO anon USING (true);
-- CREATE POLICY "anon_read_settings" ON public.settings
--   FOR SELECT TO anon USING (true);
--
-- -- Restore 3 authenticated_read.
-- CREATE POLICY "authenticated_read_products" ON public.products
--   FOR SELECT TO authenticated USING (true);
-- CREATE POLICY "authenticated_read_stores"   ON public.stores
--   FOR SELECT TO authenticated USING (true);
-- CREATE POLICY "authenticated_read_settings" ON public.settings
--   FOR SELECT TO authenticated USING (true);
--
-- -- Restore 5 dead Gen 2 store_isolation (single-store scalar).
-- CREATE POLICY "store_isolation" ON public.favorites
--   FOR ALL TO public USING (store_id = get_user_store_id());
-- CREATE POLICY "store_isolation" ON public.held_invoices
--   FOR ALL TO public USING (store_id = get_user_store_id());
-- CREATE POLICY "store_isolation" ON public.products
--   FOR ALL TO public USING (store_id = get_user_store_id());
-- CREATE POLICY "store_isolation" ON public.stores
--   FOR ALL TO public USING (id = get_user_store_id());
-- CREATE POLICY "store_isolation" ON public.settings
--   FOR ALL TO public USING (store_id = get_user_store_id());
--
-- -- Drop 4 new Gen 3 / bypass policies.
-- DROP POLICY IF EXISTS shifts_store_access ON public.shifts;
-- DROP POLICY IF EXISTS shifts_super_admin  ON public.shifts;
-- DROP POLICY IF EXISTS products_super_admin ON public.products;
-- DROP POLICY IF EXISTS stores_super_admin   ON public.stores;
--
-- COMMIT;
--
-- =============================================================================
-- END v66 — Closure Extended. Only `users` wildcard/anon/Gen 2 remain.
-- =============================================================================
