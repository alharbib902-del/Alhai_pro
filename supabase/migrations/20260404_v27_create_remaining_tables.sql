-- ============================================================================
-- Migration v27: Create remaining tables that Drift defines locally but
--               have no CREATE TABLE in Supabase
-- Date: 2026-04-04
-- Tables: inventory_movements, accounts, transactions, held_invoices,
--         favorites, whatsapp_messages
-- ============================================================================

-- ############################################################
-- 1. inventory_movements
-- ############################################################

CREATE TABLE IF NOT EXISTS public.inventory_movements (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  store_id TEXT NOT NULL,
  type TEXT NOT NULL,                       -- sale, purchase, adjustment, return, transfer, waste
  qty DOUBLE PRECISION NOT NULL,
  previous_qty DOUBLE PRECISION NOT NULL,
  new_qty DOUBLE PRECISION NOT NULL,
  reference_type TEXT,                      -- sale, purchase_order, adjustment
  reference_id TEXT,
  reason TEXT,
  notes TEXT,
  user_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_inventory_product_id   ON public.inventory_movements (product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_store_id     ON public.inventory_movements (store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_created_at   ON public.inventory_movements (created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_type         ON public.inventory_movements (type);
CREATE INDEX IF NOT EXISTS idx_inventory_reference    ON public.inventory_movements (reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_inventory_synced_at    ON public.inventory_movements (synced_at);

ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.inventory_movements;
CREATE POLICY "store_member_access" ON public.inventory_movements
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 2. accounts
-- ############################################################

CREATE TABLE IF NOT EXISTS public.accounts (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  type TEXT NOT NULL,                       -- receivable, payable
  customer_id TEXT REFERENCES public.customers(id) ON DELETE SET NULL,
  supplier_id TEXT REFERENCES public.suppliers(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  phone TEXT,
  balance DOUBLE PRECISION DEFAULT 0,
  credit_limit DOUBLE PRECISION DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  last_transaction_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_accounts_store_id    ON public.accounts (store_id);
CREATE INDEX IF NOT EXISTS idx_accounts_type        ON public.accounts (type);
CREATE INDEX IF NOT EXISTS idx_accounts_customer_id ON public.accounts (customer_id);
CREATE INDEX IF NOT EXISTS idx_accounts_supplier_id ON public.accounts (supplier_id);
CREATE INDEX IF NOT EXISTS idx_accounts_synced_at   ON public.accounts (synced_at);

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.accounts;
CREATE POLICY "store_member_access" ON public.accounts
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_accounts_updated_at ON public.accounts;
CREATE TRIGGER trg_accounts_updated_at
  BEFORE UPDATE ON public.accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ############################################################
-- 3. transactions
-- ############################################################

CREATE TABLE IF NOT EXISTS public.transactions (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  account_id TEXT NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  type TEXT NOT NULL,                       -- invoice, payment, interest, adjustment
  amount DOUBLE PRECISION NOT NULL,
  balance_after DOUBLE PRECISION NOT NULL,
  description TEXT,
  reference_id TEXT,                        -- saleId, purchaseId, etc
  reference_type TEXT,                      -- sale, purchase
  period_key TEXT,                          -- YYYY-MM format (for monthly interest)
  payment_method TEXT,                      -- cash, card, transfer
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_transactions_store_id   ON public.transactions (store_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON public.transactions (account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type       ON public.transactions (type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions (created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_synced_at  ON public.transactions (synced_at);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.transactions;
CREATE POLICY "store_member_access" ON public.transactions
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- 4. held_invoices
-- ############################################################

CREATE TABLE IF NOT EXISTS public.held_invoices (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  customer_name TEXT,
  customer_phone TEXT,
  items TEXT NOT NULL,                      -- JSON array of cart items
  subtotal DOUBLE PRECISION DEFAULT 0,
  discount DOUBLE PRECISION DEFAULT 0,
  total DOUBLE PRECISION DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  sync_status TEXT DEFAULT 'pending',
  org_id TEXT
);

CREATE INDEX IF NOT EXISTS idx_held_invoices_store_id   ON public.held_invoices (store_id);
CREATE INDEX IF NOT EXISTS idx_held_invoices_cashier_id ON public.held_invoices (cashier_id);

ALTER TABLE public.held_invoices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.held_invoices;
CREATE POLICY "store_member_access" ON public.held_invoices
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_held_invoices_updated_at ON public.held_invoices;
CREATE TRIGGER trg_held_invoices_updated_at
  BEFORE UPDATE ON public.held_invoices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ############################################################
-- 5. favorites
-- ############################################################

CREATE TABLE IF NOT EXISTS public.favorites (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  org_id TEXT
);

-- Unique constraint: one favorite per product per store
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_store_product_unique
  ON public.favorites (store_id, product_id);

CREATE INDEX IF NOT EXISTS idx_favorites_store_id   ON public.favorites (store_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON public.favorites (product_id);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.favorites;
CREATE POLICY "store_member_access" ON public.favorites
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_favorites_updated_at ON public.favorites;
CREATE TRIGGER trg_favorites_updated_at
  BEFORE UPDATE ON public.favorites
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ############################################################
-- 6. whatsapp_messages
-- ############################################################

CREATE TABLE IF NOT EXISTS public.whatsapp_messages (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  phone TEXT NOT NULL,
  customer_name TEXT,
  customer_id TEXT,
  message_type TEXT NOT NULL,               -- text, image, document, video, audio, location, contact
  text_content TEXT,
  media_url TEXT,
  media_local_path TEXT,
  file_name TEXT,
  template_id TEXT,
  reference_type TEXT,                      -- sale, order, debt_reminder, promotion, return, welcome
  reference_id TEXT,
  status TEXT DEFAULT 'pending',            -- pending, uploading, sending, sent, delivered, read, failed
  external_msg_id TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  last_error TEXT,
  priority INTEGER DEFAULT 2,              -- 1=low, 2=normal, 3=high
  batch_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  sent_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  last_attempt_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_wa_msg_status     ON public.whatsapp_messages (status);
CREATE INDEX IF NOT EXISTS idx_wa_msg_phone      ON public.whatsapp_messages (phone);
CREATE INDEX IF NOT EXISTS idx_wa_msg_type       ON public.whatsapp_messages (message_type);
CREATE INDEX IF NOT EXISTS idx_wa_msg_created_at ON public.whatsapp_messages (created_at);
CREATE INDEX IF NOT EXISTS idx_wa_msg_reference  ON public.whatsapp_messages (reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_wa_msg_batch      ON public.whatsapp_messages (batch_id);
CREATE INDEX IF NOT EXISTS idx_wa_msg_external   ON public.whatsapp_messages (external_msg_id);

ALTER TABLE public.whatsapp_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_member_access" ON public.whatsapp_messages;
CREATE POLICY "store_member_access" ON public.whatsapp_messages
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));

-- ############################################################
-- Realtime publication (safe idempotent add)
-- ############################################################

DO $$
DECLARE
  tbl TEXT;
  tables TEXT[] := ARRAY[
    'inventory_movements', 'accounts', 'transactions',
    'held_invoices', 'favorites', 'whatsapp_messages'
  ];
BEGIN
  FOREACH tbl IN ARRAY tables
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime' AND tablename = tbl
    ) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', tbl);
    END IF;
  END LOOP;
END;
$$;
