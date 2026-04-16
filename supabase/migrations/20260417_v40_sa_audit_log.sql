-- =============================================================================
-- Migration v40: create sa_audit_log (Super Admin / platform audit trail).
-- Date: 2026-04-17
-- Author: Schema team
--
-- Background
--   v25 created `public.audit_log` with a POS-oriented shape:
--       (id TEXT, store_id, user_id, action, entity_type, entity_id,
--        details JSONB, ip_address TEXT, created_at, synced_at)
--   This is the shape that Drift's cashier app pushes into.
--
--   v35 then attempted to redefine `audit_log` with a Super-Admin shape
--   (actor_id UUID, target_type, before JSONB, after JSONB, ...) BUT used
--   `CREATE TABLE IF NOT EXISTS`, so the statement was a no-op in any
--   project that already had the v25 table. The indexes and RLS policies
--   in v35 were applied on top of the v25 shape.
--
--   Consequences observed 2026-04-17:
--     - Super Admin app's AuditLogService, driver_app's DriverAuditService,
--       and distributor_portal's DistributorAuditService insert with the
--       v35 shape (actor_id / target_type / before / after). These columns
--       DO NOT EXIST on the live table, so every privileged-mutation audit
--       write currently errors out silently (the services swallow it).
--     - The POS-cashier audit trail (the v25 shape) is intact.
--
-- Fix
--   Create a SEPARATE table `sa_audit_log` with the v35 shape, copy the
--   indexes and RLS policies over, and update the three client services
--   to write there. This preserves the existing POS audit_log for the
--   cashier pipeline.
--
-- Rollout
--   1. Deploy this migration.
--   2. Ship the client change that moves AuditLogService /
--      DriverAuditService / DistributorAuditService to `sa_audit_log`.
--      (Same release; the services tolerate transient schema mismatch
--      because they swallow insert errors.)
--
-- Rollback
--   DROP TABLE IF EXISTS public.sa_audit_log CASCADE;
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.sa_audit_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id     UUID NOT NULL,
  actor_email  TEXT,
  action       TEXT NOT NULL,              -- e.g. 'store.create', 'user.role.update'
  target_type  TEXT NOT NULL,              -- e.g. 'store', 'user', 'distributor'
  target_id    TEXT NOT NULL,
  before       JSONB,
  after        JSONB,
  metadata     JSONB,
  ip_address   INET,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes mirroring v35's intent (plus a standalone actor_email index for
-- ops dashboards that filter by email rather than uuid).
CREATE INDEX IF NOT EXISTS idx_sa_audit_log_actor_created
  ON public.sa_audit_log (actor_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sa_audit_log_target_created
  ON public.sa_audit_log (target_type, target_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sa_audit_log_action_created
  ON public.sa_audit_log (action, created_at DESC);

-- RLS: tamper-evident append-only. service_role bypasses RLS, so server
-- writes still work. No UPDATE / DELETE policies are granted.
ALTER TABLE public.sa_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sa_audit_log_select_super_admin" ON public.sa_audit_log;
CREATE POLICY "sa_audit_log_select_super_admin" ON public.sa_audit_log
  FOR SELECT TO authenticated
  USING (is_super_admin());

-- INSERT: allow any authenticated user to append THEIR OWN audit row.
-- Accountability comes from the fact that actor_id must equal auth.uid().
-- Distinct from v35's stricter "only super_admin can insert" because this
-- table also records driver and distributor actions, not just super admin.
DROP POLICY IF EXISTS "sa_audit_log_insert_self" ON public.sa_audit_log;
CREATE POLICY "sa_audit_log_insert_self" ON public.sa_audit_log
  FOR INSERT TO authenticated
  WITH CHECK (actor_id = auth.uid());

COMMENT ON TABLE public.sa_audit_log IS
  'Platform-wide privileged-action audit trail. Written by super_admin, '
  'driver_app, distributor_portal. Distinct from public.audit_log which '
  'belongs to the POS cashier pipeline. Append-only: no UPDATE/DELETE.';
