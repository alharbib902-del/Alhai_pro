-- =============================================================================
-- Migration v48: update_platform_settings(...) RPC.
-- Date: 2026-04-19
-- Author: Schema team
--
-- Background
--   v43 created public.platform_settings with RLS gated on is_super_admin().
--   Direct UPDATEs from the Flutter client work in principle, but:
--     (a) there is no client-side Save action yet -- toggles only mutate
--         local setState (P0 from 2026-04-17 intake).
--     (b) multi-field direct UPDATEs are fragile from a client -- and more
--         importantly each column-at-a-time UPDATE would emit its own
--         audit row via the v43 trigger, polluting sa_audit_log.
--
-- Fix
--   A single RPC taking every mutable column as a parameter and performing
--   ONE atomic UPDATE. The v43 AFTER UPDATE trigger emits exactly one
--   'platform_settings.update' audit row per save.
--
--   Five defense layers protect this RPC:
--     1. REVOKE EXECUTE FROM PUBLIC        -- deny the open default grant
--     2. REVOKE EXECUTE FROM anon          -- Supabase auto-grants to anon
--                                             on new public functions and
--                                             that grant SURVIVES a REVOKE
--                                             FROM PUBLIC. Must be revoked
--                                             explicitly. (Pattern confirmed
--                                             during U7 on sa_audit_log; re-
--                                             confirmed during U2 V48-B.)
--     3. GRANT EXECUTE TO authenticated    -- only authenticated sessions
--                                             can call; RLS still also gates
--                                             the underlying UPDATE
--     4. IF NOT is_super_admin() THEN RAISE  -- defense-in-depth inside the
--                                             function body, rejects non-
--                                             super-admin callers even if a
--                                             future mistake widens grants
--     5. CHECK constraints on platform_settings -- Postgres enforces value
--                                             ranges and enums (vat_rate
--                                             0..100, zatca_environment IN
--                                             (sandbox,production), etc.).
--                                             Invalid input => 23514 rollback.
--
--   Future RPCs in this repo must include REVOKE FROM anon explicitly -- it
--   is a real on-the-wire leak vector if left off.
--
-- Security posture
--   SECURITY DEFINER. This is the blessed client path; owning it with
--   elevated privs lets the in-function is_super_admin() guard be the
--   authoritative gate instead of relying on caller RLS. The v43 audit
--   trigger still sees the correct auth.uid() because auth.uid() reads
--   the session JWT claim -- preserved across DEFINER (unlike current_user).
--   v47's sa_audit_log BEFORE INSERT trigger (WHEN auth.uid() IS NOT NULL)
--   canonicalises actor_id onto the audit row.
--
--   SET search_path = public defends against search_path hijack on DEFINER.
--
-- Validation
--   The RPC does NOT re-validate ranges or enums. v43's CHECK constraints
--   are authoritative (vat_rate 0..100, zatca_environment IN (sandbox,
--   production), default_language IN (ar,en), trial_period_days >= 0).
--   Invalid input raises 23514 check_violation; the UPDATE rolls back
--   atomically. Keeping the RPC thin avoids validation drift between
--   SQL and Dart.
--
-- Application note
--   Applied manually to live Supabase on 2026-04-19 via SQL Editor.
--   Verified:
--     - V48-A: pg_proc row with security_definer=true, search_path=public,
--       correct 10-param signature, returns platform_settings.
--     - V48-B: after explicit REVOKE FROM anon, grants list shows only
--       authenticated + postgres (owner) + service_role. No anon, no PUBLIC.
--     - V48-C1: service_role (auth.uid() IS NULL) call raises SQLSTATE
--       42501 'permission denied: super admin role required' without
--       touching platform_settings. Guard confirmed.
--     - V48-C2: happy path deferred to Dart widget test in U2 Part 2.
--
--   The migration file below exactly mirrors the applied state so that
--   fresh environments (CI, new tenants) reach the same final state from
--   a clean run.
--
-- Rollback
--   DROP FUNCTION IF EXISTS public.update_platform_settings(
--     boolean, text, numeric, text, text, integer,
--     boolean, boolean, boolean, boolean);
-- =============================================================================

-- Drop with exact signature so this script does not accidentally collide
-- with a future overload that shares the name.
DROP FUNCTION IF EXISTS public.update_platform_settings(
  boolean, text, numeric, text, text, integer,
  boolean, boolean, boolean, boolean
);

CREATE OR REPLACE FUNCTION public.update_platform_settings(
  p_zatca_enabled       boolean,
  p_zatca_environment   text,
  p_vat_rate            numeric,
  p_default_language    text,
  p_default_currency    text,
  p_trial_period_days   integer,
  p_moyasar_enabled     boolean,
  p_hyperpay_enabled    boolean,
  p_tabby_enabled       boolean,
  p_tamara_enabled      boolean
)
RETURNS public.platform_settings
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row public.platform_settings;
BEGIN
  -- Defense-in-depth: reject non-super-admins even though RLS would also
  -- block them. Keeping the guard inside the function means a future
  -- mistake that widens GRANTs does not silently become a privilege leak.
  IF NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'permission denied: super admin role required'
      USING ERRCODE = '42501';
  END IF;

  UPDATE public.platform_settings
     SET zatca_enabled     = p_zatca_enabled,
         zatca_environment = p_zatca_environment,
         vat_rate          = p_vat_rate,
         default_language  = p_default_language,
         default_currency  = p_default_currency,
         trial_period_days = p_trial_period_days,
         moyasar_enabled   = p_moyasar_enabled,
         hyperpay_enabled  = p_hyperpay_enabled,
         tabby_enabled     = p_tabby_enabled,
         tamara_enabled    = p_tamara_enabled
   WHERE id = 1
  RETURNING * INTO v_row;

  -- Should be unreachable -- the singleton is seeded by v43 and never
  -- deleted -- but fail loudly if someone DELETEd it out from under us.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'platform_settings row id=1 missing'
      USING ERRCODE = 'P0002';
  END IF;

  RETURN v_row;
END;
$$;

-- Layer 1: deny the default PUBLIC grant.
REVOKE EXECUTE ON FUNCTION public.update_platform_settings(
  boolean, text, numeric, text, text, integer,
  boolean, boolean, boolean, boolean
) FROM PUBLIC;

-- Layer 2: deny anon explicitly. Supabase auto-grants EXECUTE on new
-- public functions to anon/authenticated/service_role via default grants
-- that SURVIVE a REVOKE FROM PUBLIC. This REVOKE is NOT optional -- without
-- it the function is callable from an unauthenticated session (it would
-- then immediately fail the is_super_admin() guard, but that is a waste
-- of the database round-trip and a fingerprintable difference from
-- "function does not exist").
REVOKE EXECUTE ON FUNCTION public.update_platform_settings(
  boolean, text, numeric, text, text, integer,
  boolean, boolean, boolean, boolean
) FROM anon;

-- Layer 3: permit authenticated sessions. is_super_admin() still gates.
GRANT EXECUTE ON FUNCTION public.update_platform_settings(
  boolean, text, numeric, text, text, integer,
  boolean, boolean, boolean, boolean
) TO authenticated;

COMMENT ON FUNCTION public.update_platform_settings(
  boolean, text, numeric, text, text, integer,
  boolean, boolean, boolean, boolean
) IS
  'Atomic UPDATE of the singleton platform_settings row. Five defense '
  'layers: REVOKE PUBLIC + REVOKE anon + GRANT authenticated + in-function '
  'is_super_admin() guard + CHECK constraints on the table. Non-super-admin '
  'callers receive SQLSTATE 42501. Invalid values receive 23514 '
  '(check_violation) from Postgres.';
