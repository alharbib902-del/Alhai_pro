-- Migration: Remove products_public_select and fix is_store_member
-- Date: 2026-01-19
-- Description: Secure public products access via Edge Function instead of RLS

-- 1. Remove the vulnerable public policy
DROP POLICY IF EXISTS "products_public_select" ON products;

-- 2. Fix is_store_member function with secure search_path
CREATE OR REPLACE FUNCTION is_store_member(store_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.stores WHERE id = store_uuid AND owner_id = auth.uid()
    UNION
    SELECT 1 FROM public.store_staff WHERE store_id = store_uuid AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 3. Ensure store_staff table has proper RLS
ALTER TABLE store_staff ENABLE ROW LEVEL SECURITY;

-- Only owner/admin can manage staff
DROP POLICY IF EXISTS "store_staff_owner_select" ON store_staff;
CREATE POLICY "store_staff_owner_select" ON store_staff
  FOR SELECT USING (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
    OR user_id = auth.uid()
  );

DROP POLICY IF EXISTS "store_staff_owner_insert" ON store_staff;
CREATE POLICY "store_staff_owner_insert" ON store_staff
  FOR INSERT WITH CHECK (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
  );

DROP POLICY IF EXISTS "store_staff_owner_delete" ON store_staff;
CREATE POLICY "store_staff_owner_delete" ON store_staff
  FOR DELETE USING (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
  );

-- 4. Add comment explaining public access
COMMENT ON TABLE products IS 'Public read access is handled via Edge Function (public-products) which enforces store_id';
