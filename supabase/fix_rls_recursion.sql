-- ============================================================================
-- FIX RLS RECURSION: store_members infinite recursion prevention
-- Run this in Supabase SQL Editor as Project Owner
-- ============================================================================
-- Updated: align with supabase_init.sql schema
-- In supabase_init.sql, public.users.id directly references auth.users.id,
-- so we can use auth.uid() directly without a lookup through auth_uid column.
-- The table is store_members (not user_stores).
-- ============================================================================

-- 1. Helper function to get current user id (bypasses RLS on users table)
-- Since public.users.id = auth.uid() by FK definition, this simply returns auth.uid()
CREATE OR REPLACE FUNCTION public.get_my_user_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, auth
STABLE
AS $$
  SELECT auth.uid();
$$;

-- 2. حذف السياسات القديمة التي تسبب التكرار
DROP POLICY IF EXISTS store_members_self_select ON public.store_members;
DROP POLICY IF EXISTS stores_member_select ON public.stores;

-- 3. إعادة إنشاء سياسة store_members باستخدام الدالة (تتجاوز RLS)
CREATE POLICY store_members_self_select ON public.store_members
FOR SELECT USING (
  user_id = get_my_user_id()
);

-- 4. إعادة إنشاء سياسة stores_member_select باستخدام الدالة
CREATE POLICY stores_member_select ON public.stores
FOR SELECT USING (
  id IN (
    SELECT store_id FROM public.store_members
    WHERE user_id = get_my_user_id()
    AND is_active = true
  )
);
