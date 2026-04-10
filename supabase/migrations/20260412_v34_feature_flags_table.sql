-- Feature flags table for kill switches and gradual rollout
CREATE TABLE IF NOT EXISTS public.feature_flags (
  key TEXT PRIMARY KEY,
  enabled BOOLEAN NOT NULL DEFAULT false,
  rollout_percent INT NOT NULL DEFAULT 0 CHECK (rollout_percent BETWEEN 0 AND 100),
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

-- All authenticated users can READ flags
CREATE POLICY "feature_flags_read_all" ON public.feature_flags
  FOR SELECT TO authenticated
  USING (true);

-- Only super admins can modify flags (checked via is_super_admin function from earlier migrations)
CREATE POLICY "feature_flags_modify_super_admin" ON public.feature_flags
  FOR ALL TO authenticated
  USING (is_super_admin())
  WITH CHECK (is_super_admin());

-- Seed a few example flags
INSERT INTO public.feature_flags (key, enabled, description) VALUES
  ('ai_assistant_enabled', true, 'Enable AI assistant features'),
  ('realtime_sync_enabled', true, 'Enable realtime Supabase sync'),
  ('new_pos_ui', false, 'Enable new POS UI (rollout in progress)')
ON CONFLICT (key) DO NOTHING;
