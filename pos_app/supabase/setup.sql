-- ============================================================================
-- ALHAI POS - Supabase Database Setup
-- ============================================================================
-- تشغيل هذا الملف في Supabase SQL Editor
-- يتضمن: الجداول، الفهارس، RLS، الدوال، التخزين
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 2. CUSTOM TYPES (ENUMS)
-- ============================================================================
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('owner', 'manager', 'cashier', 'driver', 'viewer');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE shift_status AS ENUM ('open', 'closed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE sync_status AS ENUM ('pending', 'syncing', 'synced', 'failed', 'conflict');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- 3. TABLES
-- ============================================================================

-- --------------------------------------------------------------------------
-- 3.1 المتاجر/الفروع (stores)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stores (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  name TEXT NOT NULL,
  name_en TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  logo TEXT,
  tax_number TEXT,
  commercial_reg TEXT,
  currency TEXT NOT NULL DEFAULT 'SAR',
  timezone TEXT NOT NULL DEFAULT 'Asia/Riyadh',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stores_owner_id ON stores(owner_id);
CREATE INDEX IF NOT EXISTS idx_stores_is_active ON stores(is_active);

-- --------------------------------------------------------------------------
-- 3.2 المستخدمين (users)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_users (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  auth_id UUID REFERENCES auth.users(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  pin TEXT,
  role TEXT NOT NULL DEFAULT 'cashier',
  avatar TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_app_users_store_id ON app_users(store_id);
CREATE INDEX IF NOT EXISTS idx_app_users_phone ON app_users(phone);
CREATE INDEX IF NOT EXISTS idx_app_users_auth_id ON app_users(auth_id);
CREATE INDEX IF NOT EXISTS idx_app_users_is_active ON app_users(is_active);

-- --------------------------------------------------------------------------
-- 3.3 الأدوار والصلاحيات (roles)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  permissions JSONB NOT NULL DEFAULT '{}',
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_roles_store_id ON roles(store_id);

-- --------------------------------------------------------------------------
-- 3.4 التصنيفات (categories)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  parent_id TEXT REFERENCES categories(id),
  image_url TEXT,
  color TEXT,
  icon TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_categories_store_id ON categories(store_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_sort_order ON categories(sort_order);

-- --------------------------------------------------------------------------
-- 3.5 المنتجات (products)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku TEXT,
  barcode TEXT,
  price DOUBLE PRECISION NOT NULL,
  cost_price DOUBLE PRECISION,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  min_qty INTEGER NOT NULL DEFAULT 1,
  unit TEXT,
  description TEXT,
  image_thumbnail TEXT,
  image_medium TEXT,
  image_large TEXT,
  image_hash TEXT,
  category_id TEXT REFERENCES categories(id),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  track_inventory BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_products_store_id ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);

-- --------------------------------------------------------------------------
-- 3.6 العملاء (customers)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  tax_number TEXT,
  type TEXT NOT NULL DEFAULT 'individual',
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_customers_store_id ON customers(store_id);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_is_active ON customers(is_active);

-- --------------------------------------------------------------------------
-- 3.7 عناوين العملاء (customer_addresses)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_addresses (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  customer_id TEXT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  label TEXT NOT NULL DEFAULT 'home',
  address TEXT NOT NULL,
  city TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer_id ON customer_addresses(customer_id);

-- --------------------------------------------------------------------------
-- 3.8 الموردين (suppliers)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS suppliers (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  tax_number TEXT,
  payment_terms TEXT,
  rating INTEGER NOT NULL DEFAULT 0,
  balance DOUBLE PRECISION NOT NULL DEFAULT 0,
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_suppliers_store_id ON suppliers(store_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_phone ON suppliers(phone);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);

-- --------------------------------------------------------------------------
-- 3.9 المبيعات/الفواتير (sales)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sales (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  receipt_no TEXT NOT NULL,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  cashier_id TEXT NOT NULL,
  customer_id TEXT REFERENCES customers(id),
  customer_name TEXT,
  customer_phone TEXT,
  subtotal DOUBLE PRECISION NOT NULL,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  tax DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL,
  payment_method TEXT NOT NULL,
  is_paid BOOLEAN NOT NULL DEFAULT TRUE,
  amount_received DOUBLE PRECISION,
  change_amount DOUBLE PRECISION,
  notes TEXT,
  channel TEXT NOT NULL DEFAULT 'POS',
  status TEXT NOT NULL DEFAULT 'completed',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_cashier_id ON sales(cashier_id);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sales_store_created ON sales(store_id, created_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_receipt_no ON sales(store_id, receipt_no);

-- --------------------------------------------------------------------------
-- 3.10 عناصر البيع (sale_items)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sale_items (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_sku TEXT,
  product_barcode TEXT,
  qty INTEGER NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  cost_price DOUBLE PRECISION,
  subtotal DOUBLE PRECISION NOT NULL,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL,
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);

-- --------------------------------------------------------------------------
-- 3.11 الطلبات (orders)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  customer_id TEXT REFERENCES customers(id),
  order_number TEXT NOT NULL,
  channel TEXT NOT NULL DEFAULT 'app',
  status TEXT NOT NULL DEFAULT 'pending',
  subtotal DOUBLE PRECISION NOT NULL DEFAULT 0,
  tax_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  delivery_fee DOUBLE PRECISION NOT NULL DEFAULT 0,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL DEFAULT 0,
  payment_method TEXT,
  payment_status TEXT NOT NULL DEFAULT 'pending',
  delivery_type TEXT NOT NULL DEFAULT 'delivery',
  delivery_address TEXT,
  delivery_lat DOUBLE PRECISION,
  delivery_lng DOUBLE PRECISION,
  driver_id TEXT,
  notes TEXT,
  cancel_reason TEXT,
  order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ,
  preparing_at TIMESTAMPTZ,
  ready_at TIMESTAMPTZ,
  delivering_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_orders_store_id ON orders(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_store_status ON orders(store_id, status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_order_number ON orders(store_id, order_number);

-- --------------------------------------------------------------------------
-- 3.12 عناصر الطلب (order_items)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_name_en TEXT,
  barcode TEXT,
  quantity DOUBLE PRECISION NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  tax_rate DOUBLE PRECISION NOT NULL DEFAULT 15,
  tax_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL,
  notes TEXT,
  is_reserved BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- --------------------------------------------------------------------------
-- 3.13 حركات المخزون (inventory_movements)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_movements (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  product_id TEXT NOT NULL REFERENCES products(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- sale, purchase, adjustment, return, transfer, waste
  qty INTEGER NOT NULL,
  previous_qty INTEGER NOT NULL,
  new_qty INTEGER NOT NULL,
  reference_type TEXT,
  reference_id TEXT,
  reason TEXT,
  notes TEXT,
  user_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_store_id ON inventory_movements(store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_created_at ON inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_type ON inventory_movements(type);
CREATE INDEX IF NOT EXISTS idx_inventory_reference ON inventory_movements(reference_type, reference_id);

-- --------------------------------------------------------------------------
-- 3.14 الحسابات (accounts)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- receivable, payable
  customer_id TEXT REFERENCES customers(id),
  supplier_id TEXT REFERENCES suppliers(id),
  name TEXT NOT NULL,
  phone TEXT,
  balance DOUBLE PRECISION NOT NULL DEFAULT 0,
  credit_limit DOUBLE PRECISION NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_transaction_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_accounts_store_id ON accounts(store_id);
CREATE INDEX IF NOT EXISTS idx_accounts_type ON accounts(type);
CREATE INDEX IF NOT EXISTS idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX IF NOT EXISTS idx_accounts_supplier_id ON accounts(supplier_id);

-- --------------------------------------------------------------------------
-- 3.15 حركات الحسابات (transactions)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  account_id TEXT NOT NULL REFERENCES accounts(id),
  type TEXT NOT NULL, -- invoice, payment, interest, adjustment
  amount DOUBLE PRECISION NOT NULL,
  balance_after DOUBLE PRECISION NOT NULL,
  description TEXT,
  reference_id TEXT,
  reference_type TEXT,
  period_key TEXT, -- YYYY-MM
  payment_method TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_transactions_store_id ON transactions(store_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);

-- --------------------------------------------------------------------------
-- 3.16 الورديات (shifts)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS shifts (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  cashier_id TEXT NOT NULL,
  cashier_name TEXT NOT NULL,
  opening_cash DOUBLE PRECISION NOT NULL DEFAULT 0,
  closing_cash DOUBLE PRECISION,
  expected_cash DOUBLE PRECISION,
  difference DOUBLE PRECISION,
  total_sales INTEGER NOT NULL DEFAULT 0,
  total_sales_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_refunds INTEGER NOT NULL DEFAULT 0,
  total_refunds_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'open',
  notes TEXT,
  opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_shifts_store_id ON shifts(store_id);
CREATE INDEX IF NOT EXISTS idx_shifts_cashier_id ON shifts(cashier_id);
CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts(status);
CREATE INDEX IF NOT EXISTS idx_shifts_opened_at ON shifts(opened_at);

-- --------------------------------------------------------------------------
-- 3.17 حركات الصندوق (cash_movements)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cash_movements (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  shift_id TEXT NOT NULL REFERENCES shifts(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- in, out
  amount DOUBLE PRECISION NOT NULL,
  reason TEXT,
  reference TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_cash_movements_shift_id ON cash_movements(shift_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_store_id ON cash_movements(store_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_created_at ON cash_movements(created_at);

-- --------------------------------------------------------------------------
-- 3.18 المرتجعات (returns)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS returns (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  return_number TEXT NOT NULL,
  sale_id TEXT NOT NULL REFERENCES sales(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  customer_id TEXT REFERENCES customers(id),
  customer_name TEXT,
  reason TEXT,
  type TEXT NOT NULL DEFAULT 'full',
  refund_method TEXT NOT NULL DEFAULT 'cash',
  total_refund DOUBLE PRECISION NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  created_by TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_returns_store_id ON returns(store_id);
CREATE INDEX IF NOT EXISTS idx_returns_sale_id ON returns(sale_id);
CREATE INDEX IF NOT EXISTS idx_returns_status ON returns(status);
CREATE INDEX IF NOT EXISTS idx_returns_created_at ON returns(created_at);

-- --------------------------------------------------------------------------
-- 3.19 عناصر المرتجعات (return_items)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS return_items (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  return_id TEXT NOT NULL REFERENCES returns(id) ON DELETE CASCADE,
  sale_item_id TEXT,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  qty INTEGER NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  refund_amount DOUBLE PRECISION NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_return_items_return_id ON return_items(return_id);
CREATE INDEX IF NOT EXISTS idx_return_items_product_id ON return_items(product_id);

-- --------------------------------------------------------------------------
-- 3.20 المصروفات (expenses)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id TEXT,
  amount DOUBLE PRECISION NOT NULL,
  description TEXT,
  payment_method TEXT NOT NULL DEFAULT 'cash',
  receipt_image TEXT,
  created_by TEXT,
  expense_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_expenses_store_id ON expenses(store_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at);

-- --------------------------------------------------------------------------
-- 3.21 فئات المصروفات (expense_categories)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expense_categories (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  icon TEXT,
  color TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_expense_categories_store_id ON expense_categories(store_id);

-- --------------------------------------------------------------------------
-- 3.22 أوامر الشراء (purchases)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchases (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  supplier_id TEXT REFERENCES suppliers(id),
  supplier_name TEXT,
  purchase_number TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  subtotal DOUBLE PRECISION NOT NULL DEFAULT 0,
  tax DOUBLE PRECISION NOT NULL DEFAULT 0,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL DEFAULT 0,
  payment_status TEXT NOT NULL DEFAULT 'pending',
  payment_method TEXT,
  notes TEXT,
  received_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_purchases_store_id ON purchases(store_id);
CREATE INDEX IF NOT EXISTS idx_purchases_supplier_id ON purchases(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON purchases(status);
CREATE INDEX IF NOT EXISTS idx_purchases_created_at ON purchases(created_at);

-- --------------------------------------------------------------------------
-- 3.23 عناصر الشراء (purchase_items)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchase_items (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  purchase_id TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_barcode TEXT,
  qty INTEGER NOT NULL,
  received_qty INTEGER NOT NULL DEFAULT 0,
  unit_cost DOUBLE PRECISION NOT NULL,
  total DOUBLE PRECISION NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase_id ON purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product_id ON purchase_items(product_id);

-- --------------------------------------------------------------------------
-- 3.24 الخصومات (discounts)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS discounts (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  type TEXT NOT NULL, -- percentage, fixed
  value DOUBLE PRECISION NOT NULL,
  min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0,
  max_discount DOUBLE PRECISION,
  applies_to TEXT NOT NULL DEFAULT 'all',
  product_ids JSONB, -- JSON array
  category_ids JSONB, -- JSON array
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_discounts_store_id ON discounts(store_id);
CREATE INDEX IF NOT EXISTS idx_discounts_is_active ON discounts(is_active);

-- --------------------------------------------------------------------------
-- 3.25 الكوبونات (coupons)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coupons (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  discount_id TEXT REFERENCES discounts(id),
  type TEXT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  max_uses INTEGER NOT NULL DEFAULT 0,
  current_uses INTEGER NOT NULL DEFAULT 0,
  min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_coupons_store_id ON coupons(store_id);
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON coupons(is_active);
CREATE UNIQUE INDEX IF NOT EXISTS idx_coupons_store_code ON coupons(store_id, code);

-- --------------------------------------------------------------------------
-- 3.26 العروض الترويجية (promotions)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS promotions (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  description TEXT,
  type TEXT NOT NULL, -- buy_x_get_y, bundle, flash_sale
  rules JSONB NOT NULL DEFAULT '{}',
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_promotions_store_id ON promotions(store_id);
CREATE INDEX IF NOT EXISTS idx_promotions_is_active ON promotions(is_active);

-- --------------------------------------------------------------------------
-- 3.27 الفواتير المعلقة (held_invoices)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS held_invoices (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  cashier_id TEXT NOT NULL,
  customer_name TEXT,
  customer_phone TEXT,
  items JSONB NOT NULL,
  subtotal DOUBLE PRECISION NOT NULL DEFAULT 0,
  discount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total DOUBLE PRECISION NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_held_invoices_store_id ON held_invoices(store_id);
CREATE INDEX IF NOT EXISTS idx_held_invoices_cashier_id ON held_invoices(cashier_id);

-- --------------------------------------------------------------------------
-- 3.28 الإشعارات (notifications)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  user_id TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'info',
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  data JSONB,
  action_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_notifications_store_id ON notifications(store_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- --------------------------------------------------------------------------
-- 3.29 تحويلات المخزون (stock_transfers)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stock_transfers (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  transfer_number TEXT NOT NULL,
  from_store_id TEXT NOT NULL REFERENCES stores(id),
  to_store_id TEXT NOT NULL REFERENCES stores(id),
  status TEXT NOT NULL DEFAULT 'pending',
  items JSONB NOT NULL,
  notes TEXT,
  created_by TEXT,
  approved_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stock_transfers_from_store ON stock_transfers(from_store_id);
CREATE INDEX IF NOT EXISTS idx_stock_transfers_to_store ON stock_transfers(to_store_id);
CREATE INDEX IF NOT EXISTS idx_stock_transfers_status ON stock_transfers(status);

-- --------------------------------------------------------------------------
-- 3.30 الإعدادات (settings)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_store_key ON settings(store_id, key);

-- --------------------------------------------------------------------------
-- 3.31 عمليات الجرد (stock_takes)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stock_takes (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'in_progress',
  items JSONB NOT NULL DEFAULT '[]',
  total_items INTEGER NOT NULL DEFAULT 0,
  counted_items INTEGER NOT NULL DEFAULT 0,
  variance_items INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_by TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stock_takes_store_id ON stock_takes(store_id);
CREATE INDEX IF NOT EXISTS idx_stock_takes_status ON stock_takes(status);

-- --------------------------------------------------------------------------
-- 3.32 صلاحية المنتجات (product_expiry)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_expiry (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  product_id TEXT NOT NULL REFERENCES products(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  batch_number TEXT,
  expiry_date TIMESTAMPTZ NOT NULL,
  quantity INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_product_expiry_product_id ON product_expiry(product_id);
CREATE INDEX IF NOT EXISTS idx_product_expiry_store_id ON product_expiry(store_id);
CREATE INDEX IF NOT EXISTS idx_product_expiry_expiry_date ON product_expiry(expiry_date);

-- --------------------------------------------------------------------------
-- 3.33 السائقين (drivers)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS drivers (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  vehicle_type TEXT,
  vehicle_plate TEXT,
  status TEXT NOT NULL DEFAULT 'available',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_drivers_store_id ON drivers(store_id);
CREATE INDEX IF NOT EXISTS idx_drivers_is_active ON drivers(is_active);

-- --------------------------------------------------------------------------
-- 3.34 الملخصات اليومية (daily_summaries)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS daily_summaries (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  date TIMESTAMPTZ NOT NULL,
  total_sales INTEGER NOT NULL DEFAULT 0,
  total_sales_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_orders INTEGER NOT NULL DEFAULT 0,
  total_orders_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_refunds INTEGER NOT NULL DEFAULT 0,
  total_refunds_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
  total_expenses DOUBLE PRECISION NOT NULL DEFAULT 0,
  cash_total DOUBLE PRECISION NOT NULL DEFAULT 0,
  card_total DOUBLE PRECISION NOT NULL DEFAULT 0,
  credit_total DOUBLE PRECISION NOT NULL DEFAULT 0,
  net_profit DOUBLE PRECISION NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_daily_summaries_store_id ON daily_summaries(store_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_date ON daily_summaries(date);
CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_summaries_store_date ON daily_summaries(store_id, date);

-- --------------------------------------------------------------------------
-- 3.35 سجل حالة الطلبات (order_status_history)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_status_history (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status TEXT NOT NULL,
  changed_by TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_created_at ON order_status_history(created_at);

-- --------------------------------------------------------------------------
-- 3.36 المفضلات (favorites)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS favorites (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES products(id),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_favorites_store_id ON favorites(store_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON favorites(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_store_product ON favorites(store_id, product_id);

-- --------------------------------------------------------------------------
-- 3.37 سجل التدقيق (audit_log)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  old_value JSONB,
  new_value JSONB,
  description TEXT,
  ip_address TEXT,
  device_info TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_audit_store_id ON audit_log(store_id);
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_log(entity_type, entity_id);

-- --------------------------------------------------------------------------
-- 3.38 نقاط الولاء (loyalty_points)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS loyalty_points (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  customer_id TEXT NOT NULL REFERENCES customers(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  current_points INTEGER NOT NULL DEFAULT 0,
  total_earned INTEGER NOT NULL DEFAULT 0,
  total_redeemed INTEGER NOT NULL DEFAULT 0,
  tier_level TEXT NOT NULL DEFAULT 'bronze',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_customer_id ON loyalty_points(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_store_id ON loyalty_points(store_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_loyalty_store_customer ON loyalty_points(store_id, customer_id);

-- --------------------------------------------------------------------------
-- 3.39 معاملات الولاء (loyalty_transactions)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS loyalty_transactions (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  loyalty_id TEXT NOT NULL REFERENCES loyalty_points(id),
  customer_id TEXT NOT NULL REFERENCES customers(id),
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL, -- earn, redeem, expire, adjust
  points INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  sale_id TEXT REFERENCES sales(id),
  sale_amount DOUBLE PRECISION,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  cashier_id TEXT,
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_tx_loyalty_id ON loyalty_transactions(loyalty_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_customer_id ON loyalty_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_store_id ON loyalty_transactions(store_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_created_at ON loyalty_transactions(created_at);

-- --------------------------------------------------------------------------
-- 3.40 مكافآت الولاء (loyalty_rewards)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS loyalty_rewards (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
  store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  points_required INTEGER NOT NULL,
  reward_type TEXT NOT NULL, -- discount_percentage, discount_fixed, free_item
  reward_value DOUBLE PRECISION NOT NULL,
  min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0,
  required_tier TEXT NOT NULL DEFAULT 'all',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_rewards_store_id ON loyalty_rewards(store_id);

-- ============================================================================
-- 3.5 DEFERRED FOREIGN KEYS (لتجنب مشاكل ترتيب الجداول)
-- ============================================================================

-- ربط orders.driver_id بـ drivers
ALTER TABLE orders ADD CONSTRAINT fk_orders_driver
  FOREIGN KEY (driver_id) REFERENCES drivers(id);

-- ربط expenses.category_id بـ expense_categories
ALTER TABLE expenses ADD CONSTRAINT fk_expenses_category
  FOREIGN KEY (category_id) REFERENCES expense_categories(id);

-- ============================================================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- دالة مساعدة: الحصول على store_ids التابعة للمستخدم الحالي
CREATE OR REPLACE FUNCTION get_user_store_ids()
RETURNS TEXT[] AS $$
  SELECT ARRAY_AGG(store_id)
  FROM app_users
  WHERE auth_id = auth.uid() AND is_active = TRUE;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- دالة مساعدة: التحقق من ملكية المتجر
CREATE OR REPLACE FUNCTION is_store_owner(p_store_id TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM stores
    WHERE id = p_store_id AND owner_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- دالة مساعدة: التحقق من صلاحية الوصول للمتجر
CREATE OR REPLACE FUNCTION has_store_access(p_store_id TEXT)
RETURNS BOOLEAN AS $$
  SELECT p_store_id = ANY(get_user_store_ids())
    OR is_store_owner(p_store_id);
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- تفعيل RLS على جميع الجداول
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE held_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_takes ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_expiry ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_rewards ENABLE ROW LEVEL SECURITY;

-- ===== STORES =====
CREATE POLICY stores_select ON stores FOR SELECT
  USING (owner_id = auth.uid() OR id = ANY(get_user_store_ids()));
CREATE POLICY stores_insert ON stores FOR INSERT
  WITH CHECK (owner_id = auth.uid());
CREATE POLICY stores_update ON stores FOR UPDATE
  USING (owner_id = auth.uid());
CREATE POLICY stores_delete ON stores FOR DELETE
  USING (owner_id = auth.uid());

-- ===== APP_USERS =====
CREATE POLICY app_users_select ON app_users FOR SELECT
  USING (has_store_access(store_id));
CREATE POLICY app_users_insert ON app_users FOR INSERT
  WITH CHECK (is_store_owner(store_id));
CREATE POLICY app_users_update ON app_users FOR UPDATE
  USING (is_store_owner(store_id) OR auth_id = auth.uid());
CREATE POLICY app_users_delete ON app_users FOR DELETE
  USING (is_store_owner(store_id));

-- ===== MACRO: جداول تابعة للمتجر (store_id) =====
-- نمط موحد: SELECT/INSERT/UPDATE/DELETE بناءً على has_store_access

-- ROLES
CREATE POLICY roles_select ON roles FOR SELECT USING (has_store_access(store_id));
CREATE POLICY roles_insert ON roles FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY roles_update ON roles FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY roles_delete ON roles FOR DELETE USING (is_store_owner(store_id));

-- CATEGORIES
CREATE POLICY categories_select ON categories FOR SELECT USING (has_store_access(store_id));
CREATE POLICY categories_insert ON categories FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY categories_update ON categories FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY categories_delete ON categories FOR DELETE USING (has_store_access(store_id));

-- PRODUCTS
CREATE POLICY products_select ON products FOR SELECT USING (has_store_access(store_id));
CREATE POLICY products_insert ON products FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY products_update ON products FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY products_delete ON products FOR DELETE USING (has_store_access(store_id));

-- CUSTOMERS
CREATE POLICY customers_select ON customers FOR SELECT USING (has_store_access(store_id));
CREATE POLICY customers_insert ON customers FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY customers_update ON customers FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY customers_delete ON customers FOR DELETE USING (has_store_access(store_id));

-- CUSTOMER_ADDRESSES
CREATE POLICY customer_addresses_select ON customer_addresses FOR SELECT
  USING (EXISTS(SELECT 1 FROM customers c WHERE c.id = customer_id AND has_store_access(c.store_id)));
CREATE POLICY customer_addresses_insert ON customer_addresses FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM customers c WHERE c.id = customer_id AND has_store_access(c.store_id)));
CREATE POLICY customer_addresses_update ON customer_addresses FOR UPDATE
  USING (EXISTS(SELECT 1 FROM customers c WHERE c.id = customer_id AND has_store_access(c.store_id)));
CREATE POLICY customer_addresses_delete ON customer_addresses FOR DELETE
  USING (EXISTS(SELECT 1 FROM customers c WHERE c.id = customer_id AND has_store_access(c.store_id)));

-- SUPPLIERS
CREATE POLICY suppliers_select ON suppliers FOR SELECT USING (has_store_access(store_id));
CREATE POLICY suppliers_insert ON suppliers FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY suppliers_update ON suppliers FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY suppliers_delete ON suppliers FOR DELETE USING (has_store_access(store_id));

-- SALES
CREATE POLICY sales_select ON sales FOR SELECT USING (has_store_access(store_id));
CREATE POLICY sales_insert ON sales FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY sales_update ON sales FOR UPDATE USING (has_store_access(store_id));

-- SALE_ITEMS (via sales parent)
CREATE POLICY sale_items_select ON sale_items FOR SELECT
  USING (EXISTS(SELECT 1 FROM sales s WHERE s.id = sale_id AND has_store_access(s.store_id)));
CREATE POLICY sale_items_insert ON sale_items FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM sales s WHERE s.id = sale_id AND has_store_access(s.store_id)));

-- ORDERS
CREATE POLICY orders_select ON orders FOR SELECT USING (has_store_access(store_id));
CREATE POLICY orders_insert ON orders FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY orders_update ON orders FOR UPDATE USING (has_store_access(store_id));

-- ORDER_ITEMS
CREATE POLICY order_items_select ON order_items FOR SELECT
  USING (EXISTS(SELECT 1 FROM orders o WHERE o.id = order_id AND has_store_access(o.store_id)));
CREATE POLICY order_items_insert ON order_items FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM orders o WHERE o.id = order_id AND has_store_access(o.store_id)));

-- INVENTORY_MOVEMENTS
CREATE POLICY inventory_movements_select ON inventory_movements FOR SELECT USING (has_store_access(store_id));
CREATE POLICY inventory_movements_insert ON inventory_movements FOR INSERT WITH CHECK (has_store_access(store_id));

-- ACCOUNTS
CREATE POLICY accounts_select ON accounts FOR SELECT USING (has_store_access(store_id));
CREATE POLICY accounts_insert ON accounts FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY accounts_update ON accounts FOR UPDATE USING (has_store_access(store_id));

-- TRANSACTIONS
CREATE POLICY transactions_select ON transactions FOR SELECT USING (has_store_access(store_id));
CREATE POLICY transactions_insert ON transactions FOR INSERT WITH CHECK (has_store_access(store_id));

-- SHIFTS
CREATE POLICY shifts_select ON shifts FOR SELECT USING (has_store_access(store_id));
CREATE POLICY shifts_insert ON shifts FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY shifts_update ON shifts FOR UPDATE USING (has_store_access(store_id));

-- CASH_MOVEMENTS
CREATE POLICY cash_movements_select ON cash_movements FOR SELECT USING (has_store_access(store_id));
CREATE POLICY cash_movements_insert ON cash_movements FOR INSERT WITH CHECK (has_store_access(store_id));

-- RETURNS
CREATE POLICY returns_select ON returns FOR SELECT USING (has_store_access(store_id));
CREATE POLICY returns_insert ON returns FOR INSERT WITH CHECK (has_store_access(store_id));

-- RETURN_ITEMS
CREATE POLICY return_items_select ON return_items FOR SELECT
  USING (EXISTS(SELECT 1 FROM returns r WHERE r.id = return_id AND has_store_access(r.store_id)));
CREATE POLICY return_items_insert ON return_items FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM returns r WHERE r.id = return_id AND has_store_access(r.store_id)));

-- EXPENSES
CREATE POLICY expenses_select ON expenses FOR SELECT USING (has_store_access(store_id));
CREATE POLICY expenses_insert ON expenses FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY expenses_update ON expenses FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY expenses_delete ON expenses FOR DELETE USING (has_store_access(store_id));

-- EXPENSE_CATEGORIES
CREATE POLICY expense_categories_select ON expense_categories FOR SELECT USING (has_store_access(store_id));
CREATE POLICY expense_categories_insert ON expense_categories FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY expense_categories_update ON expense_categories FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY expense_categories_delete ON expense_categories FOR DELETE USING (has_store_access(store_id));

-- PURCHASES
CREATE POLICY purchases_select ON purchases FOR SELECT USING (has_store_access(store_id));
CREATE POLICY purchases_insert ON purchases FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY purchases_update ON purchases FOR UPDATE USING (has_store_access(store_id));

-- PURCHASE_ITEMS
CREATE POLICY purchase_items_select ON purchase_items FOR SELECT
  USING (EXISTS(SELECT 1 FROM purchases p WHERE p.id = purchase_id AND has_store_access(p.store_id)));
CREATE POLICY purchase_items_insert ON purchase_items FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM purchases p WHERE p.id = purchase_id AND has_store_access(p.store_id)));

-- DISCOUNTS
CREATE POLICY discounts_select ON discounts FOR SELECT USING (has_store_access(store_id));
CREATE POLICY discounts_insert ON discounts FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY discounts_update ON discounts FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY discounts_delete ON discounts FOR DELETE USING (has_store_access(store_id));

-- COUPONS
CREATE POLICY coupons_select ON coupons FOR SELECT USING (has_store_access(store_id));
CREATE POLICY coupons_insert ON coupons FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY coupons_update ON coupons FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY coupons_delete ON coupons FOR DELETE USING (has_store_access(store_id));

-- PROMOTIONS
CREATE POLICY promotions_select ON promotions FOR SELECT USING (has_store_access(store_id));
CREATE POLICY promotions_insert ON promotions FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY promotions_update ON promotions FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY promotions_delete ON promotions FOR DELETE USING (has_store_access(store_id));

-- HELD_INVOICES
CREATE POLICY held_invoices_select ON held_invoices FOR SELECT USING (has_store_access(store_id));
CREATE POLICY held_invoices_insert ON held_invoices FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY held_invoices_delete ON held_invoices FOR DELETE USING (has_store_access(store_id));

-- NOTIFICATIONS
CREATE POLICY notifications_select ON notifications FOR SELECT USING (has_store_access(store_id));
CREATE POLICY notifications_insert ON notifications FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY notifications_update ON notifications FOR UPDATE USING (has_store_access(store_id));

-- STOCK_TRANSFERS
CREATE POLICY stock_transfers_select ON stock_transfers FOR SELECT
  USING (has_store_access(from_store_id) OR has_store_access(to_store_id));
CREATE POLICY stock_transfers_insert ON stock_transfers FOR INSERT
  WITH CHECK (has_store_access(from_store_id));
CREATE POLICY stock_transfers_update ON stock_transfers FOR UPDATE
  USING (has_store_access(from_store_id) OR has_store_access(to_store_id));

-- SETTINGS
CREATE POLICY settings_select ON settings FOR SELECT USING (has_store_access(store_id));
CREATE POLICY settings_insert ON settings FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY settings_update ON settings FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY settings_delete ON settings FOR DELETE USING (is_store_owner(store_id));

-- STOCK_TAKES
CREATE POLICY stock_takes_select ON stock_takes FOR SELECT USING (has_store_access(store_id));
CREATE POLICY stock_takes_insert ON stock_takes FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY stock_takes_update ON stock_takes FOR UPDATE USING (has_store_access(store_id));

-- PRODUCT_EXPIRY
CREATE POLICY product_expiry_select ON product_expiry FOR SELECT USING (has_store_access(store_id));
CREATE POLICY product_expiry_insert ON product_expiry FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY product_expiry_update ON product_expiry FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY product_expiry_delete ON product_expiry FOR DELETE USING (has_store_access(store_id));

-- DRIVERS
CREATE POLICY drivers_select ON drivers FOR SELECT USING (has_store_access(store_id));
CREATE POLICY drivers_insert ON drivers FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY drivers_update ON drivers FOR UPDATE USING (has_store_access(store_id));

-- DAILY_SUMMARIES
CREATE POLICY daily_summaries_select ON daily_summaries FOR SELECT USING (has_store_access(store_id));
CREATE POLICY daily_summaries_insert ON daily_summaries FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY daily_summaries_update ON daily_summaries FOR UPDATE USING (has_store_access(store_id));

-- ORDER_STATUS_HISTORY
CREATE POLICY order_status_history_select ON order_status_history FOR SELECT
  USING (EXISTS(SELECT 1 FROM orders o WHERE o.id = order_id AND has_store_access(o.store_id)));
CREATE POLICY order_status_history_insert ON order_status_history FOR INSERT
  WITH CHECK (EXISTS(SELECT 1 FROM orders o WHERE o.id = order_id AND has_store_access(o.store_id)));

-- FAVORITES
CREATE POLICY favorites_select ON favorites FOR SELECT USING (has_store_access(store_id));
CREATE POLICY favorites_insert ON favorites FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY favorites_delete ON favorites FOR DELETE USING (has_store_access(store_id));

-- AUDIT_LOG
CREATE POLICY audit_log_select ON audit_log FOR SELECT USING (has_store_access(store_id));
CREATE POLICY audit_log_insert ON audit_log FOR INSERT WITH CHECK (has_store_access(store_id));

-- LOYALTY_POINTS
CREATE POLICY loyalty_points_select ON loyalty_points FOR SELECT USING (has_store_access(store_id));
CREATE POLICY loyalty_points_insert ON loyalty_points FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY loyalty_points_update ON loyalty_points FOR UPDATE USING (has_store_access(store_id));

-- LOYALTY_TRANSACTIONS
CREATE POLICY loyalty_transactions_select ON loyalty_transactions FOR SELECT USING (has_store_access(store_id));
CREATE POLICY loyalty_transactions_insert ON loyalty_transactions FOR INSERT WITH CHECK (has_store_access(store_id));

-- LOYALTY_REWARDS
CREATE POLICY loyalty_rewards_select ON loyalty_rewards FOR SELECT USING (has_store_access(store_id));
CREATE POLICY loyalty_rewards_insert ON loyalty_rewards FOR INSERT WITH CHECK (has_store_access(store_id));
CREATE POLICY loyalty_rewards_update ON loyalty_rewards FOR UPDATE USING (has_store_access(store_id));
CREATE POLICY loyalty_rewards_delete ON loyalty_rewards FOR DELETE USING (has_store_access(store_id));

-- ============================================================================
-- 5. DATABASE FUNCTIONS
-- ============================================================================

-- --------------------------------------------------------------------------
-- 5.1 تسجيل مستخدم جديد وإنشاء متجر
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_store_id TEXT;
BEGIN
  -- إنشاء متجر افتراضي للمستخدم الجديد
  v_store_id := uuid_generate_v4()::TEXT;

  INSERT INTO stores (id, name, owner_id, created_at)
  VALUES (v_store_id, 'متجري', NEW.id, NOW());

  -- إنشاء سجل مستخدم في app_users
  INSERT INTO app_users (id, auth_id, store_id, name, phone, role, created_at)
  VALUES (
    uuid_generate_v4()::TEXT,
    NEW.id,
    v_store_id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'),
    COALESCE(NEW.raw_user_meta_data->>'phone', NEW.phone),
    'owner',
    NOW()
  );

  -- إضافة الأدوار الافتراضية
  INSERT INTO roles (id, store_id, name, name_en, permissions, is_system, created_at) VALUES
  (uuid_generate_v4()::TEXT, v_store_id, 'مالك', 'Owner', '{"all": true}', TRUE, NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'مدير', 'Manager', '{"sales": true, "inventory": true, "reports": true, "customers": true, "employees": true}', TRUE, NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'كاشير', 'Cashier', '{"sales": true, "customers_view": true}', TRUE, NOW());

  -- إضافة فئات المصروفات الافتراضية
  INSERT INTO expense_categories (id, store_id, name, name_en, icon, created_at) VALUES
  (uuid_generate_v4()::TEXT, v_store_id, 'إيجار', 'Rent', 'home', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'رواتب', 'Salaries', 'people', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'كهرباء وماء', 'Utilities', 'bolt', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'مشتريات عامة', 'General', 'shopping_cart', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'صيانة', 'Maintenance', 'build', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'نقل', 'Transportation', 'local_shipping', NOW()),
  (uuid_generate_v4()::TEXT, v_store_id, 'أخرى', 'Other', 'more_horiz', NOW());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ربط الدالة بـ auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- --------------------------------------------------------------------------
-- 5.2 تحديث المخزون تلقائياً عند البيع
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_stock_on_sale_item()
RETURNS TRIGGER AS $$
DECLARE
  v_store_id TEXT;
  v_track BOOLEAN;
  v_old_qty INTEGER;
BEGIN
  -- الحصول على store_id من البيع
  SELECT store_id INTO v_store_id FROM sales WHERE id = NEW.sale_id;

  -- التحقق من تتبع المخزون
  SELECT track_inventory, stock_qty INTO v_track, v_old_qty
  FROM products WHERE id = NEW.product_id;

  IF v_track THEN
    -- تحديث الكمية
    UPDATE products
    SET stock_qty = stock_qty - NEW.qty,
        updated_at = NOW()
    WHERE id = NEW.product_id;

    -- تسجيل حركة المخزون
    INSERT INTO inventory_movements (
      id, product_id, store_id, type, qty, previous_qty, new_qty,
      reference_type, reference_id, created_at
    ) VALUES (
      uuid_generate_v4()::TEXT, NEW.product_id, v_store_id,
      'sale', -NEW.qty, v_old_qty, v_old_qty - NEW.qty,
      'sale', NEW.sale_id, NOW()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_sale_item_insert ON sale_items;
CREATE TRIGGER on_sale_item_insert
  AFTER INSERT ON sale_items
  FOR EACH ROW EXECUTE FUNCTION update_stock_on_sale_item();

-- --------------------------------------------------------------------------
-- 5.3 استعادة المخزون عند المرتجع
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_stock_on_return_item()
RETURNS TRIGGER AS $$
DECLARE
  v_store_id TEXT;
  v_track BOOLEAN;
  v_old_qty INTEGER;
BEGIN
  SELECT store_id INTO v_store_id FROM returns WHERE id = NEW.return_id;
  SELECT track_inventory, stock_qty INTO v_track, v_old_qty
  FROM products WHERE id = NEW.product_id;

  IF v_track THEN
    UPDATE products
    SET stock_qty = stock_qty + NEW.qty,
        updated_at = NOW()
    WHERE id = NEW.product_id;

    INSERT INTO inventory_movements (
      id, product_id, store_id, type, qty, previous_qty, new_qty,
      reference_type, reference_id, created_at
    ) VALUES (
      uuid_generate_v4()::TEXT, NEW.product_id, v_store_id,
      'return', NEW.qty, v_old_qty, v_old_qty + NEW.qty,
      'return', NEW.return_id, NOW()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_return_item_insert ON return_items;
CREATE TRIGGER on_return_item_insert
  AFTER INSERT ON return_items
  FOR EACH ROW EXECUTE FUNCTION update_stock_on_return_item();

-- --------------------------------------------------------------------------
-- 5.4 تحديث updated_at تلقائياً
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تطبيق على الجداول التي تحتوي على updated_at
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'stores', 'app_users', 'roles', 'categories', 'products',
    'customers', 'suppliers', 'sales', 'expenses', 'purchases',
    'discounts', 'promotions', 'drivers'
  ]) LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON %I', t);
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at()',
      t
    );
  END LOOP;
END $$;

-- --------------------------------------------------------------------------
-- 5.5 توليد رقم فاتورة تسلسلي
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_receipt_no(p_store_id TEXT)
RETURNS TEXT AS $$
DECLARE
  v_date TEXT;
  v_count INTEGER;
BEGIN
  v_date := TO_CHAR(NOW() AT TIME ZONE 'Asia/Riyadh', 'YYYYMMDD');

  SELECT COUNT(*) + 1 INTO v_count
  FROM sales
  WHERE store_id = p_store_id
    AND created_at::DATE = (NOW() AT TIME ZONE 'Asia/Riyadh')::DATE;

  RETURN 'INV-' || v_date || '-' || LPAD(v_count::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- --------------------------------------------------------------------------
-- 5.6 توليد رقم طلب تسلسلي
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_order_number(p_store_id TEXT)
RETURNS TEXT AS $$
DECLARE
  v_date TEXT;
  v_count INTEGER;
BEGIN
  v_date := TO_CHAR(NOW() AT TIME ZONE 'Asia/Riyadh', 'YYYYMMDD');

  SELECT COUNT(*) + 1 INTO v_count
  FROM orders
  WHERE store_id = p_store_id
    AND created_at::DATE = (NOW() AT TIME ZONE 'Asia/Riyadh')::DATE;

  RETURN 'ORD-' || v_date || '-' || LPAD(v_count::TEXT, 3, '0');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- --------------------------------------------------------------------------
-- 5.7 ملخص مبيعات اليوم
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_daily_summary(p_store_id TEXT, p_date DATE DEFAULT CURRENT_DATE)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_sales', COALESCE(COUNT(*), 0),
    'total_amount', COALESCE(SUM(total), 0),
    'total_tax', COALESCE(SUM(tax), 0),
    'total_discount', COALESCE(SUM(discount), 0),
    'cash_sales', COALESCE(SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END), 0),
    'card_sales', COALESCE(SUM(CASE WHEN payment_method = 'card' THEN total ELSE 0 END), 0),
    'credit_sales', COALESCE(SUM(CASE WHEN payment_method = 'credit' THEN total ELSE 0 END), 0),
    'avg_sale', COALESCE(AVG(total), 0)
  ) INTO v_result
  FROM sales
  WHERE store_id = p_store_id
    AND status = 'completed'
    AND created_at::DATE = p_date;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- --------------------------------------------------------------------------
-- 5.8 المنتجات منخفضة المخزون
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_low_stock_products(p_store_id TEXT)
RETURNS SETOF products AS $$
  SELECT * FROM products
  WHERE store_id = p_store_id
    AND is_active = TRUE
    AND track_inventory = TRUE
    AND stock_qty <= min_qty
  ORDER BY stock_qty ASC;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- --------------------------------------------------------------------------
-- 5.9 Sync API: استقبال بيانات من الجهاز
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sync_from_device(
  p_table_name TEXT,
  p_records JSONB,
  p_store_id TEXT
)
RETURNS JSONB AS $$
DECLARE
  v_record JSONB;
  v_inserted INTEGER := 0;
  v_updated INTEGER := 0;
  v_errors JSONB := '[]'::JSONB;
BEGIN
  -- التحقق من صلاحية الوصول
  IF NOT has_store_access(p_store_id) THEN
    RETURN jsonb_build_object('error', 'Access denied');
  END IF;

  FOR v_record IN SELECT * FROM jsonb_array_elements(p_records)
  LOOP
    BEGIN
      EXECUTE format(
        'INSERT INTO %I SELECT * FROM jsonb_populate_record(NULL::%I, $1)
         ON CONFLICT (id) DO UPDATE SET synced_at = NOW()',
        p_table_name, p_table_name
      ) USING v_record;
      v_inserted := v_inserted + 1;
    EXCEPTION WHEN OTHERS THEN
      v_errors := v_errors || jsonb_build_object(
        'id', v_record->>'id',
        'error', SQLERRM
      );
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'inserted', v_inserted,
    'errors', v_errors,
    'timestamp', NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 6. STORAGE BUCKETS
-- ============================================================================

-- إنشاء buckets للتخزين
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('product-images', 'product-images', TRUE, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('receipt-images', 'receipt-images', FALSE, 3145728, ARRAY['image/jpeg', 'image/png']),
  ('store-logos', 'store-logos', TRUE, 2097152, ARRAY['image/jpeg', 'image/png', 'image/svg+xml']),
  ('expense-receipts', 'expense-receipts', FALSE, 5242880, ARRAY['image/jpeg', 'image/png', 'application/pdf']),
  ('user-avatars', 'user-avatars', TRUE, 1048576, ARRAY['image/jpeg', 'image/png']),
  ('invoice-imports', 'invoice-imports', FALSE, 10485760, ARRAY['image/jpeg', 'image/png', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- ===== Storage RLS Policies =====

-- product-images: قراءة عامة، رفع/حذف بصلاحية
CREATE POLICY product_images_select ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');
CREATE POLICY product_images_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images' AND auth.uid() IS NOT NULL);
CREATE POLICY product_images_delete ON storage.objects FOR DELETE
  USING (bucket_id = 'product-images' AND auth.uid() IS NOT NULL);

-- store-logos: قراءة عامة، رفع بصلاحية
CREATE POLICY store_logos_select ON storage.objects FOR SELECT
  USING (bucket_id = 'store-logos');
CREATE POLICY store_logos_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'store-logos' AND auth.uid() IS NOT NULL);
CREATE POLICY store_logos_delete ON storage.objects FOR DELETE
  USING (bucket_id = 'store-logos' AND auth.uid() IS NOT NULL);

-- user-avatars: قراءة عامة، رفع بصلاحية
CREATE POLICY user_avatars_select ON storage.objects FOR SELECT
  USING (bucket_id = 'user-avatars');
CREATE POLICY user_avatars_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'user-avatars' AND auth.uid() IS NOT NULL);
CREATE POLICY user_avatars_delete ON storage.objects FOR DELETE
  USING (bucket_id = 'user-avatars' AND auth.uid() IS NOT NULL);

-- receipt-images: خاصة - بصلاحية فقط
CREATE POLICY receipt_images_select ON storage.objects FOR SELECT
  USING (bucket_id = 'receipt-images' AND auth.uid() IS NOT NULL);
CREATE POLICY receipt_images_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'receipt-images' AND auth.uid() IS NOT NULL);

-- expense-receipts: خاصة - بصلاحية فقط
CREATE POLICY expense_receipts_select ON storage.objects FOR SELECT
  USING (bucket_id = 'expense-receipts' AND auth.uid() IS NOT NULL);
CREATE POLICY expense_receipts_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'expense-receipts' AND auth.uid() IS NOT NULL);

-- invoice-imports: خاصة - بصلاحية فقط
CREATE POLICY invoice_imports_select ON storage.objects FOR SELECT
  USING (bucket_id = 'invoice-imports' AND auth.uid() IS NOT NULL);
CREATE POLICY invoice_imports_insert ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'invoice-imports' AND auth.uid() IS NOT NULL);

-- ============================================================================
-- 7. REALTIME SUBSCRIPTIONS
-- ============================================================================

-- تفعيل Realtime للجداول المهمة
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE order_status_history;
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE sales;

-- ============================================================================
-- DONE! ✅
-- ============================================================================
-- الخطوات التالية:
-- 1. اذهب إلى Supabase Dashboard > SQL Editor
-- 2. الصق هذا الملف بالكامل وقم بتشغيله
-- 3. اذهب إلى Authentication > Settings:
--    - فعّل Phone Auth (OTP)
--    - أضف رقم تجريبي في Test Phone Numbers
-- 4. اذهب إلى Settings > API:
--    - انسخ URL و anon key
--    - أضفهم في التطبيق (lib/core/config/)
-- 5. اذهب إلى Storage:
--    - تأكد أن الـ buckets تم إنشاؤها
-- ============================================================================
