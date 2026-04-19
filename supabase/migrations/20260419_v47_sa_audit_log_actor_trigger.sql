-- =============================================================================
-- Migration v47: enforce actor_id = auth.uid() via BEFORE INSERT trigger.
-- Date: 2026-04-19
-- Author: Schema team
--
-- Background
--   v40's "sa_audit_log_insert_self" RLS policy has:
--       WITH CHECK (actor_id = auth.uid())
--   which rejects an authenticated insert whose actor_id doesn't match the
--   caller's uid. That's good, but it's the only defense: a client must
--   SEND the right actor_id to pass the check. Any library bug that
--   serializes NULL / omits the field / accidentally sends another uid
--   either crashes the insert or (in pathological cases) relies on a
--   client-chosen value slipping through.
--
-- Fix
--   CANONICALIZE actor_id at the server: a BEFORE INSERT trigger on
--   sa_audit_log rewrites NEW.actor_id := auth.uid() unconditionally.
--   The client's value becomes irrelevant -- the server always attributes
--   the row to the true JWT subject. This removes the "actor_id spoof"
--   attack surface and makes the audit trail correct by construction.
--
-- Edge case: SECURITY DEFINER backend writers with no JWT
--   v43's audit_platform_settings_update() trigger fires on platform_settings
--   UPDATE. When triggered from an authenticated session, auth.uid() returns
--   the user's uid -- fine. But if platform_settings is ever updated from a
--   non-JWT context (psql superuser, cron, post-deploy admin script),
--   auth.uid() returns NULL. The v43 trigger handles this via:
--       COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid)
--   so it inserts a row with actor_id = zero-uuid as a "system" attribution.
--
--   If this v47 trigger unconditionally did `NEW.actor_id := auth.uid()`,
--   it would clobber the zero-uuid with NULL -> NOT NULL violation -> the
--   platform_settings UPDATE would fail. Catastrophic regression.
--
--   Fix: gate the trigger with WHEN (auth.uid() IS NOT NULL).
--     - Authenticated client insert (super_admin/driver/distributor):
--       auth.uid() is a real uuid -> trigger fires -> actor_id rewritten
--       to the caller's uid. Spoofing blocked.
--     - SECURITY DEFINER backend insert (v43 trigger, future cron jobs):
--       auth.uid() is NULL -> trigger does NOT fire -> the explicit
--       actor_id passes through untouched.
--
-- Security
--   SECURITY INVOKER (default). The function only reads auth.uid() and
--   mutates NEW. No elevated privilege needed. INVOKER is strictly safer
--   than DEFINER: no risk of privilege escalation via a compromised
--   trigger chain. auth.uid() works identically in both contexts (it
--   reads the session JWT claim, not row-level ownership).
--
-- Application note
--   Applied manually to live Supabase on 2026-04-19 via SQL Editor.
--   Verified:
--     - V8-A: trigger present with correct WHEN clause, tgenabled='O'.
--     - V8-D: UPDATE public.platform_settings succeeded post-migration;
--             v43 audit trigger wrote a row with actor_id = zero-uuid
--             (SQL Editor runs as service_role where auth.uid() is NULL,
--             so v47's WHEN clause correctly skipped -- no regression).
--
-- Rollback
--   DROP TRIGGER IF EXISTS sa_audit_log_force_actor_id ON public.sa_audit_log;
--   DROP FUNCTION IF EXISTS public.sa_audit_log_force_actor_id();
-- =============================================================================

CREATE OR REPLACE FUNCTION public.sa_audit_log_force_actor_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.actor_id := auth.uid();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS sa_audit_log_force_actor_id ON public.sa_audit_log;

CREATE TRIGGER sa_audit_log_force_actor_id
  BEFORE INSERT ON public.sa_audit_log
  FOR EACH ROW
  WHEN (auth.uid() IS NOT NULL)
  EXECUTE FUNCTION public.sa_audit_log_force_actor_id();

COMMENT ON FUNCTION public.sa_audit_log_force_actor_id() IS
  'BEFORE INSERT trigger fn for sa_audit_log. Forces NEW.actor_id to the '
  'current JWT subject (auth.uid()) so clients cannot spoof attribution. '
  'Trigger is gated on auth.uid() IS NOT NULL so SECURITY DEFINER backend '
  'writes (e.g. v43 platform_settings audit trigger from non-JWT contexts) '
  'pass through untouched with their explicit actor_id.';
