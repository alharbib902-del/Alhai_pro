-- =============================================================================
-- v35: audit_log table for Super Admin mutation tracking
-- =============================================================================
-- Every privileged mutation performed by the Super Admin app should be
-- recorded here. The Super Admin app bypasses normal RLS (elevated access),
-- so an immutable audit trail is the primary accountability mechanism.
--
-- ROLLBACK:
--   DROP TABLE IF EXISTS public.audit_log CASCADE;
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.audit_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id     UUID NOT NULL,
  actor_email  TEXT,
  action       TEXT NOT NULL, -- e.g. 'store.create', 'subscription.update', 'user.suspend'
  target_type  TEXT NOT NULL, -- e.g. 'store', 'subscription', 'user'
  target_id    TEXT NOT NULL,
  before       JSONB,
  after        JSONB,
  metadata     JSONB,
  ip_address   INET,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes tuned for the most common audit queries:
--   "what did this admin do recently?"
--   "what happened to this target recently?"
--   "who performed this action recently?"
CREATE INDEX IF NOT EXISTS idx_audit_log_actor_created
  ON public.audit_log (actor_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_target_created
  ON public.audit_log (target_type, target_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_action_created
  ON public.audit_log (action, created_at DESC);

-- Enable RLS. Rows are tamper-evident: no UPDATE/DELETE policies are granted,
-- so even a super_admin cannot mutate past entries via the API.
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- SELECT: only super admins can read the audit log.
DROP POLICY IF EXISTS "audit_log_select_super_admin" ON public.audit_log;
CREATE POLICY "audit_log_select_super_admin" ON public.audit_log
  FOR SELECT TO authenticated
  USING (is_super_admin());

-- INSERT: only super admins can write to the audit log from the client.
-- (service_role bypasses RLS entirely, so server-side inserts still work.)
DROP POLICY IF EXISTS "audit_log_insert_super_admin" ON public.audit_log;
CREATE POLICY "audit_log_insert_super_admin" ON public.audit_log
  FOR INSERT TO authenticated
  WITH CHECK (is_super_admin());

-- Explicitly deny UPDATE and DELETE by omission: no policies granted means
-- the table is append-only for every role except service_role.

COMMENT ON TABLE public.audit_log IS
  'Append-only audit trail of privileged Super Admin mutations. '
  'Writes allowed only for super_admin role and service_role. '
  'No UPDATE/DELETE policies are granted — rows are tamper-evident.';
