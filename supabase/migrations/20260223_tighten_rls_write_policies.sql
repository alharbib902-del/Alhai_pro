-- Migration: Tighten RLS write policies (is_store_member → is_store_admin)
-- Date: 2026-02-23
-- Description: Restrict INSERT/UPDATE/DELETE on sensitive tables to owner/manager only.
--              Cashiers can still READ but cannot modify products, categories, etc.
-- SAFE: Uses DROP IF EXISTS + CREATE POLICY (idempotent, can re-run safely)
--
-- Live DB tables: products, categories, suppliers, promotions
-- Tables NOT yet in live DB (skipped): debts, debt_payments,
--   purchase_orders, purchase_order_items, stock_adjustments

-- ============================================================
-- STEP 1A: Create is_super_admin function (prerequisite)
-- users.id is UUID, auth.uid() is UUID -> no cast needed
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin');
$$;

-- ============================================================
-- STEP 1B: Create is_store_member function (prerequisite)
-- store_members.user_id is UUID → no cast needed
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id TEXT)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
);
$$;

-- ============================================================
-- STEP 1C: Create is_store_admin function
-- stores.owner_id is UUID, store_members.user_id is UUID → no cast
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id TEXT)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT
    public.is_super_admin()
    OR EXISTS (SELECT 1 FROM public.stores WHERE id = p_store_id AND owner_id = auth.uid())
    OR EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid()
        AND is_active = true AND role_in_store IN ('owner', 'manager')
    );
$$;

-- ============================================================
-- STEP 2: products — write policies → is_store_admin
-- ============================================================
DROP POLICY IF EXISTS "products_staff_insert" ON public.products;
CREATE POLICY "products_staff_insert" ON public.products FOR INSERT
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "products_staff_update" ON public.products;
CREATE POLICY "products_staff_update" ON public.products FOR UPDATE
USING (public.is_store_admin(store_id))
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "products_staff_delete" ON public.products;
CREATE POLICY "products_staff_delete" ON public.products FOR DELETE
USING (public.is_store_admin(store_id));

-- ============================================================
-- STEP 3: categories — write policies → is_store_admin
-- ============================================================
DROP POLICY IF EXISTS "categories_staff_insert" ON public.categories;
CREATE POLICY "categories_staff_insert" ON public.categories FOR INSERT
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "categories_staff_update" ON public.categories;
CREATE POLICY "categories_staff_update" ON public.categories FOR UPDATE
USING (public.is_store_admin(store_id))
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "categories_staff_delete" ON public.categories;
CREATE POLICY "categories_staff_delete" ON public.categories FOR DELETE
USING (public.is_store_admin(store_id));

-- ============================================================
-- STEP 4: suppliers — write policies → is_store_admin
-- ============================================================
DROP POLICY IF EXISTS "suppliers_staff_insert" ON public.suppliers;
CREATE POLICY "suppliers_staff_insert" ON public.suppliers FOR INSERT
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "suppliers_staff_update" ON public.suppliers;
CREATE POLICY "suppliers_staff_update" ON public.suppliers FOR UPDATE
USING (public.is_store_admin(store_id))
WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "suppliers_staff_delete" ON public.suppliers;
CREATE POLICY "suppliers_staff_delete" ON public.suppliers FOR DELETE
USING (public.is_store_admin(store_id));

-- ============================================================
-- STEP 5: promotions — split FOR ALL into READ(member) + WRITE(admin)
-- ============================================================
DROP POLICY IF EXISTS "promotions_staff_all" ON public.promotions;

DROP POLICY IF EXISTS "promotions_staff_read" ON public.promotions;
CREATE POLICY "promotions_staff_read" ON public.promotions FOR SELECT
  USING (public.is_store_member(store_id));

DROP POLICY IF EXISTS "promotions_staff_insert" ON public.promotions;
CREATE POLICY "promotions_staff_insert" ON public.promotions FOR INSERT
  WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "promotions_staff_update" ON public.promotions;
CREATE POLICY "promotions_staff_update" ON public.promotions FOR UPDATE
  USING (public.is_store_admin(store_id))
  WITH CHECK (public.is_store_admin(store_id));

DROP POLICY IF EXISTS "promotions_staff_delete" ON public.promotions;
CREATE POLICY "promotions_staff_delete" ON public.promotions FOR DELETE
  USING (public.is_store_admin(store_id));

-- ============================================================
-- DONE! Summary:
-- ✅ 3 helper functions created (is_super_admin, is_store_member, is_store_admin)
-- ✅ 4 tables secured: products, categories, suppliers, promotions
-- ✅ 13 write policies now use is_store_admin
-- ✅ SELECT policies unchanged (cashier can still read)
-- ✅ promotions_staff_all split into READ(member) + WRITE(admin)
--
-- TODO (when tables are created in live DB):
--   debts, debt_payments, purchase_orders,
--   purchase_order_items, stock_adjustments
-- ============================================================
