-- =============================================================================
-- Migration v64: Platform admin RLS bypass + drop 3 authenticated wildcards
-- =============================================================================
-- Branch:   fix/platform-admin-rls
-- Date:     2026-04-21
-- Type:     Additive (2 bypass policies) + subtractive (3 wildcards). Atomic.
-- Scope:    3 tables (subscriptions, organizations, pos_terminals),
--           5 statements total (2 CREATE + 3 DROP).
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Unblocks the 3 tables deferred from W2 (v60) by adding
-- `is_super_admin()`-based bypass policies for super_admin app and
-- distributor_portal admin workflows, then drops the Gen 1 authenticated
-- wildcards that were silently masking the tenant-isolated Gen 3 policies.
--
-- Bypass pattern mirrors the canonical `is_super_admin()` usage already in
-- live policies (9 pre-v64 references across invoices, platform_settings,
-- sa_audit_log, org_products fallback, etc.).
--
-- -----------------------------------------------------------------------------
-- BACKGROUND — why these 3 tables were deferred from W2
-- -----------------------------------------------------------------------------
-- W2 (v60) dropped identity wildcards on org_members, roles, user_stores.
-- These 3 were held back because Gen 3 policies existed but would deny
-- cross-org access that super_admin + distributor_portal admin workflows
-- legitimately need:
--
--   subscriptions.org_isolation:
--     qual=(org_id = get_user_org_id()) AND is_org_admin()
--     → super_admin is NOT an org admin and has no tenant org_id → BLOCKED
--
--   organizations.org_isolation:
--     qual=(id = get_user_org_id())
--     → super_admin has no tenant org_id → BLOCKED from cross-org reads
--     → distributor_portal admin cannot approve/reject/suspend other orgs
--
--   pos_terminals.terminal_isolation:
--     qual=(org_id = get_user_org_id()) AND
--          (is_org_admin() OR store_id IN (SELECT get_user_store_ids()))
--     → ALREADY COMPLETE — Phase A investigation confirmed org_sync_service
--       is tenant-scoped (filters by org_id at line 129). No bypass needed.
--
-- v64 adds super_admin bypass to subscriptions + organizations only.
-- pos_terminals just gets its wildcard dropped.
--
-- -----------------------------------------------------------------------------
-- PHASE A INVESTIGATION EVIDENCE (docs/sessions/FIX_SESSION_LOG.md)
-- -----------------------------------------------------------------------------
-- - is_super_admin() helper is live, SECURITY DEFINER, STABLE, with hardened
--   search_path=public,auth (applied in v50).
-- - 14 cross-org calls on subscriptions in super_admin/lib/data/
--   (sa_subscriptions_datasource.dart, sa_analytics_datasource.dart,
--    sa_stores_datasource.dart).
-- - 9 cross-org calls on organizations in distributor_portal/lib/data/
--   (admin_service.dart for approve/reject/suspend/reinstate,
--    distributor_datasource.dart for own-org settings — tenant-scoped).
-- - super_admin app + distributor_portal admin both use
--   users.role='super_admin' auth model (verified via userMetadata.role reads).
-- - super_admin login flow calls rpc('is_super_admin') for server-side
--   verification (sa_login_screen.dart:153) — same function v64 uses in RLS.
-- - Zero .from('subscriptions'|'organizations'|'pos_terminals') hits in
--   apps/cashier, apps/admin, apps/admin_lite, customer_app, driver_app.
-- - pos_terminals access is strictly tenant-scoped via alhai_sync
--   org_sync_service.dart (filters by org_id — never cross-org).
-- - 1 super_admin user exists (caller is real, not speculative).
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED
-- -----------------------------------------------------------------------------
-- This migration file records work applied to Supabase production on
-- 2026-04-21 via SQL Editor. Pre/Apply/Post verification confirmed green.
-- File exists for git-tracked audit trail + canonical rollback reference.
--
-- -----------------------------------------------------------------------------
-- CAMPAIGN CONTEXT
-- -----------------------------------------------------------------------------
-- Wildcard-cleanup campaign progress (post-v64):
--   v58 —  2 S-0 anon wildcards (sales, sale_items)
--   v59 — 12 policies on 6 financial tables (W1)
--   v60 —  4 policies on 3 identity tables (W2 scope-reduced)
--   v61 — 21 policies on 10 operational tables + customers anon (W4)
--   v62 —  3 policies on categories (W5 scope-reduced)
--   v63 —  1 policy on sync_queue (vestigial)
--   v64 —  5 statements: 2 ADD bypass + 3 DROP wildcards (this migration)
--
-- After v64: 28 of 33 wildcards resolved (85%). 5 remaining, all blocked on
-- Wildcard Gen 3 Bootstrap session (sales + sale_items authenticated,
-- promotions, suppliers, whatsapp_messages).
-- =============================================================================


-- =============================================================================
-- V64-PRE — Verify baseline (expected: 7 rows)
-- =============================================================================
--
-- SELECT tablename, policyname, permissive, roles, cmd,
--        LEFT(qual, 120) AS qual_trunc, LEFT(with_check, 120) AS with_check_trunc
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename IN ('subscriptions', 'organizations', 'pos_terminals')
-- ORDER BY tablename, policyname;
--
-- Expected rows:
--   organizations  | Allow authenticated full access | ALL    | {authenticated} | qual=true / with_check=true
--   organizations  | org_isolation                   | ALL    | {public}        | (id = get_user_org_id())
--   organizations  | organizations_signup_insert     | INSERT | {authenticated} | (owner_id = auth.uid()::text)
--   pos_terminals  | Allow authenticated full access | ALL    | {authenticated} | qual=true / with_check=true
--   pos_terminals  | terminal_isolation              | ALL    | {public}        | (org_id=get_user_org_id()) AND (is_org_admin() OR store_id IN ...)
--   subscriptions  | Allow authenticated full access | ALL    | {authenticated} | qual=true / with_check=true
--   subscriptions  | org_isolation                   | ALL    | {public}        | (org_id=get_user_org_id()) AND is_org_admin()


-- =============================================================================
-- APPLY BLOCK — atomic: 2 CREATE + 3 DROP in one transaction
-- =============================================================================
BEGIN;

-- --------------------------------------------------------------------------
-- ADD: platform-admin bypass for subscriptions.
-- Allows super_admin app to read/write all subscriptions cross-org for
-- plan management, MRR analytics, and customer provisioning.
-- --------------------------------------------------------------------------
CREATE POLICY subscriptions_super_admin ON public.subscriptions
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- --------------------------------------------------------------------------
-- ADD: platform-admin bypass for organizations.
-- Allows super_admin app + distributor_portal admin workflows to
-- approve/reject/suspend/reinstate distributor organizations cross-org.
-- Tenant-scoped users continue to use `org_isolation` (id = get_user_org_id()).
-- --------------------------------------------------------------------------
CREATE POLICY organizations_super_admin ON public.organizations
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- --------------------------------------------------------------------------
-- DROP: Gen 1 "Allow authenticated full access" wildcards on 3 tables.
-- After this drop:
--   - subscriptions governance: subscriptions_super_admin (cross-org) +
--     org_isolation (own-org, org-admin-only)
--   - organizations governance: organizations_super_admin (cross-org) +
--     org_isolation (own-org read/update) +
--     organizations_signup_insert (self-signup owner-pinned)
--   - pos_terminals governance: terminal_isolation
--     (own-org + (org-admin OR own-store))
-- --------------------------------------------------------------------------
DROP POLICY "Allow authenticated full access" ON public.subscriptions;
DROP POLICY "Allow authenticated full access" ON public.organizations;
DROP POLICY "Allow authenticated full access" ON public.pos_terminals;

COMMIT;


-- =============================================================================
-- V64-POST-A — Confirm final shape (expected: 6 rows, no wildcards)
-- =============================================================================
--
-- Re-run the V64-PRE query verbatim. Expected:
--   organizations  | org_isolation               | ALL    | {public}        | (id = get_user_org_id())
--   organizations  | organizations_signup_insert | INSERT | {authenticated} | (owner_id = auth.uid()::text)
--   organizations  | organizations_super_admin   | ALL    | {public}        | is_super_admin() / is_super_admin()
--   pos_terminals  | terminal_isolation          | ALL    | {public}        | (org_id=get_user_org_id()) AND (is_org_admin() OR store_id IN ...)
--   subscriptions  | org_isolation               | ALL    | {public}        | (org_id=get_user_org_id()) AND is_org_admin()
--   subscriptions  | subscriptions_super_admin   | ALL    | {public}        | is_super_admin() / is_super_admin()


-- =============================================================================
-- V64-POST-B — Baseline data preservation (expected: subs=0, orgs=1, terms=0)
-- =============================================================================
--
-- SELECT 'subscriptions' AS t, COUNT(*) FROM public.subscriptions
-- UNION ALL SELECT 'organizations', COUNT(*) FROM public.organizations
-- UNION ALL SELECT 'pos_terminals', COUNT(*) FROM public.pos_terminals;


-- =============================================================================
-- V64-POST-C — Confirm wildcards fully gone (expected: 0 rows)
-- =============================================================================
--
-- SELECT tablename, policyname, roles
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND policyname = 'Allow authenticated full access'
--   AND tablename IN ('subscriptions', 'organizations', 'pos_terminals');


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction (inverts v64 atomically)
-- =============================================================================
-- ⚠️  WARNING: Restoring the 3 wildcards re-opens full cross-tenant access
--     for any authenticated user. Only use this block during emergency
--     rollback and then immediately investigate why the Gen 3 policies did
--     not cover the intended access pattern.
--
-- BEGIN;
--
-- -- Re-create the 3 Gen 1 wildcards.
-- CREATE POLICY "Allow authenticated full access" ON public.subscriptions
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.organizations
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow authenticated full access" ON public.pos_terminals
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);
--
-- -- Drop the 2 new bypass policies.
-- DROP POLICY IF EXISTS subscriptions_super_admin ON public.subscriptions;
-- DROP POLICY IF EXISTS organizations_super_admin ON public.organizations;
--
-- COMMIT;
--
-- =============================================================================
-- END v64
-- =============================================================================
