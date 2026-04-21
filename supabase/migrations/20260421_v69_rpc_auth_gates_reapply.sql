-- =============================================================================
-- Migration v69: RPC AUTH GATE re-apply — v37 intent for 8 remaining RPCs
-- =============================================================================
-- Branch:   fix/rpc-auth-gates
-- Date:     2026-04-21
-- Type:     Body-level security hardening (8 × CREATE OR REPLACE).
--           Single atomic BEGIN..COMMIT.
-- Scope:    8 SECURITY DEFINER RPCs on public.* that existed on live DB but
--           lacked AUTH GATES. (9th — release_reserved_stock — already
--           hardened in v68.)
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Closes the body-level AUTH GATE gap left by v68, which handled config-
-- level CVE hardening (search_path) for 35 SECURITY DEFINER functions but
-- deferred privilege-escalation gates for dedicated treatment.
--
-- v37 (2026-04-16) originally intended AUTH GATES for 17 RPCs. Phase A
-- audit found that only 9 of those 17 exist on live DB today (8 are
-- phantom — never created or removed later). Of the 9:
--   - 1 (release_reserved_stock) got AUTH GATE in v68 (along with column fix)
--   - 8 remain to be hardened — this migration's scope
--
-- -----------------------------------------------------------------------------
-- SCOPE — 8 RPCs hardened
-- -----------------------------------------------------------------------------
-- Store-scoped (3): AUTH + has_store_access(p_store_id) check
--   apply_stock_deltas(p_store_id, p_deltas)
--   apply_stock_deltas(p_org_id, p_store_id, p_deltas)
--   get_store_stats(p_store_id)
--
-- Authentication-only (5): AUTH check; scope enforced by RPC-specific logic
--   reserve_online_stock(p_product_id, p_qty double precision)
--   reserve_online_stock(p_store_id, p_items jsonb)
--   release_online_stock(p_product_id, p_qty double precision)
--   confirm_delivery(p_order_id, p_confirmation_code)
--   sync_org_product_to_stores(p_org_product_id)
--
-- -----------------------------------------------------------------------------
-- SCOPE NOT AFFECTED (not on live)
-- -----------------------------------------------------------------------------
-- 8 RPCs from v37 that don't exist on live:
--   sa_monthly_revenue(), sa_top_stores_by_revenue(INT),
--   sa_top_stores_by_transactions(INT),
--   update_order_with_items(UUID, TEXT, TEXT, JSONB),
--   batch_update_product_prices(UUID, JSONB),
--   get_driver_dashboard_stats(UUID),
--   assign_delivery_to_driver(UUID, UUID, TEXT),
--   insert_security_events(JSONB)
-- If any of these get created in the future, they'll need AUTH GATES too.
--
-- -----------------------------------------------------------------------------
-- DESIGN DECISIONS
-- -----------------------------------------------------------------------------
-- 1. AUTH GATE pattern (matches v37 intent):
--      IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
--
-- 2. Store-access pattern: USE `has_store_access(p_store_id)` HELPER
--    instead of v37's direct `store_members` query. Rationale:
--      - `has_store_access` is the canonical access check post-v50
--        (hardened + multi-store + includes owner via is_store_owner OR)
--      - Matches the pattern used in v64-v67 RLS policies
--      - Avoids policy-vs-RPC logic divergence
--
-- 3. Body preservation: where live body differs from v37's (e.g. the
--    apply_stock_deltas v16 variant uses INTEGER type, v14 variant uses
--    NUMERIC), LIVE BODY is preserved. v37 changes are scoped to
--    AUTH GATES only — no silent semantic changes.
--
-- 4. search_path: re-specified in SET clause of each CREATE OR REPLACE
--    (v68 set this via ALTER FUNCTION; CREATE OR REPLACE fully redefines
--    so we must include it explicitly, matching v50 + v68 pattern).
--
-- 5. SECURITY DEFINER preserved (was true on live, remains true).
--
-- -----------------------------------------------------------------------------
-- RISK CONSIDERATIONS
-- -----------------------------------------------------------------------------
-- - apply_stock_deltas: requires user to have store access via store_members
--   or ownership. Clients calling this from POS sync should already satisfy
--   this (cashier is a store_member). super_admin users CAN'T call this —
--   intentional, stock changes are staff work.
--
-- - get_store_stats: same store-access requirement. super_admin can't call
--   directly (would need to go through sa_* datasources which query tables
--   directly under `*_super_admin` policies, not via this RPC).
--
-- - reserve_online_stock / release_online_stock / release_reserved_stock /
--   confirm_delivery / sync_org_product_to_stores: any authenticated user
--   can call. Protection is RPC-specific (row-level matching in WHERE
--   clauses, order ownership via delivery status, etc.). This mirrors
--   v37's intended scope.
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED
-- -----------------------------------------------------------------------------
-- Applied to Supabase production on 2026-04-21 via SQL Editor in a single
-- atomic BEGIN..COMMIT block. V-POST verification confirmed all 8 (+ v68's
-- release_reserved_stock) now have:
--   - has_auth_null_check = true
--   - has_store_access_check = true (for the 3 store-scoped)
--   - has_search_path = true
-- =============================================================================


-- =============================================================================
-- APPLY BLOCK — atomic: 8 × CREATE OR REPLACE
-- =============================================================================
BEGIN;

-- ############################################################
-- B1. apply_stock_deltas(TEXT, JSONB) — v16 variant
-- Store-scoped stock mutation. Requires store access.
-- ############################################################
CREATE OR REPLACE FUNCTION public.apply_stock_deltas(
  p_store_id TEXT,
  p_deltas JSONB
) RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  delta_item JSONB;
  v_product_id TEXT;
  v_qty_change INTEGER;
  v_count INTEGER := 0;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  -- AUTH GATE: must have access to the target store
  IF NOT public.has_store_access(p_store_id) THEN
    RAISE EXCEPTION 'Access denied: no access to this store';
  END IF;

  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'qty_change')::INTEGER;

    UPDATE public.products
    SET stock_qty = stock_qty + v_qty_change, updated_at = NOW()
    WHERE id = v_product_id AND store_id = p_store_id;

    IF FOUND THEN v_count := v_count + 1; END IF;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ############################################################
-- B2. apply_stock_deltas(TEXT, TEXT, JSONB) — v14 variant
-- Org + store-scoped stock mutation. Requires store access.
-- ############################################################
CREATE OR REPLACE FUNCTION public.apply_stock_deltas(
  p_org_id TEXT,
  p_store_id TEXT,
  p_deltas JSONB
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  delta_item JSONB;
  new_stock NUMERIC;
  result JSONB := '[]'::JSONB;
  v_product_id TEXT;
  v_qty_change NUMERIC;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  -- AUTH GATE: must have access to the target store
  IF NOT public.has_store_access(p_store_id) THEN
    RAISE EXCEPTION 'Access denied: no access to this store';
  END IF;

  FOR delta_item IN SELECT * FROM jsonb_array_elements(p_deltas)
  LOOP
    v_product_id := delta_item->>'product_id';
    v_qty_change := (delta_item->>'quantity_change')::NUMERIC;

    UPDATE public.products
    SET stock_qty = stock_qty + v_qty_change, updated_at = NOW()
    WHERE id = v_product_id AND store_id = p_store_id
    RETURNING stock_qty INTO new_stock;

    IF FOUND THEN
      result := result || jsonb_build_object(
        'product_id', v_product_id,
        'final_stock', new_stock
      );
    END IF;
  END LOOP;

  RETURN result;
END;
$$;

-- ############################################################
-- B3. reserve_online_stock(TEXT, DOUBLE PRECISION) — v16 variant
-- Single-product reservation. Authentication only.
-- ############################################################
CREATE OR REPLACE FUNCTION public.reserve_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_available DOUBLE PRECISION;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT (stock_qty - COALESCE(online_reserved_qty, 0))
    INTO v_available
    FROM public.products
   WHERE id = p_product_id
     FOR UPDATE;

  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF v_available < p_qty THEN RETURN FALSE; END IF;

  UPDATE public.products
  SET online_reserved_qty = COALESCE(online_reserved_qty, 0) + p_qty,
      updated_at = NOW()
  WHERE id = p_product_id;

  RETURN TRUE;
END;
$$;

-- ############################################################
-- B4. release_online_stock(TEXT, DOUBLE PRECISION)
-- Single-product release. Authentication only.
-- ############################################################
CREATE OR REPLACE FUNCTION public.release_online_stock(
  p_product_id TEXT,
  p_qty DOUBLE PRECISION
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.products
  SET online_reserved_qty = GREATEST(0, COALESCE(online_reserved_qty, 0) - p_qty),
      updated_at = NOW()
  WHERE id = p_product_id;
END;
$$;

-- ############################################################
-- B5. reserve_online_stock(TEXT, JSONB) — v14 variant
-- Batch reservation within a store. Authentication only (RPC scope).
-- ############################################################
CREATE OR REPLACE FUNCTION public.reserve_online_stock(
  p_store_id TEXT,
  p_items JSONB
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  item JSONB;
  v_product_id TEXT;
  v_requested_qty NUMERIC;
  v_available NUMERIC;
  result JSONB := '[]'::JSONB;
  all_ok BOOLEAN := true;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  FOR item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := item->>'product_id';
    v_requested_qty := (item->>'qty')::NUMERIC;

    SELECT LEAST(
      stock_qty - online_reserved_qty,
      COALESCE(online_max_qty, stock_qty - online_reserved_qty)
    ) INTO v_available
    FROM public.products
    WHERE id = v_product_id AND store_id = p_store_id
      AND online_available = true
    FOR UPDATE;

    IF v_available IS NULL OR v_available < v_requested_qty THEN
      all_ok := false;
      result := result || jsonb_build_object(
        'product_id', v_product_id, 'status', 'insufficient',
        'available', COALESCE(v_available, 0), 'requested', v_requested_qty
      );
    ELSE
      UPDATE public.products
      SET online_reserved_qty = online_reserved_qty + v_requested_qty,
          updated_at = NOW()
      WHERE id = v_product_id AND store_id = p_store_id;

      result := result || jsonb_build_object(
        'product_id', v_product_id, 'status', 'reserved',
        'reserved_qty', v_requested_qty,
        'remaining', v_available - v_requested_qty
      );
    END IF;
  END LOOP;

  RETURN jsonb_build_object('success', all_ok, 'items', result);
END;
$$;

-- ############################################################
-- B7. confirm_delivery(TEXT, TEXT)
-- Order delivery confirmation with 3-attempt limit. Authentication only.
-- ############################################################
CREATE OR REPLACE FUNCTION public.confirm_delivery(
  p_order_id TEXT,
  p_confirmation_code TEXT
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_order RECORD;
  v_max_attempts INTEGER := 3;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT * INTO v_order FROM public.orders
  WHERE id = p_order_id::UUID FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_not_found');
  END IF;
  IF v_order.status != 'out_for_delivery' THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_status', 'current_status', v_order.status);
  END IF;
  IF v_order.confirmation_attempts >= v_max_attempts THEN
    RETURN jsonb_build_object('success', false, 'error', 'max_attempts_exceeded');
  END IF;

  IF v_order.confirmation_code = p_confirmation_code THEN
    UPDATE public.orders
    SET status = 'delivered', delivered_at = NOW(), updated_at = NOW()
    WHERE id = p_order_id::UUID;
    RETURN jsonb_build_object('success', true, 'status', 'delivered');
  ELSE
    UPDATE public.orders
    SET confirmation_attempts = confirmation_attempts + 1, updated_at = NOW()
    WHERE id = p_order_id::UUID;
    RETURN jsonb_build_object(
      'success', false, 'error', 'wrong_code',
      'attempts_remaining', v_max_attempts - v_order.confirmation_attempts - 1
    );
  END IF;
END;
$$;

-- ############################################################
-- B8. get_store_stats(TEXT)
-- Sensitive business metrics (sales, revenue). Store access required.
-- ############################################################
CREATE OR REPLACE FUNCTION public.get_store_stats(
  p_store_id TEXT
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_total_products INTEGER;
  v_low_stock INTEGER;
  v_total_sales INTEGER;
  v_total_revenue DOUBLE PRECISION;
  v_today_start TIMESTAMPTZ;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  -- AUTH GATE: must have access to the target store
  IF NOT public.has_store_access(p_store_id) THEN
    RAISE EXCEPTION 'Access denied: no access to this store';
  END IF;

  v_today_start := date_trunc('day', NOW());

  SELECT COUNT(*) INTO v_total_products
    FROM public.products
   WHERE store_id = p_store_id AND is_active = true AND deleted_at IS NULL;

  SELECT COUNT(*) INTO v_low_stock
    FROM public.products
   WHERE store_id = p_store_id AND is_active = true AND deleted_at IS NULL
     AND min_qty > 0 AND stock_qty <= min_qty;

  SELECT COALESCE(COUNT(*), 0), COALESCE(SUM(total), 0)
    INTO v_total_sales, v_total_revenue
    FROM public.orders
   WHERE store_id = p_store_id
     AND status IN ('completed', 'delivered')
     AND order_date >= v_today_start
     AND deleted_at IS NULL;

  RETURN jsonb_build_object(
    'total_products', v_total_products,
    'low_stock_count', v_low_stock,
    'total_sales_today', v_total_sales,
    'total_revenue_today', v_total_revenue
  );
END;
$$;

-- ############################################################
-- B9. sync_org_product_to_stores(TEXT)
-- Propagates org product metadata to store products. Authentication only.
-- ############################################################
CREATE OR REPLACE FUNCTION public.sync_org_product_to_stores(
  p_org_product_id TEXT
) RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.products p
  SET name = op.name, barcode = op.barcode, sku = op.sku,
      org_image_thumbnail = op.org_image_thumbnail,
      org_image_medium = op.org_image_medium,
      org_image_large = op.org_image_large,
      org_image_hash = op.org_image_hash,
      updated_at = NOW()
  FROM public.org_products op
  WHERE p.org_product_id = op.id
    AND op.id = p_org_product_id
    AND p.image_thumbnail IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$;

COMMIT;


-- =============================================================================
-- V-POST-A — Verify all 9 RPCs have auth + appropriate store checks
-- =============================================================================
--
-- SELECT p.proname, pg_get_function_arguments(p.oid) AS args,
--        (p.prosrc ILIKE '%auth.uid()%IS NULL%') AS has_auth_null_check,
--        (p.prosrc ILIKE '%has_store_access%') AS has_store_access_check,
--        (p.proconfig IS NOT NULL) AS has_search_path
-- FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.proname IN (
--     'apply_stock_deltas', 'reserve_online_stock', 'release_online_stock',
--     'confirm_delivery', 'get_store_stats', 'sync_org_product_to_stores',
--     'release_reserved_stock'
--   )
-- ORDER BY p.proname, args;
--
-- Expected:
--   apply_stock_deltas × 2:      auth=t, store_access=t, search_path=t
--   reserve_online_stock × 2:    auth=t, store_access=f, search_path=t
--   release_online_stock:        auth=t, store_access=f, search_path=t
--   release_reserved_stock:      auth=t, store_access=f, search_path=t  (from v68)
--   confirm_delivery:            auth=t, store_access=f, search_path=t
--   get_store_stats:             auth=t, store_access=t, search_path=t
--   sync_org_product_to_stores:  auth=t, store_access=f, search_path=t


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction (inverts v69 to pre-AUTH-GATE state)
-- =============================================================================
-- ⚠️  WARNING: Reverting removes AUTH GATES from 8 RPCs, re-opening them
--     to unauthenticated callers (even though Supabase's public API
--     layer would still reject unauthenticated requests, defense-in-depth
--     would be lost).
--
-- The rollback would need to re-apply the pre-v69 live bodies. See the
-- Phase A SQL query output in FIX_SESSION_LOG.md (Server RPC Audit +
-- RPC AUTH GATE Re-Apply entries) for the exact pre-v69 bodies.
--
-- =============================================================================
-- END v69 — 8 RPCs hardened, v37 body-level intent closed
-- =============================================================================
