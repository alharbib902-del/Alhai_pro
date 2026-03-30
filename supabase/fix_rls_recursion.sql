-- ============================================================================
-- FIX RLS RECURSION: stores table infinite recursion prevention
-- Run this in Supabase SQL Editor as Project Owner
-- ============================================================================

-- 1. Drop ALL policies that depend on get_my_user_id FIRST
DROP POLICY IF EXISTS "stores_staff_read_own" ON public.stores;
DROP POLICY IF EXISTS "stores_member_select" ON public.stores;
DROP POLICY IF EXISTS "stores_public_read_active" ON public.stores;
DROP POLICY IF EXISTS "store_members_self_select" ON public.store_members;
DROP POLICY IF EXISTS "store_members_self_read" ON public.store_members;
DROP POLICY IF EXISTS "user_stores_self_select" ON public.user_stores;

-- 2. Now safe to drop and recreate the function
DROP FUNCTION IF EXISTS public.get_my_user_id();
CREATE OR REPLACE FUNCTION public.get_my_user_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, auth
STABLE
AS $$
  SELECT auth.uid();
$$;

-- 3. Recreate store_members self-read policy
CREATE POLICY "store_members_self_read" ON public.store_members
FOR SELECT USING (
  user_id = get_my_user_id()
);

-- 4. Recreate user_stores self-select policy
CREATE POLICY "user_stores_self_select" ON public.user_stores
FOR SELECT USING (
  user_id = get_my_user_id()::TEXT
);

-- 5. Safe stores SELECT policy (no recursion)
CREATE POLICY "stores_member_select" ON public.stores
FOR SELECT USING (
  owner_id = auth.uid()
  OR id IN (
    SELECT store_id FROM public.store_members
    WHERE user_id = get_my_user_id()
      AND is_active = true
  )
  OR public.is_super_admin()
);

-- 6. Replace is_store_admin to avoid recursion
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

-- ============================================================================
-- Done!
-- ============================================================================
