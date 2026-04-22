-- =============================================================================
-- Migration v43: create `platform_settings` (Super Admin global config).
-- Date: 2026-04-17
-- Author: Schema team
--
-- Background
--   The super_admin app's Platform Settings screen reads from a
--   `platform_settings` table that was never defined in any prior migration.
--   As a result:
--     - sa_settings_providers.dart swallowed the read error and returned
--       hard-coded defaults.
--     - Every toggle/field in the screen only mutated local setState — nothing
--       was ever persisted (P0 bug discovered during 2026-04-17 intake).
--
-- Fix
--   Single-row table (enforced by CHECK id = 1) holding platform-wide
--   configuration. Only super admins may SELECT or UPDATE. INSERT is
--   locked entirely — the row is seeded by this migration and never
--   changes identity.
--
-- Auditing
--   Every UPDATE fires a trigger that appends a row to sa_audit_log with
--   action='platform_settings.update', before=OLD::jsonb, after=NEW::jsonb.
--   This gives us tamper-evident accountability for ZATCA/VAT changes —
--   a legal-grade event for ZATCA compliance reviews.
--
-- Rollback
--   DROP TRIGGER IF EXISTS platform_settings_audit_trigger ON public.platform_settings;
--   DROP FUNCTION IF EXISTS public.audit_platform_settings_update();
--   DROP TABLE IF EXISTS public.platform_settings CASCADE;
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.platform_settings (
  id                  INT PRIMARY KEY CHECK (id = 1),

  -- ZATCA e-invoicing configuration
  zatca_enabled       BOOLEAN NOT NULL DEFAULT TRUE,
  zatca_environment   TEXT    NOT NULL DEFAULT 'production'
                              CHECK (zatca_environment IN ('sandbox', 'production')),
  vat_rate            NUMERIC(5,2) NOT NULL DEFAULT 15.00 CHECK (vat_rate >= 0 AND vat_rate <= 100),

  -- Defaults for newly-created organizations
  default_language    TEXT    NOT NULL DEFAULT 'ar'
                              CHECK (default_language IN ('ar', 'en')),
  default_currency    TEXT    NOT NULL DEFAULT 'SAR',
  trial_period_days   INT     NOT NULL DEFAULT 14 CHECK (trial_period_days >= 0),

  -- Payment gateway feature flags (platform-level on/off)
  moyasar_enabled     BOOLEAN NOT NULL DEFAULT TRUE,
  hyperpay_enabled    BOOLEAN NOT NULL DEFAULT FALSE,
  tabby_enabled       BOOLEAN NOT NULL DEFAULT TRUE,
  tamara_enabled      BOOLEAN NOT NULL DEFAULT FALSE,

  -- Provenance
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by          UUID        REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Seed the singleton row (idempotent via ON CONFLICT).
INSERT INTO public.platform_settings (id) VALUES (1)
  ON CONFLICT (id) DO NOTHING;

-- Trigger to keep updated_at fresh.
CREATE OR REPLACE FUNCTION public.touch_platform_settings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := NOW();
  NEW.updated_by := auth.uid();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS platform_settings_touch_updated_at ON public.platform_settings;
CREATE TRIGGER platform_settings_touch_updated_at
  BEFORE UPDATE ON public.platform_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.touch_platform_settings_updated_at();

-- Audit trigger: write a sa_audit_log row on every UPDATE.
CREATE OR REPLACE FUNCTION public.audit_platform_settings_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.sa_audit_log (
    actor_id, actor_email, action, target_type, target_id, before, after
  ) VALUES (
    COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid),
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    'platform_settings.update',
    'platform_settings',
    NEW.id::TEXT,
    to_jsonb(OLD),
    to_jsonb(NEW)
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS platform_settings_audit_trigger ON public.platform_settings;
CREATE TRIGGER platform_settings_audit_trigger
  AFTER UPDATE ON public.platform_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_platform_settings_update();

-- RLS: super admins only. service_role bypasses, used by backend admins tools.
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "platform_settings_select_super_admin" ON public.platform_settings;
CREATE POLICY "platform_settings_select_super_admin" ON public.platform_settings
  FOR SELECT TO authenticated
  USING (is_super_admin());

DROP POLICY IF EXISTS "platform_settings_update_super_admin" ON public.platform_settings;
CREATE POLICY "platform_settings_update_super_admin" ON public.platform_settings
  FOR UPDATE TO authenticated
  USING (is_super_admin())
  WITH CHECK (is_super_admin() AND id = 1);

-- Intentionally NO INSERT or DELETE policy:
--   - The singleton row is seeded by this migration and never rotates.
--   - UPDATE is the only operation clients should ever perform.

COMMENT ON TABLE public.platform_settings IS
  'Global platform configuration (single row, id=1). Super-admin read+update '
  'only. Every UPDATE is mirrored into sa_audit_log for ZATCA-grade '
  'accountability. Seeded by migration v43.';

COMMENT ON COLUMN public.platform_settings.vat_rate IS
  'Platform-default VAT percent (0-100). Organizations may override via '
  'store_settings.vat_rate_override.';

COMMENT ON COLUMN public.platform_settings.zatca_environment IS
  'Which ZATCA gateway the platform targets. Switching to production without '
  'certified certificates will cause invoice submissions to fail — coordinate '
  'with ZATCA cert rotation.';
