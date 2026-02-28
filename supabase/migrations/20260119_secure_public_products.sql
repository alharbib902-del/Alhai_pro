-- Migration: Remove public read policy and fix is_store_member
-- Date: 2026-01-19
-- Description: Secure public products access via Edge Function instead of RLS
-- REQUIRES: supabase_init.sql must have run first (creates products table + policies)

-- 1. Remove the public read policy (name matches supabase_init.sql:849)
-- Safe: DROP IF EXISTS handles case where policy doesn't exist yet
DROP POLICY IF EXISTS "products_public_read_active" ON public.products;

-- 2. Fix is_store_member function with secure search_path
-- Aligned with supabase_init.sql: uses store_members table (not store_staff)
CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id TEXT)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, auth
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  );
$$;

-- 3. Ensure store_members table has proper RLS (already enabled in supabase_init.sql)
-- Note: store_staff does not exist in the schema; the correct table is store_members.
-- RLS policies for store_members are defined in supabase_init.sql.
-- The following ensures they exist if this migration runs before supabase_init.sql policies.
ALTER TABLE public.store_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_members_owner_select_migration" ON public.store_members;
CREATE POLICY "store_members_owner_select_migration" ON public.store_members
  FOR SELECT USING (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
    OR user_id = auth.uid()
  );

DROP POLICY IF EXISTS "store_members_owner_insert_migration" ON public.store_members;
CREATE POLICY "store_members_owner_insert_migration" ON public.store_members
  FOR INSERT WITH CHECK (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
  );

DROP POLICY IF EXISTS "store_members_owner_delete_migration" ON public.store_members;
CREATE POLICY "store_members_owner_delete_migration" ON public.store_members
  FOR DELETE USING (
    store_id IN (SELECT id FROM public.stores WHERE owner_id = auth.uid())
  );

-- 4. Add comment explaining public access
COMMENT ON TABLE public.products IS 'Public read access is handled via Edge Function (public-products) which enforces store_id';
