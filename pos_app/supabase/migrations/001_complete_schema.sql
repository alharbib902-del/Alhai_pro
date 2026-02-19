-- ============================================================================
-- Alhai POS - Complete Supabase Schema
-- Generated: 2026-02-19
-- Total Tables: 43 + RLS Policies + Functions + Storage Buckets + Triggers
-- ============================================================================

-- ============================================================================
-- 0. EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- For fuzzy text search
CREATE EXTENSION IF NOT EXISTS "unaccent";   -- For Arabic diacritic handling

-- ============================================================================
-- 1. CORE TABLES
-- ============================================================================

-- ------- STORES -------
CREATE TABLE IF NOT EXISTS stores (
    id TEXT PRIMARY KEY,
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
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stores_is_active ON stores(is_active);

-- ------- ROLES -------
CREATE TABLE IF NOT EXISTS roles (
    id TEXT PRIMARY KEY,
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

-- ------- USERS -------
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    auth_uid UUID REFERENCES auth.users(id),  -- Link to Supabase Auth
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    pin TEXT,
    role TEXT NOT NULL DEFAULT 'cashier',
    role_id TEXT REFERENCES roles(id),
    avatar TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_store_id ON users(store_id);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_auth_uid ON users(auth_uid);

-- ------- CATEGORIES -------
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_en TEXT,
    parent_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
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
CREATE INDEX IF NOT EXISTS idx_categories_synced_at ON categories(synced_at);

-- ------- PRODUCTS -------
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
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
    category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
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
CREATE INDEX IF NOT EXISTS idx_products_name ON products USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_products_synced_at ON products(synced_at);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);

-- ------- CUSTOMERS -------
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
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
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_customers_is_active ON customers(is_active);

-- ------- CUSTOMER ADDRESSES -------
CREATE TABLE IF NOT EXISTS customer_addresses (
    id TEXT PRIMARY KEY,
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

-- ------- SUPPLIERS -------
CREATE TABLE IF NOT EXISTS suppliers (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    address TEXT,
    city TEXT,
    tax_number TEXT,
    payment_terms TEXT,
    rating INTEGER NOT NULL DEFAULT 0,
    balance DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_suppliers_store_id ON suppliers(store_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_phone ON suppliers(phone);
CREATE INDEX IF NOT EXISTS idx_suppliers_is_active ON suppliers(is_active);

-- ------- DRIVERS -------
CREATE TABLE IF NOT EXISTS drivers (
    id TEXT PRIMARY KEY,
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

-- ============================================================================
-- 2. SALES & ORDERS
-- ============================================================================

-- ------- SALES -------
CREATE TABLE IF NOT EXISTS sales (
    id TEXT PRIMARY KEY,
    receipt_no TEXT NOT NULL,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    cashier_id TEXT NOT NULL REFERENCES users(id),
    customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
    customer_name TEXT,
    customer_phone TEXT,
    subtotal DOUBLE PRECISION NOT NULL,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    tax DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'card', 'mixed', 'credit')),
    is_paid BOOLEAN NOT NULL DEFAULT TRUE,
    amount_received DOUBLE PRECISION,
    change_amount DOUBLE PRECISION,
    notes TEXT,
    channel TEXT NOT NULL DEFAULT 'POS' CHECK (channel IN ('POS', 'ONLINE')),
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'voided', 'refunded')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_cashier_id ON sales(cashier_id);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sales_synced_at ON sales(synced_at);
CREATE INDEX IF NOT EXISTS idx_sales_store_created ON sales(store_id, created_at);

-- ------- SALE ITEMS -------
CREATE TABLE IF NOT EXISTS sale_items (
    id TEXT PRIMARY KEY,
    sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id),
    product_name TEXT NOT NULL,
    product_sku TEXT,
    product_barcode TEXT,
    qty INTEGER NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    cost_price DOUBLE PRECISION,
    subtotal DOUBLE PRECISION NOT NULL,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL,
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);

-- ------- ORDERS -------
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
    order_number TEXT NOT NULL,
    channel TEXT NOT NULL DEFAULT 'app' CHECK (channel IN ('app', 'pos')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled')),
    subtotal DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    tax_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    delivery_fee DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    payment_method TEXT CHECK (payment_method IN ('cash', 'card', 'online')),
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
    delivery_type TEXT NOT NULL DEFAULT 'delivery' CHECK (delivery_type IN ('delivery', 'pickup')),
    delivery_address TEXT,
    delivery_lat DOUBLE PRECISION,
    delivery_lng DOUBLE PRECISION,
    driver_id TEXT REFERENCES drivers(id) ON DELETE SET NULL,
    notes TEXT,
    cancel_reason TEXT,
    order_date TIMESTAMPTZ NOT NULL,
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
CREATE INDEX IF NOT EXISTS idx_orders_synced_at ON orders(synced_at);

-- ------- ORDER ITEMS -------
CREATE TABLE IF NOT EXISTS order_items (
    id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id),
    product_name TEXT NOT NULL,
    product_name_en TEXT,
    barcode TEXT,
    quantity DOUBLE PRECISION NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    tax_rate DOUBLE PRECISION NOT NULL DEFAULT 15.0,
    tax_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL,
    notes TEXT,
    is_reserved BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- ------- ORDER STATUS HISTORY -------
CREATE TABLE IF NOT EXISTS order_status_history (
    id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status TEXT,
    to_status TEXT NOT NULL,
    changed_by TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_created_at ON order_status_history(created_at);

-- ============================================================================
-- 3. INVENTORY & STOCK
-- ============================================================================

-- ------- INVENTORY MOVEMENTS -------
CREATE TABLE IF NOT EXISTS inventory_movements (
    id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES products(id),
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('sale', 'purchase', 'adjustment', 'return', 'transfer', 'waste')),
    qty INTEGER NOT NULL,
    previous_qty INTEGER NOT NULL,
    new_qty INTEGER NOT NULL,
    reference_type TEXT,
    reference_id TEXT,
    reason TEXT,
    notes TEXT,
    user_id TEXT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_store_id ON inventory_movements(store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_created_at ON inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_type ON inventory_movements(type);
CREATE INDEX IF NOT EXISTS idx_inventory_reference ON inventory_movements(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_inventory_synced_at ON inventory_movements(synced_at);

-- ------- PRODUCT EXPIRY -------
CREATE TABLE IF NOT EXISTS product_expiry (
    id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
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

-- ------- STOCK TAKES -------
CREATE TABLE IF NOT EXISTS stock_takes (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'in_progress',
    items JSONB NOT NULL DEFAULT '[]',
    total_items INTEGER NOT NULL DEFAULT 0,
    counted_items INTEGER NOT NULL DEFAULT 0,
    variance_items INTEGER NOT NULL DEFAULT 0,
    notes TEXT,
    created_by TEXT,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_stock_takes_store_id ON stock_takes(store_id);
CREATE INDEX IF NOT EXISTS idx_stock_takes_status ON stock_takes(status);

-- ------- STOCK TRANSFERS -------
CREATE TABLE IF NOT EXISTS stock_transfers (
    id TEXT PRIMARY KEY,
    transfer_number TEXT NOT NULL,
    from_store_id TEXT NOT NULL REFERENCES stores(id),
    to_store_id TEXT NOT NULL REFERENCES stores(id),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'in_transit', 'completed', 'cancelled')),
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

-- ============================================================================
-- 4. FINANCIAL
-- ============================================================================

-- ------- ACCOUNTS (Receivable/Payable) -------
CREATE TABLE IF NOT EXISTS accounts (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('receivable', 'payable')),
    customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
    supplier_id TEXT REFERENCES suppliers(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    phone TEXT,
    balance DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    credit_limit DOUBLE PRECISION NOT NULL DEFAULT 0.0,
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
CREATE INDEX IF NOT EXISTS idx_accounts_synced_at ON accounts(synced_at);

-- ------- TRANSACTIONS -------
CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('invoice', 'payment', 'interest', 'adjustment')),
    amount DOUBLE PRECISION NOT NULL,
    balance_after DOUBLE PRECISION NOT NULL,
    description TEXT,
    reference_id TEXT,
    reference_type TEXT,
    period_key TEXT,  -- YYYY-MM format
    payment_method TEXT CHECK (payment_method IN ('cash', 'card', 'transfer')),
    created_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_transactions_store_id ON transactions(store_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_synced_at ON transactions(synced_at);

-- ------- EXPENSES -------
CREATE TABLE IF NOT EXISTS expense_categories (
    id TEXT PRIMARY KEY,
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

CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    category_id TEXT REFERENCES expense_categories(id) ON DELETE SET NULL,
    amount DOUBLE PRECISION NOT NULL,
    description TEXT,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    receipt_image TEXT,
    created_by TEXT,
    expense_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_expenses_store_id ON expenses(store_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at);

-- ============================================================================
-- 5. PURCHASES
-- ============================================================================

CREATE TABLE IF NOT EXISTS purchases (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    supplier_id TEXT REFERENCES suppliers(id) ON DELETE SET NULL,
    supplier_name TEXT,
    purchase_number TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft',
    subtotal DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    tax DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
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

CREATE TABLE IF NOT EXISTS purchase_items (
    id TEXT PRIMARY KEY,
    purchase_id TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id),
    product_name TEXT NOT NULL,
    product_barcode TEXT,
    qty INTEGER NOT NULL,
    received_qty INTEGER NOT NULL DEFAULT 0,
    unit_cost DOUBLE PRECISION NOT NULL,
    total DOUBLE PRECISION NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase_id ON purchase_items(purchase_id);
CREATE INDEX IF NOT EXISTS idx_purchase_items_product_id ON purchase_items(product_id);

-- ============================================================================
-- 6. RETURNS & REFUNDS
-- ============================================================================

CREATE TABLE IF NOT EXISTS returns (
    id TEXT PRIMARY KEY,
    return_number TEXT NOT NULL,
    sale_id TEXT NOT NULL REFERENCES sales(id),
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
    customer_name TEXT,
    reason TEXT,
    type TEXT NOT NULL DEFAULT 'full' CHECK (type IN ('full', 'partial')),
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

CREATE TABLE IF NOT EXISTS return_items (
    id TEXT PRIMARY KEY,
    return_id TEXT NOT NULL REFERENCES returns(id) ON DELETE CASCADE,
    sale_item_id TEXT REFERENCES sale_items(id),
    product_id TEXT NOT NULL REFERENCES products(id),
    product_name TEXT NOT NULL,
    qty INTEGER NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    refund_amount DOUBLE PRECISION NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_return_items_return_id ON return_items(return_id);
CREATE INDEX IF NOT EXISTS idx_return_items_product_id ON return_items(product_id);

-- ============================================================================
-- 7. SHIFTS & CASH MANAGEMENT
-- ============================================================================

CREATE TABLE IF NOT EXISTS shifts (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    cashier_id TEXT NOT NULL REFERENCES users(id),
    cashier_name TEXT NOT NULL,
    opening_cash DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    closing_cash DOUBLE PRECISION,
    expected_cash DOUBLE PRECISION,
    difference DOUBLE PRECISION,
    total_sales INTEGER NOT NULL DEFAULT 0,
    total_sales_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total_refunds INTEGER NOT NULL DEFAULT 0,
    total_refunds_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'open',
    notes TEXT,
    opened_at TIMESTAMPTZ NOT NULL,
    closed_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_shifts_store_id ON shifts(store_id);
CREATE INDEX IF NOT EXISTS idx_shifts_cashier_id ON shifts(cashier_id);
CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts(status);
CREATE INDEX IF NOT EXISTS idx_shifts_opened_at ON shifts(opened_at);

CREATE TABLE IF NOT EXISTS cash_movements (
    id TEXT PRIMARY KEY,
    shift_id TEXT NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('in', 'out')),
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

-- ============================================================================
-- 8. LOYALTY PROGRAM
-- ============================================================================

CREATE TABLE IF NOT EXISTS loyalty_points (
    id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    current_points INTEGER NOT NULL DEFAULT 0,
    total_earned INTEGER NOT NULL DEFAULT 0,
    total_redeemed INTEGER NOT NULL DEFAULT 0,
    tier_level TEXT NOT NULL DEFAULT 'bronze' CHECK (tier_level IN ('bronze', 'silver', 'gold', 'platinum')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_customer_id ON loyalty_points(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_store_id ON loyalty_points(store_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_synced_at ON loyalty_points(synced_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_loyalty_customer_store ON loyalty_points(customer_id, store_id);

CREATE TABLE IF NOT EXISTS loyalty_transactions (
    id TEXT PRIMARY KEY,
    loyalty_id TEXT NOT NULL REFERENCES loyalty_points(id) ON DELETE CASCADE,
    customer_id TEXT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('earn', 'redeem', 'expire', 'adjust')),
    points INTEGER NOT NULL,
    balance_after INTEGER NOT NULL,
    sale_id TEXT REFERENCES sales(id) ON DELETE SET NULL,
    sale_amount DOUBLE PRECISION,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cashier_id TEXT REFERENCES users(id),
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_tx_loyalty_id ON loyalty_transactions(loyalty_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_customer_id ON loyalty_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_store_id ON loyalty_transactions(store_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_created_at ON loyalty_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_loyalty_tx_synced_at ON loyalty_transactions(synced_at);

CREATE TABLE IF NOT EXISTS loyalty_rewards (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL,
    reward_type TEXT NOT NULL CHECK (reward_type IN ('discount_percentage', 'discount_fixed', 'free_item')),
    reward_value DOUBLE PRECISION NOT NULL,
    min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    required_tier TEXT NOT NULL DEFAULT 'all' CHECK (required_tier IN ('all', 'bronze', 'silver', 'gold', 'platinum')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_loyalty_rewards_store_id ON loyalty_rewards(store_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_rewards_synced_at ON loyalty_rewards(synced_at);

-- ============================================================================
-- 9. DISCOUNTS & PROMOTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS discounts (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_en TEXT,
    type TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
    value DOUBLE PRECISION NOT NULL,
    min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    max_discount DOUBLE PRECISION,
    applies_to TEXT NOT NULL DEFAULT 'all',
    product_ids JSONB,
    category_ids JSONB,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_discounts_store_id ON discounts(store_id);
CREATE INDEX IF NOT EXISTS idx_discounts_is_active ON discounts(is_active);

CREATE TABLE IF NOT EXISTS coupons (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    discount_id TEXT REFERENCES discounts(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
    value DOUBLE PRECISION NOT NULL,
    max_uses INTEGER NOT NULL DEFAULT 0,
    current_uses INTEGER NOT NULL DEFAULT 0,
    min_purchase DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_coupons_store_id ON coupons(store_id);
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON coupons(is_active);
CREATE UNIQUE INDEX IF NOT EXISTS idx_coupons_store_code ON coupons(store_id, code);

CREATE TABLE IF NOT EXISTS promotions (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_en TEXT,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('buy_x_get_y', 'bundle', 'flash_sale')),
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

-- ============================================================================
-- 10. WHATSAPP MESSAGING
-- ============================================================================

CREATE TABLE IF NOT EXISTS whatsapp_templates (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('receipt', 'debt_reminder', 'promotion', 'order_update', 'welcome', 'custom')),
    content TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'ar',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    media_type TEXT,  -- NULL, 'image', or 'document'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_wa_tmpl_type ON whatsapp_templates(type);
CREATE INDEX IF NOT EXISTS idx_wa_tmpl_active ON whatsapp_templates(is_active);

CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    phone TEXT NOT NULL,
    customer_name TEXT,
    customer_id TEXT REFERENCES customers(id) ON DELETE SET NULL,
    message_type TEXT NOT NULL CHECK (message_type IN ('text', 'image', 'document', 'video', 'audio', 'location', 'contact')),
    text_content TEXT,
    media_url TEXT,
    media_local_path TEXT,
    file_name TEXT,
    template_id TEXT REFERENCES whatsapp_templates(id) ON DELETE SET NULL,
    reference_type TEXT CHECK (reference_type IN ('sale', 'order', 'debt_reminder', 'promotion', 'return', 'welcome')),
    reference_id TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'uploading', 'sending', 'sent', 'delivered', 'read', 'failed')),
    external_msg_id TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    last_error TEXT,
    priority INTEGER NOT NULL DEFAULT 2,
    batch_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    last_attempt_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_wa_msg_status ON whatsapp_messages(status);
CREATE INDEX IF NOT EXISTS idx_wa_msg_phone ON whatsapp_messages(phone);
CREATE INDEX IF NOT EXISTS idx_wa_msg_type ON whatsapp_messages(message_type);
CREATE INDEX IF NOT EXISTS idx_wa_msg_created_at ON whatsapp_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_wa_msg_reference ON whatsapp_messages(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_wa_msg_batch ON whatsapp_messages(batch_id);
CREATE INDEX IF NOT EXISTS idx_wa_msg_external ON whatsapp_messages(external_msg_id);

-- ============================================================================
-- 11. OTHER TABLES
-- ============================================================================

-- ------- AUDIT LOG -------
CREATE TABLE IF NOT EXISTS audit_log (
    id TEXT PRIMARY KEY,
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
CREATE INDEX IF NOT EXISTS idx_audit_synced_at ON audit_log(synced_at);

-- ------- SYNC QUEUE -------
CREATE TABLE IF NOT EXISTS sync_queue (
    id TEXT PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
    payload JSONB NOT NULL,
    idempotency_key TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'syncing', 'synced', 'failed')),
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    last_error TEXT,
    priority INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_attempt_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_sync_status ON sync_queue(status);
CREATE INDEX IF NOT EXISTS idx_sync_priority ON sync_queue(priority);
CREATE INDEX IF NOT EXISTS idx_sync_created_at ON sync_queue(created_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_idempotency ON sync_queue(idempotency_key);
CREATE INDEX IF NOT EXISTS idx_sync_status_priority ON sync_queue(status, priority);

-- ------- HELD INVOICES -------
CREATE TABLE IF NOT EXISTS held_invoices (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    cashier_id TEXT NOT NULL REFERENCES users(id),
    customer_name TEXT,
    customer_phone TEXT,
    items JSONB NOT NULL,
    subtotal DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    discount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_held_invoices_store_id ON held_invoices(store_id);
CREATE INDEX IF NOT EXISTS idx_held_invoices_cashier_id ON held_invoices(cashier_id);

-- ------- NOTIFICATIONS -------
CREATE TABLE IF NOT EXISTS notifications (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    user_id TEXT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'info' CHECK (type IN ('info', 'warning', 'error', 'success')),
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

-- ------- SETTINGS -------
CREATE TABLE IF NOT EXISTS settings (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_store_key ON settings(store_id, key);

-- ------- FAVORITES -------
CREATE TABLE IF NOT EXISTS favorites (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_favorites_store_id ON favorites(store_id);
CREATE INDEX IF NOT EXISTS idx_favorites_product_id ON favorites(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_store_product ON favorites(store_id, product_id);

-- ------- DAILY SUMMARIES -------
CREATE TABLE IF NOT EXISTS daily_summaries (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    date TIMESTAMPTZ NOT NULL,
    total_sales INTEGER NOT NULL DEFAULT 0,
    total_sales_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_orders_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total_refunds INTEGER NOT NULL DEFAULT 0,
    total_refunds_amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    total_expenses DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    cash_total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    card_total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    credit_total DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    net_profit DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_daily_summaries_store_id ON daily_summaries(store_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_date ON daily_summaries(date);
CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_summaries_store_date ON daily_summaries(store_id, date);

-- ============================================================================
-- 12. ROW LEVEL SECURITY (RLS) - Multi-tenant isolation
-- ============================================================================

-- Enable RLS on ALL tables
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_expiry ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_takes ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE held_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

-- Helper: get current user's store_id from JWT
CREATE OR REPLACE FUNCTION get_user_store_id()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT store_id FROM users WHERE auth_uid = auth.uid() LIMIT 1;
$$;

-- Helper: get current user's id from JWT
CREATE OR REPLACE FUNCTION get_user_id()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT id FROM users WHERE auth_uid = auth.uid() LIMIT 1;
$$;

-- RLS Policies for store-scoped tables
-- DROP existing policies first to make this idempotent
DO $$
DECLARE
    tbl TEXT;
    tbls TEXT[] := ARRAY[
        'stores','roles','users','categories','products','customers',
        'customer_addresses','suppliers','drivers','sales','sale_items',
        'orders','order_items','order_status_history','inventory_movements',
        'product_expiry','stock_takes','stock_transfers','accounts','transactions',
        'expense_categories','expenses','purchases','purchase_items','returns',
        'return_items','shifts','cash_movements','loyalty_points','loyalty_transactions',
        'loyalty_rewards','discounts','coupons','promotions','whatsapp_templates',
        'whatsapp_messages','audit_log','sync_queue','held_invoices','notifications',
        'settings','favorites','daily_summaries'
    ];
BEGIN
    FOREACH tbl IN ARRAY tbls LOOP
        EXECUTE format('DROP POLICY IF EXISTS "store_isolation" ON %I', tbl);
    END LOOP;
END;
$$;

CREATE POLICY "store_isolation" ON stores
    FOR ALL USING (id = get_user_store_id());

CREATE POLICY "store_isolation" ON roles
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON users
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON categories
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON products
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON customers
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON customer_addresses
    FOR ALL USING (
        customer_id IN (SELECT id FROM customers WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON suppliers
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON drivers
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON sales
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON sale_items
    FOR ALL USING (
        sale_id IN (SELECT id FROM sales WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON orders
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON order_items
    FOR ALL USING (
        order_id IN (SELECT id FROM orders WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON order_status_history
    FOR ALL USING (
        order_id IN (SELECT id FROM orders WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON inventory_movements
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON product_expiry
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON stock_takes
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON stock_transfers
    FOR ALL USING (
        from_store_id = get_user_store_id()
        OR to_store_id = get_user_store_id()
    );

CREATE POLICY "store_isolation" ON accounts
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON transactions
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON expense_categories
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON expenses
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON purchases
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON purchase_items
    FOR ALL USING (
        purchase_id IN (SELECT id FROM purchases WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON returns
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON return_items
    FOR ALL USING (
        return_id IN (SELECT id FROM returns WHERE store_id = get_user_store_id())
    );

CREATE POLICY "store_isolation" ON shifts
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON cash_movements
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON loyalty_points
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON loyalty_transactions
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON loyalty_rewards
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON discounts
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON coupons
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON promotions
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON whatsapp_templates
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON whatsapp_messages
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON audit_log
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON sync_queue
    FOR ALL USING (TRUE);  -- sync_queue doesn't have store_id directly

CREATE POLICY "store_isolation" ON held_invoices
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON notifications
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON settings
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON favorites
    FOR ALL USING (store_id = get_user_store_id());

CREATE POLICY "store_isolation" ON daily_summaries
    FOR ALL USING (store_id = get_user_store_id());

-- ============================================================================
-- 13. STORAGE BUCKETS
-- ============================================================================

-- Product images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images',
    'product-images',
    TRUE,
    5242880,  -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Store logos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'store-logos',
    'store-logos',
    TRUE,
    2097152,  -- 2MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']
) ON CONFLICT (id) DO NOTHING;

-- Receipt images (expense receipts)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'receipt-images',
    'receipt-images',
    FALSE,
    10485760,  -- 10MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
) ON CONFLICT (id) DO NOTHING;

-- WhatsApp media
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'whatsapp-media',
    'whatsapp-media',
    FALSE,
    16777216,  -- 16MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf', 'video/mp4', 'audio/mpeg', 'audio/ogg']
) ON CONFLICT (id) DO NOTHING;

-- User avatars
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    TRUE,
    1048576,  -- 1MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Category images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'category-images',
    'category-images',
    TRUE,
    2097152,  -- 2MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Storage RLS policies (drop first for idempotency)
DO $$
DECLARE
    pol TEXT;
    pols TEXT[] := ARRAY[
        'store_product_images','store_logos','store_receipts',
        'store_whatsapp_media','store_avatars','store_category_images',
        'public_product_images_read','public_store_logos_read',
        'public_avatars_read','public_category_images_read'
    ];
BEGIN
    FOREACH pol IN ARRAY pols LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol);
    END LOOP;
END;
$$;

CREATE POLICY "store_product_images"
    ON storage.objects FOR ALL
    USING (bucket_id = 'product-images' AND (storage.foldername(name))[1] = get_user_store_id());

CREATE POLICY "store_logos"
    ON storage.objects FOR ALL
    USING (bucket_id = 'store-logos' AND (storage.foldername(name))[1] = get_user_store_id());

CREATE POLICY "store_receipts"
    ON storage.objects FOR ALL
    USING (bucket_id = 'receipt-images' AND (storage.foldername(name))[1] = get_user_store_id());

CREATE POLICY "store_whatsapp_media"
    ON storage.objects FOR ALL
    USING (bucket_id = 'whatsapp-media' AND (storage.foldername(name))[1] = get_user_store_id());

CREATE POLICY "store_avatars"
    ON storage.objects FOR ALL
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = get_user_store_id());

CREATE POLICY "store_category_images"
    ON storage.objects FOR ALL
    USING (bucket_id = 'category-images' AND (storage.foldername(name))[1] = get_user_store_id());

-- Public read for public buckets
CREATE POLICY "public_product_images_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'product-images');

CREATE POLICY "public_store_logos_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'store-logos');

CREATE POLICY "public_avatars_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "public_category_images_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'category-images');

-- ============================================================================
-- 14. DATABASE FUNCTIONS
-- ============================================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Apply updated_at trigger to all tables with updated_at column (idempotent)
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT table_name FROM information_schema.columns
        WHERE column_name = 'updated_at'
        AND table_schema = 'public'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON %I', t);
        EXECUTE format(
            'CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at()',
            t
        );
    END LOOP;
END;
$$;

-- Function: Update product stock after sale
DROP FUNCTION IF EXISTS update_stock_on_sale() CASCADE;
CREATE OR REPLACE FUNCTION update_stock_on_sale()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock_qty = stock_qty - NEW.qty,
            updated_at = NOW()
        WHERE id = NEW.product_id
        AND track_inventory = TRUE;

        -- Create inventory movement
        INSERT INTO inventory_movements (id, product_id, store_id, type, qty, previous_qty, new_qty, reference_type, reference_id, created_at)
        SELECT
            uuid_generate_v4()::TEXT,
            NEW.product_id,
            s.store_id,
            'sale',
            -NEW.qty,
            p.stock_qty + NEW.qty,
            p.stock_qty,
            'sale',
            NEW.sale_id,
            NOW()
        FROM products p
        JOIN sales s ON s.id = NEW.sale_id
        WHERE p.id = NEW.product_id AND p.track_inventory = TRUE;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_stock_on_sale ON sale_items;
CREATE TRIGGER trigger_stock_on_sale
    AFTER INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_stock_on_sale();

-- Function: Update stock on return
DROP FUNCTION IF EXISTS update_stock_on_return() CASCADE;
CREATE OR REPLACE FUNCTION update_stock_on_return()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock_qty = stock_qty + NEW.qty,
            updated_at = NOW()
        WHERE id = NEW.product_id
        AND track_inventory = TRUE;

        -- Create inventory movement
        INSERT INTO inventory_movements (id, product_id, store_id, type, qty, previous_qty, new_qty, reference_type, reference_id, created_at)
        SELECT
            uuid_generate_v4()::TEXT,
            NEW.product_id,
            r.store_id,
            'return',
            NEW.qty,
            p.stock_qty - NEW.qty,
            p.stock_qty,
            'sale',
            r.sale_id,
            NOW()
        FROM products p
        JOIN returns r ON r.id = NEW.return_id
        WHERE p.id = NEW.product_id AND p.track_inventory = TRUE;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_stock_on_return ON return_items;
CREATE TRIGGER trigger_stock_on_return
    AFTER INSERT ON return_items
    FOR EACH ROW
    EXECUTE FUNCTION update_stock_on_return();

-- Function: Update account balance on transaction
DROP FUNCTION IF EXISTS update_account_balance() CASCADE;
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE accounts
    SET balance = NEW.balance_after,
        last_transaction_at = NOW(),
        updated_at = NOW()
    WHERE id = NEW.account_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_account_balance ON transactions;
CREATE TRIGGER trigger_account_balance
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_account_balance();

-- Function: Update loyalty points
DROP FUNCTION IF EXISTS update_loyalty_points() CASCADE;
CREATE OR REPLACE FUNCTION update_loyalty_points()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.transaction_type = 'earn' THEN
        UPDATE loyalty_points
        SET current_points = current_points + NEW.points,
            total_earned = total_earned + NEW.points,
            updated_at = NOW()
        WHERE id = NEW.loyalty_id;
    ELSIF NEW.transaction_type = 'redeem' THEN
        UPDATE loyalty_points
        SET current_points = current_points - ABS(NEW.points),
            total_redeemed = total_redeemed + ABS(NEW.points),
            updated_at = NOW()
        WHERE id = NEW.loyalty_id;
    ELSIF NEW.transaction_type = 'expire' THEN
        UPDATE loyalty_points
        SET current_points = current_points - ABS(NEW.points),
            updated_at = NOW()
        WHERE id = NEW.loyalty_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_loyalty_points ON loyalty_transactions;
CREATE TRIGGER trigger_loyalty_points
    AFTER INSERT ON loyalty_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_loyalty_points();

-- Function: Update coupon usage count
DROP FUNCTION IF EXISTS increment_coupon_usage(TEXT, TEXT);
CREATE OR REPLACE FUNCTION increment_coupon_usage(coupon_code TEXT, p_store_id TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE coupons
    SET current_uses = current_uses + 1
    WHERE code = coupon_code
    AND store_id = p_store_id
    AND is_active = TRUE
    AND (max_uses = 0 OR current_uses < max_uses)
    AND (expires_at IS NULL OR expires_at > NOW());
END;
$$;

-- Function: Generate daily summary
DROP FUNCTION IF EXISTS generate_daily_summary(TEXT, DATE);
CREATE OR REPLACE FUNCTION generate_daily_summary(p_store_id TEXT, p_date DATE)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_sales INTEGER;
    v_total_sales_amount DOUBLE PRECISION;
    v_total_orders INTEGER;
    v_total_orders_amount DOUBLE PRECISION;
    v_total_refunds INTEGER;
    v_total_refunds_amount DOUBLE PRECISION;
    v_total_expenses DOUBLE PRECISION;
    v_cash_total DOUBLE PRECISION;
    v_card_total DOUBLE PRECISION;
    v_credit_total DOUBLE PRECISION;
BEGIN
    -- Sales
    SELECT COUNT(*), COALESCE(SUM(total), 0)
    INTO v_total_sales, v_total_sales_amount
    FROM sales
    WHERE store_id = p_store_id
    AND DATE(created_at) = p_date
    AND status = 'completed';

    -- Orders
    SELECT COUNT(*), COALESCE(SUM(total), 0)
    INTO v_total_orders, v_total_orders_amount
    FROM orders
    WHERE store_id = p_store_id
    AND DATE(order_date) = p_date
    AND status = 'delivered';

    -- Refunds
    SELECT COUNT(*), COALESCE(SUM(total_refund), 0)
    INTO v_total_refunds, v_total_refunds_amount
    FROM returns
    WHERE store_id = p_store_id
    AND DATE(created_at) = p_date;

    -- Expenses
    SELECT COALESCE(SUM(amount), 0)
    INTO v_total_expenses
    FROM expenses
    WHERE store_id = p_store_id
    AND DATE(expense_date) = p_date;

    -- Payment breakdown
    SELECT COALESCE(SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END), 0),
           COALESCE(SUM(CASE WHEN payment_method = 'card' THEN total ELSE 0 END), 0),
           COALESCE(SUM(CASE WHEN payment_method = 'credit' THEN total ELSE 0 END), 0)
    INTO v_cash_total, v_card_total, v_credit_total
    FROM sales
    WHERE store_id = p_store_id
    AND DATE(created_at) = p_date
    AND status = 'completed';

    -- Upsert
    INSERT INTO daily_summaries (
        id, store_id, date,
        total_sales, total_sales_amount,
        total_orders, total_orders_amount,
        total_refunds, total_refunds_amount,
        total_expenses,
        cash_total, card_total, credit_total,
        net_profit, created_at
    ) VALUES (
        uuid_generate_v4()::TEXT, p_store_id, p_date,
        v_total_sales, v_total_sales_amount,
        v_total_orders, v_total_orders_amount,
        v_total_refunds, v_total_refunds_amount,
        v_total_expenses,
        v_cash_total, v_card_total, v_credit_total,
        v_total_sales_amount - v_total_refunds_amount - v_total_expenses,
        NOW()
    )
    ON CONFLICT (store_id, date) DO UPDATE SET
        total_sales = EXCLUDED.total_sales,
        total_sales_amount = EXCLUDED.total_sales_amount,
        total_orders = EXCLUDED.total_orders,
        total_orders_amount = EXCLUDED.total_orders_amount,
        total_refunds = EXCLUDED.total_refunds,
        total_refunds_amount = EXCLUDED.total_refunds_amount,
        total_expenses = EXCLUDED.total_expenses,
        cash_total = EXCLUDED.cash_total,
        card_total = EXCLUDED.card_total,
        credit_total = EXCLUDED.credit_total,
        net_profit = EXCLUDED.net_profit,
        updated_at = NOW();
END;
$$;

-- Function: Full-text search for products (replaces SQLite FTS5)
DROP FUNCTION IF EXISTS search_products(TEXT, TEXT, INTEGER);
CREATE OR REPLACE FUNCTION search_products(
    p_store_id TEXT,
    p_query TEXT,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    id TEXT,
    name TEXT,
    barcode TEXT,
    sku TEXT,
    price DOUBLE PRECISION,
    stock_qty INTEGER,
    category_id TEXT,
    image_thumbnail TEXT,
    rank REAL
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.name,
        p.barcode,
        p.sku,
        p.price,
        p.stock_qty,
        p.category_id,
        p.image_thumbnail,
        similarity(p.name, p_query) AS rank
    FROM products p
    WHERE p.store_id = p_store_id
    AND p.is_active = TRUE
    AND (
        p.name ILIKE '%' || p_query || '%'
        OR p.barcode = p_query
        OR p.sku ILIKE '%' || p_query || '%'
        OR p.description ILIKE '%' || p_query || '%'
    )
    ORDER BY
        CASE WHEN p.barcode = p_query THEN 0 ELSE 1 END,
        similarity(p.name, p_query) DESC
    LIMIT p_limit;
$$;

-- Function: Get low stock products
DROP FUNCTION IF EXISTS get_low_stock_products(TEXT);
CREATE OR REPLACE FUNCTION get_low_stock_products(p_store_id TEXT)
RETURNS TABLE (
    id TEXT,
    name TEXT,
    barcode TEXT,
    stock_qty INTEGER,
    min_qty INTEGER,
    category_name TEXT
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.id,
        p.name,
        p.barcode,
        p.stock_qty,
        p.min_qty,
        c.name AS category_name
    FROM products p
    LEFT JOIN categories c ON c.id = p.category_id
    WHERE p.store_id = p_store_id
    AND p.is_active = TRUE
    AND p.track_inventory = TRUE
    AND p.stock_qty <= p.min_qty
    ORDER BY (p.stock_qty::DOUBLE PRECISION / NULLIF(p.min_qty, 0)) ASC;
$$;

-- Function: Get expiring products
DROP FUNCTION IF EXISTS get_expiring_products(TEXT, INTEGER);
CREATE OR REPLACE FUNCTION get_expiring_products(
    p_store_id TEXT,
    p_days_ahead INTEGER DEFAULT 30
)
RETURNS TABLE (
    product_id TEXT,
    product_name TEXT,
    batch_number TEXT,
    expiry_date TIMESTAMPTZ,
    quantity INTEGER,
    days_until_expiry INTEGER
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        pe.product_id,
        p.name AS product_name,
        pe.batch_number,
        pe.expiry_date,
        pe.quantity,
        EXTRACT(DAY FROM pe.expiry_date - NOW())::INTEGER AS days_until_expiry
    FROM product_expiry pe
    JOIN products p ON p.id = pe.product_id
    WHERE pe.store_id = p_store_id
    AND pe.expiry_date <= NOW() + (p_days_ahead || ' days')::INTERVAL
    AND pe.quantity > 0
    ORDER BY pe.expiry_date ASC;
$$;

-- Function: Sales analytics
DROP FUNCTION IF EXISTS get_sales_analytics(TEXT, DATE, DATE);
CREATE OR REPLACE FUNCTION get_sales_analytics(
    p_store_id TEXT,
    p_from DATE,
    p_to DATE
)
RETURNS TABLE (
    period DATE,
    total_sales BIGINT,
    total_amount DOUBLE PRECISION,
    avg_ticket DOUBLE PRECISION,
    total_items BIGINT,
    cash_amount DOUBLE PRECISION,
    card_amount DOUBLE PRECISION,
    credit_amount DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        DATE(s.created_at) AS period,
        COUNT(*)::BIGINT AS total_sales,
        SUM(s.total) AS total_amount,
        AVG(s.total) AS avg_ticket,
        SUM(si.total_items)::BIGINT AS total_items,
        SUM(CASE WHEN s.payment_method = 'cash' THEN s.total ELSE 0 END) AS cash_amount,
        SUM(CASE WHEN s.payment_method = 'card' THEN s.total ELSE 0 END) AS card_amount,
        SUM(CASE WHEN s.payment_method = 'credit' THEN s.total ELSE 0 END) AS credit_amount
    FROM sales s
    LEFT JOIN LATERAL (
        SELECT SUM(qty)::BIGINT AS total_items FROM sale_items WHERE sale_id = s.id
    ) si ON TRUE
    WHERE s.store_id = p_store_id
    AND s.status = 'completed'
    AND DATE(s.created_at) BETWEEN p_from AND p_to
    GROUP BY DATE(s.created_at)
    ORDER BY period;
$$;

-- Function: Top selling products
DROP FUNCTION IF EXISTS get_top_products(TEXT, DATE, DATE, INTEGER);
CREATE OR REPLACE FUNCTION get_top_products(
    p_store_id TEXT,
    p_from DATE,
    p_to DATE,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    product_id TEXT,
    product_name TEXT,
    total_qty BIGINT,
    total_revenue DOUBLE PRECISION,
    total_profit DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        si.product_id,
        si.product_name,
        SUM(si.qty)::BIGINT AS total_qty,
        SUM(si.total) AS total_revenue,
        SUM(si.total - COALESCE(si.cost_price, 0) * si.qty) AS total_profit
    FROM sale_items si
    JOIN sales s ON s.id = si.sale_id
    WHERE s.store_id = p_store_id
    AND s.status = 'completed'
    AND DATE(s.created_at) BETWEEN p_from AND p_to
    GROUP BY si.product_id, si.product_name
    ORDER BY total_qty DESC
    LIMIT p_limit;
$$;

-- Function: Peak hours analysis
DROP FUNCTION IF EXISTS get_peak_hours(TEXT, DATE, DATE);
CREATE OR REPLACE FUNCTION get_peak_hours(
    p_store_id TEXT,
    p_from DATE,
    p_to DATE
)
RETURNS TABLE (
    hour INTEGER,
    total_sales BIGINT,
    total_amount DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        EXTRACT(HOUR FROM s.created_at)::INTEGER AS hour,
        COUNT(*)::BIGINT AS total_sales,
        SUM(s.total) AS total_amount
    FROM sales s
    WHERE s.store_id = p_store_id
    AND s.status = 'completed'
    AND DATE(s.created_at) BETWEEN p_from AND p_to
    GROUP BY EXTRACT(HOUR FROM s.created_at)
    ORDER BY hour;
$$;

-- Function: Sync - Batch upsert from client
DROP FUNCTION IF EXISTS sync_batch_upsert(TEXT, JSONB);
CREATE OR REPLACE FUNCTION sync_batch_upsert(
    p_table_name TEXT,
    p_records JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_record JSONB;
    v_success INTEGER := 0;
    v_failed INTEGER := 0;
    v_errors JSONB := '[]'::JSONB;
BEGIN
    FOR v_record IN SELECT * FROM jsonb_array_elements(p_records)
    LOOP
        BEGIN
            EXECUTE format(
                'INSERT INTO %I SELECT * FROM jsonb_populate_record(NULL::%I, $1)
                 ON CONFLICT (id) DO UPDATE SET %s',
                p_table_name,
                p_table_name,
                (
                    SELECT string_agg(format('%I = EXCLUDED.%I', col, col), ', ')
                    FROM jsonb_object_keys(v_record) AS col
                    WHERE col != 'id'
                )
            ) USING v_record;
            v_success := v_success + 1;
        EXCEPTION WHEN OTHERS THEN
            v_failed := v_failed + 1;
            v_errors := v_errors || jsonb_build_object(
                'record_id', v_record->>'id',
                'error', SQLERRM
            );
        END;
    END LOOP;

    RETURN jsonb_build_object(
        'success', v_success,
        'failed', v_failed,
        'errors', v_errors
    );
END;
$$;

-- Function: Get changes since last sync
DROP FUNCTION IF EXISTS get_changes_since(TEXT, TEXT, TIMESTAMPTZ, INTEGER);
CREATE OR REPLACE FUNCTION get_changes_since(
    p_store_id TEXT,
    p_table_name TEXT,
    p_since TIMESTAMPTZ,
    p_limit INTEGER DEFAULT 100
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    EXECUTE format(
        'SELECT COALESCE(jsonb_agg(row_to_json(t)), ''[]''::jsonb)
         FROM (
             SELECT * FROM %I
             WHERE store_id = $1
             AND (synced_at > $2 OR updated_at > $2 OR (synced_at IS NULL AND created_at > $2))
             ORDER BY COALESCE(updated_at, created_at)
             LIMIT $3
         ) t',
        p_table_name
    ) INTO v_result USING p_store_id, p_since, p_limit;

    RETURN v_result;
END;
$$;

-- ============================================================================
-- 15. REALTIME SUBSCRIPTIONS (Enable for key tables)
-- ============================================================================

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE orders;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE order_status_history;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE products;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE sales;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE inventory_movements;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE sync_queue;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE whatsapp_messages;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE shifts;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE held_invoices;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;

-- ============================================================================
-- 16. CRON JOBS (via pg_cron extension - enable in Supabase dashboard first)
-- ============================================================================

-- Uncomment after enabling pg_cron in Supabase Dashboard > Database > Extensions

-- Daily summary generation (runs at midnight Saudi time = 9 PM UTC)
-- SELECT cron.schedule(
--     'generate-daily-summaries',
--     '0 21 * * *',
--     $$
--     SELECT generate_daily_summary(id, (NOW() AT TIME ZONE 'Asia/Riyadh')::DATE - INTERVAL '1 day')
--     FROM stores WHERE is_active = TRUE;
--     $$
-- );

-- Expire loyalty points (runs daily at 1 AM UTC)
-- SELECT cron.schedule(
--     'expire-loyalty-points',
--     '0 1 * * *',
--     $$
--     UPDATE loyalty_points SET current_points = 0, updated_at = NOW()
--     WHERE id IN (
--         SELECT lp.id FROM loyalty_points lp
--         WHERE lp.current_points > 0
--         AND NOT EXISTS (
--             SELECT 1 FROM loyalty_transactions lt
--             WHERE lt.loyalty_id = lp.id
--             AND lt.created_at > NOW() - INTERVAL '365 days'
--         )
--     );
--     $$
-- );

-- Clean old sync queue entries (runs weekly)
-- SELECT cron.schedule(
--     'clean-sync-queue',
--     '0 3 * * 0',
--     $$
--     DELETE FROM sync_queue WHERE status = 'synced' AND synced_at < NOW() - INTERVAL '30 days';
--     $$
-- );

-- ============================================================================
-- DONE! Schema is ready for Supabase deployment
-- Run this SQL in Supabase Dashboard > SQL Editor
-- ============================================================================
