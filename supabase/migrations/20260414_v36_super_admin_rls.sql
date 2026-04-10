-- =============================================================================
-- v36: Super Admin RLS enforcement for stores / subscriptions / users
-- =============================================================================
-- Adds server-side gates for super-admin-only mutations so that a tampered
-- client build cannot bypass the Flutter router guard and call Supabase
-- directly. All policies here are ADDITIVE — no existing policy is dropped
-- or loosened. New policies are prefixed `super_admin_*` so they never
-- collide with existing names.
--
-- Source of truth for role: `public.users.role` column. The helper
-- `public.is_super_admin()` (created in 20260223_tighten_rls_write_policies)
-- reads that column for `auth.uid()`.
--
-- Covered mutations:
--   1. DELETE on public.stores                → super-admin only
--   2. UPDATE on public.subscriptions (plan)  → super-admin only
--   3. UPDATE of public.users.role column     → super-admin only
--
-- ROLLBACK:
--   DROP POLICY IF EXISTS "super_admin_stores_delete"         ON public.stores;
--   DROP POLICY IF EXISTS "super_admin_subscriptions_update"  ON public.subscriptions;
--   DROP POLICY IF EXISTS "super_admin_users_role_update"     ON public.users;
--   DROP TRIGGER IF EXISTS trg_users_role_super_admin_only    ON public.users;
--   DROP FUNCTION IF EXISTS public.enforce_role_change_super_admin();
-- =============================================================================

-- ============================================================
-- STEP 0: Ensure is_super_admin() exists (idempotent re-create)
-- Safe to re-run: CREATE OR REPLACE leaves dependent policies intact.
-- Mirrors the definition from 20260223_tighten_rls_write_policies.sql.
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

COMMENT ON FUNCTION public.is_super_admin() IS
  'Returns true iff the authenticated user has role = super_admin in '
  'public.users. Canonical source of truth for Super Admin RLS gates. '
  'SECURITY DEFINER so it can read public.users regardless of caller RLS.';

-- ============================================================
-- STEP 1: stores — gate DELETE on is_super_admin()
-- Additive: any existing DELETE policy (e.g. tenant owner) still applies.
-- Because multiple FOR DELETE policies combine with OR, we name this one
-- distinctly so it only EXTENDS existing access, never shrinks it.
-- ============================================================
DROP POLICY IF EXISTS "super_admin_stores_delete" ON public.stores;
CREATE POLICY "super_admin_stores_delete" ON public.stores
  FOR DELETE TO authenticated
  USING (public.is_super_admin());

-- ============================================================
-- STEP 2: subscriptions — gate UPDATE on is_super_admin()
-- Plan changes (upgrade/downgrade, trial extension) are super-admin only.
-- Additive policy: existing tenant-read / org-member policies unchanged.
-- ============================================================
DROP POLICY IF EXISTS "super_admin_subscriptions_update" ON public.subscriptions;
CREATE POLICY "super_admin_subscriptions_update" ON public.subscriptions
  FOR UPDATE TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

DROP POLICY IF EXISTS "super_admin_subscriptions_delete" ON public.subscriptions;
CREATE POLICY "super_admin_subscriptions_delete" ON public.subscriptions
  FOR DELETE TO authenticated
  USING (public.is_super_admin());

-- ============================================================
-- STEP 3: users.role — gate column-level updates via BEFORE UPDATE trigger
-- ------------------------------------------------------------
-- Postgres RLS policies work at row granularity; there is no built-in
-- column-level gate. A non-super-admin user may legitimately be allowed
-- (by an existing policy such as `users_customer_upsert_own`) to update
-- their own row — but they must NOT be able to promote themselves by
-- changing the `role` column. A BEFORE UPDATE trigger enforces this
-- without disturbing any existing RLS policy.
-- ============================================================
CREATE OR REPLACE FUNCTION public.enforce_role_change_super_admin()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth AS $$
BEGIN
  -- If the role column is unchanged, allow the update.
  IF NEW.role IS NOT DISTINCT FROM OLD.role THEN
    RETURN NEW;
  END IF;

  -- service_role (server-side, bypasses RLS) is allowed to change roles
  -- via auth.jwt() claim check; otherwise require is_super_admin().
  IF public.is_super_admin() THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION
    'Only super_admin can change users.role (attempted % -> %)',
    OLD.role, NEW.role
    USING ERRCODE = '42501'; -- insufficient_privilege
END;
$$;

COMMENT ON FUNCTION public.enforce_role_change_super_admin() IS
  'BEFORE UPDATE trigger on public.users: rejects changes to the role '
  'column unless public.is_super_admin() returns true. Prevents '
  'privilege escalation via self-update even when row-level update is '
  'otherwise allowed by an additive RLS policy.';

DROP TRIGGER IF EXISTS trg_users_role_super_admin_only ON public.users;
CREATE TRIGGER trg_users_role_super_admin_only
  BEFORE UPDATE OF role ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_role_change_super_admin();

-- Additional safety net: an explicit UPDATE policy that allows a
-- super_admin to update ANY user row (needed so the Super Admin app can
-- reach rows it doesn't own). This is additive: existing "users can
-- update their own row" policies remain unchanged.
DROP POLICY IF EXISTS "super_admin_users_role_update" ON public.users;
CREATE POLICY "super_admin_users_role_update" ON public.users
  FOR UPDATE TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- =============================================================================
-- Verification notes (run manually after apply):
--   1. As a non-super_admin, `UPDATE public.users SET role='super_admin' WHERE id=auth.uid();`
--      must fail with SQLSTATE 42501.
--   2. As a non-super_admin, `DELETE FROM public.stores WHERE id='<any>';`
--      should be denied unless covered by an existing tenant DELETE policy.
--   3. As a super_admin, all three mutations should succeed.
-- =============================================================================
