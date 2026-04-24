-- =============================================================================
-- v80: Align remaining qty columns to DOUBLE PRECISION (fractional units)
-- =============================================================================
--
-- Context: v79 (2026-04-25) migrated the primary qty columns on line-item
-- tables (sale_items.qty, purchase_items.qty, return_items.qty,
-- order_items.quantity, inventory_movements.qty). The live schema check on
-- 2026-04-24 revealed 7 auxiliary qty columns were missed — still INTEGER
-- on Supabase while the code flows treat them as fractional (Drift side is
-- REAL and callers pass doubles that get silently truncated on push).
--
-- Columns in scope (from tools/supabase_schema_check.sql output):
--   products.stock_qty                  -- can't track 2.5 kg rice stock
--   products.min_qty                    -- can't reorder at 1.5 kg threshold
--   inventory_movements.previous_qty    -- snapshot of stock before move
--   inventory_movements.new_qty         -- snapshot of stock after move
--   purchase_items.received_qty         -- partial reception (1.3 kg of 2 kg)
--   product_expiry.quantity             -- batch qty
--   stock_deltas.quantity_change        -- per-device delta (can be fractional)
--
-- Money columns: CONFIRMED ALIGNED (0 drift from live check). No action.
--
-- =============================================================================
-- SAFETY MODEL
-- =============================================================================
--
-- Type widening INTEGER -> DOUBLE PRECISION is a **lossless** cast in
-- PostgreSQL — existing integer values (1, 5, 100) become (1.0, 5.0, 100.0)
-- with no data loss. No USING clause needed. No backfill logic.
--
-- This is MUCH safer than the money migration would have been (money needed
-- `ROUND(col * 100)::INTEGER` with a value transform). Here we just widen
-- the type. Running on a populated table is cheap (an in-place rewrite on
-- each row, but no arithmetic).
--
-- RISK: on very large tables (1M+ rows) the ALTER TABLE holds an ACCESS
-- EXCLUSIVE lock for the duration. For Alhai POS the biggest table is
-- inventory_movements (likely 100k-500k rows per store); lock held ~seconds.
--
-- MITIGATION: run inside BEGIN..COMMIT so either everything migrates or
-- nothing does. If any column fails, the whole migration rolls back.
--
-- =============================================================================
-- DEPLOYMENT CHECKLIST (before running on prod)
-- =============================================================================
--
-- [ ] 1. Apply this migration to a staging project first (pg_dump + restore).
-- [ ] 2. Verify: SELECT data_type FROM information_schema.columns
--          WHERE table_name IN ('products','inventory_movements',...)
--          AND column_name IN ('stock_qty','min_qty','previous_qty',...);
--       All should be 'double precision'.
-- [ ] 3. Run representative POS flows on staging (sell 2.5 kg, receive 1.3 kg)
--       and verify the Drift↔Supabase round-trip preserves decimals.
-- [ ] 4. Schedule prod maintenance window (5-15 min expected).
-- [ ] 5. Take Supabase snapshot immediately before running.
-- [ ] 6. Run migration on prod in single transaction.
-- [ ] 7. Re-run tools/supabase_schema_check.sql — qty_drift_count must be 0.
-- [ ] 8. Monitor sync_queue for next 30 min for any REGCLASS / type errors.
--
-- =============================================================================
-- APPLY BLOCK — atomic: 7 × ALTER COLUMN TYPE
--
-- **v80 r2 (2026-04-24):** products.stock_qty is referenced by the trigger
-- `trigger_stock_alert` with an `AFTER UPDATE OF stock_qty` clause. Postgres
-- refuses to ALTER TYPE while that OF-clause dependency exists. We drop the
-- trigger, run the ALTERs, then recreate it with identical definition. The
-- `check_stock_alert` function body is unchanged — plpgsql auto-promotes
-- int↔double for `NEW.stock_qty` comparisons so no function edit needed.
--
-- The second trigger on products (`set_updated_at`) is `BEFORE UPDATE` with
-- no `OF column` clause → Postgres allows the ALTER without dropping it.
-- Other tables touched (inventory_movements / purchase_items / product_expiry
-- / stock_deltas) have no OF-column triggers on the columns we alter.
-- =============================================================================

BEGIN;

-- Drop the only blocking dependency (exact same CREATE re-emitted at end).
DROP TRIGGER IF EXISTS trigger_stock_alert ON public.products;

-- products: core inventory columns. Most-read table in the system.
ALTER TABLE public.products
  ALTER COLUMN stock_qty TYPE DOUBLE PRECISION;

ALTER TABLE public.products
  ALTER COLUMN min_qty TYPE DOUBLE PRECISION;

-- inventory_movements: qty snapshot pair. Required for auditing fractional
-- adjustments (e.g. wastage of 0.25 kg).
ALTER TABLE public.inventory_movements
  ALTER COLUMN previous_qty TYPE DOUBLE PRECISION;

ALTER TABLE public.inventory_movements
  ALTER COLUMN new_qty TYPE DOUBLE PRECISION;

-- purchase_items: partial reception support.
ALTER TABLE public.purchase_items
  ALTER COLUMN received_qty TYPE DOUBLE PRECISION;

-- product_expiry: batch-level qty tracking.
ALTER TABLE public.product_expiry
  ALTER COLUMN quantity TYPE DOUBLE PRECISION;

-- stock_deltas: multi-device delta sync. Delta itself can be fractional.
ALTER TABLE public.stock_deltas
  ALTER COLUMN quantity_change TYPE DOUBLE PRECISION;

-- Recreate the stock-alert trigger — identical shape to the original.
-- Definition extracted via pg_get_triggerdef on 2026-04-24.
CREATE TRIGGER trigger_stock_alert
  AFTER UPDATE OF stock_qty ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.check_stock_alert();

COMMIT;

-- =============================================================================
-- POST-MIGRATION VERIFICATION (paste after running)
-- =============================================================================

SELECT
  table_name,
  column_name,
  data_type,
  CASE
    WHEN data_type = 'double precision' THEN '✅ migrated'
    ELSE '🔴 still ' || data_type
  END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    (table_name = 'products' AND column_name IN ('stock_qty', 'min_qty'))
    OR (table_name = 'inventory_movements'
        AND column_name IN ('previous_qty', 'new_qty'))
    OR (table_name = 'purchase_items' AND column_name = 'received_qty')
    OR (table_name = 'product_expiry' AND column_name = 'quantity')
    OR (table_name = 'stock_deltas' AND column_name = 'quantity_change')
  )
ORDER BY table_name, column_name;

-- Expected output: 7 rows, all '✅ migrated'.
