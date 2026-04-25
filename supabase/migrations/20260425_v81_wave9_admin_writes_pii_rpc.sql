-- ============================================================================
-- Migration v81 — Wave 9 (P0-02 + P0-28): admin-only writes + PII RPC
-- ============================================================================
-- Branch:   fix/wave9-rls-permissions
-- Date:     2026-04-25
-- Prereqs:  v22 (is_super_admin), v36 (is_super_admin canonical),
--           v67 (users PII select policies), v27 (transactions +
--           inventory_movements tables)
--
-- Mirrors the client-side `Permissions` class added in
-- packages/alhai_auth/lib/src/security/permissions.dart so a well-formed
-- REST call can't bypass the UI gates.
--
-- This migration introduces server-side enforcement for three gaps the
-- client used to enforce alone:
--
--   1. `transactions` — INSERT/UPDATE rows where `type = 'adjustment'`
--      requires an admin role (super_admin OR store_owner of the same
--      store). Generic store-member access stays for non-adjustment
--      writes (payments, invoices, etc).
--
--   2. `inventory_movements` — INSERT rows where
--      `type IN ('adjust', 'wastage', 'stock_take')` requires an admin
--      role. Sale / receive / void / return / transfer movements stay
--      open to any store member because they're driven by the cashier's
--      normal workflow.
--
--   3. `users` — a new SECURITY DEFINER RPC `get_user_pii(p_user_id)`
--      returns email + phone only when the caller is the user
--      themselves, a super admin, or the store owner of the user's
--      store. The cashier app's users-permissions screen should switch
--      to calling this RPC for PII reads. A future Wave 9b migration
--      can REVOKE column-level SELECT on users.email/phone once every
--      caller has migrated; doing it now would break login + profile
--      flows that do plain `SELECT * FROM users`.
--
-- ROLLBACK:
--   DROP POLICY IF EXISTS transactions_store_member_select ON public.transactions;
--   DROP POLICY IF EXISTS transactions_admin_adjustment ON public.transactions;
--   DROP POLICY IF EXISTS transactions_member_write_non_adjustment ON public.transactions;
--   DROP POLICY IF EXISTS inventory_movements_store_member_select ON public.inventory_movements;
--   DROP POLICY IF EXISTS inventory_movements_admin_restricted_write ON public.inventory_movements;
--   DROP POLICY IF EXISTS inventory_movements_member_write_open_types ON public.inventory_movements;
--   DROP FUNCTION IF EXISTS public.is_store_admin(TEXT);
--   DROP FUNCTION IF EXISTS public.get_user_pii(TEXT);
--   -- Then re-CREATE POLICY "store_member_access" on each table per v27.

-- ============================================================================
-- STEP 0: helper — is_store_admin(p_store_id)
-- ============================================================================
-- Returns true iff the caller is super_admin OR is the store_owner of
-- the named store. Idempotent recreate so subsequent migrations can
-- depend on a stable signature without dropping policies that reference
-- this function.
CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id TEXT)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()::TEXT
      AND (
        role = 'super_admin'
        OR (role = 'store_owner' AND store_id = p_store_id)
      )
  );
$$;

COMMENT ON FUNCTION public.is_store_admin(TEXT) IS
  'Wave 9 (P0-02/28): true if caller is super_admin or store_owner of '
  'the given store. SECURITY DEFINER so it can read public.users '
  'regardless of caller RLS. Used by transactions + inventory_movements '
  'write policies and the users PII RPC.';

-- ============================================================================
-- STEP 1: transactions — split read/write so adjustments are admin-only
-- ============================================================================
-- The v27 "store_member_access" policy was FOR ALL — any store member
-- could insert any transaction type, including 'adjustment' which is
-- the highest-impact ledger write (manual debit/credit on a customer
-- account). Split into a SELECT policy (open) + per-operation write
-- policies that gate adjustments behind is_store_admin().

DROP POLICY IF EXISTS "store_member_access" ON public.transactions;

CREATE POLICY transactions_store_member_select ON public.transactions
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
  );

CREATE POLICY transactions_member_write_non_adjustment ON public.transactions
  FOR INSERT TO authenticated
  WITH CHECK (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
    AND type != 'adjustment'
  );

CREATE POLICY transactions_admin_adjustment ON public.transactions
  FOR INSERT TO authenticated
  WITH CHECK (
    type = 'adjustment'
    AND public.is_store_admin(store_id)
  );

CREATE POLICY transactions_member_update ON public.transactions
  FOR UPDATE TO authenticated
  USING (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
  )
  WITH CHECK (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
    AND (type != 'adjustment' OR public.is_store_admin(store_id))
  );

CREATE POLICY transactions_admin_delete ON public.transactions
  FOR DELETE TO authenticated
  USING (public.is_store_admin(store_id));

-- ============================================================================
-- STEP 2: inventory_movements — admin-only for adjust / wastage / stock_take
-- ============================================================================
-- Same shape: open read for store members, but writes that touch the
-- shrinkage-prone types require admin. Sale / receive / void / return /
-- transfer_in / transfer_out are driven by the cashier's normal flows
-- and stay open. Wave 7 (P0-19) migrated the canonical type names —
-- this policy uses the post-v48 strings.

DROP POLICY IF EXISTS "store_member_access" ON public.inventory_movements;

CREATE POLICY inventory_movements_store_member_select ON public.inventory_movements
  FOR SELECT TO authenticated
  USING (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
  );

CREATE POLICY inventory_movements_member_write_open_types ON public.inventory_movements
  FOR INSERT TO authenticated
  WITH CHECK (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
    AND type IN (
      'sale', 'receive', 'void', 'return',
      'transfer_in', 'transfer_out'
    )
  );

CREATE POLICY inventory_movements_admin_restricted_write ON public.inventory_movements
  FOR INSERT TO authenticated
  WITH CHECK (
    type IN ('adjust', 'wastage', 'stock_take')
    AND public.is_store_admin(store_id)
  );

CREATE POLICY inventory_movements_member_update ON public.inventory_movements
  FOR UPDATE TO authenticated
  USING (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
  )
  WITH CHECK (
    store_id IN (
      SELECT store_id FROM public.org_members
      WHERE user_id = auth.uid()::TEXT
    )
    AND (
      type NOT IN ('adjust', 'wastage', 'stock_take')
      OR public.is_store_admin(store_id)
    )
  );

CREATE POLICY inventory_movements_admin_delete ON public.inventory_movements
  FOR DELETE TO authenticated
  USING (public.is_store_admin(store_id));

-- ============================================================================
-- STEP 3: users — RPC for gated PII reads
-- ============================================================================
-- Lets the cashier app fetch email/phone of a specific user only when
-- the caller has business reason (self, super admin, or owner of the
-- target user's store). Today the table itself still permits broad
-- column reads; once every PII caller in the app uses this RPC, a
-- Wave 9b migration can REVOKE column-level SELECT on email/phone from
-- the authenticated role and seal the gap entirely.
--
-- Returns NULL row when the caller has no right to see the PII — the
-- app should treat null email/phone as "not authorised" rather than
-- "user has no contact info".

CREATE OR REPLACE FUNCTION public.get_user_pii(p_user_id TEXT)
RETURNS TABLE(email TEXT, phone TEXT)
LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT u.email, u.phone
  FROM public.users u
  WHERE u.id = p_user_id
    AND (
      u.id = auth.uid()::TEXT
      OR public.is_super_admin()
      OR public.is_store_admin(u.store_id)
    );
$$;

COMMENT ON FUNCTION public.get_user_pii(TEXT) IS
  'Wave 9 (P0-02): admin/self-gated read of users.email + users.phone. '
  'SECURITY DEFINER so the function can see the PII even when the '
  'authenticated role can not. Returns NULL when caller has no right '
  'to see the requested PII (treat null as "denied", not "missing").';

GRANT EXECUTE ON FUNCTION public.get_user_pii(TEXT) TO authenticated;

-- ============================================================================
-- Recap
-- ============================================================================
-- Policies created: 11 (transactions ×5, inventory_movements ×5, plus
-- one PII RPC).
-- Policies replaced: 2 (store_member_access on transactions and
-- inventory_movements were too broad; split into select + per-operation
-- writes).
-- Functions added: 2 (is_store_admin, get_user_pii).
-- Existing v67 policies on public.users untouched.
