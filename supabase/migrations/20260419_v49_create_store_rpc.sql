-- =============================================================================
-- Migration v49: create_store(...) RPC.
-- Date: 2026-04-19
-- Author: Schema team
--
-- Background
--   super_admin/lib/screens/stores/sa_create_store_screen.dart together with
--   sa_stores_datasource.dart.createStore(...) perform a multi-step,
--   non-atomic client write:
--     1. INSERT public.stores
--     2. INSERT public.subscriptions
--        (best-effort compensating DELETE on failure -- fragile; if the
--         compensating DELETE itself fails, an orphan stores row is left
--         with no subscription)
--     3. Client-side audit_log writes -- duplicated: both the datasource
--        and the screen call auditLogService.log('store.create'), so every
--        successful creation emits TWO audit rows.
--
--   P0 flaws catalogued during Tier 2 intake (2026-04-17):
--     (a) No real transaction. Partial failure is possible and has been
--         observed in operator reports.
--     (b) Client sent 'business_type' to public.stores (ghost column, has
--         never existed in the live schema -- confirmed during V49-PRE).
--         Silent no-op today.
--     (c) Client sent 'branch_count' to nowhere -- the form captures a
--         value that is never persisted, and nothing reads it later.
--     (d) Client plan whitelist ('basic','advanced','professional') did
--         NOT match the live subscriptions_plan_check
--         ('free','starter','professional','enterprise'). Two of three
--         form options were raising SQLSTATE 23514 in production. This
--         is a separate Dart-side fix in U4 Part 3.
--     (e) Client would set subscriptions.status='trial' for trial plans,
--         but subscriptions_status_check only allows 'trialing' (ing).
--         Another silent 23514 in production.
--     (f) Owner-related form fields (owner_name) captured but never
--         persisted. stores.owner_id never set.
--     (g) Duplicate 'store.create' audit rows per successful creation.
--
-- Fix
--   A single RPC that performs one atomic transaction:
--     INSERT public.stores  ->  INSERT public.subscriptions  ->
--     INSERT public.sa_audit_log
--   All-or-nothing. Any failure -- including CHECK constraint violations
--   -- rolls back both INSERTs and the audit row via standard plpgsql
--   transaction semantics.
--
--   business_type is persisted into subscriptions.features JSONB (single
--   key 'business_type'), so no schema change is required to preserve
--   the analytics signal. If indexing becomes necessary later, a GIN
--   index on features is a separate migration.
--
--   Five defense layers protect this RPC:
--     1. REVOKE EXECUTE FROM PUBLIC            -- deny the open default
--     2. REVOKE EXECUTE FROM anon              -- Supabase auto-grants
--                                                 EXECUTE to anon on new
--                                                 public functions and
--                                                 that grant SURVIVES a
--                                                 REVOKE FROM PUBLIC.
--                                                 Pattern first caught
--                                                 in U7 (sa_audit_log),
--                                                 re-confirmed in v48.
--                                                 Including REVOKE FROM
--                                                 anon IN the DDL from
--                                                 the start (as here)
--                                                 prevents the default
--                                                 grant from ever taking
--                                                 effect -- V49-B
--                                                 verified clean with no
--                                                 manual REVOKE needed.
--     3. GRANT EXECUTE TO authenticated        -- only authenticated
--                                                 sessions
--     4. IF NOT is_super_admin() THEN RAISE 42501
--                                              -- defense-in-depth inside
--                                                 the function body
--     5. CHECK constraints on stores +         -- Postgres enforces:
--        subscriptions                            - subscriptions.plan IN
--                                                   ('free','starter',
--                                                   'professional',
--                                                   'enterprise')
--                                                 - subscriptions.status
--                                                   IN ('active',
--                                                   'past_due',
--                                                   'cancelled',
--                                                   'trialing',
--                                                   'expired')
--                                                 - subscriptions
--                                                   .billing_cycle IN
--                                                   ('monthly','yearly')
--                                                 Invalid input -> 23514
--                                                 check_violation;
--                                                 whole transaction rolls
--                                                 back.
--
--   Additional application-layer guards inside the function:
--     - p_name   NULL/empty/whitespace-only  -> SQLSTATE 22023
--     - p_plan   NULL/empty/whitespace-only  -> SQLSTATE 22023
--       (NOT NULL column constraint catches NULL natively as 23502, but
--        would accept an empty string -- we refuse that at the RPC
--        boundary with a clearer message.)
--
-- Security posture
--   SECURITY DEFINER. Same rationale as v48: owning the single blessed
--   client path with elevated privs lets the in-function is_super_admin()
--   guard be the authoritative gate, rather than chaining through caller
--   RLS across two tables. auth.uid() reads the session JWT claim, which
--   is preserved across DEFINER boundaries -- so the audit INSERT
--   correctly attributes to the super_admin caller, and v47's
--   sa_audit_log BEFORE INSERT trigger (WHEN auth.uid() IS NOT NULL)
--   canonicalises actor_id onto the audit row.
--
--   SET search_path = public defends against search_path hijack on
--   DEFINER.
--
-- MFA enforcement (TODO)
--   This RPC does NOT check AAL2. AAL2 enforcement lives client-side in
--   MfaGuardService.requireAAL2(client), called by the datasource before
--   the rpc() invocation -- identical to every other privileged
--   super_admin mutation. Once a public.is_aal2() SQL helper lands
--   (Tier 3 follow-up), add it as an additional guard at the top of
--   this function alongside is_super_admin().
--
-- Rate limiting
--   Platform-level (cloud edge / nginx / Supabase project rate limits).
--   Not enforced inside this RPC -- SQL is the wrong layer.
--
-- Audit trail
--   A single sa_audit_log row is INSERTed as the last step of the
--   transaction. Payload is PII-light by design (GDPR right-to-erasure
--   -- pattern from U12): includes name, plan, business_type; EXCLUDES
--   phone, email, tax_number. Those remain retrievable via target_id ->
--   stores.id for operators with direct DB access; they are deliberately
--   NOT duplicated into the append-only audit log, where they would
--   block future erasure requests.
--
-- UUID source
--   gen_random_uuid() from pgcrypto -- enabled by default on Supabase
--   projects. Verified present via `SELECT gen_random_uuid();` before
--   applying this migration.
--
-- CRITICAL discovery during V49-PRE
--   The live subscriptions table has a CHECK constraint
--   subscriptions_plan_check whitelisting
--   ('free','starter','professional','enterprise'), but the current
--   super_admin create-store form hardcodes ('basic','advanced',
--   'professional'). That means 'basic' and 'advanced' today raise
--   SQLSTATE 23514 in production -- two of three form options were
--   broken. The Dart refactor (U4 Part 3) updates the form labels to
--   the 4 valid plan values. This RPC relies on the Postgres CHECK as
--   the authoritative whitelist; no in-function validation of plan
--   values is added here, to avoid drift between SQL and Dart.
--
-- Application note
--   Applied manually to live Supabase on 2026-04-19 via SQL Editor.
--   Verified:
--     - V49-A: pg_proc row with security_definer=true,
--       search_path=public, correct 6-param signature, returns
--       public.stores.
--     - V49-B: grants clean straight from the DDL -- authenticated +
--       postgres (owner) + service_role. NO anon, NO PUBLIC. No manual
--       post-hoc REVOKE was required (REVOKE FROM anon IS in the DDL).
--     - V49-C1: service_role call (auth.uid() IS NULL) raises SQLSTATE
--       42501 'permission denied: super admin role required' without
--       touching public.stores, public.subscriptions, or
--       public.sa_audit_log. Sanity check:
--       SELECT COUNT(*) FROM public.stores
--       WHERE name = 'Test Store Should Not Land'  --> 0.
--     - V49-C2: happy-path validation deferred to live smoke in U4
--       Part 3 (Dart refactor) -- same pattern as v48.
--
--   The migration file below exactly mirrors the applied state so fresh
--   environments (CI, new tenants) reach the same final state from a
--   clean run.
--
-- Rollback
--   DROP FUNCTION IF EXISTS public.create_store(
--     text, text, text, text, text, text);
-- =============================================================================

-- Drop with exact signature so this script does not accidentally collide
-- with a future overload that shares the name.
DROP FUNCTION IF EXISTS public.create_store(
  text, text, text, text, text, text
);

CREATE OR REPLACE FUNCTION public.create_store(
  p_name           text,
  p_phone          text,
  p_email          text,
  p_tax_number     text,
  p_plan           text,
  p_business_type  text
)
RETURNS public.stores
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_store_id   text;
  v_sub_id     text;
  v_new_store  public.stores;
  v_now        timestamptz := NOW();
  v_features   jsonb;
BEGIN
  -- Layer 4: defense-in-depth.
  IF NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'permission denied: super admin role required'
      USING ERRCODE = '42501';
  END IF;

  -- Application-layer fail-fast guards. NOT NULL on stores.name would
  -- only catch NULL (23502); empty string would slip through. Same for
  -- subscriptions.plan. Reject both with a clearer message before the
  -- INSERTs run so the caller gets a single diagnosable error rather
  -- than a generic constraint violation from a later row.
  IF p_name IS NULL OR btrim(p_name) = '' THEN
    RAISE EXCEPTION 'store name is required'
      USING ERRCODE = '22023';  -- invalid_parameter_value
  END IF;

  IF p_plan IS NULL OR btrim(p_plan) = '' THEN
    RAISE EXCEPTION 'plan is required'
      USING ERRCODE = '22023';
  END IF;

  -- business_type becomes a single key in subscriptions.features so no
  -- schema change is needed. Empty / NULL -> leave features at the
  -- default {} jsonb.
  IF p_business_type IS NOT NULL AND btrim(p_business_type) <> '' THEN
    v_features := jsonb_build_object('business_type', p_business_type);
  ELSE
    v_features := '{}'::jsonb;
  END IF;

  v_store_id := gen_random_uuid()::text;
  v_sub_id   := gen_random_uuid()::text;

  -- Step 1: stores row. Only the explicitly set columns; everything
  -- else (currency, timezone, is_active, created_at) flows from column
  -- defaults. owner_id stays NULL -- the super_admin is a provisioner,
  -- not the owner; a separate "assign owner" flow will set it later.
  INSERT INTO public.stores (
    id, name, phone, email, tax_number
  ) VALUES (
    v_store_id, btrim(p_name), p_phone, p_email, p_tax_number
  )
  RETURNING * INTO v_new_store;

  -- Step 2: subscriptions row. If p_plan is not in the whitelist the
  -- subscriptions_plan_check raises 23514 and the whole transaction
  -- rolls back -- including the stores INSERT above -- by standard
  -- plpgsql semantics.
  INSERT INTO public.subscriptions (
    id, org_id, plan, status,
    current_period_start, current_period_end, amount, features
  ) VALUES (
    v_sub_id,
    v_store_id,
    p_plan,
    'trialing',
    v_now,
    v_now + INTERVAL '30 days',
    0,
    v_features
  );

  -- Step 3: audit row. PII-light: name, plan, business_type only --
  -- phone/email/tax_number are retrievable via target_id and are kept
  -- out of the append-only log for GDPR reasons (U12 pattern).
  -- actor_id is COALESCEd for non-JWT contexts; v47's BEFORE INSERT
  -- trigger canonicalises it to auth.uid() whenever auth.uid() IS NOT
  -- NULL.
  INSERT INTO public.sa_audit_log (
    actor_id, actor_email, action, target_type, target_id, after
  ) VALUES (
    COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid),
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    'store.create',
    'store',
    v_store_id,
    jsonb_build_object(
      'name',          v_new_store.name,
      'plan',          p_plan,
      'business_type', p_business_type
    )
  );

  RETURN v_new_store;
END;
$$;

-- Layer 1: deny the default PUBLIC grant.
REVOKE EXECUTE ON FUNCTION public.create_store(
  text, text, text, text, text, text
) FROM PUBLIC;

-- Layer 2: deny anon explicitly, IN the same DDL batch. This prevents
-- the Supabase default grant from ever taking effect for anon --
-- confirmed by V49-B which showed clean grants with no manual post-hoc
-- REVOKE required.
REVOKE EXECUTE ON FUNCTION public.create_store(
  text, text, text, text, text, text
) FROM anon;

-- Layer 3: permit authenticated sessions. is_super_admin() still gates.
GRANT EXECUTE ON FUNCTION public.create_store(
  text, text, text, text, text, text
) TO authenticated;

COMMENT ON FUNCTION public.create_store(
  text, text, text, text, text, text
) IS
  'Atomic create-store RPC: inserts stores + subscriptions + sa_audit_log '
  'in one transaction. Five defense layers (REVOKE PUBLIC + REVOKE anon + '
  'GRANT authenticated + in-function is_super_admin() guard + CHECK '
  'constraints on the target tables). Rejects non-super-admin with '
  'SQLSTATE 42501; rejects empty p_name or p_plan with 22023; rejects '
  'invalid plan/status/billing_cycle combinations with 23514. '
  'business_type is persisted into subscriptions.features jsonb. '
  'owner_id stays NULL -- a separate "assign owner" flow will set it. '
  'Audit payload is PII-light (name, plan, business_type only; '
  'phone/email/tax_number retrievable via target_id for GDPR erasure '
  'compliance).';
