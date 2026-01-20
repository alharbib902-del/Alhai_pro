-- ============================================================================
-- Alhai Platform - Supabase Init SQL
-- Version: 2.4.0
-- Generated: 2026-01-20
-- Target: Supabase Postgres
-- ============================================================================
-- THIS FILE: RUN_AS_NORMAL_MIGRATION - Can run in normal migration context
-- OWNER_ONLY statements are in: supabase_owner_only.sql (run separately)
-- ============================================================================

-- ############################################################################
-- SECTION B: RUN_AS_NORMAL_MIGRATION
-- ############################################################################
-- Run this section first via Supabase migrations or SQL Editor

-- ============================================================================
-- 1. EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- 2. ENUMS
-- ============================================================================

DO $$ BEGIN CREATE TYPE user_role AS ENUM ('super_admin', 'store_owner', 'employee', 'delivery', 'customer'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE store_role AS ENUM ('owner', 'manager', 'cashier'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE order_status AS ENUM ('created', 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'picked_up', 'completed', 'cancelled', 'refunded'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE delivery_status AS ENUM ('assigned', 'accepted', 'picked_up', 'delivered', 'cancelled', 'failed'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE payment_method AS ENUM ('cash', 'card', 'credit', 'wallet'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE adjustment_type AS ENUM ('received', 'sold', 'adjustment', 'damaged', 'returned'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE debt_type AS ENUM ('customer_debt', 'supplier_debt'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE po_status AS ENUM ('draft', 'ordered', 'partial', 'received', 'cancelled'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE promo_type AS ENUM ('percentage', 'fixed_amount', 'buy_x_get_y'); EXCEPTION WHEN duplicate_object THEN null; END $$;
DO $$ BEGIN CREATE TYPE shift_status AS ENUM ('open', 'closed'); EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ============================================================================
-- 3. TABLES
-- ============================================================================

-- users
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  role user_role NOT NULL DEFAULT 'customer',
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  fcm_token TEXT,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- role_audit_log
CREATE TABLE public.role_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  old_role user_role NOT NULL,
  new_role user_role NOT NULL,
  changed_by UUID NOT NULL REFERENCES public.users(id),
  changed_at TIMESTAMPTZ DEFAULT now(),
  reason TEXT
);

-- stores
CREATE TABLE public.stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.users(id),
  name VARCHAR(255) NOT NULL,
  name_ar VARCHAR(255),
  description TEXT,
  logo_url TEXT,
  cover_url TEXT,
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  city VARCHAR(100),
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  rating DECIMAL(2,1) DEFAULT 0,
  rating_count INT DEFAULT 0,
  opening_time TIME,
  closing_time TIME,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- store_members
CREATE TABLE public.store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role_in_store store_role NOT NULL DEFAULT 'cashier',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(store_id, user_id)
);

-- categories
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  name_ar VARCHAR(255),
  image_url TEXT,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- products
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  barcode VARCHAR(100),
  name VARCHAR(255) NOT NULL,
  name_ar VARCHAR(255),
  description TEXT,
  image_url TEXT,
  price DECIMAL(10,2) NOT NULL,
  cost_price DECIMAL(10,2),
  compare_at_price DECIMAL(10,2),
  stock_qty INT DEFAULT 0,
  min_stock_qty INT DEFAULT 0,
  track_inventory BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  unit VARCHAR(50) DEFAULT 'piece',
  weight DECIMAL(10,3),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- addresses
CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  label VARCHAR(100),
  full_address TEXT NOT NULL,
  city VARCHAR(100),
  district VARCHAR(100),
  street VARCHAR(255),
  building VARCHAR(100),
  floor VARCHAR(50),
  apartment VARCHAR(50),
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- orders
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id),
  customer_id UUID REFERENCES public.users(id),
  address_id UUID REFERENCES public.addresses(id),
  order_number VARCHAR(50),
  status order_status NOT NULL DEFAULT 'created',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  payment_method payment_method,
  payment_status VARCHAR(20) DEFAULT 'pending',
  notes TEXT,
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  scheduled_at TIMESTAMPTZ,
  confirmed_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- order_items
CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id),
  product_name VARCHAR(255) NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  notes TEXT
);

-- suppliers
CREATE TABLE public.suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  contact_name VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- debts
CREATE TABLE public.debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  type debt_type NOT NULL,
  customer_id UUID REFERENCES public.users(id),
  supplier_id UUID REFERENCES public.suppliers(id),
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  order_id UUID REFERENCES public.orders(id),
  original_amount DECIMAL(10,2) NOT NULL,
  remaining_amount DECIMAL(10,2) NOT NULL,
  due_date DATE,
  notes TEXT,
  is_settled BOOLEAN DEFAULT false,
  settled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- debt_payments
CREATE TABLE public.debt_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  debt_id UUID NOT NULL REFERENCES public.debts(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method payment_method,
  notes TEXT,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- deliveries
CREATE TABLE public.deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES public.users(id),
  status delivery_status NOT NULL DEFAULT 'assigned',
  pickup_address TEXT,
  delivery_address TEXT,
  pickup_lat DECIMAL(10,8),
  pickup_lng DECIMAL(11,8),
  delivery_lat DECIMAL(10,8),
  delivery_lng DECIMAL(11,8),
  distance_km DECIMAL(10,2),
  estimated_time_minutes INT,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- customer_accounts
CREATE TABLE public.customer_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.users(id),
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(12,2) DEFAULT 0,
  last_order_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(store_id, customer_id)
);

-- loyalty_points
CREATE TABLE public.loyalty_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.users(id),
  points INT NOT NULL DEFAULT 0,
  points_earned INT NOT NULL DEFAULT 0,
  points_redeemed INT NOT NULL DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_redeemed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(store_id, customer_id)
);

-- stock_adjustments
CREATE TABLE public.stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id),
  type adjustment_type NOT NULL,
  quantity INT NOT NULL,
  previous_qty INT NOT NULL,
  new_qty INT NOT NULL,
  reference_id UUID,
  reference_type VARCHAR(50),
  reason TEXT,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- purchase_orders
CREATE TABLE public.purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES public.suppliers(id),
  po_number VARCHAR(50),
  status po_status NOT NULL DEFAULT 'draft',
  subtotal DECIMAL(12,2) DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(12,2) DEFAULT 0,
  notes TEXT,
  ordered_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- purchase_order_items
CREATE TABLE public.purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id UUID NOT NULL REFERENCES public.purchase_orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id),
  product_name VARCHAR(255) NOT NULL,
  qty_ordered INT NOT NULL,
  qty_received INT DEFAULT 0,
  unit_cost DECIMAL(10,2) NOT NULL,
  total_cost DECIMAL(10,2) NOT NULL
);

-- notifications (v2.4.0)
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  body TEXT,
  type VARCHAR(50),
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- promotions (v2.4.0)
CREATE TABLE public.promotions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50),
  type promo_type NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2),
  max_discount DECIMAL(10,2),
  usage_limit INT,
  usage_count INT DEFAULT 0,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- order_payments (v2.4.0)
CREATE TABLE public.order_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  method payment_method NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  reference_no VARCHAR(100),
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- store_settings (v2.4.0)
CREATE TABLE public.store_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID UNIQUE NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  receipt_header TEXT,
  receipt_footer TEXT,
  tax_rate DECIMAL(5,2) DEFAULT 15.00,
  low_stock_threshold INT DEFAULT 10,
  enable_loyalty BOOLEAN DEFAULT true,
  loyalty_points_per_rial INT DEFAULT 1,
  auto_print_receipt BOOLEAN DEFAULT true,
  currency VARCHAR(10) DEFAULT 'SAR',
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- activity_logs (v2.4.0)
CREATE TABLE public.activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE SET NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50),
  entity_id UUID,
  details JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- shifts (v2.4.0)
CREATE TABLE public.shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  cashier_id UUID NOT NULL REFERENCES public.users(id),
  opening_cash DECIMAL(10,2) NOT NULL,
  closing_cash DECIMAL(10,2),
  expected_cash DECIMAL(10,2),
  cash_difference DECIMAL(10,2),
  status shift_status DEFAULT 'open',
  opened_at TIMESTAMPTZ DEFAULT now(),
  closed_at TIMESTAMPTZ,
  notes TEXT
);

-- ============================================================================
-- 4. INDEXES
-- ============================================================================

CREATE INDEX ON public.role_audit_log (user_id, changed_at DESC);
CREATE INDEX ON public.role_audit_log (changed_by, changed_at DESC);

CREATE INDEX ON public.stores (owner_id);
CREATE INDEX ON public.stores (is_active, city);

CREATE INDEX ON public.store_members (user_id, is_active);

CREATE INDEX ON public.categories (store_id, is_active, sort_order);

CREATE INDEX ON public.products (store_id, is_active);
CREATE INDEX ON public.products (store_id, category_id);
CREATE INDEX ON public.products (store_id, barcode);

CREATE INDEX ON public.addresses (user_id, is_default);

CREATE INDEX ON public.orders (store_id, status, created_at DESC);
CREATE INDEX ON public.orders (customer_id, created_at DESC);
CREATE INDEX ON public.orders (store_id, order_number);

CREATE INDEX ON public.order_items (order_id);
CREATE INDEX ON public.order_items (product_id);

CREATE INDEX ON public.suppliers (store_id, is_active);

CREATE INDEX ON public.debts (store_id, type, is_settled);
CREATE INDEX ON public.debts (customer_id);
CREATE INDEX ON public.debts (supplier_id);

CREATE INDEX ON public.debt_payments (debt_id, created_at DESC);

CREATE INDEX ON public.deliveries (driver_id, status);
CREATE INDEX ON public.deliveries (order_id);

CREATE INDEX ON public.customer_accounts (customer_id);

CREATE INDEX ON public.loyalty_points (customer_id);

CREATE INDEX ON public.stock_adjustments (store_id, created_at DESC);
CREATE INDEX ON public.stock_adjustments (product_id, created_at DESC);

CREATE INDEX ON public.purchase_orders (store_id, status, created_at DESC);
CREATE INDEX ON public.purchase_orders (supplier_id);

CREATE INDEX ON public.purchase_order_items (purchase_order_id);
CREATE INDEX ON public.purchase_order_items (product_id);

CREATE INDEX ON public.notifications (user_id, is_read, created_at DESC);

CREATE INDEX ON public.promotions (store_id, is_active);
CREATE UNIQUE INDEX ON public.promotions (store_id, code) WHERE code IS NOT NULL;

CREATE INDEX ON public.order_payments (order_id);

CREATE INDEX ON public.activity_logs (store_id, created_at DESC);
CREATE INDEX ON public.activity_logs (user_id, created_at DESC);

CREATE INDEX ON public.shifts (store_id, status, opened_at DESC);
CREATE INDEX ON public.shifts (cashier_id, opened_at DESC);
CREATE UNIQUE INDEX ON public.shifts (cashier_id) WHERE status = 'open';

-- ============================================================================
-- 5. CONSTRAINTS
-- ============================================================================

ALTER TABLE public.deliveries ADD CONSTRAINT deliveries_order_unique UNIQUE(order_id);
ALTER TABLE public.order_items ADD CONSTRAINT order_items_unique_product_per_order UNIQUE(order_id, product_id);

-- ============================================================================
-- 6. HELPER FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin');
$$;

CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id UUID)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
SELECT EXISTS (
    SELECT 1 FROM public.store_members 
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
);
$$;

CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id UUID)
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

-- ============================================================================
-- 7. TRIGGER FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.prevent_direct_role_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, auth
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role 
     AND COALESCE(current_setting('app.role_update', true), '') != '1' THEN
    RAISE EXCEPTION 'role لا يتغير إلا عبر RPC update_user_role';
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.prevent_store_id_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
IF OLD.store_id IS DISTINCT FROM NEW.store_id THEN
    RAISE EXCEPTION 'لا يمكن تغيير store_id بعد الإنشاء';
END IF;
RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.deduct_stock_on_order_confirm()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
v_insufficient_count INT;
BEGIN
IF NOT (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
    RETURN NEW;
END IF;

PERFORM 1
FROM public.order_items oi
JOIN public.products p ON p.id = oi.product_id
WHERE oi.order_id = NEW.id
    AND p.track_inventory = true
ORDER BY p.id
FOR UPDATE OF p;

SELECT COUNT(*) INTO v_insufficient_count
FROM public.order_items oi
JOIN public.products p ON p.id = oi.product_id
WHERE oi.order_id = NEW.id
    AND p.track_inventory = true
    AND p.stock_qty < oi.qty;

IF v_insufficient_count > 0 THEN
    RAISE EXCEPTION 'المخزون غير كافٍ لأحد المنتجات';
END IF;

INSERT INTO public.stock_adjustments (
    store_id, product_id, type, quantity,
    previous_qty, new_qty, reference_id, reference_type, created_by
)
SELECT
    NEW.store_id, oi.product_id, 'sold', -oi.qty,
    p.stock_qty, p.stock_qty - oi.qty,
    NEW.id, 'order', NEW.customer_id
FROM public.order_items oi
JOIN public.products p ON p.id = oi.product_id
WHERE oi.order_id = NEW.id AND p.track_inventory = true;

UPDATE public.products p
SET stock_qty = p.stock_qty - oi.qty,
    updated_at = now()
FROM public.order_items oi
WHERE oi.order_id = NEW.id
    AND p.id = oi.product_id
    AND p.track_inventory = true;

RETURN NEW;
END;
$$;

-- ============================================================================
-- 8. RPC FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_user_role(
  p_user_id UUID,
  p_new_role user_role,
  p_reason TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_old_role user_role;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'معرف المستخدم مطلوب';
  END IF;
  
  SELECT role INTO v_old_role FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF v_old_role IS NULL THEN
    RAISE EXCEPTION 'المستخدم غير موجود';
  END IF;
  
  IF p_new_role = v_old_role THEN
    RAISE EXCEPTION 'الدور الجديد مطابق للدور الحالي';
  END IF;
  
  IF NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'غير مصرح بتغيير الدور';
  END IF;
  
  IF v_old_role = 'super_admin' THEN
    RAISE EXCEPTION 'لا يمكن تغيير دور سوبر أدمن آخر';
  END IF;
  
  BEGIN
    PERFORM set_config('app.role_update', '1', true);
    
    UPDATE public.users SET role = p_new_role, updated_at = now()
    WHERE id = p_user_id;
    
    IF NOT FOUND THEN
      RAISE EXCEPTION 'فشل تحديث الدور';
    END IF;
    
    INSERT INTO public.role_audit_log (user_id, old_role, new_role, changed_by, reason)
    VALUES (p_user_id, v_old_role, p_new_role, auth.uid(), p_reason);
    
    PERFORM set_config('app.role_update', '0', true);
  EXCEPTION WHEN OTHERS THEN
    PERFORM set_config('app.role_update', '0', true);
    RAISE;
  END;
END;
$$;

-- ============================================================================
-- 9. TRIGGERS
-- ============================================================================

CREATE TRIGGER prevent_direct_role_update
BEFORE UPDATE OF role ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.prevent_direct_role_update();

CREATE TRIGGER prevent_store_id_change_products BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.prevent_store_id_change();

CREATE TRIGGER prevent_store_id_change_store_members BEFORE UPDATE ON public.store_members
FOR EACH ROW EXECUTE FUNCTION public.prevent_store_id_change();

CREATE TRIGGER prevent_store_id_change_debts BEFORE UPDATE ON public.debts
FOR EACH ROW EXECUTE FUNCTION public.prevent_store_id_change();

CREATE TRIGGER prevent_store_id_change_purchase_orders BEFORE UPDATE ON public.purchase_orders
FOR EACH ROW EXECUTE FUNCTION public.prevent_store_id_change();

CREATE TRIGGER on_order_status_change
AFTER UPDATE OF status ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.deduct_stock_on_order_confirm();

-- ============================================================================
-- 10. REVOKE STATEMENTS
-- ============================================================================

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

-- ============================================================================
-- 11. ENABLE ROW LEVEL SECURITY
-- ============================================================================

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

-- ============================================================================
-- 12. CREATE POLICIES
-- ============================================================================

-- role_audit_log
CREATE POLICY "role_audit_superadmin_read" ON public.role_audit_log FOR SELECT
  USING (public.is_super_admin());

-- users
CREATE POLICY "users_superadmin_select" ON public.users FOR SELECT
USING (public.is_super_admin());

CREATE POLICY "users_self_select" ON public.users FOR SELECT
USING (id = auth.uid());

CREATE POLICY "users_self_update" ON public.users FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

CREATE POLICY "users_superadmin_update" ON public.users FOR UPDATE
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

-- stores
CREATE POLICY "stores_superadmin_all" ON public.stores FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "stores_public_read_active" ON public.stores FOR SELECT
USING (is_active = true);

CREATE POLICY "stores_staff_read_own" ON public.stores FOR SELECT
USING (public.is_store_admin(id));

CREATE POLICY "stores_owner_insert" ON public.stores FOR INSERT
WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_update" ON public.stores FOR UPDATE
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_delete" ON public.stores FOR DELETE
USING (owner_id = auth.uid());

-- store_members
CREATE POLICY "store_members_superadmin_all" ON public.store_members FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "store_members_admin_insert" ON public.store_members FOR INSERT
WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_update" ON public.store_members FOR UPDATE
USING (public.is_store_admin(store_id))
WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_delete" ON public.store_members FOR DELETE
USING (public.is_store_admin(store_id));

CREATE POLICY "store_members_self_read" ON public.store_members FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "store_members_staff_read" ON public.store_members FOR SELECT
USING (public.is_store_member(store_id));

-- categories
CREATE POLICY "categories_superadmin_all" ON public.categories FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "categories_public_read_active" ON public.categories FOR SELECT
USING (
    is_active = true 
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
);

CREATE POLICY "categories_staff_read_all" ON public.categories FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "categories_staff_insert" ON public.categories FOR INSERT
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "categories_staff_update" ON public.categories FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "categories_staff_delete" ON public.categories FOR DELETE
USING (public.is_store_member(store_id));

-- products
CREATE POLICY "products_superadmin_all" ON public.products FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "products_public_read_active" ON public.products FOR SELECT
USING (
    is_active = true 
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
);

CREATE POLICY "products_staff_read_all" ON public.products FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "products_staff_insert" ON public.products FOR INSERT
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "products_staff_update" ON public.products FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "products_staff_delete" ON public.products FOR DELETE
USING (public.is_store_member(store_id));

-- orders
CREATE POLICY "orders_superadmin_all" ON public.orders FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "orders_customer_read" ON public.orders FOR SELECT
USING (customer_id = auth.uid());

CREATE POLICY "orders_customer_insert" ON public.orders FOR INSERT
WITH CHECK (customer_id = auth.uid());

CREATE POLICY "orders_customer_update_created" ON public.orders FOR UPDATE
USING (customer_id = auth.uid() AND status = 'created')
WITH CHECK (customer_id = auth.uid() AND status = 'created');

CREATE POLICY "orders_staff_read" ON public.orders FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "orders_staff_update" ON public.orders FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

-- order_items
DROP POLICY IF EXISTS "order_items_staff_all" ON public.order_items;

CREATE POLICY "order_items_superadmin_all" ON public.order_items FOR ALL
USING (public.is_super_admin())
WITH CHECK (public.is_super_admin());

CREATE POLICY "order_items_read_via_order" ON public.order_items FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id 
    AND (o.customer_id = auth.uid() OR public.is_store_member(o.store_id))
));

CREATE POLICY "order_items_customer_insert" ON public.order_items FOR INSERT
WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o
    JOIN public.products p ON p.id = product_id
    WHERE o.id = order_id
    AND o.customer_id = auth.uid()
    AND o.status = 'created'
    AND p.store_id = o.store_id
    AND p.is_active = true
));

CREATE POLICY "order_items_staff_read" ON public.order_items FOR SELECT
USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "order_items_staff_insert" ON public.order_items FOR INSERT
WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o 
    WHERE o.id = order_id 
    AND public.is_store_member(o.store_id)
    AND o.status = 'created'
));

CREATE POLICY "order_items_staff_update_created" ON public.order_items FOR UPDATE
USING (EXISTS (
    SELECT 1 FROM public.orders o 
    WHERE o.id = order_id 
    AND public.is_store_member(o.store_id)
    AND o.status = 'created'
))
WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o 
    WHERE o.id = order_id 
    AND public.is_store_member(o.store_id)
    AND o.status = 'created'
));

CREATE POLICY "order_items_staff_delete_created" ON public.order_items FOR DELETE
USING (EXISTS (
    SELECT 1 FROM public.orders o 
    WHERE o.id = order_id 
    AND public.is_store_member(o.store_id)
    AND o.status = 'created'
));

-- suppliers
CREATE POLICY "suppliers_superadmin_all" ON public.suppliers FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "suppliers_staff_read" ON public.suppliers FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_insert" ON public.suppliers FOR INSERT
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_update" ON public.suppliers FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_delete" ON public.suppliers FOR DELETE
USING (public.is_store_member(store_id));

-- debts
CREATE POLICY "debts_superadmin_all" ON public.debts FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debts_staff_read" ON public.debts FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "debts_staff_insert" ON public.debts FOR INSERT
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "debts_staff_update" ON public.debts FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "debts_staff_delete" ON public.debts FOR DELETE
USING (public.is_store_member(store_id));

-- debt_payments
CREATE POLICY "debt_payments_superadmin_all" ON public.debt_payments FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debt_payments_staff_read" ON public.debt_payments FOR SELECT
USING (EXISTS (SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_member(d.store_id)));

CREATE POLICY "debt_payments_staff_insert" ON public.debt_payments FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_member(d.store_id)));

-- deliveries
CREATE POLICY "deliveries_superadmin_all" ON public.deliveries FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "deliveries_driver_read" ON public.deliveries FOR SELECT
USING (driver_id = auth.uid());

CREATE POLICY "deliveries_driver_update" ON public.deliveries FOR UPDATE
USING (driver_id = auth.uid())
WITH CHECK (driver_id = auth.uid());

CREATE POLICY "deliveries_staff_read" ON public.deliveries FOR SELECT
USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "deliveries_staff_update" ON public.deliveries FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)))
WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "deliveries_staff_insert" ON public.deliveries FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

-- purchase_orders
CREATE POLICY "purchase_orders_superadmin_all" ON public.purchase_orders FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "purchase_orders_staff_read" ON public.purchase_orders FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_insert" ON public.purchase_orders FOR INSERT
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_update" ON public.purchase_orders FOR UPDATE
USING (public.is_store_member(store_id))
WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_delete" ON public.purchase_orders FOR DELETE
USING (public.is_store_member(store_id));

-- purchase_order_items
CREATE POLICY "po_items_superadmin_all" ON public.purchase_order_items FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "po_items_staff_all" ON public.purchase_order_items FOR ALL
USING (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_member(po.store_id)))
WITH CHECK (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_member(po.store_id)));

-- addresses
CREATE POLICY "addresses_user_all" ON public.addresses FOR ALL
USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- customer_accounts
CREATE POLICY "customer_accounts_superadmin_all" ON public.customer_accounts FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "customer_accounts_customer_read" ON public.customer_accounts FOR SELECT
USING (customer_id = auth.uid());

CREATE POLICY "customer_accounts_staff_read" ON public.customer_accounts FOR SELECT
USING (public.is_store_member(store_id));

-- loyalty_points
CREATE POLICY "loyalty_points_superadmin_all" ON public.loyalty_points FOR ALL
USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "loyalty_points_customer_read" ON public.loyalty_points FOR SELECT
USING (customer_id = auth.uid());

CREATE POLICY "loyalty_points_staff_read" ON public.loyalty_points FOR SELECT
USING (public.is_store_member(store_id));

-- stock_adjustments
CREATE POLICY "stock_adj_superadmin_select" ON public.stock_adjustments FOR SELECT
USING (public.is_super_admin());

CREATE POLICY "stock_adj_superadmin_insert" ON public.stock_adjustments FOR INSERT
WITH CHECK (public.is_super_admin());

CREATE POLICY "stock_adj_staff_read" ON public.stock_adjustments FOR SELECT
USING (public.is_store_member(store_id));

CREATE POLICY "stock_adj_staff_insert" ON public.stock_adjustments FOR INSERT
WITH CHECK (public.is_store_member(store_id));

-- notifications (v2.4.0)
CREATE POLICY "notifications_user_read" ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "notifications_user_update" ON public.notifications FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "notifications_superadmin_all" ON public.notifications FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- promotions (v2.4.0)
CREATE POLICY "promotions_public_read_active" ON public.promotions FOR SELECT
  USING (
    is_active = true 
    AND now() BETWEEN start_date AND end_date
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
  );

CREATE POLICY "promotions_staff_all" ON public.promotions FOR ALL
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "promotions_superadmin_all" ON public.promotions FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- order_payments (v2.4.0)
CREATE POLICY "order_payments_read_via_order" ON public.order_payments FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id 
    AND (o.customer_id = auth.uid() OR public.is_store_member(o.store_id))
  ));

CREATE POLICY "order_payments_staff_insert" ON public.order_payments FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)
  ));

CREATE POLICY "order_payments_superadmin_all" ON public.order_payments FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- store_settings (v2.4.0)
CREATE POLICY "store_settings_staff_read" ON public.store_settings FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "store_settings_admin_update" ON public.store_settings FOR UPDATE
  USING (public.is_store_admin(store_id))
  WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_settings_admin_insert" ON public.store_settings FOR INSERT
  WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_settings_superadmin_all" ON public.store_settings FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- activity_logs (v2.4.0)
CREATE POLICY "activity_logs_staff_read" ON public.activity_logs FOR SELECT
  USING (public.is_store_admin(store_id));

CREATE POLICY "activity_logs_staff_insert" ON public.activity_logs FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "activity_logs_superadmin_all" ON public.activity_logs FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- shifts (v2.4.0)
CREATE POLICY "shifts_cashier_read_own" ON public.shifts FOR SELECT
  USING (cashier_id = auth.uid());

CREATE POLICY "shifts_cashier_update_own_open" ON public.shifts FOR UPDATE
  USING (cashier_id = auth.uid() AND status = 'open')
  WITH CHECK (cashier_id = auth.uid());

CREATE POLICY "shifts_staff_read" ON public.shifts FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "shifts_staff_insert" ON public.shifts FOR INSERT
  WITH CHECK (public.is_store_member(store_id) AND cashier_id = auth.uid());

CREATE POLICY "shifts_admin_all" ON public.shifts FOR ALL
  USING (public.is_store_admin(store_id))
  WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "shifts_superadmin_all" ON public.shifts FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());


-- ============================================================================
-- END OF SECTION B (RUN_AS_NORMAL_MIGRATION)
-- ============================================================================
-- ⚠️ NEXT STEP: Run supabase_owner_only.sql from SQL Editor as Project Owner
-- ============================================================================


