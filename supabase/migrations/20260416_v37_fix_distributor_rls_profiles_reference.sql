-- ============================================================================
-- Migration v37: Fix distributor RLS policies that referenced nonexistent
--                `profiles` table
-- Date: 2026-04-16
-- ============================================================================
-- Problem:
--   The original 20260404_distributor_rls_policies.sql migration created a
--   helper function `auth.user_org_id()` that queried:
--
--       SELECT org_id FROM profiles WHERE id = auth.uid()
--
--   No `profiles` table exists in this schema. This caused the function to
--   fail at runtime, which in turn caused ALL distributor RLS policies
--   (8 policies across 6 tables) to fail. Depending on Postgres behavior,
--   this results in either:
--     - BLOCKED access (function error = policy evaluates to false)
--     - or an unhandled error on every query from the distributor portal.
--
-- Fix:
--   1. Drop the broken `auth.user_org_id()` function.
--   2. Create `public.user_org_id()` using `org_members` (the canonical
--      membership table used by v26/v32/v33 policies).
--   3. Re-create all 8 distributor policies to use `public.user_org_id()`
--      instead of `auth.user_org_id()`.
--
-- Why org_members:
--   `org_members` is the ONLY table that maps auth UIDs to org_ids. It is
--   used by every other RLS policy in the system (v26, v32, v33). The
--   `users` table also has an `org_id` column, but org_members is the
--   canonical membership source and supports multi-org scenarios.
--
-- Why public schema (not auth):
--   All other helper functions in this project (is_super_admin,
--   is_store_member, is_store_admin, get_my_user_id) are in the `public`
--   schema. The `auth` schema is managed by Supabase and should not contain
--   user-defined functions.
--
-- Idempotent: safe to re-run. Uses DROP IF EXISTS + CREATE OR REPLACE.
-- ============================================================================

-- ############################################################
-- STEP 1: Drop the broken function in auth schema
-- ############################################################

DROP FUNCTION IF EXISTS auth.user_org_id();

-- ############################################################
-- STEP 2: Create the corrected function in public schema
-- ############################################################

CREATE OR REPLACE FUNCTION public.user_org_id()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth
AS $$
  SELECT org_id FROM public.org_members
  WHERE user_id = auth.uid()::TEXT AND is_active = true
  LIMIT 1
$$;

COMMENT ON FUNCTION public.user_org_id() IS
  'Returns the org_id of the current authenticated user from org_members. '
  'Used by distributor RLS policies to scope access to a single organization. '
  'SECURITY DEFINER so it can read org_members regardless of caller RLS. '
  'Fixed in v37: was originally auth.user_org_id() querying nonexistent profiles table.';

-- ############################################################
-- STEP 3: Re-create distributor policies using public.user_org_id()
-- ############################################################

-- ---- Orders --------------------------------------------------------

DROP POLICY IF EXISTS "distributor_orders_select" ON public.orders;
CREATE POLICY "distributor_orders_select" ON public.orders
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT id FROM public.stores WHERE org_id = public.user_org_id()
    )
  );

DROP POLICY IF EXISTS "distributor_orders_update" ON public.orders;
CREATE POLICY "distributor_orders_update" ON public.orders
  FOR UPDATE TO authenticated
  USING (
    store_id IN (
      SELECT id FROM public.stores WHERE org_id = public.user_org_id()
    )
  );

-- ---- Order Items ---------------------------------------------------

DROP POLICY IF EXISTS "distributor_order_items_select" ON public.order_items;
CREATE POLICY "distributor_order_items_select" ON public.order_items
  FOR SELECT TO authenticated
  USING (
    order_id IN (
      SELECT id FROM public.orders
      WHERE store_id IN (
        SELECT id FROM public.stores WHERE org_id = public.user_org_id()
      )
    )
  );

DROP POLICY IF EXISTS "distributor_order_items_update" ON public.order_items;
CREATE POLICY "distributor_order_items_update" ON public.order_items
  FOR UPDATE TO authenticated
  USING (
    order_id IN (
      SELECT id FROM public.orders
      WHERE store_id IN (
        SELECT id FROM public.stores WHERE org_id = public.user_org_id()
      )
    )
  );

-- ---- Products ------------------------------------------------------

DROP POLICY IF EXISTS "distributor_products_select" ON public.products;
CREATE POLICY "distributor_products_select" ON public.products
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());

DROP POLICY IF EXISTS "distributor_products_update" ON public.products;
CREATE POLICY "distributor_products_update" ON public.products
  FOR UPDATE TO authenticated
  USING (org_id = public.user_org_id());

-- ---- Organizations -------------------------------------------------

DROP POLICY IF EXISTS "distributor_organizations_select" ON public.organizations;
CREATE POLICY "distributor_organizations_select" ON public.organizations
  FOR SELECT TO authenticated
  USING (id = public.user_org_id());

DROP POLICY IF EXISTS "distributor_organizations_update" ON public.organizations;
CREATE POLICY "distributor_organizations_update" ON public.organizations
  FOR UPDATE TO authenticated
  USING (id = public.user_org_id());

-- ---- Stores --------------------------------------------------------

DROP POLICY IF EXISTS "distributor_stores_select" ON public.stores;
CREATE POLICY "distributor_stores_select" ON public.stores
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());

-- ---- Categories ----------------------------------------------------

DROP POLICY IF EXISTS "distributor_categories_select" ON public.categories;
CREATE POLICY "distributor_categories_select" ON public.categories
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());


-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Fixed 1 function + 8 policies across 6 tables:
--
-- Function replaced:
--   auth.user_org_id() [BROKEN: referenced `profiles`]
--   -> public.user_org_id() [FIXED: queries `org_members`]
--
-- Policies re-created (all use public.user_org_id()):
--   1. distributor_orders_select       (orders)
--   2. distributor_orders_update       (orders)
--   3. distributor_order_items_select  (order_items)
--   4. distributor_order_items_update  (order_items)
--   5. distributor_products_select     (products)
--   6. distributor_products_update     (products)
--   7. distributor_organizations_select (organizations)
--   8. distributor_organizations_update (organizations)
--   9. distributor_stores_select       (stores)
--  10. distributor_categories_select   (categories)
--
-- These policies are ADDITIVE to the existing store_member_access policies
-- from v32/v33. They coexist because Postgres OR's multiple PERMISSIVE
-- policies on the same table.
-- ============================================================================
