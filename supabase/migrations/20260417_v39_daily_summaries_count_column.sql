-- ============================================================
-- Migration v39: add total_refunds_count to daily_summaries.
-- Date: 2026-04-17
-- Author: Schema team
--
-- Purpose
--   Close the last semantic mismatch between Drift's daily_summaries and
--   Supabase's daily_summaries.
--
--   Drift schema has:
--     totalSales          INTEGER  (count of sales)
--     totalSalesAmount    REAL     (sum of sale amounts in currency)
--     totalRefunds        INTEGER  (count of refunds)     <-- no Supabase twin
--     totalRefundsAmount  REAL     (sum of refunded money)
--
--   Supabase (post-v29) has:
--     total_sales         DOUBLE PRECISION  (money)        [v25]
--     total_sales_count   INTEGER           (count)        [v29]
--     total_refunds       DOUBLE PRECISION  (money)        [v25]
--     total_refunds_amount DOUBLE PRECISION (money)        [v29 — duplicate of total_refunds]
--     (no total_refunds_count)
--
--   Without this column, the sync layer is forced to stuff Drift's integer
--   refund-count into Supabase's `total_refunds` DOUBLE column, which is
--   semantically a money field. Reports then mis-read counts as riyals.
--
-- What this migration does
--   1. Adds `total_refunds_count INTEGER DEFAULT 0` for the INT count.
--   2. Backfills it from any rows whose historical `total_refunds` value
--      looks like a whole-number count (0..999) rather than money — a
--      heuristic that captures the likely-wrong rows without over-reaching.
--   3. Adds a comment on both columns disambiguating them.
--
-- What this migration does NOT do
--   - Does not drop or rename the ambiguous `total_refunds` column (doing
--     so would break any app/BI tool still reading it). Leave the cleanup
--     to a later migration once all consumers are migrated.
--   - Does not change Drift. That is handled in
--     packages/alhai_sync/lib/src/sync_payload_utils.dart (column mapping).
--
-- Risks
--   - The backfill heuristic is conservative: rows whose total_refunds is
--     already > 999 (genuine money amounts) are NOT touched. Ops should
--     review the row count affected by the diagnostic below before deploy.
-- ============================================================

-- 1. Add the count column
ALTER TABLE public.daily_summaries
  ADD COLUMN IF NOT EXISTS total_refunds_count INTEGER DEFAULT 0;

-- 2. Diagnostic: surface how many rows would be touched by backfill.
DO $$
DECLARE
  v_candidate_rows BIGINT;
BEGIN
  SELECT COUNT(*) INTO v_candidate_rows
  FROM public.daily_summaries
  WHERE total_refunds IS NOT NULL
    AND total_refunds = FLOOR(total_refunds)
    AND total_refunds >= 0
    AND total_refunds <= 999;

  RAISE NOTICE 'v39: % daily_summaries rows look like integer counts in total_refunds — will be moved to total_refunds_count', v_candidate_rows;
END $$;

-- 3. Conservative backfill: only touch rows that look like counts.
UPDATE public.daily_summaries
SET total_refunds_count = CAST(total_refunds AS INTEGER)
WHERE total_refunds IS NOT NULL
  AND total_refunds = FLOOR(total_refunds)
  AND total_refunds >= 0
  AND total_refunds <= 999
  AND total_refunds_count = 0;

-- 4. Disambiguating column comments
COMMENT ON COLUMN public.daily_summaries.total_sales       IS 'Sum of sale amounts for the day (money).';
COMMENT ON COLUMN public.daily_summaries.total_sales_count IS 'Count of sales for the day (integer). Drift source: totalSales.';
COMMENT ON COLUMN public.daily_summaries.total_refunds     IS 'Historically ambiguous — contained count or money depending on client version. Deprecated: new clients write total_refunds_count (INT) and total_refunds_amount (money).';
COMMENT ON COLUMN public.daily_summaries.total_refunds_count IS 'Count of refunds for the day (integer). Drift source: totalRefunds.';
COMMENT ON COLUMN public.daily_summaries.total_refunds_amount IS 'Sum of refunded amounts for the day (money). Drift source: totalRefundsAmount.';
