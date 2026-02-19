-- ============================================================================
-- Alhai POS - Migration 002: Multi-Tenant + Multi-Branch + Multi-POS
-- ============================================================================
-- Adds:
--   organizations (merchants/tenants)
--   subscriptions (billing plans)
--   org_members (user <-> org role)
--   user_stores (user <-> multiple stores)
--   pos_terminals (multiple POS devices per store)
--   Updates stores to belong to an organization
--   Updates RLS for full tenant isolation
-- ============================================================================

-- ============================================================================
-- 1. ORGANIZATIONS (التجار / المؤسسات)
-- ============================================================================

CREATE TABLE IF NOT EXISTS organizations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT,
    slug TEXT UNIQUE,                          -- unique URL-friendly identifier
    logo TEXT,
    owner_id TEXT,                              -- references users.id (set after user created)
    phone TEXT,
    email TEXT,
    address TEXT,
    city TEXT,
    country TEXT NOT NULL DEFAULT 'SA',
    tax_number TEXT,                            -- الرقم الضريبي
    commercial_reg TEXT,                        -- السجل التجاري
    currency TEXT NOT NULL DEFAULT 'SAR',
    timezone TEXT NOT NULL DEFAULT 'Asia/Riyadh',
    locale TEXT NOT NULL DEFAULT 'ar',
    plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'starter', 'professional', 'enterprise')),
    max_stores INTEGER NOT NULL DEFAULT 1,     -- max branches per plan
    max_users INTEGER NOT NULL DEFAULT 3,      -- max users per plan
    max_products INTEGER NOT NULL DEFAULT 100, -- max products per plan
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    trial_ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations(slug);
CREATE INDEX IF NOT EXISTS idx_organizations_owner_id ON organizations(owner_id);
CREATE INDEX IF NOT EXISTS idx_organizations_is_active ON organizations(is_active);
CREATE INDEX IF NOT EXISTS idx_organizations_plan ON organizations(plan);

-- ============================================================================
-- 2. SUBSCRIPTIONS (الاشتراكات والفوترة)
-- ============================================================================

CREATE TABLE IF NOT EXISTS subscriptions (
    id TEXT PRIMARY KEY,
    org_id TEXT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    plan TEXT NOT NULL CHECK (plan IN ('free', 'starter', 'professional', 'enterprise')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'past_due', 'cancelled', 'trialing', 'expired')),
    amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    currency TEXT NOT NULL DEFAULT 'SAR',
    billing_cycle TEXT NOT NULL DEFAULT 'monthly' CHECK (billing_cycle IN ('monthly', 'yearly')),
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMPTZ NOT NULL,
    cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE,
    payment_method TEXT,                       -- stripe/tap/moyasar
    external_subscription_id TEXT,             -- ID from payment provider
    features JSONB NOT NULL DEFAULT '{}',      -- plan feature overrides
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_org_id ON subscriptions(org_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_period_end ON subscriptions(current_period_end);

-- ============================================================================
-- 3. ORG MEMBERS (عضوية المؤسسة)
-- ============================================================================

CREATE TABLE IF NOT EXISTS org_members (
    id TEXT PRIMARY KEY,
    org_id TEXT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,                     -- references users.id
    role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('owner', 'admin', 'manager', 'staff')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    invited_by TEXT,
    invited_at TIMESTAMPTZ,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_org_members_org_user ON org_members(org_id, user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user_id ON org_members(user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_role ON org_members(role);

-- ============================================================================
-- 4. USER_STORES (ربط المستخدم بعدة فروع)
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_stores (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'cashier' CHECK (role IN ('manager', 'supervisor', 'cashier', 'viewer')),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,  -- الفرع الافتراضي
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_stores_user_store ON user_stores(user_id, store_id);
CREATE INDEX IF NOT EXISTS idx_user_stores_user_id ON user_stores(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stores_store_id ON user_stores(store_id);

-- ============================================================================
-- 5. POS TERMINALS (أجهزة نقاط البيع)
-- ============================================================================

CREATE TABLE IF NOT EXISTS pos_terminals (
    id TEXT PRIMARY KEY,
    store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    org_id TEXT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                        -- e.g. "كاشير 1", "كاشير 2"
    terminal_number INTEGER NOT NULL DEFAULT 1,
    device_id TEXT,                             -- unique hardware/device ID
    device_name TEXT,                           -- e.g. "iPad Pro", "Android Tablet"
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    current_shift_id TEXT REFERENCES shifts(id),
    current_user_id TEXT REFERENCES users(id),
    last_heartbeat_at TIMESTAMPTZ,             -- last ping from device
    last_sync_at TIMESTAMPTZ,
    settings JSONB NOT NULL DEFAULT '{}',       -- terminal-specific settings
    receipt_header TEXT,                        -- terminal-specific receipt header
    receipt_footer TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_pos_terminals_store_id ON pos_terminals(store_id);
CREATE INDEX IF NOT EXISTS idx_pos_terminals_org_id ON pos_terminals(org_id);
CREATE INDEX IF NOT EXISTS idx_pos_terminals_device_id ON pos_terminals(device_id);
CREATE INDEX IF NOT EXISTS idx_pos_terminals_status ON pos_terminals(status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_pos_terminals_store_number ON pos_terminals(store_id, terminal_number);

-- ============================================================================
-- 6. ALTER EXISTING TABLES - Add org_id
-- ============================================================================

-- Add org_id to stores
ALTER TABLE stores ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_stores_org_id ON stores(org_id);

-- Add org_id to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_users_org_id ON users(org_id);

-- Add terminal_id to sales (which POS terminal made this sale)
ALTER TABLE sales ADD COLUMN IF NOT EXISTS terminal_id TEXT REFERENCES pos_terminals(id);
CREATE INDEX IF NOT EXISTS idx_sales_terminal_id ON sales(terminal_id);

-- Add terminal_id to shifts (which terminal the shift belongs to)
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS terminal_id TEXT REFERENCES pos_terminals(id);
CREATE INDEX IF NOT EXISTS idx_shifts_terminal_id ON shifts(terminal_id);

-- Add org_id to key tables for faster org-level queries
ALTER TABLE products ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_products_org_id ON products(org_id);

ALTER TABLE customers ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_customers_org_id ON customers(org_id);

ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_suppliers_org_id ON suppliers(org_id);

ALTER TABLE categories ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_categories_org_id ON categories(org_id);

ALTER TABLE sales ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_sales_org_id ON sales(org_id);

ALTER TABLE orders ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_orders_org_id ON orders(org_id);

ALTER TABLE inventory_movements ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_inventory_org_id ON inventory_movements(org_id);

ALTER TABLE accounts ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_accounts_org_id ON accounts(org_id);

ALTER TABLE expenses ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_expenses_org_id ON expenses(org_id);

ALTER TABLE purchases ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_purchases_org_id ON purchases(org_id);

ALTER TABLE returns ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_returns_org_id ON returns(org_id);

ALTER TABLE shifts ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_shifts_org_id ON shifts(org_id);

ALTER TABLE discounts ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_discounts_org_id ON discounts(org_id);

ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_loyalty_org_id ON loyalty_points(org_id);

ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_audit_org_id ON audit_log(org_id);

ALTER TABLE daily_summaries ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_daily_summaries_org_id ON daily_summaries(org_id);

ALTER TABLE notifications ADD COLUMN IF NOT EXISTS org_id TEXT REFERENCES organizations(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_notifications_org_id ON notifications(org_id);

-- ============================================================================
-- 7. ENABLE RLS ON NEW TABLES
-- ============================================================================

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos_terminals ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 8. UPDATED HELPER FUNCTIONS
-- ============================================================================

-- Get current user's org_id
DROP FUNCTION IF EXISTS get_user_org_id() CASCADE;
CREATE OR REPLACE FUNCTION get_user_org_id()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT org_id FROM users WHERE auth_uid = auth.uid() LIMIT 1;
$$;

-- Get all store_ids the current user can access
DROP FUNCTION IF EXISTS get_user_store_ids() CASCADE;
CREATE OR REPLACE FUNCTION get_user_store_ids()
RETURNS SETOF TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT us.store_id
    FROM user_stores us
    JOIN users u ON u.id = us.user_id
    WHERE u.auth_uid = auth.uid()
    AND us.is_active = TRUE
    UNION
    -- Fallback: also include the user's direct store_id for backwards compatibility
    SELECT store_id FROM users WHERE auth_uid = auth.uid() AND store_id IS NOT NULL;
$$;

-- Get current user's active store (primary or selected)
DROP FUNCTION IF EXISTS get_user_store_id() CASCADE;
CREATE OR REPLACE FUNCTION get_user_store_id()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    -- Try primary store from user_stores first
    SELECT COALESCE(
        (SELECT us.store_id FROM user_stores us
         JOIN users u ON u.id = us.user_id
         WHERE u.auth_uid = auth.uid()
         AND us.is_primary = TRUE
         AND us.is_active = TRUE
         LIMIT 1),
        -- Fallback to users.store_id
        (SELECT store_id FROM users WHERE auth_uid = auth.uid() LIMIT 1)
    );
$$;

-- Get user's role in a specific organization
DROP FUNCTION IF EXISTS get_user_org_role() CASCADE;
CREATE OR REPLACE FUNCTION get_user_org_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT om.role
    FROM org_members om
    JOIN users u ON u.id = om.user_id
    WHERE u.auth_uid = auth.uid()
    AND om.org_id = get_user_org_id()
    AND om.is_active = TRUE
    LIMIT 1;
$$;

-- Check if user is org owner or admin
DROP FUNCTION IF EXISTS is_org_admin() CASCADE;
CREATE OR REPLACE FUNCTION is_org_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS(
        SELECT 1 FROM org_members om
        JOIN users u ON u.id = om.user_id
        WHERE u.auth_uid = auth.uid()
        AND om.org_id = get_user_org_id()
        AND om.role IN ('owner', 'admin')
        AND om.is_active = TRUE
    );
$$;

-- Check if user has access to a specific store
DROP FUNCTION IF EXISTS user_has_store_access(TEXT) CASCADE;
CREATE OR REPLACE FUNCTION user_has_store_access(p_store_id TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT EXISTS(
        SELECT 1 FROM user_stores us
        JOIN users u ON u.id = us.user_id
        WHERE u.auth_uid = auth.uid()
        AND us.store_id = p_store_id
        AND us.is_active = TRUE
    ) OR EXISTS(
        -- org admins have access to all stores
        SELECT 1 FROM org_members om
        JOIN users u ON u.id = om.user_id
        JOIN stores s ON s.org_id = om.org_id
        WHERE u.auth_uid = auth.uid()
        AND s.id = p_store_id
        AND om.role IN ('owner', 'admin')
        AND om.is_active = TRUE
    );
$$;

-- ============================================================================
-- 9. RLS POLICIES FOR NEW TABLES
-- ============================================================================

-- Organizations: user can see their own org
DROP POLICY IF EXISTS "org_isolation" ON organizations;
CREATE POLICY "org_isolation" ON organizations
    FOR ALL USING (id = get_user_org_id());

-- Subscriptions: only org admins
DROP POLICY IF EXISTS "org_isolation" ON subscriptions;
CREATE POLICY "org_isolation" ON subscriptions
    FOR ALL USING (org_id = get_user_org_id() AND is_org_admin());

-- Org Members: see members of your org
DROP POLICY IF EXISTS "org_isolation" ON org_members;
CREATE POLICY "org_isolation" ON org_members
    FOR ALL USING (org_id = get_user_org_id());

-- User Stores: see your own store assignments + admins see all
DROP POLICY IF EXISTS "user_stores_policy" ON user_stores;
CREATE POLICY "user_stores_policy" ON user_stores
    FOR ALL USING (
        user_id = get_user_id()
        OR (is_org_admin() AND store_id IN (
            SELECT id FROM stores WHERE org_id = get_user_org_id()
        ))
    );

-- POS Terminals: see terminals in stores you have access to
DROP POLICY IF EXISTS "terminal_isolation" ON pos_terminals;
CREATE POLICY "terminal_isolation" ON pos_terminals
    FOR ALL USING (
        org_id = get_user_org_id()
        AND (is_org_admin() OR store_id IN (SELECT get_user_store_ids()))
    );

-- ============================================================================
-- 10. UPDATE EXISTING RLS POLICIES
-- ============================================================================
-- Update store isolation to support multi-store access

-- Stores: users see stores they have access to (or all if org admin)
DROP POLICY IF EXISTS "store_isolation" ON stores;
CREATE POLICY "store_isolation" ON stores
    FOR ALL USING (
        org_id = get_user_org_id()
        AND (is_org_admin() OR id IN (SELECT get_user_store_ids()))
    );

-- Users: see users in your org
DROP POLICY IF EXISTS "store_isolation" ON users;
CREATE POLICY "store_isolation" ON users
    FOR ALL USING (org_id = get_user_org_id());

-- For tables with store_id: user sees data from stores they have access to
-- Org admins see all stores in their org

-- Helper: checks store_id against user access
-- We'll use this pattern: store_id IN (SELECT get_user_store_ids())

DROP POLICY IF EXISTS "store_isolation" ON products;
CREATE POLICY "store_isolation" ON products
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON categories;
CREATE POLICY "store_isolation" ON categories
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON customers;
CREATE POLICY "store_isolation" ON customers
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON suppliers;
CREATE POLICY "store_isolation" ON suppliers
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON drivers;
CREATE POLICY "store_isolation" ON drivers
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON sales;
CREATE POLICY "store_isolation" ON sales
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON sale_items;
CREATE POLICY "store_isolation" ON sale_items
    FOR ALL USING (
        sale_id IN (SELECT id FROM sales WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON orders;
CREATE POLICY "store_isolation" ON orders
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON order_items;
CREATE POLICY "store_isolation" ON order_items
    FOR ALL USING (
        order_id IN (SELECT id FROM orders WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON order_status_history;
CREATE POLICY "store_isolation" ON order_status_history
    FOR ALL USING (
        order_id IN (SELECT id FROM orders WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON inventory_movements;
CREATE POLICY "store_isolation" ON inventory_movements
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON product_expiry;
CREATE POLICY "store_isolation" ON product_expiry
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON stock_takes;
CREATE POLICY "store_isolation" ON stock_takes
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON stock_transfers;
CREATE POLICY "store_isolation" ON stock_transfers
    FOR ALL USING (
        from_store_id IN (SELECT get_user_store_ids())
        OR to_store_id IN (SELECT get_user_store_ids())
    );

DROP POLICY IF EXISTS "store_isolation" ON accounts;
CREATE POLICY "store_isolation" ON accounts
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON transactions;
CREATE POLICY "store_isolation" ON transactions
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON expense_categories;
CREATE POLICY "store_isolation" ON expense_categories
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON expenses;
CREATE POLICY "store_isolation" ON expenses
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON purchases;
CREATE POLICY "store_isolation" ON purchases
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON purchase_items;
CREATE POLICY "store_isolation" ON purchase_items
    FOR ALL USING (
        purchase_id IN (SELECT id FROM purchases WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON returns;
CREATE POLICY "store_isolation" ON returns
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON return_items;
CREATE POLICY "store_isolation" ON return_items
    FOR ALL USING (
        return_id IN (SELECT id FROM returns WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON shifts;
CREATE POLICY "store_isolation" ON shifts
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON cash_movements;
CREATE POLICY "store_isolation" ON cash_movements
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON loyalty_points;
CREATE POLICY "store_isolation" ON loyalty_points
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON loyalty_transactions;
CREATE POLICY "store_isolation" ON loyalty_transactions
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON loyalty_rewards;
CREATE POLICY "store_isolation" ON loyalty_rewards
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON discounts;
CREATE POLICY "store_isolation" ON discounts
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON coupons;
CREATE POLICY "store_isolation" ON coupons
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON promotions;
CREATE POLICY "store_isolation" ON promotions
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON whatsapp_templates;
CREATE POLICY "store_isolation" ON whatsapp_templates
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON whatsapp_messages;
CREATE POLICY "store_isolation" ON whatsapp_messages
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON audit_log;
CREATE POLICY "store_isolation" ON audit_log
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON held_invoices;
CREATE POLICY "store_isolation" ON held_invoices
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON notifications;
CREATE POLICY "store_isolation" ON notifications
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON settings;
CREATE POLICY "store_isolation" ON settings
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON favorites;
CREATE POLICY "store_isolation" ON favorites
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON daily_summaries;
CREATE POLICY "store_isolation" ON daily_summaries
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()) OR (org_id = get_user_org_id() AND is_org_admin()));

DROP POLICY IF EXISTS "store_isolation" ON roles;
CREATE POLICY "store_isolation" ON roles
    FOR ALL USING (store_id IN (SELECT get_user_store_ids()));

DROP POLICY IF EXISTS "store_isolation" ON customer_addresses;
CREATE POLICY "store_isolation" ON customer_addresses
    FOR ALL USING (
        customer_id IN (SELECT id FROM customers WHERE store_id IN (SELECT get_user_store_ids()))
    );

DROP POLICY IF EXISTS "store_isolation" ON sync_queue;
CREATE POLICY "store_isolation" ON sync_queue
    FOR ALL USING (TRUE);

-- ============================================================================
-- 11. ORG-LEVEL ANALYTICS FUNCTIONS
-- ============================================================================

-- Get org-wide sales summary (all branches)
DROP FUNCTION IF EXISTS get_org_sales_summary(TEXT, DATE, DATE);
CREATE OR REPLACE FUNCTION get_org_sales_summary(
    p_org_id TEXT,
    p_from DATE,
    p_to DATE
)
RETURNS TABLE (
    store_id TEXT,
    store_name TEXT,
    total_sales BIGINT,
    total_amount DOUBLE PRECISION,
    total_refunds BIGINT,
    refund_amount DOUBLE PRECISION,
    net_amount DOUBLE PRECISION
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT
        st.id AS store_id,
        st.name AS store_name,
        COUNT(s.id)::BIGINT AS total_sales,
        COALESCE(SUM(s.total), 0) AS total_amount,
        COALESCE(r.refund_count, 0)::BIGINT AS total_refunds,
        COALESCE(r.refund_total, 0) AS refund_amount,
        COALESCE(SUM(s.total), 0) - COALESCE(r.refund_total, 0) AS net_amount
    FROM stores st
    LEFT JOIN sales s ON s.store_id = st.id
        AND s.status = 'completed'
        AND DATE(s.created_at) BETWEEN p_from AND p_to
    LEFT JOIN LATERAL (
        SELECT COUNT(*)::BIGINT AS refund_count, SUM(total_refund) AS refund_total
        FROM returns
        WHERE store_id = st.id
        AND DATE(created_at) BETWEEN p_from AND p_to
    ) r ON TRUE
    WHERE st.org_id = p_org_id AND st.is_active = TRUE
    GROUP BY st.id, st.name, r.refund_count, r.refund_total
    ORDER BY total_amount DESC;
$$;

-- Get org-wide inventory overview (all branches)
DROP FUNCTION IF EXISTS get_org_inventory_overview(TEXT);
CREATE OR REPLACE FUNCTION get_org_inventory_overview(p_org_id TEXT)
RETURNS TABLE (
    store_id TEXT,
    store_name TEXT,
    total_products BIGINT,
    low_stock_count BIGINT,
    out_of_stock_count BIGINT,
    total_stock_value DOUBLE PRECISION
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT
        st.id AS store_id,
        st.name AS store_name,
        COUNT(p.id)::BIGINT AS total_products,
        COUNT(CASE WHEN p.stock_qty <= p.min_qty AND p.stock_qty > 0 THEN 1 END)::BIGINT AS low_stock_count,
        COUNT(CASE WHEN p.stock_qty = 0 THEN 1 END)::BIGINT AS out_of_stock_count,
        COALESCE(SUM(p.stock_qty * COALESCE(p.cost_price, p.price)), 0) AS total_stock_value
    FROM stores st
    LEFT JOIN products p ON p.store_id = st.id AND p.is_active = TRUE AND p.track_inventory = TRUE
    WHERE st.org_id = p_org_id AND st.is_active = TRUE
    GROUP BY st.id, st.name
    ORDER BY st.name;
$$;

-- Check plan limits
DROP FUNCTION IF EXISTS check_plan_limit(TEXT, TEXT);
CREATE OR REPLACE FUNCTION check_plan_limit(p_org_id TEXT, p_resource TEXT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_org organizations%ROWTYPE;
    v_current INTEGER;
    v_max INTEGER;
    v_allowed BOOLEAN;
BEGIN
    SELECT * INTO v_org FROM organizations WHERE id = p_org_id;

    IF p_resource = 'stores' THEN
        SELECT COUNT(*) INTO v_current FROM stores WHERE org_id = p_org_id AND is_active = TRUE;
        v_max := v_org.max_stores;
    ELSIF p_resource = 'users' THEN
        SELECT COUNT(*) INTO v_current FROM org_members WHERE org_id = p_org_id AND is_active = TRUE;
        v_max := v_org.max_users;
    ELSIF p_resource = 'products' THEN
        SELECT COUNT(*) INTO v_current FROM products WHERE org_id = p_org_id AND is_active = TRUE;
        v_max := v_org.max_products;
    ELSE
        RETURN jsonb_build_object('error', 'unknown resource: ' || p_resource);
    END IF;

    v_allowed := v_current < v_max;

    RETURN jsonb_build_object(
        'resource', p_resource,
        'current', v_current,
        'max', v_max,
        'allowed', v_allowed,
        'plan', v_org.plan
    );
END;
$$;

-- ============================================================================
-- 12. REALTIME FOR NEW TABLES
-- ============================================================================

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE pos_terminals;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE user_stores;
EXCEPTION WHEN duplicate_object THEN NULL;
END;
$$;

-- ============================================================================
-- 13. UPDATED TRIGGERS FOR updated_at ON NEW TABLES
-- ============================================================================

DROP TRIGGER IF EXISTS set_updated_at ON organizations;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON subscriptions;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON org_members;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON org_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON user_stores;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON user_stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON pos_terminals;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON pos_terminals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- DONE!
-- ============================================================================
-- New hierarchy:
--
--   Organization (التاجر/المؤسسة)
--     ├── Subscription (الاشتراك)
--     ├── Org Members (أعضاء المؤسسة - owner/admin/manager/staff)
--     ├── Store 1 (فرع الرياض)
--     │     ├── POS Terminal 1 (كاشير 1)
--     │     ├── POS Terminal 2 (كاشير 2)
--     │     └── Users (via user_stores)
--     ├── Store 2 (فرع جدة)
--     │     ├── POS Terminal 1
--     │     └── Users (via user_stores)
--     └── Store 3 (فرع الدمام)
--           ├── POS Terminal 1
--           └── Users (via user_stores)
--
-- Plan limits:
--   free:         1 store,  3 users,  100 products
--   starter:      3 stores, 10 users, 1000 products
--   professional: 10 stores, 50 users, unlimited products
--   enterprise:   unlimited
-- ============================================================================
