-- =====================================================
-- دوال RPC لمزامنة البيانات من Supabase → Local DB
-- نفذها في SQL Editor في Supabase Dashboard
-- مصدر الحقيقة: Live DB schema (information_schema)
-- الأنواع: stores.id=TEXT, store_id=TEXT, category/product IDs=TEXT
-- =====================================================

-- 1. دالة جلب التصنيفات حسب المتجر
-- SECURITY DEFINER لتجاوز RLS
CREATE OR REPLACE FUNCTION get_store_categories(p_store_id TEXT)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Input validation (M19 fix)
  IF p_store_id IS NULL OR TRIM(p_store_id) = '' THEN
    RAISE EXCEPTION 'store_id is required and cannot be empty';
  END IF;

  -- Authorization: verify caller is an active member of the store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id
      AND user_id = auth.uid()
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  RETURN COALESCE(
    (SELECT jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'org_id', c.org_id,
        'store_id', c.store_id,
        'name', c.name,
        'name_en', c.name_en,
        'parent_id', c.parent_id,
        'image_url', c.image_url,
        'color', c.color,
        'icon', c.icon,
        'sort_order', c.sort_order,
        'is_active', c.is_active,
        'created_at', c.created_at,
        'updated_at', c.updated_at
      )
    )
    FROM public.categories c
    WHERE c.store_id = p_store_id
      AND c.is_active = true
    ),
    '[]'::jsonb
  );
END;
$$;

-- 2. دالة جلب المنتجات حسب المتجر
-- SECURITY DEFINER لتجاوز RLS
CREATE OR REPLACE FUNCTION get_store_products(
  p_store_id TEXT,
  p_limit INT DEFAULT 500,
  p_offset INT DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Input validation (M19 fix)
  IF p_store_id IS NULL OR TRIM(p_store_id) = '' THEN
    RAISE EXCEPTION 'store_id is required and cannot be empty';
  END IF;

  -- Authorization: verify caller is an active member of the store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id
      AND user_id = auth.uid()
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  -- Clamp limit to prevent abuse
  IF p_limit > 1000 THEN
    p_limit := 1000;
  END IF;

  RETURN COALESCE(
    (SELECT jsonb_agg(row_data) FROM (
      SELECT jsonb_build_object(
        'id', p.id,
        'org_id', p.org_id,
        'store_id', p.store_id,
        'category_id', p.category_id,
        'sku', p.sku,
        'barcode', p.barcode,
        'name', p.name,
        'description', p.description,
        'image_thumbnail', p.image_thumbnail,
        'image_medium', p.image_medium,
        'image_large', p.image_large,
        'image_hash', p.image_hash,
        'price', p.price,
        'cost_price', p.cost_price,
        'stock_qty', p.stock_qty,
        'min_qty', p.min_qty,
        'unit', p.unit,
        'track_inventory', p.track_inventory,
        'is_active', p.is_active,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) AS row_data
      FROM public.products p
      WHERE p.store_id = p_store_id
        AND p.is_active = true
      ORDER BY p.name
      LIMIT p_limit
      OFFSET p_offset
    ) sub),
    '[]'::jsonb
  );
END;
$$;

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION get_store_categories(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_store_products(TEXT, INT, INT) TO authenticated;

-- 3. دالة تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- تطبيق trigger على جميع الجداول الرئيسية
DO $$
DECLARE
  tbl TEXT;
  tables TEXT[] := ARRAY[
    'products', 'categories', 'sales', 'sale_items',
    'orders', 'order_items', 'customers', 'suppliers',
    'purchases', 'purchase_items', 'returns', 'return_items',
    'accounts', 'transactions', 'inventory_movements',
    'stores', 'organizations', 'org_members', 'user_stores',
    'loyalty_points', 'loyalty_transactions', 'loyalty_rewards',
    'expenses', 'shifts', 'pos_terminals', 'notifications',
    'discounts', 'settings'
  ];
BEGIN
  FOREACH tbl IN ARRAY tables
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_%I_updated_at ON public.%I;
       CREATE TRIGGER trg_%I_updated_at
         BEFORE UPDATE ON public.%I
         FOR EACH ROW
         EXECUTE FUNCTION update_updated_at_column();',
      tbl, tbl, tbl, tbl
    );
  END LOOP;
END;
$$;
