-- ═══════════════════════════════════════════════════════════════
-- v76 — 2026-04-23
-- C-10: invoices RLS fallback for historical NULL-orgId rows
-- ═══════════════════════════════════════════════════════════════
--
-- Context
-- -------
-- Before commit e00e158 (C-3, 2026-04-21), cashier-originated invoices
-- were written to the local Drift `invoices` table with `org_id = NULL`
-- because the `sales` row they were derived from had `org_id = NULL` in
-- Drift. These invoices were enqueued to Supabase's sync queue but the
-- `invoices_insert_policy` RLS required `org_id IN (user's orgs)` —
-- NULL ∉ anything in SQL's three-valued logic — so INSERT silently
-- denied and every such invoice landed in `dead_letter` indefinitely.
--
-- C-3 fixed the source: post-C-3 sales + invoices populate org_id
-- correctly. This migration handles the HISTORICAL pile by extending
-- the insert-check to allow NULL-org_id invoices to land IF the calling
-- user is a member of the invoice's store via `store_members`.
--
-- Effect
-- ------
-- - Dead-letter invoices (pre-C-3) unblock on their next sync retry.
-- - New invoices (post-C-3) go through the existing org_id path unchanged
--   because org_id IS NOT NULL and the org-membership check still fires.
-- - RLS remains tenant-safe: a NULL-org_id invoice can only be inserted
--   by someone who is already a member of the target store.
--
-- Rollback
-- --------
--   BEGIN;
--   DROP POLICY IF EXISTS "invoices_insert_policy" ON public.invoices;
--   CREATE POLICY "invoices_insert_policy" ON public.invoices
--     FOR INSERT WITH CHECK (
--       org_id IN (
--         SELECT om.org_id FROM public.org_members om
--         WHERE om.user_id = auth.uid()::TEXT
--           AND om.is_active = true
--       )
--     );
--   COMMIT;
--
-- Pre-apply verification (run BEFORE the migration)
-- -------------------------------------------------
-- On Supabase Dashboard → SQL editor, as postgres admin:
--
--   -- Q1: baseline — how many invoice rows already have a NULL org_id
--   -- on the server? Should be 0 normally (they're in dead-letter on
--   -- clients, not on the server yet). If > 0, investigate before
--   -- proceeding.
--   SELECT COUNT(*) AS null_org_invoices FROM public.invoices
--    WHERE org_id IS NULL;
--
--   -- Q2: confirm the policy about to be replaced exists and is
--   -- what we expect.
--   SELECT polname, pg_get_expr(polqual, polrelid, true) AS using_qual,
--          pg_get_expr(polwithcheck, polrelid, true) AS with_check
--     FROM pg_policy
--    WHERE polrelid = 'public.invoices'::regclass
--      AND polname = 'invoices_insert_policy';
--   -- Expect: with_check = "(org_id IN ( SELECT om.org_id FROM
--   --   org_members om WHERE (om.user_id = (auth.uid())::text) AND
--   --   (om.is_active = true)))"
--
-- Post-apply verification (run AFTER the migration)
-- -------------------------------------------------
--   -- Q3: confirm the new policy body contains the NULL fallback.
--   SELECT pg_get_expr(polwithcheck, polrelid, true)
--     FROM pg_policy
--    WHERE polrelid = 'public.invoices'::regclass
--      AND polname = 'invoices_insert_policy';
--   -- Expect: contains "org_id IS NULL AND store_id IN" substring.
--
--   -- Q4: sample — ask a cashier device to sync, then check whether
--   -- dead-letter invoices dropped on the client. Server-side:
--   SELECT COUNT(*) AS null_org_invoices FROM public.invoices
--    WHERE org_id IS NULL;
--   -- Expect: > 0 if devices had stuck invoices and have synced since;
--   -- 0 if no devices had stuck invoices (benign).
--
-- ═══════════════════════════════════════════════════════════════

BEGIN;

DROP POLICY IF EXISTS "invoices_insert_policy" ON public.invoices;

-- Allow INSERT when:
--   (a) the standard org-membership path matches (post-C-3 writes), OR
--   (b) the invoice has NULL org_id AND the user is an active member of
--       the invoice's store via the existing `store_members` table.
--       Historical-only path; pre-C-3 invoices clear via this branch.
CREATE POLICY "invoices_insert_policy" ON public.invoices
  FOR INSERT WITH CHECK (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT
        AND om.is_active = true
    )
    OR (
      org_id IS NULL
      AND store_id IN (
        -- store_members.user_id is UUID (see get_my_stores.sql),
        -- unlike org_members.user_id which is TEXT. Do NOT add a ::TEXT
        -- cast here — that forces a runtime text comparison that the
        -- UUID index cannot serve.
        SELECT sm.store_id FROM public.store_members sm
        WHERE sm.user_id = auth.uid()
          AND sm.is_active = true
      )
    )
  );

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- End of v76
-- ═══════════════════════════════════════════════════════════════
