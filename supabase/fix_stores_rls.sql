-- ============================================================================
-- FIX STORES RLS: Allow store members to see their stores
-- Run this in Supabase SQL Editor as Project Owner
-- ============================================================================
-- Updated: align with supabase_init.sql (store_members table, auth.uid() directly)
-- ============================================================================

-- Allow users who are members of a store (via store_members) to SELECT that store
-- Uses auth.uid() directly since public.users.id = auth.users.id (FK in supabase_init.sql)
DROP POLICY IF EXISTS stores_member_select ON public.stores;
CREATE POLICY stores_member_select ON public.stores
FOR SELECT USING (
  id IN (
    SELECT store_id FROM public.store_members
    WHERE user_id = auth.uid()
      AND is_active = true
  )
);
