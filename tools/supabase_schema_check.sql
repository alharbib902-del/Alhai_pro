-- =============================================================================
-- Alhai POS — Live Supabase Schema Check
-- =============================================================================
--
-- Purpose: verify whether the production Supabase DB's money columns are
-- INTEGER (cents) or DOUBLE PRECISION (SAR). The schema drift checker
-- (tools/schema_drift_checker.dart) flagged 25 mismatches based on static
-- migration-file analysis — this query answers the live-DB question.
--
-- How to run:
--   1. Open https://supabase.com/dashboard/project/<your-project>/sql/new
--   2. Paste this entire file.
--   3. Click "Run".
--   4. Review results: any row with `data_type = 'double precision'` in the
--      first section is a real drift.
--
-- What to look for:
--   ✅ OK       — column is INTEGER / BIGINT (matches Drift int cents)
--   🔴 DRIFT    — column is DOUBLE PRECISION / REAL / NUMERIC (mismatch)
--
-- Tables under audit (covers the 25 mismatches from the static checker):
--   sales, sale_items, invoices, returns, return_items,
--   shifts, cash_movements, transactions
-- =============================================================================


-- === 1. MONEY COLUMNS AUDIT ==================================================
-- Every column in these tables that should be INTEGER per C-4 §4h.
SELECT
  table_name,
  column_name,
  data_type,
  CASE
    WHEN data_type IN ('integer', 'bigint') THEN '✅ OK (int cents)'
    WHEN data_type IN ('double precision', 'real', 'numeric')
      THEN '🔴 DRIFT — migrate to INTEGER'
    ELSE '⚠️ unexpected: ' || data_type
  END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'sales', 'sale_items', 'invoices',
    'returns', 'return_items',
    'shifts', 'cash_movements',
    'transactions'
  )
  AND column_name IN (
    -- Sales + line items money columns
    'subtotal', 'discount', 'tax_amount', 'total',
    'amount_paid', 'amount_due', 'amount_received', 'change_amount',
    'cash_amount', 'card_amount', 'credit_amount',
    'unit_price', 'cost_price', 'refund_amount',
    -- Shifts
    'opening_float', 'closing_float', 'expected_cash', 'actual_cash',
    'total_sales', 'total_sales_amount', 'total_refunds_amount',
    -- Cash movements + transactions
    'amount', 'balance_after',
    -- Returns
    'total_refund'
  )
ORDER BY
  CASE WHEN data_type IN ('double precision', 'real', 'numeric') THEN 0 ELSE 1 END,
  table_name,
  column_name;


-- === 2. QTY COLUMNS AUDIT ====================================================
-- Qty columns should be DOUBLE PRECISION (fractional units like 2.5 kg).
-- v79 migrated most; check no INTEGER leaks remain.
SELECT
  table_name,
  column_name,
  data_type,
  CASE
    WHEN data_type IN ('double precision', 'real', 'numeric') THEN '✅ OK (fractional)'
    WHEN data_type IN ('integer', 'bigint')
      THEN '🟠 DRIFT — fractional qty would truncate, migrate to DOUBLE'
    ELSE '⚠️ unexpected: ' || data_type
  END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name IN (
    'qty', 'quantity', 'stock_qty', 'min_qty',
    'quantity_change', 'previous_qty', 'new_qty', 'received_qty'
  )
ORDER BY
  CASE WHEN data_type IN ('integer', 'bigint') THEN 0 ELSE 1 END,
  table_name,
  column_name;


-- === 3. SUMMARY ==============================================================
-- Single-row yes/no: is any money column still DOUBLE? Is any qty still INT?
WITH money_drift AS (
  SELECT count(*) AS cnt
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN (
      'sales', 'sale_items', 'invoices', 'returns', 'return_items',
      'shifts', 'cash_movements', 'transactions'
    )
    AND column_name IN (
      'subtotal', 'discount', 'tax_amount', 'total',
      'amount_paid', 'amount_due', 'amount_received', 'change_amount',
      'cash_amount', 'card_amount', 'credit_amount',
      'unit_price', 'cost_price', 'refund_amount',
      'opening_float', 'closing_float', 'expected_cash', 'actual_cash',
      'total_sales_amount', 'total_refunds_amount',
      'amount', 'balance_after', 'total_refund'
    )
    AND data_type IN ('double precision', 'real', 'numeric')
),
qty_drift AS (
  SELECT count(*) AS cnt
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name IN (
      'qty', 'quantity', 'stock_qty', 'min_qty',
      'quantity_change', 'previous_qty', 'new_qty', 'received_qty'
    )
    AND data_type IN ('integer', 'bigint')
)
SELECT
  m.cnt                                              AS money_drift_count,
  q.cnt                                              AS qty_drift_count,
  CASE
    WHEN m.cnt = 0 AND q.cnt = 0 THEN
      '✅ No live drift. The static checker''s mismatches are stale migration history only.'
    WHEN m.cnt > 0 AND q.cnt = 0 THEN
      '🔴 Live money drift confirmed — v80 migration needed.'
    WHEN m.cnt = 0 AND q.cnt > 0 THEN
      '🟠 Qty drift — check product_expiry.quantity etc.'
    ELSE
      '🔴 Both money and qty drift — need combined v80 migration.'
  END                                                AS verdict
FROM money_drift m, qty_drift q;
