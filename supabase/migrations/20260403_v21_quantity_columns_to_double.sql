-- ============================================================================
-- v21: تحويل أعمدة الكميات من integer إلى double precision
-- ============================================================================
-- المشكلة: Drift (المحلي) يستخدم REAL للكميات لدعم الكميات الكسرية
-- (مثال: 2.5 كجم أرز) بينما Supabase لا يزال يستخدم integer.
-- هذا يسبب:
--   1. فقدان الدقة عند المزامنة (2.5 → 2)
--   2. أخطاء في المطابقة بين القاعدتين
--
-- الجداول المتأثرة:
--   - products: stock_qty, min_qty
--   - inventory_movements: qty, previous_qty, new_qty
--   - purchase_items: qty, received_qty
--   - return_items: qty
--   - stock_deltas: quantity_change
-- ============================================================================

-- 1. products: stock_qty, min_qty
ALTER TABLE public.products
  ALTER COLUMN stock_qty TYPE double precision USING stock_qty::double precision,
  ALTER COLUMN min_qty TYPE double precision USING min_qty::double precision;

-- 2. inventory_movements: qty, previous_qty, new_qty
ALTER TABLE public.inventory_movements
  ALTER COLUMN qty TYPE double precision USING qty::double precision,
  ALTER COLUMN previous_qty TYPE double precision USING previous_qty::double precision,
  ALTER COLUMN new_qty TYPE double precision USING new_qty::double precision;

-- 3. purchase_items: qty, received_qty
ALTER TABLE public.purchase_items
  ALTER COLUMN qty TYPE double precision USING qty::double precision,
  ALTER COLUMN received_qty TYPE double precision USING received_qty::double precision;

-- 4. return_items: qty
ALTER TABLE public.return_items
  ALTER COLUMN qty TYPE double precision USING qty::double precision;

-- 5. stock_deltas: quantity_change
ALTER TABLE public.stock_deltas
  ALTER COLUMN quantity_change TYPE double precision USING quantity_change::double precision;
