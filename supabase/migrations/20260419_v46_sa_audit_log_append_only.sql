-- =============================================================================
-- Migration v46: harden sa_audit_log as strictly append-only.
-- Date: 2026-04-19
-- Author: Schema team
--
-- Background
--   v40 created sa_audit_log with SELECT + INSERT RLS policies. No UPDATE or
--   DELETE policy was defined, so authenticated users already cannot mutate
--   rows via PostgREST -- the policy check fails.
--
--   However, the `service_role` role bypasses RLS entirely. Supabase's
--   defaults GRANT service_role full privileges on every new table, which
--   means admin tools, cron jobs, and any leaked service_role key can still
--   UPDATE or DELETE audit rows -- defeating the tamper-evident property of
--   the trail.
--
-- Fix
--   REVOKE UPDATE, DELETE, TRUNCATE on sa_audit_log from:
--     - PUBLIC        (belt-and-suspenders; rarely granted but explicit)
--     - anon          (pre-login role; should never touch the audit log)
--     - authenticated (RLS already blocks; revoking at the SQL layer is
--                      defense-in-depth against future policy drift)
--     - service_role  (the one that MATTERS -- this is what bypasses RLS)
--
--   INSERT and SELECT privileges are deliberately NOT touched:
--     - INSERT: needed by v40's "sa_audit_log_insert_self" RLS policy for
--       authenticated clients (super_admin / driver_app / distributor_portal)
--       and by v43's audit_platform_settings_update() SECURITY DEFINER
--       trigger (runs with the function owner's privileges and needs INSERT).
--     - SELECT: needed by v40's "sa_audit_log_select_super_admin" RLS policy.
--
--   After v46, modifying existing audit rows requires a Postgres superuser
--   session (the `postgres` role, owned by Supabase infrastructure).
--   Regular app paths, admin tools, and leaked service_role keys cannot
--   tamper with the audit trail.
--
-- Application note
--   Applied manually to live Supabase on 2026-04-19 via SQL Editor.
--   Verified via information_schema.role_table_grants: only `postgres`
--   retains UPDATE/DELETE/TRUNCATE (as table owner -- Supabase cannot
--   revoke from itself). INSERT/SELECT intact for anon/authenticated/
--   postgres/service_role.
--
-- Rollback
--   GRANT UPDATE, DELETE, TRUNCATE ON public.sa_audit_log TO service_role;
--   -- Do NOT regrant to PUBLIC, anon, or authenticated; they never held
--   -- these privileges in any intentional design.
-- =============================================================================

REVOKE UPDATE, DELETE, TRUNCATE ON public.sa_audit_log FROM PUBLIC;
REVOKE UPDATE, DELETE, TRUNCATE ON public.sa_audit_log FROM anon;
REVOKE UPDATE, DELETE, TRUNCATE ON public.sa_audit_log FROM authenticated;
REVOKE UPDATE, DELETE, TRUNCATE ON public.sa_audit_log FROM service_role;

COMMENT ON TABLE public.sa_audit_log IS
  'Platform-wide privileged-action audit trail. Written by super_admin, '
  'driver_app, distributor_portal, and the audit_platform_settings_update '
  'trigger. Distinct from public.audit_log which belongs to the POS cashier '
  'pipeline. Append-only since v46: UPDATE/DELETE/TRUNCATE revoked from all '
  'roles including service_role. Modification requires a Postgres superuser.';
