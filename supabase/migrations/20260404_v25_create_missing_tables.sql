-- ============================================================================
-- Migration v25: Create 5 missing tables that POS pushes to
-- Date: 2026-04-04
-- Purpose: The POS app creates rows locally for returns, return_items,
--          cash_movements, audit_log, and daily_summaries. Without these
--          tables in Supabase, sync pushes fail with "relation does not exist".
--
-- Note: cash_movements and audit_log may already exist from earlier setup.
--       Using IF NOT EXISTS to be safe.
-- ============================================================================

-- ############################################################
-- 1. returns
-- ############################################################

CREATE TABLE IF NOT EXISTS public.returns (
  id TEXT PRIMARY KEY,
  sale_id TEXT REFERENCES public.sales(id) ON DELETE SET NULL,
  store_id TEXT NOT NULL,
  customer_id TEXT REFERENCES public.customers(id) ON DELETE SET NULL,
  type TEXT,
  status TEXT,
  total_amount DOUBLE PRECISION,
  refund_amount DOUBLE PRECISION,
  refund_method TEXT,
  reason TEXT,
  notes TEXT,
  approved_by TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_returns_store_id ON public.returns (store_id);
CREATE INDEX IF NOT EXISTS idx_returns_sale_id ON public.returns (sale_id);
CREATE INDEX IF NOT EXISTS idx_returns_created_at ON public.returns (created_at DESC);

ALTER TABLE public.returns ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.returns;
CREATE POLICY "store_member_access" ON public.returns
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 2. return_items
-- ############################################################

CREATE TABLE IF NOT EXISTS public.return_items (
  id TEXT PRIMARY KEY,
  return_id TEXT NOT NULL REFERENCES public.returns(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  sale_item_id TEXT,
  qty DOUBLE PRECISION NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  total DOUBLE PRECISION NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_return_items_return_id ON public.return_items (return_id);
CREATE INDEX IF NOT EXISTS idx_return_items_product_id ON public.return_items (product_id);

ALTER TABLE public.return_items ENABLE ROW LEVEL SECURITY;

-- return_items scoped via returns JOIN (same pattern as sale_items via sales)
DROP POLICY IF EXISTS "store_member_access" ON public.return_items;
CREATE POLICY "store_member_access" ON public.return_items
  FOR ALL TO authenticated
  USING (return_id IN (
    SELECT id FROM public.returns
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (return_id IN (
    SELECT id FROM public.returns
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));

-- ############################################################
-- 3. cash_movements
-- ############################################################

CREATE TABLE IF NOT EXISTS public.cash_movements (
  id TEXT PRIMARY KEY,
  shift_id TEXT,
  store_id TEXT NOT NULL,
  type TEXT,
  amount DOUBLE PRECISION,
  reason TEXT,
  notes TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_cash_movements_store_id ON public.cash_movements (store_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_shift_id ON public.cash_movements (shift_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_created_at ON public.cash_movements (created_at DESC);

ALTER TABLE public.cash_movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.cash_movements;
CREATE POLICY "store_member_access" ON public.cash_movements
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 4. audit_log
-- ############################################################

CREATE TABLE IF NOT EXISTS public.audit_log (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  user_id TEXT,
  action TEXT,
  entity_type TEXT,
  entity_id TEXT,
  details JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_audit_log_store_id ON public.audit_log (store_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON public.audit_log (user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON public.audit_log (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON public.audit_log (entity_type, entity_id);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.audit_log;
CREATE POLICY "store_member_access" ON public.audit_log
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 5. daily_summaries
-- ############################################################

CREATE TABLE IF NOT EXISTS public.daily_summaries (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  date DATE NOT NULL,
  total_sales DOUBLE PRECISION DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  total_refunds DOUBLE PRECISION DEFAULT 0,
  total_expenses DOUBLE PRECISION DEFAULT 0,
  net_profit DOUBLE PRECISION DEFAULT 0,
  cash_total DOUBLE PRECISION DEFAULT 0,
  card_total DOUBLE PRECISION DEFAULT 0,
  credit_total DOUBLE PRECISION DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_daily_summaries_store_id ON public.daily_summaries (store_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_date ON public.daily_summaries (store_id, date DESC);

ALTER TABLE public.daily_summaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.daily_summaries;
CREATE POLICY "store_member_access" ON public.daily_summaries
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));
