-- ============================================================================
-- Distributor Portal RLS Policies
-- Enforces org_id filtering at the database level so distributor users
-- can only access data belonging to their own organization.
-- ============================================================================
-- FIX (2026-04-16): Replaced nonexistent `profiles` table with `org_members`.
--   The original file defined `auth.user_org_id()` which queried
--   `SELECT org_id FROM profiles WHERE id = auth.uid()` -- but no `profiles`
--   table exists in this schema. The canonical membership table is
--   `public.org_members` (user_id TEXT, org_id TEXT, store_id TEXT),
--   used by all other RLS policies (v26, v32, v33).
--
--   The function is now created in the `public` schema (not `auth`) to match
--   the project convention. All policies below use the same org_members-based
--   pattern established in the rest of the codebase.
--
--   These policies are ADDITIVE to the existing `store_member_access` policies
--   from v32/v33. They provide a distributor-specific org-scoped view.
-- ============================================================================

-- Enable RLS on all relevant tables (idempotent)
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Helper: get the current user's org_id from their org_members membership.
-- Returns the first org_id found (a user typically belongs to one org).
-- Created in `public` schema to match project convention (not `auth`).
-- SECURITY DEFINER so it can read org_members regardless of caller RLS.
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

-- ---- Orders --------------------------------------------------------

-- Users can only see orders from stores in their org
DROP POLICY IF EXISTS "distributor_orders_select" ON public.orders;
CREATE POLICY "distributor_orders_select" ON public.orders
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT id FROM public.stores WHERE org_id = public.user_org_id()
    )
  );

-- Users can only update orders from stores in their org
DROP POLICY IF EXISTS "distributor_orders_update" ON public.orders;
CREATE POLICY "distributor_orders_update" ON public.orders
  FOR UPDATE TO authenticated
  USING (
    store_id IN (
      SELECT id FROM public.stores WHERE org_id = public.user_org_id()
    )
  );

-- ---- Order Items ---------------------------------------------------

-- Users can only see order items for orders belonging to their org's stores
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

-- Users can only update order items for orders belonging to their org's stores
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

-- Users can only see products belonging to their org
DROP POLICY IF EXISTS "distributor_products_select" ON public.products;
CREATE POLICY "distributor_products_select" ON public.products
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());

-- Users can only update products belonging to their org
DROP POLICY IF EXISTS "distributor_products_update" ON public.products;
CREATE POLICY "distributor_products_update" ON public.products
  FOR UPDATE TO authenticated
  USING (org_id = public.user_org_id());

-- ---- Organizations -------------------------------------------------

-- Users can only see their own organization
DROP POLICY IF EXISTS "distributor_organizations_select" ON public.organizations;
CREATE POLICY "distributor_organizations_select" ON public.organizations
  FOR SELECT TO authenticated
  USING (id = public.user_org_id());

-- Users can only update their own organization
DROP POLICY IF EXISTS "distributor_organizations_update" ON public.organizations;
CREATE POLICY "distributor_organizations_update" ON public.organizations
  FOR UPDATE TO authenticated
  USING (id = public.user_org_id());

-- ---- Stores --------------------------------------------------------

-- Users can only see stores belonging to their org
DROP POLICY IF EXISTS "distributor_stores_select" ON public.stores;
CREATE POLICY "distributor_stores_select" ON public.stores
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());

-- ---- Categories ----------------------------------------------------

-- Users can only see categories belonging to their org
DROP POLICY IF EXISTS "distributor_categories_select" ON public.categories;
CREATE POLICY "distributor_categories_select" ON public.categories
  FOR SELECT TO authenticated
  USING (org_id = public.user_org_id());
