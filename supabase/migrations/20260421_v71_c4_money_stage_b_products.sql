-- =============================================================================
-- Migration v71: C-4 Money Migration Stage B — products.price + cost_price
-- =============================================================================
-- Branch:   fix/zatca-queue-drift → C-4 Stage B (same branch, cumulative)
-- Date:     2026-04-21
-- Type:     ALTER COLUMN TYPE on 2 money columns with 9742-row backfill.
--           Single atomic BEGIN..COMMIT.
-- Scope:    Products table (the big one per C-4 plan §5 Stage B).
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Second production-side schema change of C-4 Money Migration. Stage B hits
-- the largest money surface: `products` table with 9742 rows.
--
-- Pre-apply audit (required):
--   1. Row count: 9742 (matches earlier D4 census).
--   2. Fractional-cent scan: 0 rows with (col * 100) != ROUND(col * 100).
--      Safe for ROUND_HALF_UP backfill — no precision loss.
--   3. Value range: 0.68..1499.99 SAR → 68..149999 cents — well within
--      INT32 range (max 2,147,483,647).
--
-- -----------------------------------------------------------------------------
-- PAIRED CHANGES
-- -----------------------------------------------------------------------------
-- Drift v40 → v41 (same branch):
--   - ProductsTable.price RealColumn → IntColumn
--   - ProductsTable.costPrice RealColumn → IntColumn (nullable)
--   - onUpgrade case 41 uses TableMigration columnTransformer with
--     CAST(ROUND(col * 100) AS INTEGER) for local SQLite conversion.
--
-- Domain + DTO changes (alhai_core):
--   - Product.price: double → int (cents)
--   - Product.costPrice: double? → int? (cents, nullable)
--   - CreateProductParams.price: double → int
--   - UpdateProductParams.price: double? → int?
--   - ProductResponse.price/costPrice: double → int / double? → int?
--   - CreateProductRequest.price/costPrice: same
--   - UpdateProductRequest.price: same
--   - Product.profitMargin getter: ratio-preserving; unchanged formula
--
-- Consumer layer (22 files across apps + packages):
--   - UI formatters divide by 100.0 for display
--   - User input multiplies by 100 and rounds for storage
--   - Cart math keeps double SAR internally (effectivePrice / total convert
--     at the product boundary)
--   - Audit log API still accepts double SAR at the call site
--
-- -----------------------------------------------------------------------------
-- APPLY BLOCK
-- -----------------------------------------------------------------------------

BEGIN;

ALTER TABLE public.products
  ALTER COLUMN price TYPE INTEGER
  USING ROUND(price * 100)::INTEGER;

ALTER TABLE public.products
  ALTER COLUMN cost_price TYPE INTEGER
  USING ROUND(cost_price * 100)::INTEGER;

COMMIT;


-- -----------------------------------------------------------------------------
-- POST-APPLY VERIFICATION
-- -----------------------------------------------------------------------------
--
-- SELECT
--   column_name,
--   data_type,
--   (SELECT COUNT(*) FROM public.products WHERE price > 0) AS rows_with_price,
--   (SELECT MIN(price) FROM public.products WHERE price > 0) AS min_price_cents,
--   (SELECT MAX(price) FROM public.products WHERE price > 0) AS max_price_cents
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'products'
--   AND column_name IN ('price', 'cost_price');
--
-- Expected:
--   data_type = 'integer' for both columns
--   rows_with_price = 9742
--   min_price_cents = 68  (was 0.68 SAR)
--   max_price_cents = 149999  (was 1499.99 SAR)


-- -----------------------------------------------------------------------------
-- ROLLBACK DDL
-- -----------------------------------------------------------------------------
-- ⚠️  WARNING: Rolling back Supabase requires coordinated Drift rollback.
--     All deployed apps have Drift v41 (expects INTEGER). Reverting Supabase
--     alone breaks sync push (apps send INTEGER, server expects DOUBLE).
--     Coordinate: Drift devices first (app update with pre-v41 schema), then
--     Supabase rollback. For tonight's test data, rollback is trivial
--     (no production data loss).
--
-- BEGIN;
--
-- ALTER TABLE public.products
--   ALTER COLUMN price TYPE DOUBLE PRECISION
--   USING (price::DOUBLE PRECISION / 100);
-- ALTER TABLE public.products
--   ALTER COLUMN cost_price TYPE DOUBLE PRECISION
--   USING (cost_price::DOUBLE PRECISION / 100);
--
-- COMMIT;
--
-- =============================================================================
-- END v71 — C-4 Stage B Supabase schema; pairs with Drift v41
-- =============================================================================
