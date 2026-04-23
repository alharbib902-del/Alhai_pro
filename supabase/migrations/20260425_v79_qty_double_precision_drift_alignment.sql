-- =============================================================================
-- Migration v79: Align Supabase `qty` columns to DOUBLE PRECISION (Drift parity)
-- =============================================================================
-- Branch:   fix/c4-schema-drift-return-items-total
-- Date:     2026-04-25
-- Type:     ALTER COLUMN TYPE on 3 qty columns. Single atomic BEGIN..COMMIT.
--           Lossless int → double cast (no data rewrite beyond the type bump).
-- Scope:    inventory_movements.qty, return_items.qty, purchase_items.qty.
--           sale_items.qty is already DOUBLE PRECISION (no change).
--
-- -----------------------------------------------------------------------------
-- CONTEXT
-- -----------------------------------------------------------------------------
-- Drift schema stores `qty` as `RealColumn` (double) on four tables —
-- sale_items, return_items, purchase_items, inventory_movements — because
-- POS workflows need fractional quantities for weighed goods (e.g. 2.5 kg
-- produce, 0.75 L dispensed liquids).
--
-- Column-type audit 2026-04-25 found Supabase stored qty as DOUBLE PRECISION
-- only for `sale_items`. The other three tables had qty as INTEGER, which:
--   - rejects any fractional push at the insert with
--     "invalid input syntax for type integer", or
--   - (depending on path) silently truncates to 0/floor.
--
-- Present state on live Supabase (2026-04-25):
--   - inventory_movements: 60 rows, all integer-valued today (no fractional
--     sales yet) so the current schema hasn't blocked pushes — but every
--     future weighed-item sale would, starting with the first one.
--   - return_items: 0 rows. Empty.
--   - purchase_items: 0 rows. Empty.
--   - sale_items: 30 rows, DOUBLE PRECISION already — 0 fractional today.
--
-- The fix aligns the three drifted columns with Drift. No Dart code change
-- needed — Drift already builds payloads with double qty; this just lets
-- Postgres accept them.
--
-- -----------------------------------------------------------------------------
-- PRE-APPLY AUDIT (run these before BEGIN and paste results back)
-- -----------------------------------------------------------------------------
--
-- Q1. Current column types (expect `integer` for all three):
--
--   SELECT table_name, column_name, data_type
--   FROM information_schema.columns
--   WHERE table_schema = 'public'
--     AND column_name = 'qty'
--     AND table_name IN ('inventory_movements','return_items','purchase_items');
--
-- Q2. Value ranges + non-null counts (for post-apply invariant check):
--
--   SELECT 'inventory_movements' AS t, COUNT(*) AS rows, MIN(qty) AS min_qty, MAX(qty) AS max_qty FROM public.inventory_movements
--   UNION ALL
--   SELECT 'return_items', COUNT(*), MIN(qty), MAX(qty) FROM public.return_items
--   UNION ALL
--   SELECT 'purchase_items', COUNT(*), MIN(qty), MAX(qty) FROM public.purchase_items;
--
-- -----------------------------------------------------------------------------
-- APPLY BLOCK
-- -----------------------------------------------------------------------------

BEGIN;

ALTER TABLE public.inventory_movements
  ALTER COLUMN qty TYPE DOUBLE PRECISION USING qty::DOUBLE PRECISION;

ALTER TABLE public.return_items
  ALTER COLUMN qty TYPE DOUBLE PRECISION USING qty::DOUBLE PRECISION;

ALTER TABLE public.purchase_items
  ALTER COLUMN qty TYPE DOUBLE PRECISION USING qty::DOUBLE PRECISION;

COMMIT;


-- -----------------------------------------------------------------------------
-- POST-APPLY VERIFICATION
-- -----------------------------------------------------------------------------
--
-- Q3. New column types are `double precision`:
--
--   SELECT table_name, column_name, data_type
--   FROM information_schema.columns
--   WHERE table_schema = 'public'
--     AND column_name = 'qty'
--     AND table_name IN ('inventory_movements','return_items','purchase_items');
--
--   Expected: data_type = 'double precision' for all three.
--
-- Q4. Row count + value-range invariant preserved (compare with Q2):
--
--   SELECT 'inventory_movements' AS t, COUNT(*), MIN(qty), MAX(qty) FROM public.inventory_movements
--   UNION ALL
--   SELECT 'return_items', COUNT(*), MIN(qty), MAX(qty) FROM public.return_items
--   UNION ALL
--   SELECT 'purchase_items', COUNT(*), MIN(qty), MAX(qty) FROM public.purchase_items;
--
--   Expected: same COUNT / MIN / MAX as Q2 (int → double is lossless).
--
-- -----------------------------------------------------------------------------
-- ROLLBACK DDL (only if downgrading both Supabase AND Drift to pre-v79 state)
-- -----------------------------------------------------------------------------
-- ⚠️  WARNING: Rolling back to INTEGER would truncate any fractional qty
--     pushed after v79 applied. If weighed-item sales happened between apply
--     and rollback, those rows would lose precision on the rollback cast.
--     Do NOT run blindly — confirm no fractional qty exists first:
--
--     SELECT 'inventory_movements' AS t, COUNT(*) AS frac FROM public.inventory_movements WHERE qty <> FLOOR(qty)
--     UNION ALL SELECT 'return_items', COUNT(*) FROM public.return_items WHERE qty <> FLOOR(qty)
--     UNION ALL SELECT 'purchase_items', COUNT(*) FROM public.purchase_items WHERE qty <> FLOOR(qty);
--
--     Only proceed if all three return 0.
--
-- BEGIN;
--
-- ALTER TABLE public.inventory_movements
--   ALTER COLUMN qty TYPE INTEGER USING qty::INTEGER;
-- ALTER TABLE public.return_items
--   ALTER COLUMN qty TYPE INTEGER USING qty::INTEGER;
-- ALTER TABLE public.purchase_items
--   ALTER COLUMN qty TYPE INTEGER USING qty::INTEGER;
--
-- COMMIT;
--
-- =============================================================================
-- END v79 — Supabase qty columns now match Drift RealColumn for the 3 drifted
-- tables; sale_items was already aligned. No Dart code change required.
-- =============================================================================
