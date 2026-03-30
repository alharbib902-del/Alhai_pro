-- ================================================================
-- Alhai POS - إصلاح التوافق بين Drift (IndexedDB) و Supabase
-- ================================================================
-- نفّذ هذا الملف في Supabase SQL Editor
-- الإصدار: 1.0.0
-- التاريخ: 2026-03-04
-- ================================================================

-- ############################################################
-- الجزء 0: حذف كل سياسات RLS من الجداول المتأثرة (تلقائي)
-- ############################################################

DO $$
DECLARE
  pol RECORD;
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'orders', 'order_items', 'shifts', 'loyalty_points',
    'notifications', 'suppliers', 'promotions'
  ])
  LOOP
    FOR pol IN
      SELECT policyname FROM pg_policies WHERE tablename = tbl AND schemaname = 'public'
    LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, tbl);
    END LOOP;
  END LOOP;
END $$;

-- === drop unique indexes that depend on column types ===
DROP INDEX IF EXISTS idx_shifts_cashier_open;
DROP INDEX IF EXISTS idx_promotions_store_code;

-- ############################################################
-- الجزء 1: إصلاح أنواع ENUM → TEXT
-- ############################################################

-- 1.1 orders.status: order_status ENUM → TEXT
ALTER TABLE orders ALTER COLUMN status DROP DEFAULT;
ALTER TABLE orders ALTER COLUMN status TYPE TEXT USING status::TEXT;
ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'created';

-- 1.2 orders.payment_method: payment_method ENUM → TEXT
ALTER TABLE orders ALTER COLUMN payment_method TYPE TEXT USING payment_method::TEXT;

-- 1.3 shifts.status: shift_status ENUM → TEXT
ALTER TABLE shifts ALTER COLUMN status DROP DEFAULT;
ALTER TABLE shifts ALTER COLUMN status TYPE TEXT USING status::TEXT;
ALTER TABLE shifts ALTER COLUMN status SET DEFAULT 'open';

-- ############################################################
-- الجزء 2: إصلاح المراجع الخارجية (FK) وأنواع الأعمدة
-- ############################################################

-- orders.customer_id: UUID → TEXT
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_customer_id_fkey;
ALTER TABLE orders ALTER COLUMN customer_id TYPE TEXT USING customer_id::TEXT;

-- orders.address_id: لا وجود له في Drift
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_address_id_fkey;

-- order_items.order_id: UUID → TEXT
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_order_id_fkey;
ALTER TABLE order_items ALTER COLUMN order_id TYPE TEXT USING order_id::TEXT;

-- order_items: drop unique constraint
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_unique_product_per_order;

-- shifts.cashier_id: UUID → TEXT
ALTER TABLE shifts DROP CONSTRAINT IF EXISTS shifts_cashier_id_fkey;
ALTER TABLE shifts ALTER COLUMN cashier_id TYPE TEXT USING cashier_id::TEXT;

-- loyalty_points.customer_id: UUID → TEXT
ALTER TABLE loyalty_points DROP CONSTRAINT IF EXISTS loyalty_points_customer_id_fkey;
ALTER TABLE loyalty_points ALTER COLUMN customer_id TYPE TEXT USING customer_id::TEXT;

-- notifications.user_id: UUID → TEXT
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE notifications ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

-- suppliers.id: UUID → TEXT
-- Drop FK from debts if table exists
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'debts' AND table_schema = 'public') THEN
    EXECUTE 'ALTER TABLE debts DROP CONSTRAINT IF EXISTS debts_supplier_id_fkey';
  END IF;
END $$;
ALTER TABLE suppliers ALTER COLUMN id TYPE TEXT USING id::TEXT;

-- promotions.type: promo_type ENUM → TEXT
ALTER TABLE promotions ALTER COLUMN type TYPE TEXT USING type::TEXT;

-- ############################################################
-- الجزء 2.5: إعادة إنشاء سياسات RLS بعد تغيير الأنواع
-- ############################################################

-- === orders: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON orders
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === order_items: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON order_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === shifts: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON shifts
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === loyalty_points: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON loyalty_points
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === notifications: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON notifications
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === suppliers: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON suppliers
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- === promotions: سياسة مبسطة للوصول الكامل ===
CREATE POLICY "Allow authenticated full access" ON promotions
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ############################################################
-- الجزء 3: إضافة الأعمدة الناقصة للجداول الموجودة
-- ############################################################

-- ==================== 3.1 orders ====================
ALTER TABLE orders ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS channel TEXT DEFAULT 'app';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_type TEXT DEFAULT 'delivery';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_lat DOUBLE PRECISION;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_lng DOUBLE PRECISION;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS driver_id TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_date TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS preparing_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS ready_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivering_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.2 order_items ====================
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_name_en TEXT;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS barcode TEXT;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS discount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS tax_rate DOUBLE PRECISION DEFAULT 15;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS tax_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS is_reserved BOOLEAN DEFAULT false;
-- Fix quantity from INT to DOUBLE PRECISION (Drift uses REAL)
ALTER TABLE order_items ALTER COLUMN quantity TYPE DOUBLE PRECISION USING quantity::DOUBLE PRECISION;

-- ==================== 3.3 shifts ====================
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS terminal_id TEXT;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS cashier_name TEXT DEFAULT '';
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS difference DOUBLE PRECISION;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_sales INT DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_sales_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_refunds INT DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_refunds_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
-- Copy old cash_difference data to new difference column (if it exists)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shifts' AND column_name = 'cash_difference' AND table_schema = 'public') THEN
    EXECUTE 'UPDATE shifts SET difference = COALESCE(difference, cash_difference)';
  END IF;
END $$;

-- ==================== 3.4 suppliers ====================
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_number TEXT;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS payment_terms TEXT;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS rating INT DEFAULT 0;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS balance DOUBLE PRECISION DEFAULT 0;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.5 loyalty_points ====================
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS current_points INT DEFAULT 0;
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS total_earned INT DEFAULT 0;
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS total_redeemed INT DEFAULT 0;
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS tier_level TEXT DEFAULT 'bronze';
ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
-- Copy old column data to new columns (if they exist)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'loyalty_points' AND column_name = 'points' AND table_schema = 'public') THEN
    EXECUTE 'UPDATE loyalty_points SET current_points = COALESCE(current_points, points), total_earned = COALESCE(total_earned, points_earned), total_redeemed = COALESCE(total_redeemed, points_redeemed)';
  END IF;
END $$;

-- ==================== 3.6 notifications ====================
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS store_id TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS action_url TEXT;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;

-- ==================== 3.7 promotions ====================
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS name_en TEXT;
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS rules JSONB DEFAULT '{}';
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.8 categories ====================
ALTER TABLE categories ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.9 products ====================
ALTER TABLE products ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.10 stores ====================
ALTER TABLE stores ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==================== 3.11 users ====================
ALTER TABLE users ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS store_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS pin TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_uid TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
-- Copy image_url to avatar (if it exists)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'image_url' AND table_schema = 'public') THEN
    EXECUTE 'UPDATE users SET avatar = COALESCE(avatar, image_url)';
  END IF;
END $$;

-- ############################################################
-- الجزء 4: إنشاء الجداول المفقودة (22 جدول)
-- ############################################################

-- 4.1 organizations
CREATE TABLE IF NOT EXISTS organizations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_en TEXT,
  slug TEXT,
  logo TEXT,
  owner_id TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  country TEXT DEFAULT 'SA',
  tax_number TEXT,
  commercial_reg TEXT,
  currency TEXT DEFAULT 'SAR',
  timezone TEXT DEFAULT 'Asia/Riyadh',
  locale TEXT DEFAULT 'ar',
  plan TEXT DEFAULT 'free',
  max_stores INT DEFAULT 1,
  max_users INT DEFAULT 3,
  max_products INT DEFAULT 100,
  is_active BOOLEAN DEFAULT true,
  trial_ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.2 subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  plan TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  amount DOUBLE PRECISION DEFAULT 0,
  currency TEXT DEFAULT 'SAR',
  billing_cycle TEXT DEFAULT 'monthly',
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT false,
  payment_method TEXT,
  external_subscription_id TEXT,
  features JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.3 org_members
CREATE TABLE IF NOT EXISTS org_members (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role TEXT DEFAULT 'staff',
  is_active BOOLEAN DEFAULT true,
  invited_by TEXT,
  invited_at TIMESTAMPTZ,
  joined_at TIMESTAMPTZ,
  store_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- 4.4 user_stores
CREATE TABLE IF NOT EXISTS user_stores (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  role TEXT DEFAULT 'cashier',
  is_primary BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- 4.5 roles
CREATE TABLE IF NOT EXISTS roles (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  name_en TEXT,
  permissions JSONB DEFAULT '{}',
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.6 discounts
CREATE TABLE IF NOT EXISTS discounts (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  name_en TEXT,
  type TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  min_purchase DOUBLE PRECISION DEFAULT 0,
  max_discount DOUBLE PRECISION,
  applies_to TEXT DEFAULT 'all',
  product_ids JSONB,
  category_ids JSONB,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- 4.7 coupons
CREATE TABLE IF NOT EXISTS coupons (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  code TEXT NOT NULL,
  discount_id TEXT,
  type TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  max_uses INT DEFAULT 0,
  current_uses INT DEFAULT 0,
  min_purchase DOUBLE PRECISION DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- 4.8 expenses
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  category_id TEXT,
  amount DOUBLE PRECISION NOT NULL,
  description TEXT,
  payment_method TEXT DEFAULT 'cash',
  receipt_image TEXT,
  created_by TEXT,
  expense_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- 4.9 expense_categories
CREATE TABLE IF NOT EXISTS expense_categories (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  name_en TEXT,
  icon TEXT,
  color TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

-- 4.10 purchases
CREATE TABLE IF NOT EXISTS purchases (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  supplier_id TEXT,
  supplier_name TEXT,
  purchase_number TEXT NOT NULL,
  status TEXT DEFAULT 'draft',
  subtotal DOUBLE PRECISION DEFAULT 0,
  tax DOUBLE PRECISION DEFAULT 0,
  discount DOUBLE PRECISION DEFAULT 0,
  total DOUBLE PRECISION DEFAULT 0,
  payment_status TEXT DEFAULT 'pending',
  payment_method TEXT,
  notes TEXT,
  received_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- 4.11 purchase_items
CREATE TABLE IF NOT EXISTS purchase_items (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  purchase_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_barcode TEXT,
  qty DOUBLE PRECISION NOT NULL,
  received_qty DOUBLE PRECISION DEFAULT 0,
  unit_cost DOUBLE PRECISION NOT NULL,
  total DOUBLE PRECISION NOT NULL
);

-- 4.12 drivers
CREATE TABLE IF NOT EXISTS drivers (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  vehicle_type TEXT,
  vehicle_plate TEXT,
  status TEXT DEFAULT 'available',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.13 loyalty_transactions
CREATE TABLE IF NOT EXISTS loyalty_transactions (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  loyalty_id TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  transaction_type TEXT NOT NULL,
  points INT NOT NULL,
  balance_after INT NOT NULL,
  sale_id TEXT,
  sale_amount DOUBLE PRECISION,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  cashier_id TEXT,
  synced_at TIMESTAMPTZ
);

-- 4.14 loyalty_rewards
CREATE TABLE IF NOT EXISTS loyalty_rewards (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  points_required INT NOT NULL,
  reward_type TEXT NOT NULL,
  reward_value DOUBLE PRECISION NOT NULL,
  min_purchase DOUBLE PRECISION DEFAULT 0,
  required_tier TEXT DEFAULT 'all',
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

-- 4.15 customer_addresses
CREATE TABLE IF NOT EXISTS customer_addresses (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  customer_id TEXT NOT NULL,
  label TEXT DEFAULT 'home',
  address TEXT NOT NULL,
  city TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4.16 order_status_history
CREATE TABLE IF NOT EXISTS order_status_history (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL,
  from_status TEXT,
  to_status TEXT NOT NULL,
  changed_by TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4.17 pos_terminals
CREATE TABLE IF NOT EXISTS pos_terminals (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  org_id TEXT NOT NULL,
  name TEXT NOT NULL,
  terminal_number INT DEFAULT 1,
  device_id TEXT,
  device_name TEXT,
  device_model TEXT,
  os_version TEXT,
  app_version TEXT,
  status TEXT DEFAULT 'active',
  current_shift_id TEXT,
  current_user_id TEXT,
  last_heartbeat_at TIMESTAMPTZ,
  last_sync_at TIMESTAMPTZ,
  settings JSONB DEFAULT '{}',
  receipt_header TEXT,
  receipt_footer TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.18 product_expiry
CREATE TABLE IF NOT EXISTS product_expiry (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  batch_number TEXT,
  expiry_date TIMESTAMPTZ NOT NULL,
  quantity INT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

-- 4.19 stock_takes
CREATE TABLE IF NOT EXISTS stock_takes (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  status TEXT DEFAULT 'in_progress',
  items JSONB DEFAULT '[]',
  total_items INT DEFAULT 0,
  counted_items INT DEFAULT 0,
  variance_items INT DEFAULT 0,
  notes TEXT,
  created_by TEXT,
  started_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.20 stock_transfers
CREATE TABLE IF NOT EXISTS stock_transfers (
  id TEXT PRIMARY KEY,
  transfer_number TEXT NOT NULL,
  from_store_id TEXT NOT NULL,
  to_store_id TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  items JSONB NOT NULL,
  notes TEXT,
  created_by TEXT,
  approved_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  approved_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- 4.21 stock_deltas
CREATE TABLE IF NOT EXISTS stock_deltas (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  org_id TEXT,
  quantity_change DOUBLE PRECISION NOT NULL,
  device_id TEXT NOT NULL,
  operation_type TEXT NOT NULL,
  reference_id TEXT,
  sync_status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);

-- 4.22 whatsapp_templates
CREATE TABLE IF NOT EXISTS whatsapp_templates (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  language TEXT DEFAULT 'ar',
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  media_type TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- 4.23 settings (key-value store - different from store_settings)
CREATE TABLE IF NOT EXISTS settings (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ############################################################
-- الجزء 5: تفعيل RLS وإنشاء السياسات للجداول الجديدة
-- ############################################################

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'organizations', 'subscriptions', 'org_members', 'user_stores',
    'roles', 'discounts', 'coupons', 'expenses', 'expense_categories',
    'purchases', 'purchase_items', 'drivers', 'loyalty_transactions',
    'loyalty_rewards', 'customer_addresses', 'order_status_history',
    'pos_terminals', 'product_expiry', 'stock_takes', 'stock_transfers',
    'stock_deltas', 'whatsapp_templates', 'settings'
  ])
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Allow authenticated full access" ON %I', tbl);
    EXECUTE format(
      'CREATE POLICY "Allow authenticated full access" ON %I FOR ALL TO authenticated USING (true) WITH CHECK (true)',
      tbl
    );
  END LOOP;
END $$;

-- ############################################################
-- الجزء 6: إنشاء فهارس للجداول الجديدة
-- ############################################################

-- organizations
CREATE INDEX IF NOT EXISTS idx_organizations_owner ON organizations (owner_id);

-- roles
CREATE INDEX IF NOT EXISTS idx_roles_store ON roles (store_id);

-- discounts
CREATE INDEX IF NOT EXISTS idx_discounts_store ON discounts (store_id, is_active);

-- coupons
CREATE INDEX IF NOT EXISTS idx_coupons_store ON coupons (store_id, is_active);
CREATE UNIQUE INDEX IF NOT EXISTS idx_coupons_code ON coupons (store_id, code);

-- expenses
CREATE INDEX IF NOT EXISTS idx_expenses_store ON expenses (store_id, expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses (category_id);

-- expense_categories
CREATE INDEX IF NOT EXISTS idx_expense_categories_store ON expense_categories (store_id);

-- purchases
CREATE INDEX IF NOT EXISTS idx_purchases_store ON purchases (store_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_purchases_supplier ON purchases (supplier_id);

-- purchase_items
CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase ON purchase_items (purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product ON purchase_items (product_id);

-- drivers
CREATE INDEX IF NOT EXISTS idx_drivers_store ON drivers (store_id, is_active);

-- loyalty_transactions
CREATE INDEX IF NOT EXISTS idx_loyalty_trans_customer ON loyalty_transactions (customer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_loyalty_trans_store ON loyalty_transactions (store_id);

-- loyalty_rewards
CREATE INDEX IF NOT EXISTS idx_loyalty_rewards_store ON loyalty_rewards (store_id, is_active);

-- customer_addresses
CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer ON customer_addresses (customer_id);

-- order_status_history
CREATE INDEX IF NOT EXISTS idx_order_status_history_order ON order_status_history (order_id, created_at DESC);

-- pos_terminals
CREATE INDEX IF NOT EXISTS idx_pos_terminals_store ON pos_terminals (store_id);

-- product_expiry
CREATE INDEX IF NOT EXISTS idx_product_expiry_product ON product_expiry (product_id);
CREATE INDEX IF NOT EXISTS idx_product_expiry_store ON product_expiry (store_id);
CREATE INDEX IF NOT EXISTS idx_product_expiry_date ON product_expiry (expiry_date);

-- stock_takes
CREATE INDEX IF NOT EXISTS idx_stock_takes_store ON stock_takes (store_id);

-- stock_transfers
CREATE INDEX IF NOT EXISTS idx_stock_transfers_from ON stock_transfers (from_store_id);
CREATE INDEX IF NOT EXISTS idx_stock_transfers_to ON stock_transfers (to_store_id);

-- stock_deltas
CREATE INDEX IF NOT EXISTS idx_stock_deltas_product ON stock_deltas (product_id);
CREATE INDEX IF NOT EXISTS idx_stock_deltas_store ON stock_deltas (store_id);
CREATE INDEX IF NOT EXISTS idx_stock_deltas_status ON stock_deltas (sync_status);

-- whatsapp_templates
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_store ON whatsapp_templates (store_id);

-- settings
CREATE INDEX IF NOT EXISTS idx_settings_store ON settings (store_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_store_key ON settings (store_id, key);

-- ############################################################
-- تم! ✅
-- ############################################################
