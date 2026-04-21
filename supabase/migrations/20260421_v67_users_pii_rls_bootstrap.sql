-- =============================================================================
-- Migration v67: users table PII RLS bootstrap — closes final campaign gap
-- =============================================================================
-- Branch:   fix/users-pii-rls
-- Date:     2026-04-21
-- Type:     Additive (5 CREATE Gen 3) + subtractive (3 DROP). Two-step atomic.
-- Scope:    1 table (users), 8 statements total (5 CREATE + 3 DROP).
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Closes the final residual from v66 — the `users` table wildcard/anon/Gen 2
-- state that was deferred for careful design. This table was the highest-
-- severity PII concern in the campaign: `anon_read_users` was an S-0 anon
-- PII leak exposing every user record to any unauthenticated client with
-- the Supabase anon key.
--
-- Design required first-principles tenancy thinking (5 user roles with
-- different visibility needs) rather than the pattern-copy approach that
-- worked on earlier tables.
--
-- -----------------------------------------------------------------------------
-- TENANCY MODEL (designed in Phase B)
-- -----------------------------------------------------------------------------
-- 5 user roles with different visibility requirements:
--   super_admin  — platform-level; sees all users cross-org
--   store_owner  — stores.owner_id = auth.uid(); sees own stores' users
--   cashier/manager — users.store_id = their store; sees coworkers
--   customer     — users.store_id = NULL; sees self only
--   delivery     — users.store_id = NULL; sees self only
--
-- Policy coverage strategy:
--   1. Self-access (SELECT/INSERT/UPDATE) for all roles — covers customer,
--      delivery, and staff self-reads. Pattern: `id = auth.uid()::text`.
--   2. Coworker visibility — for staff to see users in their store(s).
--      Pattern: `store_id IS NOT NULL AND has_store_access(store_id)`.
--      NULL store_id (customers/drivers) not visible to staff via this path.
--   3. Platform-admin bypass — for super_admin cross-org operations.
--      Pattern: `is_super_admin()` FOR ALL (same as v64/v65 pattern).
--
-- -----------------------------------------------------------------------------
-- PHASE A INVESTIGATION EVIDENCE
-- -----------------------------------------------------------------------------
-- Drift schema (`packages/alhai_database/lib/src/tables/users_table.dart`):
--   id        TEXT PK (used by all apps as auth.uid() storage)
--   orgId     TEXT nullable
--   storeId   TEXT nullable (NULL for customers + delivery)
--   authUid   TEXT nullable (parallel to id in some rows)
--   role      TEXT (default 'cashier'; super_admin | store_owner | cashier |
--                   manager | customer | delivery)
--
-- Live DB row distribution (Q-users, 2026-04-21):
--   total = 4, with_auth_uid = 4, with_id = 4, role_count = 4.
--   Every row has both `id` and `auth_uid` populated.
--
-- Cross-app `.from('users')` callers (27 hits surveyed):
--   super_admin   — 11 hits: sa_users_datasource (CRUD), sa_stores_datasource
--                   (store usage stats), sa_analytics_datasource (platform
--                   counts), sa_logs_screen. All cross-org → super_admin bypass.
--   customer_app  —  5 hits: signup upsert + self-read + self-update +
--                   FCM token registration. All self-scope.
--   driver_app    —  5 hits: signup upsert + self-read + profile +
--                   FCM token. All self-scope.
--   alhai_auth    —  1 hit: self role resolution (via id = userId).
--   alhai_sync    —  whitelisted in pull_strategy + initial_sync
--                   (cashier needs coworker user data for local operations).
--   customer_app tests — 2 mocks, not production.
--
-- Pre-v67 "users_self_select" policy used `auth_uid = auth.uid()` — still
-- functional because auth_uid is populated in 4/4 rows. All apps write
-- `id = auth.uid()::text` though, so `users_self_select_by_id` is added
-- as the canonical pattern while the legacy policy stays as additional
-- coverage path (harmless PERMISSIVE OR).
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED (split across two user-gated atomic steps)
-- -----------------------------------------------------------------------------
-- Step 1 (additive — 5 CREATE) applied to Supabase production on
--   2026-04-21 via SQL Editor. V1-POST-A confirmed 9 policies live
--   (4 pre-existing + 5 new). Wildcards + Gen 2 dead remained active
--   between Step 1 and Step 2 as safety net (verified: no access
--   disruption during the gap).
--
-- Step 2 (subtractive — 3 DROP) applied immediately after V1-POST-A.
-- V2-POST-A confirmed exactly 6 policies remaining (5 new + 1 legacy
-- users_self_select). V2-POST-B confirmed 4 users preserved (row baseline).
-- V2-POST-WILDCARDS returned zero rows — no more wildcards on users.
--
-- -----------------------------------------------------------------------------
-- CAMPAIGN CONTEXT — FINAL ACCOUNTING
-- -----------------------------------------------------------------------------
-- Wildcard-cleanup campaign final tally (v58 → v67):
--   v58 —  2 S-0 anon wildcards (sales, sale_items)
--   v59 — 12 policies on 6 financial tables (W1)
--   v60 —  4 policies on 3 identity tables (W2 scope-reduced)
--   v61 — 21 policies on 10 operational tables + customers anon (W4)
--   v62 —  3 policies on categories (W5 scope-reduced)
--   v63 —  1 policy on sync_queue (vestigial)
--   v64 —  5 statements: 2 bypass + 3 wildcards (Platform Admin RLS)
--   v65 — 12 statements: 6 Gen 3 + 6 drops (Wildcard Gen 3 Bootstrap)
--   v66 — 17 statements: 4 bypass/Gen 3 + 13 drops (Closure Audit Extended)
--   v67 —  8 statements: 5 Gen 3 + 3 drops (users PII — this migration)
--
-- 🎉 CAMPAIGN TRULY COMPLETE: every `public.*` table is now tenant-isolated
-- or platform-admin gated. Zero wildcards, zero anon_read with qual=true,
-- zero dead Gen 2 single-store-scalar policies remain on any public table.
--
-- Cumulative: ~56 wildcard-family removals + ~19 Gen 3/bypass additions
-- across 10 migrations.
-- =============================================================================


-- =============================================================================
-- V-PRE — Starting baseline (expected: 4 rows on users table)
-- =============================================================================
--
-- Expected rows:
--   users | anon_read_users             | SELECT | {anon}          | qual=true
--   users | authenticated_read_users    | SELECT | {authenticated} | qual=true
--   users | store_isolation             | ALL    | {public}        | (store_id = get_user_store_id())
--   users | users_self_select           | SELECT | {public}        | (auth_uid = auth.uid())
--
-- SELECT policyname, cmd, roles, LEFT(qual, 100) AS qual, LEFT(with_check, 100) AS with_check
-- FROM pg_policies
-- WHERE schemaname = 'public' AND tablename = 'users'
-- ORDER BY policyname;


-- =============================================================================
-- APPLY BLOCK STEP 1 — CREATE 5 Gen 3 policies (additive, fail-safe)
-- =============================================================================
BEGIN;

-- --------------------------------------------------------------------------
-- Self-read via canonical id column (matches customer_app, driver_app,
-- alhai_auth patterns). Parallel to legacy users_self_select which reads
-- via auth_uid column — both remain as OR'd coverage paths.
-- --------------------------------------------------------------------------
CREATE POLICY users_self_select_by_id ON public.users
  FOR SELECT TO public
  USING (id = (auth.uid())::text);

-- --------------------------------------------------------------------------
-- Self-insert for first-time signup upserts (customer_app, driver_app).
-- Trigger prevent_direct_role_update protects against role-escalation in
-- client payloads.
-- --------------------------------------------------------------------------
CREATE POLICY users_self_insert ON public.users
  FOR INSERT TO public
  WITH CHECK (id = (auth.uid())::text);

-- --------------------------------------------------------------------------
-- Self-update for profile changes (name, email, fcm_token). Same trigger
-- blocks role updates. Non-role columns freely editable by the owning user.
-- --------------------------------------------------------------------------
CREATE POLICY users_self_update ON public.users
  FOR UPDATE TO public
  USING (id = (auth.uid())::text)
  WITH CHECK (id = (auth.uid())::text);

-- --------------------------------------------------------------------------
-- Coworker visibility: staff can see other users in stores they have
-- access to. NULL store_id (customers, delivery drivers) excluded — they
-- surface only via users_self_* or users_super_admin.
-- --------------------------------------------------------------------------
CREATE POLICY users_same_store_select ON public.users
  FOR SELECT TO public
  USING (store_id IS NOT NULL AND public.has_store_access(store_id));

-- --------------------------------------------------------------------------
-- Platform-admin cross-org bypass. Matches canonical pattern from v64
-- (subscriptions, organizations) and v65 (sales) and v66 (products,
-- stores, shifts).
-- --------------------------------------------------------------------------
CREATE POLICY users_super_admin ON public.users
  FOR ALL TO public
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

COMMIT;


-- =============================================================================
-- V1-POST — Confirm 9 policies live (4 old + 5 new) — user-gated checkpoint
-- =============================================================================
--
-- Re-run the V-PRE query verbatim. Expected: 9 rows.
-- Between Step 1 and Step 2, wildcards remain active → app access unaffected
-- in the gap. V1-POST is the explicit go/no-go gate for Step 2.


-- =============================================================================
-- APPLY BLOCK STEP 2 — DROP 3 residual policies (subtractive)
-- =============================================================================
BEGIN;

-- 🔴 S-0 PII leak — every user record readable by unauthenticated clients
DROP POLICY "anon_read_users" ON public.users;

-- 🟠 Over-permissive: any authenticated user sees all other users
DROP POLICY "authenticated_read_users" ON public.users;

-- 🟡 Dead Gen 2: single-store scalar dominated by users_same_store_select
DROP POLICY "store_isolation" ON public.users;

COMMIT;


-- =============================================================================
-- V2-POST-A — Confirm exactly 6 policies remain (expected: 6 rows)
-- =============================================================================
--
-- Expected final state:
--   users | users_self_select           | SELECT | {public} | (auth_uid = auth.uid())
--   users | users_self_select_by_id     | SELECT | {public} | (id = (auth.uid())::text)
--   users | users_self_insert           | INSERT | {public} | WITH CHECK (id = ...)
--   users | users_self_update           | UPDATE | {public} | (id = ...) / WITH CHECK (id = ...)
--   users | users_same_store_select     | SELECT | {public} | store_id NOT NULL AND has_store_access
--   users | users_super_admin           | ALL    | {public} | is_super_admin() / is_super_admin()


-- =============================================================================
-- V2-POST-B — Baseline data preservation (expected: 4 users)
-- =============================================================================
--
-- SELECT COUNT(*) AS total FROM public.users;


-- =============================================================================
-- V2-POST-WILDCARDS — Confirm zero pseudo-wildcards (expected: 0 rows)
-- =============================================================================
--
-- SELECT policyname, roles FROM pg_policies
-- WHERE schemaname = 'public' AND tablename = 'users'
--   AND (qual = 'true' OR policyname ILIKE 'anon_read%'
--        OR policyname ILIKE 'authenticated_read%' OR policyname = 'store_isolation');


-- =============================================================================
-- ACCESS MATRIX (post-v67)
-- =============================================================================
--   Role          | Self | Coworker | All Users | Pattern
--   --------------|------|----------|-----------|---------------------------
--   anon          |  —   |    —     |     —     | No access at all
--   authenticated |  R   |    —     |     —     | Only via users_self_*
--   customer      | RIU  |    —     |     —     | self-scope via id
--   delivery      | RIU  |    —     |     —     | self-scope via id
--   cashier       | RIU  |    R     |     —     | self + users_same_store
--   store_owner   | RIU  |    R     |     —     | self + users_same_store
--                 |      |          |           | (has_store_access → owner check)
--   super_admin   | RIU  |    R     |    RIUD   | via users_super_admin (FOR ALL)
--
-- R = Read, I = Insert, U = Update, D = Delete


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction
-- =============================================================================
-- ⚠️  WARNING: Restoring these policies re-opens the S-0 PII leak. Only for
--     emergency rollback and then immediately investigate what broke.
--
-- BEGIN;
--
-- -- Restore the 3 dropped policies.
-- CREATE POLICY "anon_read_users" ON public.users
--   FOR SELECT TO anon USING (true);
-- CREATE POLICY "authenticated_read_users" ON public.users
--   FOR SELECT TO authenticated USING (true);
-- CREATE POLICY "store_isolation" ON public.users
--   FOR ALL TO public USING (store_id = get_user_store_id());
--
-- -- Drop the 5 new Gen 3 / bypass policies.
-- DROP POLICY IF EXISTS users_self_select_by_id ON public.users;
-- DROP POLICY IF EXISTS users_self_insert ON public.users;
-- DROP POLICY IF EXISTS users_self_update ON public.users;
-- DROP POLICY IF EXISTS users_same_store_select ON public.users;
-- DROP POLICY IF EXISTS users_super_admin ON public.users;
--
-- COMMIT;
--
-- =============================================================================
-- END v67 — 🎉 WILDCARD CAMPAIGN TRULY COMPLETE (7 of 7 tables closed)
-- =============================================================================
