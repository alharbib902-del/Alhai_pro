-- ═══════════════════════════════════════════════════════════════════════════
-- Migration v75 (2026-04-22) — Supabase cleanup
--
-- Part A: Partial indexes on `deleted_at IS NULL` for the active-row fast path
-- Part B: Drop 2 orphan *_org_isolation policies that referenced a dead setting
--
-- Applied live on 2026-04-22 during Session 17 (after C-4 Sessions 13-16).
-- All operations idempotent (IF NOT EXISTS / IF EXISTS) — safe to re-run.
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

-- ───────── Part A: Partial indexes on active rows ─────────
-- 10 tables with soft-delete (deleted_at) now have an active-row index.
-- Common read pattern: WHERE deleted_at IS NULL. Without partial index,
-- Postgres scans full table. Partial index narrows scan to active rows.

CREATE INDEX IF NOT EXISTS idx_categories_active
  ON public.categories (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_orders_active
  ON public.orders (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_org_products_active
  ON public.org_products (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_products_active
  ON public.products (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_promotions_active
  ON public.promotions (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_returns_active
  ON public.returns (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_sales_active
  ON public.sales (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_stores_active
  ON public.stores (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_suppliers_active
  ON public.suppliers (id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_users_active
  ON public.users (id) WHERE deleted_at IS NULL;

-- ───────── Part B: Drop orphan *_org_isolation policies ─────────
-- These policies used `current_setting('app.current_org_id')` — verified via
-- grep across Dart + SQL that nothing ever SETs that setting. Dead code.
-- Both tables retain full CRUD policy coverage (4 policies each) after DROP,
-- confirmed via V-POST-C.

DROP POLICY IF EXISTS expense_categories_org_isolation ON public.expense_categories;
DROP POLICY IF EXISTS loyalty_rewards_org_isolation ON public.loyalty_rewards;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════
-- V-POST verification (executed 2026-04-22, all ✓)
--   A. 10 new idx_*_active partial indexes exist
--   B. 0 orphan policies remain
--   C. expense_categories: 4 policies (insert/update/select/delete);
--      loyalty_rewards: 4 policies — full CRUD coverage preserved
--
-- ROLLBACK (if needed):
--   BEGIN;
--   DROP INDEX IF EXISTS public.idx_categories_active;
--   DROP INDEX IF EXISTS public.idx_orders_active;
--   DROP INDEX IF EXISTS public.idx_org_products_active;
--   DROP INDEX IF EXISTS public.idx_products_active;
--   DROP INDEX IF EXISTS public.idx_promotions_active;
--   DROP INDEX IF EXISTS public.idx_returns_active;
--   DROP INDEX IF EXISTS public.idx_sales_active;
--   DROP INDEX IF EXISTS public.idx_stores_active;
--   DROP INDEX IF EXISTS public.idx_suppliers_active;
--   DROP INDEX IF EXISTS public.idx_users_active;
--   -- (orphan policy recreate not provided — they were dead code with no callers;
--   --  no reason to restore)
--   COMMIT;
-- ═══════════════════════════════════════════════════════════════════════════
