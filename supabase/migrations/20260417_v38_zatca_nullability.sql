-- =============================================================================
-- Migration v38: ZATCA nullability enforcement for issued invoices
-- =============================================================================
-- Version:  v38
-- Date:     2026-04-17
-- Author:   Schema team
--
-- Purpose:
--   Enforce ZATCA e-invoicing compliance at the database layer. Every invoice
--   with status = 'issued' MUST carry the three ZATCA identifiers:
--     - zatca_hash  (cryptographic hash of the invoice payload)
--     - zatca_qr    (base64-encoded QR code TLV payload)
--     - zatca_uuid  (globally unique invoice UUID assigned by ZATCA stack)
--   Draft / pending / archived invoices are intentionally left free — they
--   may not yet have been through the ZATCA signing pipeline.
--
--   The columns THEMSELVES remain NULLABLE at the schema level. The rule is
--   enforced via a conditional CHECK constraint keyed on `status`. Making the
--   columns NOT NULL would break the draft workflow used by the POS before
--   an invoice is finalised.
--
-- Risks:
--   1. Existing 'issued' rows missing any ZATCA field will cause the
--      constraint validation to fail when ALTER TABLE ... ADD CONSTRAINT is
--      run WITHOUT the NOT VALID clause. This migration adds the constraint
--      as NOT VALID first, then surfaces offending rows via a SELECT so an
--      operator can remediate before running `ALTER TABLE ... VALIDATE
--      CONSTRAINT` in a later window.
--   2. Clients still writing invoices that were issued via older, non-ZATCA
--      code paths will be rejected once the constraint is validated. Gate
--      the client roll-out on all POS builds being on the ZATCA signing
--      pipeline first.
--   3. The unique index on zatca_uuid is partial (WHERE zatca_uuid IS NOT
--      NULL). Two NULL uuids are permitted; two equal non-NULL uuids are not.
--
-- Rollback:
--   BEGIN;
--     ALTER TABLE public.invoices
--       DROP CONSTRAINT IF EXISTS invoices_zatca_complete_when_issued;
--     DROP INDEX IF EXISTS public.idx_invoices_zatca_uuid;
--   COMMIT;
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 0. Pre-flight diagnostic: surface offending rows so the operator can decide
--    whether to backfill, cancel, or exclude them before VALIDATE runs.
--    This block does not mutate data — it only raises a NOTICE so ops can see
--    the scope in the migration log.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  offending_count BIGINT;
BEGIN
  SELECT COUNT(*)
    INTO offending_count
    FROM public.invoices
   WHERE status = 'issued'
     AND (zatca_hash IS NULL OR zatca_qr IS NULL OR zatca_uuid IS NULL);

  IF offending_count > 0 THEN
    RAISE NOTICE
      'v38: % issued invoices are missing one or more ZATCA fields. '
      'Constraint will be created as NOT VALID. Remediate these rows before '
      'running ALTER TABLE public.invoices VALIDATE CONSTRAINT '
      'invoices_zatca_complete_when_issued.',
      offending_count;
  ELSE
    RAISE NOTICE 'v38: all issued invoices are ZATCA-complete; safe to validate.';
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- 1. Conditional CHECK constraint: ZATCA fields are mandatory ONLY when the
--    invoice is in 'issued' status. Added as NOT VALID so existing rows are
--    NOT scanned now — new inserts and updates will be checked immediately.
--
--    After the operator confirms no offending rows remain (see §0), run:
--      ALTER TABLE public.invoices
--        VALIDATE CONSTRAINT invoices_zatca_complete_when_issued;
--    That command is intentionally NOT included here — it is a separate
--    operational step so that a first roll-out does not fail because of
--    legacy data.
-- ---------------------------------------------------------------------------
ALTER TABLE public.invoices
  DROP CONSTRAINT IF EXISTS invoices_zatca_complete_when_issued;

ALTER TABLE public.invoices
  ADD CONSTRAINT invoices_zatca_complete_when_issued
  CHECK (
    status <> 'issued'
    OR (
      zatca_hash IS NOT NULL
      AND zatca_qr  IS NOT NULL
      AND zatca_uuid IS NOT NULL
    )
  )
  NOT VALID;

-- ---------------------------------------------------------------------------
-- 2. Partial unique index on zatca_uuid.
--    ZATCA UUIDs must be globally unique per tenant — but draft / unsigned
--    invoices legitimately have NULL, and Postgres treats multiple NULLs as
--    distinct in a partial index. This gives us uniqueness where it matters
--    without blocking drafts.
-- ---------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_zatca_uuid
  ON public.invoices (zatca_uuid)
  WHERE zatca_uuid IS NOT NULL;

-- ---------------------------------------------------------------------------
-- 3. Column documentation.
--    Makes the invariant discoverable from `\d+ invoices` in psql and from
--    Supabase Studio, independent of the source migration file.
-- ---------------------------------------------------------------------------
COMMENT ON COLUMN public.invoices.zatca_hash IS
  'ZATCA invoice payload hash. Nullable for drafts. Required when status=''issued'' (enforced by invoices_zatca_complete_when_issued).';

COMMENT ON COLUMN public.invoices.zatca_qr IS
  'ZATCA QR code TLV payload (base64). Nullable for drafts. Required when status=''issued'' (enforced by invoices_zatca_complete_when_issued).';

COMMENT ON COLUMN public.invoices.zatca_uuid IS
  'ZATCA globally unique invoice UUID. Nullable for drafts. Required when status=''issued''. Partially unique via idx_invoices_zatca_uuid.';

COMMIT;

-- =============================================================================
-- Post-deploy validation step (run manually, outside this migration):
--
--   -- 1. Confirm zero offending rows:
--   SELECT COUNT(*) FROM public.invoices
--    WHERE status = 'issued'
--      AND (zatca_hash IS NULL OR zatca_qr IS NULL OR zatca_uuid IS NULL);
--
--   -- 2. Promote constraint to VALID (scans the table once):
--   ALTER TABLE public.invoices
--     VALIDATE CONSTRAINT invoices_zatca_complete_when_issued;
-- =============================================================================
