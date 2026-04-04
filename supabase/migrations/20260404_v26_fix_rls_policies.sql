-- ============================================================================
-- Migration v26: Replace blanket USING(true) RLS policies with store-scoped
-- Date: 2026-04-04
-- Purpose: The existing RLS policies on sales, sale_items, customers,
--          stock_deltas, expenses, purchases, and inventory_movements use
--          USING(true) which allows ANY authenticated user to read/write
--          ANY store's data. This migration replaces them with proper
--          store-scoped policies via org_members membership.
-- ============================================================================

-- ############################################################
-- 1. sales - replace blanket policy with store-scoped
-- ############################################################

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.sales;
DROP POLICY IF EXISTS "store_member_access" ON public.sales;

CREATE POLICY "store_member_access" ON public.sales
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 2. sale_items - scoped via sales JOIN (no direct store_id)
-- ############################################################

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.sale_items;
DROP POLICY IF EXISTS "store_member_access" ON public.sale_items;

CREATE POLICY "store_member_access" ON public.sale_items
  FOR ALL TO authenticated
  USING (sale_id IN (
    SELECT id FROM public.sales
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (sale_id IN (
    SELECT id FROM public.sales
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));

-- ############################################################
-- 3. customers - replace blanket policy with store-scoped
-- ############################################################

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.customers;
DROP POLICY IF EXISTS "store_member_access" ON public.customers;

CREATE POLICY "store_member_access" ON public.customers
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 4. stock_deltas - store-scoped
-- ############################################################

ALTER TABLE public.stock_deltas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.stock_deltas;
DROP POLICY IF EXISTS "store_member_access" ON public.stock_deltas;

CREATE POLICY "store_member_access" ON public.stock_deltas
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 5. expenses - store-scoped
-- ############################################################

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.expenses;
DROP POLICY IF EXISTS "store_member_access" ON public.expenses;

CREATE POLICY "store_member_access" ON public.expenses
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 6. purchases - store-scoped
-- ############################################################

ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.purchases;
DROP POLICY IF EXISTS "store_member_access" ON public.purchases;

CREATE POLICY "store_member_access" ON public.purchases
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 7. inventory_movements - enable RLS + add store-scoped policy
-- ############################################################

ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.inventory_movements;
DROP POLICY IF EXISTS "store_member_access" ON public.inventory_movements;

CREATE POLICY "store_member_access" ON public.inventory_movements
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));
