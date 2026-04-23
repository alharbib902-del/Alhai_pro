-- =============================================================================
-- Migration v77: Backfill invoices for pre-fix orphan sales (C-4 Session 2)
-- =============================================================================
-- Branch:   fix/c4-invoice-sync-enqueue-missing
-- Date:     2026-04-24
-- Type:     INSERT ... SELECT against public.invoices for each sale that has
--           no linked invoice. Idempotent via NOT EXISTS on sale_id.
--
-- -----------------------------------------------------------------------------
-- WHY
-- -----------------------------------------------------------------------------
-- Investigation on 2026-04-24 (Session 45) found two paired client-side bugs:
--
--   Bug A — invoice_service.createFromSale wrote `invoice.* = sale.* * 100`
--           against an already-cents source → 100× corruption on every
--           local invoice. Fixed on main @ 9b154327.
--
--   Bug B — invoice_service did NOT enqueue the created invoice to the
--           sync queue, so NOTHING ever pushed invoices to Supabase. Fixed
--           on main via this branch's code commits (SyncService injection).
--
-- Net effect on live Supabase: every completed POS sale since
-- 2026-04-22 landed in `public.sales` but produced no corresponding
-- `public.invoices` row. That is a ZATCA compliance gap — by regulation
-- every B2C sale issues a simplified tax invoice.
--
-- This migration fills the gap for historical sales. After the new POS
-- build ships with the Bug B fix, NEW sales will push invoices via the
-- normal sync path.
--
-- -----------------------------------------------------------------------------
-- IDEMPOTENCY
-- -----------------------------------------------------------------------------
-- The WHERE NOT EXISTS filter makes this safe to re-run. If some invoices
-- land from the fixed client before this migration runs, this will skip
-- those and only insert for the remaining orphans.
--
-- -----------------------------------------------------------------------------
-- SCHEMA NOTE
-- -----------------------------------------------------------------------------
-- Supabase `public.invoices` columns (subtotal, discount, tax_rate,
-- tax_amount, total, amount_paid, amount_due) are DOUBLE PRECISION (v15
-- schema — no int-cents counterpart migrated yet on the server). Source
-- `public.sales` columns are likewise DOUBLE PRECISION. So the SELECT
-- passes source amounts through with no conversion. When the deferred
-- Supabase int-cents counterpart migration lands, that migration must
-- convert both tables atomically (paired ALTER COLUMN TYPE with
-- CAST(ROUND(col * 100) AS INTEGER), per the v71 pattern).
--
-- -----------------------------------------------------------------------------
-- INVOICE NUMBER FORMAT
-- -----------------------------------------------------------------------------
-- Uses the `INV-{year}-BF-{seq:4}` prefix to distinguish backfill rows
-- from normal sequence-generated numbers (INV-{year}-{seq:5}). A
-- per-store ROW_NUMBER starting at 1 keeps the numbering deterministic.
-- The unique index (store_id, invoice_number) still protects against
-- cross-session collisions because of the distinct -BF- infix.
--
-- -----------------------------------------------------------------------------
-- PRE-APPLY VERIFICATION QUERIES
-- -----------------------------------------------------------------------------
-- Q1 (expected row count to backfill):
--   SELECT COUNT(*) FROM public.sales s
--   WHERE s.status = 'completed'
--     AND NOT EXISTS (SELECT 1 FROM public.invoices i WHERE i.sale_id = s.id);
--   -- Expected on 2026-04-24: 11
--
-- Q2 (no accidental duplicates from a prior partial run):
--   SELECT s.id AS sale_id, COUNT(i.id) AS invoice_count
--     FROM public.sales s
--     LEFT JOIN public.invoices i ON i.sale_id = s.id
--    WHERE s.status = 'completed'
--    GROUP BY s.id
--   HAVING COUNT(i.id) > 1;
--   -- Expected: 0 rows
--
-- POST-APPLY VERIFICATION QUERIES
-- Q3 (every completed sale now has exactly one invoice):
--   SELECT COUNT(*) AS orphan_sales
--     FROM public.sales s
--    WHERE s.status = 'completed'
--      AND NOT EXISTS (SELECT 1 FROM public.invoices i WHERE i.sale_id = s.id);
--   -- Expected: 0
--
-- Q4 (backfilled invoices match sale totals byte-exact):
--   SELECT COUNT(*) AS mismatched_totals
--     FROM public.invoices i
--     JOIN public.sales s ON s.id = i.sale_id
--    WHERE i.invoice_number LIKE 'INV-%-BF-%'
--      AND i.total <> s.total;
--   -- Expected: 0
--
-- Q5 (row count sanity):
--   SELECT invoice_type, COUNT(*) FROM public.invoices GROUP BY 1 ORDER BY 1;
--   -- Should now include simplified_tax rows matching Q1's count.
--
-- -----------------------------------------------------------------------------
-- ROLLBACK
-- -----------------------------------------------------------------------------
-- /*
-- -- If the backfill needs to be reversed before the fix ships and new
-- -- invoices arrive via the normal sync path, delete only the backfill
-- -- rows by matching the distinctive invoice number pattern.
-- BEGIN;
-- DELETE FROM public.invoices WHERE invoice_number LIKE 'INV-%-BF-%';
-- COMMIT;
-- */
--
-- =============================================================================

BEGIN;

INSERT INTO public.invoices (
  id,
  org_id,
  store_id,
  invoice_number,
  invoice_type,
  status,
  sale_id,
  customer_id,
  customer_name,
  customer_phone,
  subtotal,
  discount,
  tax_rate,
  tax_amount,
  total,
  payment_method,
  amount_paid,
  amount_due,
  currency,
  created_by,
  issued_at,
  paid_at,
  created_at
)
SELECT
  gen_random_uuid()::text                           AS id,
  s.org_id,
  s.store_id,
  'INV-' || EXTRACT(YEAR FROM s.created_at)::text
    || '-BF-' || LPAD(
      ROW_NUMBER() OVER (
        PARTITION BY s.store_id, EXTRACT(YEAR FROM s.created_at)
        ORDER BY s.created_at
      )::text,
      4,
      '0'
    )                                                AS invoice_number,
  'simplified_tax'                                   AS invoice_type,
  CASE WHEN s.is_paid THEN 'paid' ELSE 'issued' END  AS status,
  s.id                                               AS sale_id,
  s.customer_id,
  s.customer_name,
  s.customer_phone,
  s.subtotal,
  s.discount,
  15.0                                               AS tax_rate,
  s.tax                                              AS tax_amount,
  s.total,
  s.payment_method,
  CASE
    WHEN s.is_paid THEN s.total
    ELSE COALESCE(s.amount_received, 0)
  END                                                AS amount_paid,
  CASE
    WHEN s.is_paid THEN 0
    ELSE s.total - COALESCE(s.amount_received, 0)
  END                                                AS amount_due,
  'SAR'                                              AS currency,
  s.cashier_id                                       AS created_by,
  s.created_at                                       AS issued_at,
  CASE WHEN s.is_paid THEN s.created_at ELSE NULL END AS paid_at,
  s.created_at                                       AS created_at
FROM public.sales s
WHERE s.status = 'completed'
  AND NOT EXISTS (
    SELECT 1 FROM public.invoices i WHERE i.sale_id = s.id
  );

COMMIT;

-- =============================================================================
-- END OF MIGRATION v77
-- =============================================================================
