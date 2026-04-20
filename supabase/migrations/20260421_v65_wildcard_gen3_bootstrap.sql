-- =============================================================================
-- Migration v65: Wildcard Gen 3 Bootstrap (5 tables, full policy design)
-- =============================================================================
-- Branch:   fix/wildcard-gen3-bootstrap
-- Date:     2026-04-21
-- Type:     Additive (6 CREATE Gen 3) + subtractive (6 DROP wildcards + dead).
--           Applied in two user-gated steps with V-POST verification between.
-- Scope:    5 tables (sales, sale_items, promotions, suppliers,
--           whatsapp_messages), 12 statements total (6 CREATE + 6 DROP).
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Closes the remaining 5 `"Allow authenticated full access"` wildcards from
-- the comprehensive wildcard audit (2026-04-22 commit 1ea56b4). These 5 were
-- blocked on Wildcard Gen 3 Bootstrap session because — unlike every other
-- batch in the campaign — Phase A investigation revealed ZERO existing Gen 3
-- policies on any of the 5 tables. Straight drop would have caused
-- default-deny for legitimate app access. Every Gen 3 had to be designed
-- from scratch.
--
-- Also drops the vestigial `store_isolation` Gen 2 on whatsapp_messages
-- (single-store scalar get_user_store_id() — dominated by the new
-- has_store_access multi-store Gen 3 under PERMISSIVE OR).
--
-- -----------------------------------------------------------------------------
-- BACKGROUND — why Gen 3 was missing on all 5 tables
-- -----------------------------------------------------------------------------
-- Prior session notes (v58 comment + FIX_SESSION_LOG entries) assumed sales
-- and sale_items had existing Gen 3 behind the authenticated wildcard.
-- Phase A live `pg_policies` scan disproved that: both tables had the
-- wildcard only.
--
-- promotions, suppliers, whatsapp_messages were flagged as "no Gen 3" in
-- the 2026-04-22 W4 scope-reduction decision — deferred explicitly for
-- this session.
--
-- whatsapp_messages had a dead Gen 2 (`store_isolation` using the
-- single-store scalar) which was documented but not dropped during the W4
-- batch because it was dominated by the Gen 1 wildcard anyway. Now that
-- Gen 3 is in place, the dead Gen 2 comes out.
--
-- -----------------------------------------------------------------------------
-- PHASE A INVESTIGATION EVIDENCE
-- -----------------------------------------------------------------------------
-- Drift schema tenancy (per `packages/alhai_database/lib/src/tables/`):
--   sales:             storeId TEXT NOT NULL + orgId TEXT nullable
--   sale_items:        saleId TEXT NOT NULL (FK → sales.id, cascade delete)
--   suppliers:         storeId TEXT NOT NULL + orgId TEXT nullable
--   whatsapp_messages: storeId TEXT NOT NULL
--   promotions:        no Drift table; `alhai_core/.../promotions_repository.dart`
--                      takes storeId param on every method → store-scoped
--
-- Live Supabase column check (Q2 result):
--   sales.store_id:             text NOT NULL
--   sale_items.sale_id:         text NOT NULL (no direct store_id)
--   promotions.store_id:        text NOT NULL
--   suppliers.store_id:         text NOT NULL
--   whatsapp_messages.store_id: text NOT NULL
--
-- All 5 are effectively store-scoped. sale_items requires a JOIN back
-- to sales to resolve its tenancy (no denormalized store_id).
--
-- Cross-app `.from()` callers:
--   sales:             4 hits in super_admin (sa_analytics + sa_stores
--                      datasources — cross-org platform analytics like MRR,
--                      transaction counts, top store revenue). Requires
--                      `is_super_admin()` bypass analogous to subscriptions
--                      in v64.
--   sale_items:        0 hits (sync-only).
--   promotions:        0 hits (sync-only via alhai_sync pull_strategy +
--                      initial_sync whitelists at priority tier).
--   suppliers:         0 hits (sync-only).
--   whatsapp_messages: 0 hits (sync-only).
--
-- Helper functions (both hardened in v50 — SECURITY DEFINER STABLE,
-- search_path=public,auth):
--   has_store_access(p_store_id TEXT) → boolean
--     body: p_store_id IN (SELECT get_user_store_ids())
--           OR is_store_owner(p_store_id)
--     NOTE: no is_super_admin() short-circuit → separate bypass needed.
--
--   is_super_admin() → boolean
--     body: EXISTS (SELECT 1 FROM public.users
--                   WHERE id = auth.uid() AND role = 'super_admin')
--
-- Row baseline (Q3, 2026-04-21):
--   sales:             11 rows (test data per user confirmation)
--   sale_items:        30 rows (test data per user confirmation)
--   promotions:         0 rows
--   suppliers:          0 rows
--   whatsapp_messages:  0 rows
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED (split across two user-gated steps)
-- -----------------------------------------------------------------------------
-- Step 1 (additive — 6 CREATE) applied to Supabase production on
--   2026-04-21 via SQL Editor. V1-POST-A verification confirmed the 6 new
--   Gen 3 policies live alongside the 6 existing (5 wildcards + 1 dead
--   Gen 2) — 12 policies total, no regressions. Step 1 is FAIL-SAFE by
--   design — the PERMISSIVE OR model means additive Gen 3 widens nothing
--   and breaks nothing. Wildcards stayed active as safety net.
--
-- Step 2 (subtractive — 6 DROP) applied to Supabase production on
--   2026-04-21 via SQL Editor immediately after V1-POST-A passed.
--   V2-POST-A/B/C all green: exactly 6 Gen 3 policies remaining, row
--   counts preserved (sales=11, sale_items=30, others=0), zero wildcards
--   on target tables.
--
-- -----------------------------------------------------------------------------
-- DESIGN RATIONALE
-- -----------------------------------------------------------------------------
-- 1. `has_store_access(store_id)` for tables with direct store_id:
--    promotions, suppliers, whatsapp_messages, sales.
--    Multi-store safe (uses get_user_store_ids() set, not single-store
--    scalar). Matches the canonical pattern used by daily_summaries,
--    expense_categories, inventory_movements, loyalty_*, product_expiry,
--    etc. in prior W1–W5 migrations.
--
-- 2. `is_super_admin()` bypass on sales only:
--    super_admin analytics need cross-org reads on sales (not sale_items).
--    Pattern identical to v64 bypass policies on subscriptions +
--    organizations. sale_items has zero super_admin callers today → YAGNI.
--
-- 3. EXISTS subquery Gen 3 for sale_items:
--    sale_items.sale_id → sales.id → has_store_access(sales.store_id).
--    RLS on the inner SELECT is applied, but we redundantly call
--    has_store_access in the qual for explicitness (matches the
--    pos_terminals.terminal_isolation style from v64 era). If a future
--    super_admin analytics path needs sale_items, add
--    sale_items_super_admin as a separate bypass policy.
--
-- 4. Drop vestigial `whatsapp_messages.store_isolation`:
--    Uses single-store scalar (get_user_store_id()) dominated by the new
--    multi-store Gen 3 (has_store_access — uses get_user_store_ids()
--    set). No change in effective access. Cleaner state.
--
-- -----------------------------------------------------------------------------
-- CAMPAIGN CONTEXT
-- -----------------------------------------------------------------------------
-- Wildcard-cleanup campaign progress (post-v65):
--   v58 —  2 S-0 anon wildcards (sales, sale_items)
--   v59 — 12 policies on 6 financial tables (W1)
--   v60 —  4 policies on 3 identity tables (W2 scope-reduced)
--   v61 — 21 policies on 10 operational tables + customers anon (W4)
--   v62 —  3 policies on categories (W5 scope-reduced)
--   v63 —  1 policy on sync_queue (vestigial)
--   v64 —  5 statements: 2 bypass + 3 wildcards (Platform Admin RLS)
--   v65 — 12 statements: 6 Gen 3 + 6 drops (Wildcard Gen 3 Bootstrap)
--
-- After v65: **33 of 33 wildcards resolved (100% 🎉)**.
-- Campaign complete. No wildcard "Allow authenticated full access" policies
-- remain on any `public.*` table.
-- =============================================================================


-- =============================================================================
-- V-PRE — Verify starting baseline (expected: 6 rows on target tables)
-- =============================================================================
--
-- Expected rows (all with qual=true wildcards, plus whatsapp_messages dead Gen 2):
--   promotions        | Allow authenticated full access | ALL | {authenticated}
--   sale_items        | Allow authenticated full access | ALL | {authenticated}
--   sales             | Allow authenticated full access | ALL | {authenticated}
--   suppliers         | Allow authenticated full access | ALL | {authenticated}
--   whatsapp_messages | Allow authenticated full access | ALL | {authenticated}
--   whatsapp_messages | store_isolation                 | ALL | {public} (store_id = get_user_store_id())
--
-- SELECT tablename, policyname, permissive, roles, cmd,
--        LEFT(qual, 150) AS qual_trunc, LEFT(with_check, 150) AS with_check_trunc
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename IN ('sales', 'sale_items', 'promotions', 'suppliers', 'whatsapp_messages')
-- ORDER BY tablename, policyname;


-- =============================================================================
-- APPLY BLOCK STEP 1 — CREATE 6 Gen 3 policies (additive, fail-safe)
-- =============================================================================
BEGIN;

-- --------------------------------------------------------------------------
-- sales: store-scoped Gen 3 + super_admin cross-org bypass.
-- --------------------------------------------------------------------------
CREATE POLICY sales_store_access ON public.sales
  FOR ALL TO public
  USING (public.has_store_access(store_id))
  WITH CHECK (public.has_store_access(store_id));

CREATE POLICY sales_super_admin ON public.sales
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- --------------------------------------------------------------------------
-- sale_items: JOIN back to sales (no direct store_id column).
-- --------------------------------------------------------------------------
CREATE POLICY sale_items_sale_access ON public.sale_items
  FOR ALL TO public
  USING (EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND public.has_store_access(s.store_id)
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.sales s
    WHERE s.id = sale_items.sale_id
      AND public.has_store_access(s.store_id)
  ));

-- --------------------------------------------------------------------------
-- promotions, suppliers, whatsapp_messages: direct store_id Gen 3.
-- --------------------------------------------------------------------------
CREATE POLICY promotions_store_access ON public.promotions
  FOR ALL TO public
  USING (public.has_store_access(store_id))
  WITH CHECK (public.has_store_access(store_id));

CREATE POLICY suppliers_store_access ON public.suppliers
  FOR ALL TO public
  USING (public.has_store_access(store_id))
  WITH CHECK (public.has_store_access(store_id));

CREATE POLICY whatsapp_messages_store_access ON public.whatsapp_messages
  FOR ALL TO public
  USING (public.has_store_access(store_id))
  WITH CHECK (public.has_store_access(store_id));

COMMIT;


-- =============================================================================
-- V1-POST-A — Confirm 12 policies present (6 new Gen 3 + 6 old) before DROP
-- =============================================================================
--
-- Re-run the V-PRE query verbatim. Expected: 12 rows.
-- At this point, wildcards are still active → app access unaffected.
-- This is the explicit gate between Step 1 and Step 2 per the session's
-- user-approved step-by-step pacing.


-- =============================================================================
-- APPLY BLOCK STEP 2 — DROP 6 old policies (5 wildcards + 1 dead Gen 2)
-- =============================================================================
BEGIN;

-- Dead Gen 2 (single-store scalar, dominated by new multi-store Gen 3).
DROP POLICY "store_isolation" ON public.whatsapp_messages;

-- 5 Gen 1 authenticated wildcards.
DROP POLICY "Allow authenticated full access" ON public.sales;
DROP POLICY "Allow authenticated full access" ON public.sale_items;
DROP POLICY "Allow authenticated full access" ON public.promotions;
DROP POLICY "Allow authenticated full access" ON public.suppliers;
DROP POLICY "Allow authenticated full access" ON public.whatsapp_messages;

COMMIT;


-- =============================================================================
-- V2-POST-A — Confirm only 6 Gen 3 policies remain (expected: 6 rows)
-- =============================================================================
--
-- Re-run the V-PRE query verbatim. Expected rows:
--   promotions        | promotions_store_access        | ALL | {public} | has_store_access(store_id)
--   sale_items        | sale_items_sale_access         | ALL | {public} | EXISTS (sales s WHERE s.id = sale_items.sale_id AND has_store_access(s.store_id))
--   sales             | sales_store_access             | ALL | {public} | has_store_access(store_id)
--   sales             | sales_super_admin              | ALL | {public} | is_super_admin()
--   suppliers         | suppliers_store_access         | ALL | {public} | has_store_access(store_id)
--   whatsapp_messages | whatsapp_messages_store_access | ALL | {public} | has_store_access(store_id)


-- =============================================================================
-- V2-POST-B — Baseline data preservation (expected: sales=11, sale_items=30,
--             promotions=0, suppliers=0, whatsapp_messages=0)
-- =============================================================================
--
-- SELECT 'sales' AS t, COUNT(*) FROM public.sales
-- UNION ALL SELECT 'sale_items', COUNT(*) FROM public.sale_items
-- UNION ALL SELECT 'promotions', COUNT(*) FROM public.promotions
-- UNION ALL SELECT 'suppliers', COUNT(*) FROM public.suppliers
-- UNION ALL SELECT 'whatsapp_messages', COUNT(*) FROM public.whatsapp_messages;


-- =============================================================================
-- V2-POST-C — Confirm zero wildcards remain (expected: 0 rows)
-- =============================================================================
--
-- SELECT tablename, policyname
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND policyname = 'Allow authenticated full access'
--   AND tablename IN ('sales', 'sale_items', 'promotions', 'suppliers', 'whatsapp_messages');


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction (inverts v65 in one transaction)
-- =============================================================================
-- ⚠️  WARNING: Restoring the 5 wildcards re-opens full cross-tenant access
--     for any authenticated user — a regression to the pre-campaign state
--     on these 5 tables. Only use this block during emergency rollback and
--     then immediately investigate why the Gen 3 policies did not cover
--     the intended access pattern.
--
-- BEGIN;
--
-- -- Re-create the 5 Gen 1 wildcards + 1 dead Gen 2.
-- CREATE POLICY "Allow authenticated full access" ON public.sales
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.sale_items
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.promotions
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.suppliers
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.whatsapp_messages
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "store_isolation" ON public.whatsapp_messages
--   FOR ALL TO public USING (store_id = get_user_store_id());
--
-- -- Drop the 6 new Gen 3 policies.
-- DROP POLICY IF EXISTS sales_store_access ON public.sales;
-- DROP POLICY IF EXISTS sales_super_admin ON public.sales;
-- DROP POLICY IF EXISTS sale_items_sale_access ON public.sale_items;
-- DROP POLICY IF EXISTS promotions_store_access ON public.promotions;
-- DROP POLICY IF EXISTS suppliers_store_access ON public.suppliers;
-- DROP POLICY IF EXISTS whatsapp_messages_store_access ON public.whatsapp_messages;
--
-- COMMIT;
--
-- =============================================================================
-- END v65 — 🎉 WILDCARD CAMPAIGN 33/33 COMPLETE
-- =============================================================================
