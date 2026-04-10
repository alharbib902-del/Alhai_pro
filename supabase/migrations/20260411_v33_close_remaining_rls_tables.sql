-- ============================================================================
-- Migration v33: Close the remaining 4 RLS tables deferred from v32
-- Date: 2026-04-11
-- Purpose: v32 (20260410) replaced the blanket "Allow authenticated full
--          access" policy on 23 tables. Four tables were explicitly deferred
--          in v32's "Not included" list and still rely on the blanket
--          USING(true) policy created by supabase/fix_compatibility.sql:
--
--              1. product_expiry     (store-scoped via store_id)
--              2. stock_takes        (store-scoped via store_id)
--              3. stock_transfers    (store-scoped via from_store_id OR to_store_id)
--              4. whatsapp_templates (store-scoped via store_id)
--
--          This migration completes the v32 rollout by applying the exact
--          same membership-scoped policy pattern to these four tables,
--          closing the final cross-tenant data leak surface introduced by
--          fix_compatibility.sql.
--
--          stock_transfers is a special case: a transfer row involves two
--          stores (from_store_id and to_store_id). A user should be able to
--          see a transfer if they are a member of EITHER the source OR the
--          destination store. The policy reflects this with an OR clause.
--
-- Pattern: identical to v26/v32 — idempotent via DROP POLICY IF EXISTS,
--          single "store_member_access" policy per table,
--          FOR ALL TO authenticated.
--
-- References:
--   - supabase/migrations/20260404_v26_fix_rls_policies.sql (original pattern)
--   - supabase/migrations/20260410_v32_fix_remaining_rls_policies.sql (v32)
--   - supabase/fix_compatibility.sql (source of the blanket policy)
-- ============================================================================

-- ############################################################
-- 1. product_expiry - store-scoped (has store_id column)
--    Schema: id TEXT PK, product_id TEXT, store_id TEXT NOT NULL, ...
-- ############################################################

ALTER TABLE public.product_expiry ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.product_expiry;
DROP POLICY IF EXISTS "store_member_access" ON public.product_expiry;

CREATE POLICY "store_member_access" ON public.product_expiry
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 2. stock_takes - store-scoped (has store_id column)
--    Schema: id TEXT PK, store_id TEXT NOT NULL, name TEXT, ...
-- ############################################################

ALTER TABLE public.stock_takes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.stock_takes;
DROP POLICY IF EXISTS "store_member_access" ON public.stock_takes;

CREATE POLICY "store_member_access" ON public.stock_takes
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 3. stock_transfers - dual-store scoped (SPECIAL CASE)
--    Schema: id TEXT PK, transfer_number TEXT, from_store_id TEXT NOT NULL,
--            to_store_id TEXT NOT NULL, status TEXT, items JSONB, ...
--
--    A stock transfer row references TWO stores (source and destination).
--    A user should have access if they are a member of EITHER the source
--    OR the destination store. Without this, the sending store can't see
--    outgoing transfers and the receiving store can't see incoming ones.
--
--    WITH CHECK mirrors USING so a user can only INSERT/UPDATE a transfer
--    that involves at least one store they belong to.
-- ############################################################

ALTER TABLE public.stock_transfers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.stock_transfers;
DROP POLICY IF EXISTS "store_member_access" ON public.stock_transfers;

CREATE POLICY "store_member_access" ON public.stock_transfers
  FOR ALL TO authenticated
  USING (
    from_store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
    OR
    to_store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  )
  WITH CHECK (
    from_store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
    OR
    to_store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  );


-- ############################################################
-- 4. whatsapp_templates - store-scoped (has store_id column)
--    Schema: id TEXT PK, store_id TEXT NOT NULL, name TEXT, type TEXT,
--            content TEXT, ...
-- ############################################################

ALTER TABLE public.whatsapp_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.whatsapp_templates;
DROP POLICY IF EXISTS "store_member_access" ON public.whatsapp_templates;

CREATE POLICY "store_member_access" ON public.whatsapp_templates
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Fixed 4 tables in this migration, completing the v32 rollout:
--
-- store-scoped (direct store_id column):
--   1. product_expiry
--   2. stock_takes
--   4. whatsapp_templates
--
-- dual-store scoped (special case):
--   3. stock_transfers (from_store_id OR to_store_id membership)
--
-- Combined with v26 (7 tables) and v32 (23 tables), every table that
-- fix_compatibility.sql left wide open with a blanket "Allow authenticated
-- full access" policy has now been replaced with a properly scoped
-- membership-based policy. The cross-tenant data leak surface introduced
-- by fix_compatibility.sql is fully closed.
--
-- NOTE: supabase/fix_compatibility.sql itself must be disarmed so it cannot
-- be re-run and silently restore the blanket policies. See the WARNING block
-- at the top of that file.
-- ============================================================================
