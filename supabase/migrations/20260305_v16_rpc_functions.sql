-- Migration v16: دوال RPC أساسية للمخزون ولوحة التحكم
-- Date: 2026-03-05
-- Description:
--   1. apply_stock_deltas(TEXT, JSONB) - تطبيق تغييرات مخزون مجمعة ذرياً
--   2. reserve_online_stock(TEXT, DOUBLE PRECISION) - حجز مخزون لطلب أونلاين (منتج واحد)
--   3. release_online_stock(TEXT, DOUBLE PRECISION) - إلغاء حجز مخزون (إلغاء طلب)
--   4. get_store_stats(TEXT) - إحصائيات لوحة تحكم المتجر
--
-- NOTE: Column types follow fix_compatibility.sql conventions:
--   - id columns are TEXT (not UUID)
--   - stock_qty is INTEGER
--   - prices/amounts are DOUBLE PRECISION or NUMERIC

-- ============================================================================
-- 1. apply_stock_deltas(p_store_id TEXT, p_deltas JSONB)
--    Apply batch stock changes atomically for a single store.
--    Simpler variant of the 3-arg version in v14 (which also takes org_id).
--    Input: store_id + JSON array of {product_id, qty_change}
--    Returns: count of updated products
-- ============================================================================

DROP FUNCTION IF EXISTS public.apply_stock_deltas(TEXT, JSONB);
CREATE OR REPLACE FUNCTION public.apply_stock_deltas(
  p_store_id TEXT,
  p_deltas JSONB
) RETURNS INTEGER AS $$
DECLARE
  delta_item JSONB;
  v_product_id TEXT;
  v_qty_change INTEGER;
  v_count INTEGER := 0;
BEGIN
  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'qty_change')::INTEGER;

    -- Update stock with row-level lock to prevent race conditions
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 2. reserve_online_stock(p_product_id TEXT, p_qty DOUBLE PRECISION)
--    Reserve stock for a single product (online order).
--    Checks available = stock_qty - online_reserved_qty >= p_qty.
--    Returns: TRUE if reserved successfully, FALSE if insufficient stock.
-- ============================================================================

DROP FUNCTION IF EXISTS public.reserve_online_stock(TEXT, DOUBLE PRECISION);
CREATE OR REPLACE FUNCTION public.reserve_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS BOOLEAN AS $$
DECLARE
  v_available DOUBLE PRECISION;
BEGIN
  -- Lock the row and check available stock
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

  -- Reserve the requested quantity
  UPDATE public.products
  SET online_reserved_qty = COALESCE(online_reserved_qty, 0) + p_qty,
      updated_at = NOW()
  WHERE id = p_product_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 3. release_online_stock(p_product_id TEXT, p_qty DOUBLE PRECISION)
--    Release previously reserved stock (order cancelled/expired).
--    Clamps online_reserved_qty to 0 (never goes negative).
-- ============================================================================

DROP FUNCTION IF EXISTS public.release_online_stock(TEXT, DOUBLE PRECISION);
CREATE OR REPLACE FUNCTION public.release_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS VOID AS $$
BEGIN
  UPDATE public.products
  SET online_reserved_qty = GREATEST(0, COALESCE(online_reserved_qty, 0) - p_qty),
      updated_at = NOW()
  WHERE id = p_product_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 4. get_store_stats(p_store_id TEXT)
--    Returns JSON with dashboard stats for the given store:
--      - total_products: count of active products
--      - low_stock_count: products where stock_qty <= min_qty and min_qty > 0
--      - total_sales_today: number of completed/delivered orders today
--      - total_revenue_today: sum of order totals today
-- ============================================================================

DROP FUNCTION IF EXISTS public.get_store_stats(TEXT);
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
  -- Start of today in UTC (Supabase default)
  v_today_start := date_trunc('day', NOW());

  -- Count active products for this store
  SELECT COUNT(*)
    INTO v_total_products
    FROM public.products
   WHERE store_id = p_store_id
     AND is_active = true
     AND deleted_at IS NULL;

  -- Count products with low stock (stock_qty <= min_qty, only when min_qty > 0)
  SELECT COUNT(*)
    INTO v_low_stock
    FROM public.products
   WHERE store_id = p_store_id
     AND is_active = true
     AND deleted_at IS NULL
     AND min_qty > 0
     AND stock_qty <= min_qty;

  -- Today's completed sales count and revenue
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Grant execute permissions to authenticated users
-- ============================================================================

GRANT EXECUTE ON FUNCTION public.apply_stock_deltas(TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reserve_online_stock(TEXT, DOUBLE PRECISION) TO authenticated;
GRANT EXECUTE ON FUNCTION public.release_online_stock(TEXT, DOUBLE PRECISION) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_store_stats(TEXT) TO authenticated;
