-- =============================================================================
-- Migration v70: C-4 Money Migration Stage A — discounts + org_products
-- =============================================================================
-- Branch:   fix/zatca-queue-drift → C-4 Stage A (same branch, cumulative)
-- Date:     2026-04-21
-- Type:     ALTER COLUMN TYPE on 5 money columns across 2 empty tables.
--           Single atomic BEGIN..COMMIT.
-- Scope:    Stage A "empty-table proving ground" per C-4 plan §5.
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- First production-side schema change of the C-4 Money Migration (double/
-- numeric → integer cents). Stage A targets empty tables to validate the
-- migration approach before Stage B touches products (9742 rows).
--
-- Rounds to INTEGER using `ROUND(value * 100)::INTEGER` (ROUND_HALF_UP per
-- D1 decision). Since all 5 target columns have 0 rows pre-apply (verified
-- immediately before commit), backfill is a no-op but the USING clause is
-- required by ALTER COLUMN TYPE.
--
-- Paired with Drift migration v39 → v40 on the same branch (columnTransformer
-- runs `CAST(ROUND(col * 100) AS INTEGER)` for local SQLite).
--
-- -----------------------------------------------------------------------------
-- BACKGROUND — D3 staging decision
-- -----------------------------------------------------------------------------
-- Original C-4 plan §5.318 required Supabase branch-based staging before any
-- Session 1 SQL could apply. User explicitly removed this prerequisite before
-- this migration ran, citing empty tables + cumulative session momentum.
-- Risk accepted: production is target; no staging rehearsal.
--
-- Mitigation: pre-apply row-count verification confirmed 0 rows on all 5
-- target columns. Any fractional-cent values would have been visible in
-- the D4 audit (0 rows found across all money columns at C-4 Session 1
-- Phase 2 discovery — still valid).
--
-- -----------------------------------------------------------------------------
-- ROUND_HALF_UP SEMANTICS (per C-4 Decision D1)
-- -----------------------------------------------------------------------------
-- PostgreSQL's ROUND() on DOUBLE PRECISION / NUMERIC uses round-half-to-even
-- (banker's rounding) in some configurations. For NUMERIC, ROUND() uses
-- round-half-away-from-zero — matching ROUND_HALF_UP for positive values.
-- For DOUBLE PRECISION, behavior is implementation-defined.
--
-- Since all 5 target columns have 0 rows, rounding behavior is a no-op.
-- Stage B (products) will re-verify rounding on the 9742-row backfill with
-- a fractional-cent scan before proceeding.
--
-- -----------------------------------------------------------------------------
-- SCOPE — 5 columns across 2 tables
-- -----------------------------------------------------------------------------
-- org_products:
--   default_price  NUMERIC(12,2) NOT NULL → INTEGER NOT NULL (cents)
--   cost_price     NUMERIC(12,2)          → INTEGER           (cents, nullable)
--
-- discounts:
--   value          DOUBLE PRECISION NOT NULL → INTEGER NOT NULL (cents or
--                                                                percent-in-centi,
--                                                                semantic at app layer)
--   min_purchase   DOUBLE PRECISION          → INTEGER          (cents, default 0)
--   max_discount   DOUBLE PRECISION          → INTEGER          (cents, nullable)
--
-- Note on `discounts.value` semantic: for type='percentage' rows, value was
-- historically stored as float percent (e.g. 10.0 for 10%). Post-v70, this
-- becomes int cents of percent (e.g. 1000 for 10.00%). App layer interprets
-- based on type column.
--
-- Not in scope for Stage A (deferred to Stage B / later):
--   products.price, products.cost_price (9742 rows, Stage B)
--   coupons.value, coupons.min_purchase (not in C-4 Stage A scope)
--
-- -----------------------------------------------------------------------------
-- PRE-APPLY VERIFICATION (required before executing this migration)
-- -----------------------------------------------------------------------------
-- SELECT 'org_products' AS t, COUNT(*) FROM public.org_products
-- UNION ALL SELECT 'discounts', COUNT(*) FROM public.discounts;
--
-- Expected: both 0 rows. If either has rows, STOP and re-evaluate rounding
-- + precision loss risks per C-4 plan R2.
--
-- =============================================================================


-- =============================================================================
-- APPLY BLOCK — atomic: 5 × ALTER COLUMN TYPE
-- =============================================================================
BEGIN;

-- org_products: NUMERIC(12,2) → INTEGER cents
ALTER TABLE public.org_products
  ALTER COLUMN default_price TYPE INTEGER
  USING ROUND(default_price * 100)::INTEGER;

ALTER TABLE public.org_products
  ALTER COLUMN cost_price TYPE INTEGER
  USING ROUND(cost_price * 100)::INTEGER;

-- discounts: DOUBLE PRECISION → INTEGER cents (value in centi-units)
ALTER TABLE public.discounts
  ALTER COLUMN value TYPE INTEGER
  USING ROUND(value * 100)::INTEGER;

ALTER TABLE public.discounts
  ALTER COLUMN min_purchase TYPE INTEGER
  USING ROUND(min_purchase * 100)::INTEGER;

ALTER TABLE public.discounts
  ALTER COLUMN max_discount TYPE INTEGER
  USING ROUND(max_discount * 100)::INTEGER;

COMMIT;


-- =============================================================================
-- POST-APPLY VERIFICATION
-- =============================================================================
--
-- SELECT table_name, column_name, data_type
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND ((table_name = 'org_products'
--         AND column_name IN ('default_price', 'cost_price'))
--     OR (table_name = 'discounts'
--         AND column_name IN ('value', 'min_purchase', 'max_discount')))
-- ORDER BY table_name, column_name;
--
-- Expected: 5 rows, all data_type = 'integer'.


-- =============================================================================
-- ROLLBACK DDL
-- =============================================================================
-- ⚠️  WARNING: If Drift v40 migration has already run on production devices,
--     rolling back Supabase triggers schema mismatch. Every sync push from
--     a v40-Drift device will send INTEGER but server will expect DOUBLE.
--     Coordinate rollback: Drift devices first (via forced app update or
--     schema rollback), then Supabase.
--
-- BEGIN;
--
-- ALTER TABLE public.org_products
--   ALTER COLUMN default_price TYPE NUMERIC(12,2)
--   USING (default_price::NUMERIC / 100);
-- ALTER TABLE public.org_products
--   ALTER COLUMN cost_price TYPE NUMERIC(12,2)
--   USING (cost_price::NUMERIC / 100);
--
-- ALTER TABLE public.discounts
--   ALTER COLUMN value TYPE DOUBLE PRECISION
--   USING (value::DOUBLE PRECISION / 100);
-- ALTER TABLE public.discounts
--   ALTER COLUMN min_purchase TYPE DOUBLE PRECISION
--   USING (min_purchase::DOUBLE PRECISION / 100);
-- ALTER TABLE public.discounts
--   ALTER COLUMN max_discount TYPE DOUBLE PRECISION
--   USING (max_discount::DOUBLE PRECISION / 100);
--
-- COMMIT;
--
-- =============================================================================
-- END v70 — C-4 Stage A Supabase schema; pairs with Drift v40
-- =============================================================================
