-- ============================================================================
-- Alhai Platform - Combined RLS Policies Reference
-- ============================================================================
-- Version: 1.0.0
-- Date: 2026-04-03
-- Purpose: Single file containing ALL RLS policies for audit and review.
--          Consolidated from supabase_init.sql, all migrations, and fix files.
--
-- NOTE: This file represents the INTENDED state after all migrations.
--       Some policies were overridden by fix_compatibility.sql.
--       Tables marked with [OVERRIDE] have their proper policies replaced
--       by "Allow authenticated full access" in the current live DB.
--
-- WARNING: Do NOT run this file directly on production.
--          It is a reference document. To apply changes, create a new migration.
-- ============================================================================


-- ############################################################################
-- SECTION 1: HELPER FUNCTIONS
-- ############################################################################

-- 1a. is_super_admin: Check if current user is super_admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin');
$$;

-- 1b. is_store_member: Check if current user is active member of store
CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id TEXT)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  );
$$;

-- 1c. is_store_admin: Check if current user is super_admin, owner, or manager
CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id TEXT)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT
    public.is_super_admin()
    OR EXISTS (
      SELECT 1 FROM public.store_members
      WHERE store_id = p_store_id AND user_id = auth.uid()
        AND is_active = true AND role_in_store IN ('owner', 'manager')
    );
$$;

-- 1d. get_my_user_id: Wrapper for auth.uid() to prevent recursion
CREATE OR REPLACE FUNCTION public.get_my_user_id()
RETURNS uuid LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT auth.uid();
$$;


-- ############################################################################
-- SECTION 2: ENABLE RLS ON ALL TABLES
-- ############################################################################

-- Core tables (supabase_init.sql)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shifts ENABLE ROW LEVEL SECURITY;

-- Migration v14
ALTER TABLE public.org_products ENABLE ROW LEVEL SECURITY;

-- Migration v15
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- Migration v17
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;

-- Migration v19
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_proofs ENABLE ROW LEVEL SECURITY;

-- Compatibility migration tables
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pos_terminals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_expiry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_takes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_deltas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;


-- ############################################################################
-- SECTION 3: REVOKE STATEMENTS
-- ############################################################################

REVOKE ALL ON public.role_audit_log FROM anon, authenticated;

REVOKE UPDATE (store_id) ON public.store_members FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.products FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.debts FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.purchase_orders FROM authenticated, anon;

REVOKE UPDATE ON public.stock_adjustments FROM authenticated, anon;
REVOKE DELETE ON public.stock_adjustments FROM authenticated, anon;

REVOKE UPDATE ON public.order_payments FROM authenticated, anon;
REVOKE DELETE ON public.order_payments FROM authenticated, anon;

REVOKE UPDATE ON public.activity_logs FROM authenticated, anon;
REVOKE DELETE ON public.activity_logs FROM authenticated, anon;

REVOKE EXECUTE ON FUNCTION public.update_user_role(UUID, user_role, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.update_user_role(UUID, user_role, TEXT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.update_user_role(UUID, user_role, TEXT) FROM anon;


-- ############################################################################
-- SECTION 4: POLICIES - CORE TABLES (supabase_init.sql)
-- ############################################################################

-- ======================= role_audit_log =======================
CREATE POLICY "role_audit_superadmin_read" ON public.role_audit_log
  FOR SELECT USING (public.is_super_admin());

-- ======================= users =======================
CREATE POLICY "users_superadmin_select" ON public.users
  FOR SELECT USING (public.is_super_admin());

CREATE POLICY "users_self_select" ON public.users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "users_self_update" ON public.users
  FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY "users_superadmin_update" ON public.users
  FOR UPDATE USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- v20: Customer self-insert (for customer app registration)
CREATE POLICY "users_customer_upsert_own" ON public.users
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

-- ======================= stores =======================
CREATE POLICY "stores_superadmin_all" ON public.stores
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- Authenticated users can see active stores (for customer app store listing)
CREATE POLICY "stores_public_read_active" ON public.stores
  FOR SELECT USING (is_active = true AND auth.uid() IS NOT NULL);

-- Store admin can see full store details
CREATE POLICY "stores_staff_read_own" ON public.stores
  FOR SELECT USING (public.is_store_admin(id));

-- Members can see their stores (fix_rls_recursion.sql / fix_stores_rls.sql)
CREATE POLICY "stores_member_select" ON public.stores
  FOR SELECT USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT store_id FROM public.store_members
      WHERE user_id = get_my_user_id() AND is_active = true
    )
    OR public.is_super_admin()
  );

CREATE POLICY "stores_owner_insert" ON public.stores
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_update" ON public.stores
  FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_delete" ON public.stores
  FOR DELETE USING (owner_id = auth.uid());

-- ======================= store_members =======================
CREATE POLICY "store_members_superadmin_all" ON public.store_members
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "store_members_admin_insert" ON public.store_members
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_update" ON public.store_members
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_delete" ON public.store_members
  FOR DELETE USING (public.is_store_admin(store_id));

CREATE POLICY "store_members_self_read" ON public.store_members
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "store_members_staff_read" ON public.store_members
  FOR SELECT USING (public.is_store_member(store_id));

-- Migration v119 added these (for secure_public_products migration)
CREATE POLICY "store_members_owner_select_migration" ON public.store_members
  FOR SELECT USING (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
    OR user_id = auth.uid()
  );

CREATE POLICY "store_members_owner_insert_migration" ON public.store_members
  FOR INSERT WITH CHECK (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
  );

CREATE POLICY "store_members_owner_delete_migration" ON public.store_members
  FOR DELETE USING (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
  );

-- ======================= categories =======================
CREATE POLICY "categories_superadmin_all" ON public.categories
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "categories_public_read_active" ON public.categories
  FOR SELECT USING (
    is_active = true
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
  );

CREATE POLICY "categories_staff_read_all" ON public.categories
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "categories_staff_insert" ON public.categories
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "categories_staff_update" ON public.categories
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "categories_staff_delete" ON public.categories
  FOR DELETE USING (public.is_store_admin(store_id));

-- ======================= products =======================
CREATE POLICY "products_superadmin_all" ON public.products
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- NOTE: products_public_read_active was REMOVED in migration 20260119
-- Public access now handled via Edge Function

CREATE POLICY "products_staff_read_all" ON public.products
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "products_staff_insert" ON public.products
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "products_staff_update" ON public.products
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "products_staff_delete" ON public.products
  FOR DELETE USING (public.is_store_admin(store_id));

-- ======================= orders =======================
-- [OVERRIDE] These policies were replaced by "Allow authenticated full access"
--            in fix_compatibility.sql. Listed here as the intended design.
CREATE POLICY "orders_superadmin_all" ON public.orders
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "orders_customer_read" ON public.orders
  FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "orders_customer_insert" ON public.orders
  FOR INSERT WITH CHECK (customer_id = auth.uid());

CREATE POLICY "orders_customer_update_created" ON public.orders
  FOR UPDATE USING (customer_id = auth.uid() AND status = 'created')
  WITH CHECK (customer_id = auth.uid() AND status = 'created');

CREATE POLICY "orders_staff_read" ON public.orders
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "orders_staff_update" ON public.orders
  FOR UPDATE USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

-- v20: Customer app can create and read orders
CREATE POLICY "orders_customer_create" ON public.orders
  FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid());

CREATE POLICY "orders_customer_read_own" ON public.orders
  FOR SELECT TO authenticated USING (customer_id = auth.uid());

-- ======================= order_items =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "order_items_superadmin_all" ON public.order_items
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "order_items_read_via_order" ON public.order_items
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id
    AND (o.customer_id = auth.uid() OR public.is_store_member(o.store_id))
  ));

CREATE POLICY "order_items_customer_insert" ON public.order_items
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o
    JOIN public.products p ON p.id = product_id
    WHERE o.id = order_id
    AND o.customer_id = auth.uid()
    AND o.status = 'created'
    AND p.store_id = o.store_id
    AND p.is_active = true
  ));

CREATE POLICY "order_items_staff_insert" ON public.order_items
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id = order_id AND public.is_store_member(o.store_id) AND o.status = 'created'
  ));

CREATE POLICY "order_items_staff_update_created" ON public.order_items
  FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id) AND o.status = 'created'))
  WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id) AND o.status = 'created'));

CREATE POLICY "order_items_staff_delete_created" ON public.order_items
  FOR DELETE USING (EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id = order_id AND public.is_store_member(o.store_id) AND o.status = 'created'
  ));

-- v20: Customer can insert items into their own orders
CREATE POLICY "order_items_customer_insert" ON public.order_items
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.orders WHERE id = order_id AND customer_id = auth.uid())
  );

-- ======================= suppliers =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "suppliers_superadmin_all" ON public.suppliers
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "suppliers_staff_read" ON public.suppliers
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_insert" ON public.suppliers
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "suppliers_staff_update" ON public.suppliers
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "suppliers_staff_delete" ON public.suppliers
  FOR DELETE USING (public.is_store_admin(store_id));

-- ======================= debts =======================
CREATE POLICY "debts_superadmin_all" ON public.debts
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debts_staff_read" ON public.debts
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "debts_staff_insert" ON public.debts
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "debts_staff_update" ON public.debts
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "debts_staff_delete" ON public.debts
  FOR DELETE USING (public.is_store_admin(store_id));

-- ======================= debt_payments =======================
CREATE POLICY "debt_payments_superadmin_all" ON public.debt_payments
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debt_payments_staff_read" ON public.debt_payments
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_member(d.store_id)
  ));

CREATE POLICY "debt_payments_staff_insert" ON public.debt_payments
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_admin(d.store_id)
  ));

-- ======================= deliveries =======================
CREATE POLICY "deliveries_superadmin_all" ON public.deliveries
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "deliveries_driver_read" ON public.deliveries
  FOR SELECT USING (driver_id = auth.uid());

CREATE POLICY "deliveries_driver_update" ON public.deliveries
  FOR UPDATE USING (driver_id = auth.uid()) WITH CHECK (driver_id = auth.uid());

CREATE POLICY "deliveries_staff_read" ON public.deliveries
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)
  ));

CREATE POLICY "deliveries_staff_update" ON public.deliveries
  FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "deliveries_staff_insert" ON public.deliveries
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)
  ));

-- ======================= purchase_orders =======================
CREATE POLICY "purchase_orders_superadmin_all" ON public.purchase_orders
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "purchase_orders_staff_read" ON public.purchase_orders
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_insert" ON public.purchase_orders
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "purchase_orders_staff_update" ON public.purchase_orders
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "purchase_orders_staff_delete" ON public.purchase_orders
  FOR DELETE USING (public.is_store_admin(store_id));

-- ======================= purchase_order_items =======================
CREATE POLICY "po_items_superadmin_all" ON public.purchase_order_items
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "po_items_staff_read" ON public.purchase_order_items
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_member(po.store_id)
  ));

CREATE POLICY "po_items_staff_insert" ON public.purchase_order_items
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_admin(po.store_id)
  ));

CREATE POLICY "po_items_staff_update" ON public.purchase_order_items
  FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_admin(po.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_admin(po.store_id)));

CREATE POLICY "po_items_staff_delete" ON public.purchase_order_items
  FOR DELETE USING (EXISTS (
    SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_admin(po.store_id)
  ));

-- ======================= addresses =======================
CREATE POLICY "addresses_user_all" ON public.addresses
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- v20: Explicit per-operation policies
CREATE POLICY "addresses_customer_insert" ON public.addresses
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "addresses_customer_delete" ON public.addresses
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "addresses_customer_update" ON public.addresses
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ======================= customer_accounts =======================
CREATE POLICY "customer_accounts_superadmin_all" ON public.customer_accounts
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "customer_accounts_customer_read" ON public.customer_accounts
  FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "customer_accounts_staff_read" ON public.customer_accounts
  FOR SELECT USING (public.is_store_member(store_id));

-- ======================= loyalty_points =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "loyalty_points_superadmin_all" ON public.loyalty_points
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "loyalty_points_customer_read" ON public.loyalty_points
  FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "loyalty_points_staff_read" ON public.loyalty_points
  FOR SELECT USING (public.is_store_member(store_id));

-- ======================= stock_adjustments =======================
CREATE POLICY "stock_adj_superadmin_select" ON public.stock_adjustments
  FOR SELECT USING (public.is_super_admin());

CREATE POLICY "stock_adj_superadmin_insert" ON public.stock_adjustments
  FOR INSERT WITH CHECK (public.is_super_admin());

CREATE POLICY "stock_adj_staff_read" ON public.stock_adjustments
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "stock_adj_staff_insert" ON public.stock_adjustments
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

-- ======================= notifications =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "notifications_user_read" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "notifications_user_update" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY "notifications_superadmin_all" ON public.notifications
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- ======================= promotions =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "promotions_public_read_active" ON public.promotions
  FOR SELECT USING (
    is_active = true
    AND now() BETWEEN start_date AND end_date
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
  );

CREATE POLICY "promotions_staff_read" ON public.promotions
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "promotions_staff_insert" ON public.promotions
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "promotions_staff_update" ON public.promotions
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "promotions_staff_delete" ON public.promotions
  FOR DELETE USING (public.is_store_admin(store_id));

CREATE POLICY "promotions_superadmin_all" ON public.promotions
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- ======================= order_payments =======================
CREATE POLICY "order_payments_read_via_order" ON public.order_payments
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id
    AND (o.customer_id = auth.uid() OR public.is_store_member(o.store_id))
  ));

CREATE POLICY "order_payments_staff_insert" ON public.order_payments
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)
  ));

CREATE POLICY "order_payments_superadmin_all" ON public.order_payments
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- ======================= store_settings =======================
CREATE POLICY "store_settings_staff_read" ON public.store_settings
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "store_settings_admin_update" ON public.store_settings
  FOR UPDATE USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_settings_admin_insert" ON public.store_settings
  FOR INSERT WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_settings_superadmin_all" ON public.store_settings
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- ======================= activity_logs =======================
CREATE POLICY "activity_logs_staff_read" ON public.activity_logs
  FOR SELECT USING (public.is_store_admin(store_id));

CREATE POLICY "activity_logs_staff_insert" ON public.activity_logs
  FOR INSERT WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "activity_logs_superadmin_all" ON public.activity_logs
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

-- ======================= shifts =======================
-- [OVERRIDE] Replaced by "Allow authenticated full access" in fix_compatibility.sql
CREATE POLICY "shifts_cashier_read_own" ON public.shifts
  FOR SELECT USING (cashier_id = auth.uid());

CREATE POLICY "shifts_cashier_update_own_open" ON public.shifts
  FOR UPDATE USING (cashier_id = auth.uid() AND status = 'open')
  WITH CHECK (cashier_id = auth.uid());

CREATE POLICY "shifts_staff_read" ON public.shifts
  FOR SELECT USING (public.is_store_member(store_id));

CREATE POLICY "shifts_staff_insert" ON public.shifts
  FOR INSERT WITH CHECK (public.is_store_member(store_id) AND cashier_id = auth.uid());

CREATE POLICY "shifts_admin_all" ON public.shifts
  FOR ALL USING (public.is_store_admin(store_id)) WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "shifts_superadmin_all" ON public.shifts
  FOR ALL USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());


-- ############################################################################
-- SECTION 5: POLICIES - MIGRATION v14 (org_products)
-- ############################################################################

CREATE POLICY "org_products_members_read" ON public.org_products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id AND user_id = auth.uid()::TEXT
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_write" ON public.org_products
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_update" ON public.org_products
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_delete" ON public.org_products
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );


-- ############################################################################
-- SECTION 6: POLICIES - MIGRATION v15 (invoices)
-- ############################################################################

CREATE POLICY "invoices_select_policy" ON public.invoices
  FOR SELECT USING (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT AND om.is_active = true
    )
  );

CREATE POLICY "invoices_insert_policy" ON public.invoices
  FOR INSERT WITH CHECK (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT AND om.is_active = true
    )
  );

CREATE POLICY "invoices_update_policy" ON public.invoices
  FOR UPDATE USING (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT AND om.is_active = true
    )
  );

-- NOTE: No DELETE policy on invoices (ZATCA compliance - invoices should not be deleted)


-- ############################################################################
-- SECTION 7: POLICIES - MIGRATION v17 (customers, sales, sale_items)
-- ############################################################################
-- WARNING: These currently use "Allow authenticated full access" policies.
--          Proper policies should be:

-- customers
-- CREATE POLICY "customers_staff_read" ON public.customers
--   FOR SELECT USING (public.is_store_member(store_id));
-- CREATE POLICY "customers_staff_insert" ON public.customers
--   FOR INSERT WITH CHECK (public.is_store_member(store_id));
-- CREATE POLICY "customers_staff_update" ON public.customers
--   FOR UPDATE USING (public.is_store_member(store_id)) WITH CHECK (public.is_store_member(store_id));

-- Current (permissive):
CREATE POLICY "Allow authenticated full access" ON public.customers
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- sales
CREATE POLICY "Allow authenticated full access" ON public.sales
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- sale_items
CREATE POLICY "Allow authenticated full access" ON public.sale_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);


-- ############################################################################
-- SECTION 8: POLICIES - MIGRATION v19 (delivery system)
-- ############################################################################

-- driver_locations
CREATE POLICY "drivers_own_location_select" ON public.driver_locations
  FOR SELECT USING (
    driver_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
    OR EXISTS (
      SELECT 1 FROM public.deliveries d
      JOIN public.orders o ON o.id = d.order_id
      WHERE d.driver_id = driver_locations.driver_id
        AND o.customer_id = auth.uid()
        AND d.status NOT IN ('delivered', 'failed', 'cancelled')
    )
  );

CREATE POLICY "drivers_own_location_upsert" ON public.driver_locations
  FOR INSERT WITH CHECK (driver_id = auth.uid());

CREATE POLICY "drivers_own_location_update" ON public.driver_locations
  FOR UPDATE USING (driver_id = auth.uid());

-- driver_shifts
CREATE POLICY "drivers_own_shifts" ON public.driver_shifts
  FOR ALL USING (
    driver_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
  );

-- chat_messages
CREATE POLICY "chat_participants_select" ON public.chat_messages
  FOR SELECT USING (
    sender_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.deliveries d WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
  );

CREATE POLICY "chat_participants_insert" ON public.chat_messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND (
      EXISTS (SELECT 1 FROM public.deliveries d WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid())
      OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
    )
  );

CREATE POLICY "chat_mark_read" ON public.chat_messages
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.deliveries d WHERE d.order_id = chat_messages.order_id AND d.driver_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = chat_messages.order_id AND o.customer_id = auth.uid())
  )
  WITH CHECK (is_read = true);

-- delivery_proofs
CREATE POLICY "proof_driver_insert" ON public.delivery_proofs
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.deliveries d WHERE d.id = delivery_proofs.delivery_id AND d.driver_id = auth.uid())
  );

CREATE POLICY "proof_read" ON public.delivery_proofs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.deliveries d
      WHERE d.id = delivery_proofs.delivery_id
      AND (
        d.driver_id = auth.uid()
        OR EXISTS (SELECT 1 FROM public.orders o WHERE o.id = d.order_id AND o.customer_id = auth.uid())
        OR EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner'))
      )
    )
  );


-- ############################################################################
-- SECTION 9: POLICIES - COMPATIBILITY MIGRATION TABLES
-- ############################################################################
-- WARNING: All 23 tables below use permissive "Allow authenticated full access".
--          These should be replaced with proper store-scoped policies.

-- organizations, subscriptions, org_members, user_stores,
-- roles, discounts, coupons, expenses, expense_categories,
-- purchases, purchase_items, drivers, loyalty_transactions,
-- loyalty_rewards, customer_addresses, order_status_history,
-- pos_terminals, product_expiry, stock_takes, stock_transfers,
-- stock_deltas, whatsapp_templates, settings

-- Example for ONE table (repeat pattern for all):
-- CREATE POLICY "Allow authenticated full access" ON public.organizations
--   FOR ALL TO authenticated USING (true) WITH CHECK (true);


-- ############################################################################
-- SECTION 10: STORAGE POLICIES
-- ############################################################################

-- product-images (public read, auth write scoped to store)
CREATE POLICY "Public read product images" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');

CREATE POLICY "Auth users upload product images" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

CREATE POLICY "Auth users update product images" ON storage.objects
  FOR UPDATE TO authenticated USING (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

CREATE POLICY "Auth users delete product images" ON storage.objects
  FOR DELETE TO authenticated USING (
    bucket_id = 'product-images'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

-- store-logos (public read, owner/admin write)
CREATE POLICY "Public read store logos" ON storage.objects
  FOR SELECT USING (bucket_id = 'store-logos');

CREATE POLICY "Auth users upload store logos" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'store-logos'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

CREATE POLICY "Auth users update store logos" ON storage.objects
  FOR UPDATE TO authenticated USING (
    bucket_id = 'store-logos'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

CREATE POLICY "Auth users delete store logos" ON storage.objects
  FOR DELETE TO authenticated USING (
    bucket_id = 'store-logos'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

-- receipts (private, store member)
CREATE POLICY "Auth users read own receipts" ON storage.objects
  FOR SELECT TO authenticated USING (
    bucket_id = 'receipts'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

CREATE POLICY "Auth users upload receipts" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'receipts'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

-- backups (private, owner/admin)
CREATE POLICY "Owner/admin read backups" ON storage.objects
  FOR SELECT TO authenticated USING (
    bucket_id = 'backups'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

CREATE POLICY "Owner/admin upload backups" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'backups'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

CREATE POLICY "Owner/admin delete backups" ON storage.objects
  FOR DELETE TO authenticated USING (
    bucket_id = 'backups'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid AND us.role IN ('owner', 'admin'))
  );

-- invoice-attachments (private, store member)
CREATE POLICY "Auth users read invoice attachments" ON storage.objects
  FOR SELECT TO authenticated USING (
    bucket_id = 'invoice-attachments'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

CREATE POLICY "Auth users upload invoice attachments" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'invoice-attachments'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

CREATE POLICY "Auth users delete invoice attachments" ON storage.objects
  FOR DELETE TO authenticated USING (
    bucket_id = 'invoice-attachments'
    AND EXISTS (SELECT 1 FROM public.user_stores us WHERE us.user_id = auth.uid() AND us.store_id = (storage.foldername(name))[1]::uuid)
  );

-- delivery-proofs (private, delivery role upload, auth read)
CREATE POLICY "driver_upload_proof" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'delivery-proofs'
    AND auth.uid() IS NOT NULL
    AND EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'delivery')
  );

CREATE POLICY "proof_read_access" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'delivery-proofs'
    AND auth.uid() IS NOT NULL
  );


-- ============================================================================
-- END OF COMBINED RLS POLICIES
-- ============================================================================
