-- ============================================================================
-- Distributor Portal RLS Policies
-- Enforces org_id filtering at the database level so distributor users
-- can only access data belonging to their own organization.
-- ============================================================================

-- Enable RLS on all relevant tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Helper: get the current user's org_id from their profile
-- Used in all policies below to scope access.
CREATE OR REPLACE FUNCTION auth.user_org_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT org_id FROM profiles WHERE id = auth.uid()
$$;

-- ─── Orders ──────────────────────────────────────────────────────────

-- Users can only see orders from stores in their org
CREATE POLICY "distributor_orders_select" ON orders
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT id FROM stores WHERE org_id = auth.user_org_id()
    )
  );

-- Users can only update orders from stores in their org
CREATE POLICY "distributor_orders_update" ON orders
  FOR UPDATE TO authenticated
  USING (
    store_id IN (
      SELECT id FROM stores WHERE org_id = auth.user_org_id()
    )
  );

-- ─── Order Items ─────────────────────────────────────────────────────

-- Users can only see order items for orders belonging to their org's stores
CREATE POLICY "distributor_order_items_select" ON order_items
  FOR SELECT TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders
      WHERE store_id IN (
        SELECT id FROM stores WHERE org_id = auth.user_org_id()
      )
    )
  );

-- Users can only update order items for orders belonging to their org's stores
CREATE POLICY "distributor_order_items_update" ON order_items
  FOR UPDATE TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders
      WHERE store_id IN (
        SELECT id FROM stores WHERE org_id = auth.user_org_id()
      )
    )
  );

-- ─── Products ────────────────────────────────────────────────────────

-- Users can only see products belonging to their org
CREATE POLICY "distributor_products_select" ON products
  FOR SELECT TO authenticated
  USING (org_id = auth.user_org_id());

-- Users can only update products belonging to their org
CREATE POLICY "distributor_products_update" ON products
  FOR UPDATE TO authenticated
  USING (org_id = auth.user_org_id());

-- ─── Organizations ───────────────────────────────────────────────────

-- Users can only see their own organization
CREATE POLICY "distributor_organizations_select" ON organizations
  FOR SELECT TO authenticated
  USING (id = auth.user_org_id());

-- Users can only update their own organization
CREATE POLICY "distributor_organizations_update" ON organizations
  FOR UPDATE TO authenticated
  USING (id = auth.user_org_id());

-- ─── Stores ──────────────────────────────────────────────────────────

-- Users can only see stores belonging to their org
CREATE POLICY "distributor_stores_select" ON stores
  FOR SELECT TO authenticated
  USING (org_id = auth.user_org_id());

-- ─── Categories ──────────────────────────────────────────────────────

-- Users can only see categories belonging to their org
CREATE POLICY "distributor_categories_select" ON categories
  FOR SELECT TO authenticated
  USING (org_id = auth.user_org_id());
