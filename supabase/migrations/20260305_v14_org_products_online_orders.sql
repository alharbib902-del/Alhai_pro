-- Migration v14: كتالوج مركزي + طلبات أونلاين + صور هجينة + نقل مخزون
-- Date: 2026-03-05
-- Description:
--   1. إنشاء جدول org_products (كتالوج المنظمة المركزي)
--   2. إضافة أعمدة صور المنظمة + إعدادات أونلاين للمنتجات
--   3. إضافة أعمدة تأكيد التسليم للطلبات
--   4. تحسين جدول نقل المخزون
--   5. إنشاء RPC functions للمخزون والطلبات
--   6. إنشاء triggers للتنبيهات التلقائية
--   7. تفعيل Realtime للجداول الحرجة

-- ============================================================================
-- 1. جدول كتالوج المنظمة المركزي
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.org_products (
  id TEXT PRIMARY KEY,
  org_id TEXT NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  sku TEXT,
  barcode TEXT,
  description TEXT,
  default_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  cost_price NUMERIC(12,2),
  category_id TEXT,
  unit TEXT,
  -- صور المنظمة (الافتراضية لكل الفروع)
  org_image_thumbnail TEXT,
  org_image_medium TEXT,
  org_image_large TEXT,
  org_image_hash TEXT,
  -- إعدادات أونلاين افتراضية
  online_available BOOLEAN NOT NULL DEFAULT false,
  online_max_qty NUMERIC(12,2),
  min_alert_qty NUMERIC(12,2),
  auto_reorder BOOLEAN NOT NULL DEFAULT false,
  reorder_qty NUMERIC(12,2),
  -- الحالة
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_org_products_org_id ON public.org_products(org_id);
CREATE INDEX IF NOT EXISTS idx_org_products_sku ON public.org_products(sku);
CREATE INDEX IF NOT EXISTS idx_org_products_barcode ON public.org_products(barcode);
CREATE INDEX IF NOT EXISTS idx_org_products_active ON public.org_products(org_id, is_active) WHERE is_active = true;

-- RLS
ALTER TABLE public.org_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "org_products_members_read" ON public.org_products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id
      AND user_id = auth.uid()::TEXT
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_write" ON public.org_products
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id
      AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_update" ON public.org_products
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id
      AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );

CREATE POLICY "org_products_admin_delete" ON public.org_products
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.org_members
      WHERE org_id = org_products.org_id
      AND user_id = auth.uid()::TEXT
      AND role IN ('owner', 'admin')
    )
    OR public.is_super_admin()
  );

-- ============================================================================
-- 2. أعمدة جديدة لجدول المنتجات
-- ============================================================================

-- صور المنظمة المركزية
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS org_image_thumbnail TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS org_image_medium TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS org_image_large TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS org_image_hash TEXT;

-- ربط بكتالوج المنظمة
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS org_product_id TEXT
  REFERENCES public.org_products(id) ON DELETE SET NULL;

-- إعدادات الطلب الأونلاين
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS online_available BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS online_max_qty NUMERIC(12,2);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS online_reserved_qty NUMERIC(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS min_alert_qty NUMERIC(12,2);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS auto_reorder BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS reorder_qty NUMERIC(12,2);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS turnover_rate NUMERIC(8,4);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_online ON public.products(store_id, online_available)
  WHERE online_available = true;
CREATE INDEX IF NOT EXISTS idx_products_org_product ON public.products(org_product_id);

-- ============================================================================
-- 3. أعمدة تأكيد التسليم للطلبات
-- ============================================================================

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS confirmation_code TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS confirmation_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS auto_reorder_triggered BOOLEAN NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_orders_active_status ON public.orders(store_id, status)
  WHERE status NOT IN ('completed', 'cancelled', 'refunded');

-- ============================================================================
-- 4. تحسين جدول نقل المخزون
-- ============================================================================

ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS received_by TEXT;
ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS received_at TIMESTAMPTZ;

-- ============================================================================
-- 5. RPC Functions
-- ============================================================================

-- 5a. تطبيق stock deltas مع قفل الصفوف (لتعدد كاشير)
DROP FUNCTION IF EXISTS public.apply_stock_deltas(TEXT, TEXT, JSONB);
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
  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'quantity_change')::NUMERIC;

    -- قفل الصف لمنع Race conditions بين أجهزة الكاشير
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5b. حجز كمية للطلب الأونلاين
DROP FUNCTION IF EXISTS public.reserve_online_stock(TEXT, JSONB);
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
  FOR item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := item->>'product_id';
    v_requested_qty := (item->>'qty')::NUMERIC;

    -- فحص الكمية المتاحة
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
      -- حجز الكمية
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5c. إلغاء حجز المخزون عند إلغاء طلب
DROP FUNCTION IF EXISTS public.release_reserved_stock(TEXT);
CREATE OR REPLACE FUNCTION public.release_reserved_stock(
  p_order_id TEXT
) RETURNS void AS $$
BEGIN
  UPDATE public.products p
  SET online_reserved_qty = GREATEST(0, p.online_reserved_qty - oi.qty),
      updated_at = NOW()
  FROM public.order_items oi
  WHERE oi.order_id = p_order_id
    AND p.id = oi.product_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5d. تأكيد التسليم بالرمز
DROP FUNCTION IF EXISTS public.confirm_delivery(TEXT, TEXT);
CREATE OR REPLACE FUNCTION public.confirm_delivery(
  p_order_id TEXT,
  p_confirmation_code TEXT
) RETURNS JSONB AS $$
DECLARE
  v_order RECORD;
  v_max_attempts INTEGER := 3;
BEGIN
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
    -- تأكيد ناجح
    UPDATE public.orders
    SET status = 'delivered',
        delivered_at = NOW(),
        updated_at = NOW()
    WHERE id = p_order_id::UUID;

    RETURN jsonb_build_object('success', true, 'status', 'delivered');
  ELSE
    -- رمز خاطئ
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5e. مزامنة صورة المنظمة لكل فروعها
DROP FUNCTION IF EXISTS public.sync_org_product_to_stores(TEXT);
CREATE OR REPLACE FUNCTION public.sync_org_product_to_stores(
  p_org_product_id TEXT
) RETURNS INTEGER AS $$
DECLARE
  v_updated INTEGER;
BEGIN
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
    AND p.image_thumbnail IS NULL;  -- فقط إذا الفرع ما خصص صورة

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.apply_stock_deltas(TEXT, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reserve_online_stock(TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.release_reserved_stock(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_delivery(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.sync_org_product_to_stores(TEXT) TO authenticated;

-- ============================================================================
-- 6. Triggers
-- ============================================================================

-- 6a. تنبيه نفاد المخزون + طلب توريد تلقائي
DROP FUNCTION IF EXISTS public.check_stock_alert();
CREATE OR REPLACE FUNCTION public.check_stock_alert()
RETURNS TRIGGER AS $$
BEGIN
  -- فقط إذا المخزون تغير ووصل لحد التنبيه
  IF NEW.stock_qty <= COALESCE(NEW.min_alert_qty, -1)
     AND (OLD.stock_qty IS NULL OR NEW.stock_qty != OLD.stock_qty)
     AND NEW.min_alert_qty IS NOT NULL THEN

    -- إنشاء إشعارات لكل أعضاء المتجر
    INSERT INTO public.notifications (id, user_id, store_id, type, title, body, is_read, created_at)
    SELECT
      gen_random_uuid(),
      sm.user_id::TEXT,
      NEW.store_id,
      'stock',
      'تنبيه نفاد مخزون',
      format('المنتج "%s" وصل لحد النفاذ (متبقي: %s)', NEW.name, NEW.stock_qty),
      false,
      NOW()
    FROM public.store_members sm
    WHERE sm.store_id = NEW.store_id
      AND sm.is_active = true
      AND sm.role_in_store IN ('owner', 'manager');

    -- طلب توريد تلقائي إذا مفعّل
    IF NEW.auto_reorder = true AND COALESCE(NEW.reorder_qty, 0) > 0 THEN
      INSERT INTO public.purchase_orders (id, store_id, status, notes, created_at, updated_at)
      VALUES (
        gen_random_uuid(),
        NEW.store_id,
        'draft'::po_status,
        format('طلب توريد تلقائي: %s (كمية: %s)', NEW.name, NEW.reorder_qty),
        NOW(),
        NOW()
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_stock_alert ON public.products;
CREATE TRIGGER trigger_stock_alert
  AFTER UPDATE OF stock_qty ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.check_stock_alert();

-- 6b. updated_at تلقائي لـ org_products
DROP FUNCTION IF EXISTS public.update_org_products_updated_at();
CREATE OR REPLACE FUNCTION public.update_org_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_org_products_updated_at ON public.org_products;
CREATE TRIGGER trigger_org_products_updated_at
  BEFORE UPDATE ON public.org_products
  FOR EACH ROW EXECUTE FUNCTION public.update_org_products_updated_at();

-- ============================================================================
-- 7. Realtime
-- ============================================================================

-- تفعيل Realtime على الجداول الحرجة
DO $$
BEGIN
  -- إضافة الجداول للنشر إذا لم تكن موجودة
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'orders'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'products'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'stock_transfers'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.stock_transfers;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'stock_deltas'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.stock_deltas;
  END IF;
END $$;

-- ============================================================================
-- 8. Indexes للأداء
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_stock_deltas_pending_store
  ON public.stock_deltas(store_id, sync_status) WHERE sync_status = 'pending';
