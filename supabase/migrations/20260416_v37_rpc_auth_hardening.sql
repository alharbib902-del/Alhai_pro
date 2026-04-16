-- =============================================================================
-- v37: RPC Auth Hardening — close privilege-escalation and missing-auth gates
-- =============================================================================
-- Date: 2026-04-16
-- Severity: CRITICAL (P0)
--
-- Problem:
--   17 SECURITY DEFINER RPC functions were callable by ANY authenticated user
--   (or in some cases any caller at all) without verifying identity or role.
--   This enables:
--     - Privilege escalation: any user can call sa_monthly_revenue, etc.
--     - Cross-tenant data manipulation: any user can modify another store's
--       stock, orders, or products via apply_stock_deltas, etc.
--
-- Fix categories:
--   A. Super Admin RPCs (3): add is_super_admin() gate
--   B. Store-scoped RPCs (11): add store membership / auth.uid() checks
--   C. Delivery RPCs (2): add auth.uid() verification
--   D. Security event RPC (1): add auth.uid() check
--
-- ROLLBACK: Each function uses CREATE OR REPLACE, so re-running the original
-- migration that created the function will restore the old (vulnerable) version.
-- =============================================================================


-- ############################################################
-- CATEGORY A: Super Admin RPCs — add is_super_admin() gate
-- ############################################################
-- Source: v31 (20260404_v31_sa_plans_table.sql)
-- These 3 functions query cross-tenant analytics (subscriptions, stores, sales).
-- They must only be callable by super_admin users.

-- A1. sa_monthly_revenue()
CREATE OR REPLACE FUNCTION public.sa_monthly_revenue()
RETURNS TABLE(month TEXT, revenue DOUBLE PRECISION)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- AUTH GATE: super admin only
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: super admin access required';
  END IF;

  RETURN QUERY
  SELECT
    to_char(s.created_at, 'YYYY-MM') AS month,
    COALESCE(SUM(
      CASE
        WHEN s.billing_cycle = 'yearly' THEN s.amount / 12
        ELSE s.amount
      END
    ), 0)::DOUBLE PRECISION AS revenue
  FROM public.subscriptions s
  WHERE s.status = 'active'
    AND s.created_at >= (now() - interval '12 months')
  GROUP BY to_char(s.created_at, 'YYYY-MM')
  ORDER BY month;
END;
$$;

-- A2. sa_top_stores_by_revenue(INT)
CREATE OR REPLACE FUNCTION public.sa_top_stores_by_revenue(p_limit INT DEFAULT 5)
RETURNS TABLE(store_id TEXT, store_name TEXT, revenue DOUBLE PRECISION)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- AUTH GATE: super admin only
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: super admin access required';
  END IF;

  RETURN QUERY
  SELECT
    st.id AS store_id,
    st.name AS store_name,
    COALESCE(SUM(sa.total), 0)::DOUBLE PRECISION AS revenue
  FROM public.stores st
  LEFT JOIN public.sales sa ON sa.store_id = st.id
  WHERE st.is_active = true
  GROUP BY st.id, st.name
  ORDER BY revenue DESC
  LIMIT p_limit;
END;
$$;

-- A3. sa_top_stores_by_transactions(INT)
CREATE OR REPLACE FUNCTION public.sa_top_stores_by_transactions(p_limit INT DEFAULT 5)
RETURNS TABLE(store_id TEXT, store_name TEXT, transactions BIGINT, avg_per_day INT, products BIGINT)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- AUTH GATE: super admin only
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: super admin access required';
  END IF;

  RETURN QUERY
  SELECT
    st.id AS store_id,
    st.name AS store_name,
    COUNT(sa.id) AS transactions,
    (COUNT(sa.id) / GREATEST(1, EXTRACT(day FROM now() - MIN(sa.created_at))::INT))::INT AS avg_per_day,
    (SELECT COUNT(*) FROM public.products p WHERE p.store_id = st.id) AS products
  FROM public.stores st
  LEFT JOIN public.sales sa ON sa.store_id = st.id
  WHERE st.is_active = true
  GROUP BY st.id, st.name
  ORDER BY transactions DESC
  LIMIT p_limit;
END;
$$;


-- ############################################################
-- CATEGORY B: Store-scoped RPCs — add auth + store membership
-- ############################################################

-- B1. apply_stock_deltas(TEXT, JSONB) — v16 2-arg variant
-- Modifies product stock_qty. Must verify caller is store member.
CREATE OR REPLACE FUNCTION public.apply_stock_deltas(
  p_store_id TEXT,
  p_deltas JSONB
) RETURNS INTEGER AS $$
DECLARE
  delta_item JSONB;
  v_product_id TEXT;
  v_qty_change DOUBLE PRECISION;
  v_count INTEGER := 0;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- AUTH GATE: must be an active member of the target store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'qty_change')::DOUBLE PRECISION;

    UPDATE public.products
    SET stock_qty = stock_qty + v_qty_change,
        updated_at = NOW()
    WHERE id = v_product_id
      AND store_id = p_store_id;

    IF FOUND THEN
      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B2. apply_stock_deltas(TEXT, TEXT, JSONB) — v14 3-arg variant
CREATE OR REPLACE FUNCTION public.apply_stock_deltas(
  p_org_id TEXT,
  p_store_id TEXT,
  p_deltas JSONB
) RETURNS JSONB AS $$
DECLARE
  delta_item JSONB;
  new_stock NUMERIC;
  result JSONB := '[]'::JSONB;
  v_product_id TEXT;
  v_qty_change NUMERIC;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- AUTH GATE: must be an active member of the target store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'quantity_change')::NUMERIC;

    UPDATE public.products
    SET stock_qty = stock_qty + v_qty_change,
        updated_at = NOW()
    WHERE id = v_product_id
      AND store_id = p_store_id
    RETURNING stock_qty INTO new_stock;

    IF FOUND THEN
      result := result || jsonb_build_object(
        'product_id', v_product_id,
        'final_stock', new_stock
      );
    END IF;
  END LOOP;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B3. reserve_online_stock(TEXT, DOUBLE PRECISION) — v16 variant
CREATE OR REPLACE FUNCTION public.reserve_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS BOOLEAN AS $$
DECLARE
  v_available DOUBLE PRECISION;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT (stock_qty - COALESCE(online_reserved_qty, 0))
    INTO v_available
    FROM public.products
   WHERE id = p_product_id
     FOR UPDATE;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  IF v_available < p_qty THEN
    RETURN FALSE;
  END IF;

  UPDATE public.products
  SET online_reserved_qty = COALESCE(online_reserved_qty, 0) + p_qty,
      updated_at = NOW()
  WHERE id = p_product_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B4. release_online_stock(TEXT, DOUBLE PRECISION) — v16
CREATE OR REPLACE FUNCTION public.release_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS VOID AS $$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.products
  SET online_reserved_qty = GREATEST(0, COALESCE(online_reserved_qty, 0) - p_qty),
      updated_at = NOW()
  WHERE id = p_product_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B5. reserve_online_stock(TEXT, JSONB) — v14 variant
CREATE OR REPLACE FUNCTION public.reserve_online_stock(
  p_store_id TEXT,
  p_items JSONB
) RETURNS JSONB AS $$
DECLARE
  item JSONB;
  v_product_id TEXT;
  v_requested_qty NUMERIC;
  v_available NUMERIC;
  result JSONB := '[]'::JSONB;
  all_ok BOOLEAN := true;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  FOR item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := item->>'product_id';
    v_requested_qty := (item->>'qty')::NUMERIC;

    SELECT LEAST(
      stock_qty - online_reserved_qty,
      COALESCE(online_max_qty, stock_qty - online_reserved_qty)
    ) INTO v_available
    FROM public.products
    WHERE id = v_product_id
      AND store_id = p_store_id
      AND online_available = true
    FOR UPDATE;

    IF v_available IS NULL OR v_available < v_requested_qty THEN
      all_ok := false;
      result := result || jsonb_build_object(
        'product_id', v_product_id,
        'status', 'insufficient',
        'available', COALESCE(v_available, 0),
        'requested', v_requested_qty
      );
    ELSE
      UPDATE public.products
      SET online_reserved_qty = online_reserved_qty + v_requested_qty,
          updated_at = NOW()
      WHERE id = v_product_id AND store_id = p_store_id;

      result := result || jsonb_build_object(
        'product_id', v_product_id,
        'status', 'reserved',
        'reserved_qty', v_requested_qty,
        'remaining', v_available - v_requested_qty
      );
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'success', all_ok,
    'items', result
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B6. release_reserved_stock(TEXT) — v14
CREATE OR REPLACE FUNCTION public.release_reserved_stock(
  p_order_id TEXT
) RETURNS void AS $$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.products p
  SET online_reserved_qty = GREATEST(0, p.online_reserved_qty - oi.qty),
      updated_at = NOW()
  FROM public.order_items oi
  WHERE oi.order_id = p_order_id
    AND p.id = oi.product_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B7. confirm_delivery(TEXT, TEXT) — v14
CREATE OR REPLACE FUNCTION public.confirm_delivery(
  p_order_id TEXT,
  p_confirmation_code TEXT
) RETURNS JSONB AS $$
DECLARE
  v_order RECORD;
  v_max_attempts INTEGER := 3;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT * INTO v_order
  FROM public.orders
  WHERE id = p_order_id::UUID
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_not_found');
  END IF;

  IF v_order.status != 'out_for_delivery' THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_status', 'current_status', v_order.status);
  END IF;

  IF v_order.confirmation_attempts >= v_max_attempts THEN
    RETURN jsonb_build_object('success', false, 'error', 'max_attempts_exceeded');
  END IF;

  IF v_order.confirmation_code = p_confirmation_code THEN
    UPDATE public.orders
    SET status = 'delivered',
        delivered_at = NOW(),
        updated_at = NOW()
    WHERE id = p_order_id::UUID;

    RETURN jsonb_build_object('success', true, 'status', 'delivered');
  ELSE
    UPDATE public.orders
    SET confirmation_attempts = confirmation_attempts + 1,
        updated_at = NOW()
    WHERE id = p_order_id::UUID;

    RETURN jsonb_build_object(
      'success', false,
      'error', 'wrong_code',
      'attempts_remaining', v_max_attempts - v_order.confirmation_attempts - 1
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B8. get_store_stats(TEXT) — v16
-- Returns sensitive business metrics. Must verify store membership.
CREATE OR REPLACE FUNCTION public.get_store_stats(
  p_store_id TEXT
) RETURNS JSONB AS $$
DECLARE
  v_total_products INTEGER;
  v_low_stock INTEGER;
  v_total_sales INTEGER;
  v_total_revenue DOUBLE PRECISION;
  v_today_start TIMESTAMPTZ;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- AUTH GATE: must be an active member of the target store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  v_today_start := date_trunc('day', NOW());

  SELECT COUNT(*)
    INTO v_total_products
    FROM public.products
   WHERE store_id = p_store_id
     AND is_active = true
     AND deleted_at IS NULL;

  SELECT COUNT(*)
    INTO v_low_stock
    FROM public.products
   WHERE store_id = p_store_id
     AND is_active = true
     AND deleted_at IS NULL
     AND min_qty > 0
     AND stock_qty <= min_qty;

  SELECT COALESCE(COUNT(*), 0),
         COALESCE(SUM(total), 0)
    INTO v_total_sales, v_total_revenue
    FROM public.orders
   WHERE store_id = p_store_id
     AND status IN ('completed', 'delivered')
     AND order_date >= v_today_start
     AND deleted_at IS NULL;

  RETURN jsonb_build_object(
    'total_products', v_total_products,
    'low_stock_count', v_low_stock,
    'total_sales_today', v_total_sales,
    'total_revenue_today', v_total_revenue
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B9. sync_org_product_to_stores(TEXT) — v14
-- Modifies product images across stores. Requires authentication.
CREATE OR REPLACE FUNCTION public.sync_org_product_to_stores(
  p_org_product_id TEXT
) RETURNS INTEGER AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.products p
  SET name = op.name,
      barcode = op.barcode,
      sku = op.sku,
      org_image_thumbnail = op.org_image_thumbnail,
      org_image_medium = op.org_image_medium,
      org_image_large = op.org_image_large,
      org_image_hash = op.org_image_hash,
      updated_at = NOW()
  FROM public.org_products op
  WHERE p.org_product_id = op.id
    AND op.id = p_org_product_id
    AND p.image_thumbnail IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B10. update_order_with_items(UUID, TEXT, TEXT, JSONB) — distributor_batch
-- Modifies orders and order_items. Requires authentication.
CREATE OR REPLACE FUNCTION public.update_order_with_items(
  p_order_id UUID,
  p_status TEXT,
  p_notes TEXT DEFAULT NULL,
  p_item_prices JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE orders SET status = p_status, notes = COALESCE(p_notes, notes), updated_at = NOW() WHERE id = p_order_id;

  IF p_item_prices IS NOT NULL THEN
    UPDATE order_items oi SET
      unit_price = (p_item_prices->>oi.id::text)::numeric,
      total = quantity * (p_item_prices->>oi.id::text)::numeric
    WHERE oi.order_id = p_order_id AND p_item_prices ? oi.id::text;

    UPDATE orders SET total = (SELECT COALESCE(SUM(total), 0) FROM order_items WHERE order_id = p_order_id) WHERE id = p_order_id;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;

-- B11. batch_update_product_prices(UUID, JSONB) — distributor_batch
-- Modifies product prices across an org. Requires authentication.
CREATE OR REPLACE FUNCTION public.batch_update_product_prices(
  p_org_id UUID,
  p_prices JSONB
) RETURNS BOOLEAN AS $$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE products p SET
    price = (p_prices->>p.id::text)::numeric,
    updated_at = NOW()
  WHERE p.org_id = p_org_id AND p_prices ? p.id::text;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;


-- ############################################################
-- CATEGORY C: Delivery RPCs — add auth.uid() verification
-- ############################################################

-- C1. get_driver_dashboard_stats(UUID) — v19
-- Takes an arbitrary driver_id; must verify caller IS that driver
-- (or is a super_admin / store_owner who can view driver stats).
CREATE OR REPLACE FUNCTION public.get_driver_dashboard_stats(p_driver_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public, auth
AS $$
DECLARE
  v_today_start TIMESTAMPTZ;
  v_result JSONB;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- AUTH GATE: caller must be the driver themselves, or a super_admin/store_owner
  IF p_driver_id != auth.uid() AND NOT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('super_admin', 'store_owner')
  ) THEN
    RAISE EXCEPTION 'Access denied: can only view own dashboard stats';
  END IF;

  v_today_start := date_trunc('day', now());

  SELECT jsonb_build_object(
    'today_deliveries', COALESCE(
      (SELECT COUNT(*) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'delivered'
       AND delivered_at >= v_today_start), 0),
    'today_earnings', COALESCE(
      (SELECT SUM(delivery_fee) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'delivered'
       AND delivered_at >= v_today_start), 0),
    'active_delivery_id',
      (SELECT id FROM deliveries
       WHERE driver_id = p_driver_id
       AND status NOT IN ('delivered', 'failed', 'cancelled')
       ORDER BY created_at DESC LIMIT 1),
    'active_delivery_status',
      (SELECT status::TEXT FROM deliveries
       WHERE driver_id = p_driver_id
       AND status NOT IN ('delivered', 'failed', 'cancelled')
       ORDER BY created_at DESC LIMIT 1),
    'pending_count',
      (SELECT COUNT(*) FROM deliveries
       WHERE driver_id = p_driver_id AND status = 'assigned'),
    'is_on_shift',
      (SELECT EXISTS(SELECT 1 FROM driver_shifts
       WHERE driver_id = p_driver_id AND status = 'active')),
    'current_shift_id',
      (SELECT id FROM driver_shifts
       WHERE driver_id = p_driver_id AND status = 'active'
       LIMIT 1)
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- C2. assign_delivery_to_driver(UUID, UUID, TEXT) — v19
-- Assigns a driver to a delivery. Should require store admin or super admin.
CREATE OR REPLACE FUNCTION public.assign_delivery_to_driver(
  p_order_id UUID,
  p_driver_id UUID,
  p_store_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_delivery_id UUID;
  v_order_record RECORD;
  v_effective_store_id TEXT;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get order info
  SELECT id, store_id, delivery_address, delivery_lat, delivery_lng, delivery_fee
  INTO v_order_record
  FROM public.orders
  WHERE id = p_order_id;

  IF v_order_record IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'ORDER_NOT_FOUND');
  END IF;

  v_effective_store_id := COALESCE(p_store_id, v_order_record.store_id);

  -- AUTH GATE: caller must be store admin/manager or super_admin
  IF NOT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin'
  ) AND NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = v_effective_store_id
      AND user_id = auth.uid()
      AND is_active = true
      AND role_in_store IN ('owner', 'manager')
  ) THEN
    RAISE EXCEPTION 'Access denied: store admin or super admin required';
  END IF;

  -- Check driver exists and is delivery role
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_driver_id AND role = 'delivery' AND is_active = true) THEN
    RETURN jsonb_build_object('success', false, 'error', 'INVALID_DRIVER');
  END IF;

  -- Check if delivery already exists for this order
  SELECT id INTO v_delivery_id FROM public.deliveries WHERE order_id = p_order_id;

  IF v_delivery_id IS NOT NULL THEN
    UPDATE public.deliveries
    SET driver_id = p_driver_id, status = 'assigned', updated_at = now()
    WHERE id = v_delivery_id;
  ELSE
    INSERT INTO public.deliveries (
      order_id, driver_id, store_id, status,
      delivery_address, delivery_lat, delivery_lng, delivery_fee
    ) VALUES (
      p_order_id, p_driver_id,
      v_effective_store_id,
      'assigned',
      v_order_record.delivery_address,
      v_order_record.delivery_lat,
      v_order_record.delivery_lng,
      COALESCE(v_order_record.delivery_fee, 0)
    )
    RETURNING id INTO v_delivery_id;
  END IF;

  UPDATE public.orders
  SET driver_id = p_driver_id::TEXT, status = 'confirmed'::order_status, updated_at = now()
  WHERE id = p_order_id AND status IN ('created', 'confirmed');

  RETURN jsonb_build_object(
    'success', true,
    'delivery_id', v_delivery_id,
    'driver_id', p_driver_id,
    'order_id', p_order_id
  );
END;
$$;


-- ############################################################
-- CATEGORY D: Security event RPC — add auth check
-- ############################################################

-- D1. insert_security_events(JSONB) — v22
-- Can write arbitrary security events. Must verify caller is authenticated.
CREATE OR REPLACE FUNCTION public.insert_security_events(
  p_events JSONB
) RETURNS INTEGER AS $$
DECLARE
  evt JSONB;
  v_count INTEGER := 0;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  FOR evt IN SELECT * FROM jsonb_array_elements(p_events)
  LOOP
    INSERT INTO public.security_events (
      store_id, user_id, phone, event_type,
      details, metadata, ip_address, device_info, created_at
    ) VALUES (
      evt->>'store_id',
      evt->>'user_id',
      evt->>'phone',
      evt->>'event_type',
      evt->>'details',
      CASE WHEN evt->'metadata' IS NOT NULL AND evt->>'metadata' != 'null'
           THEN (evt->'metadata')
           ELSE NULL END,
      evt->>'ip_address',
      evt->>'device_info',
      COALESCE((evt->>'created_at')::TIMESTAMPTZ, NOW())
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth;


-- =============================================================================
-- GRANT statements (preserve existing permissions, no changes needed)
-- All functions above already have GRANT EXECUTE TO authenticated from their
-- original migrations. CREATE OR REPLACE does not revoke existing grants.
-- =============================================================================

-- =============================================================================
-- END OF MIGRATION v37
-- =============================================================================
