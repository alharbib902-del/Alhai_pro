-- =============================================================================
-- Migration v68: RPC CVE sweep + release_reserved_stock body fix
-- =============================================================================
-- Branch:   fix/server-rpc-audit
-- Date:     2026-04-21
-- Type:     Config hardening (34 ALTER FUNCTION) + 1 body fix (CREATE OR
--           REPLACE). Single atomic BEGIN..COMMIT.
-- Scope:    35 SECURITY DEFINER functions on public.*, spanning stock
--           management, sync, analytics, triggers, auth helpers.
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Closes CVE-2018-1058 exposure on all remaining SECURITY DEFINER functions
-- on `public.*` that lacked SET search_path. Audit surfaced 35 such
-- functions — a far larger gap than the "just 5" that a narrow focus on
-- reserve/release stock RPCs would have revealed.
--
-- The audit was initially scoped to server-side RPCs that might write
-- `order_items` with wrong column names (the customer_app bug pattern from
-- 2026-04-21). Phase A expanded scope when pg_proc revealed that v37's
-- intended hardening (from 2026-04-16) had NEVER BEEN APPLIED — not just
-- to the stock functions, but to virtually the entire SECURITY DEFINER
-- surface.
--
-- The release_reserved_stock function ALSO had a column-name drift bug:
-- it read `oi.qty` from order_items, but the live column is `quantity`.
-- Fixed in Part B with CREATE OR REPLACE (AUTH GATE + search_path +
-- column rename — preserving original logic).
--
-- -----------------------------------------------------------------------------
-- BACKGROUND — v37 never applied
-- -----------------------------------------------------------------------------
-- v37 (2026-04-16, `20260416_v37_rpc_auth_hardening.sql`) was a large RPC
-- hardening migration intended to:
--   - Add AUTH GATES (auth.uid() null checks + role/membership checks)
--   - Add SET search_path = public, auth
-- to 17 SECURITY DEFINER functions.
--
-- Live DB state as of 2026-04-21 showed that NONE of those 17 functions
-- had the search_path config applied (proconfig IS NULL). v37 either:
--   (a) never ran against production Supabase, or
--   (b) was overridden by later migrations or manual changes.
--
-- Root cause not deterministically known. This migration forward-fixes
-- by (re-)applying the search_path hardening via ALTER FUNCTION —
-- configuration-only, zero body drift risk (matching v50 methodology).
--
-- AUTH GATE hardening for the 16 other RPCs from v37 (body work,
-- bigger scope) is DEFERRED to a dedicated RPC AUTH GATE session.
-- Today's work closes CVE via config; dedicated session handles
-- privilege-escalation gates.
--
-- -----------------------------------------------------------------------------
-- PHASE A INVESTIGATION EVIDENCE
-- -----------------------------------------------------------------------------
-- Initial scope: identify RPCs that write to order_items using stale column
-- names (qty/total_price vs live quantity/total).
--
-- Live DB scan (pg_proc WHERE prosrc LIKE '%order_items%'):
--   → ONLY `release_reserved_stock` touches order_items.
--   → Body reads `oi.qty` — 42703 undefined_column on live schema.
--
-- Live DB scan (pg_proc WHERE prosecdef = true AND proconfig IS NULL):
--   → 35 SECURITY DEFINER functions unhardened.
--   → Includes all 5 stock/delivery RPCs from v37 + 30 more.
--   → None affect BUG severity (separate from the column issue).
--
-- Verification queries:
--   Q1 — pg_proc scan for prosecdef=true + proconfig=null = 35 rows
--   Q2 — pg_proc scan for release_reserved_stock body = confirms `oi.qty`
--   Q3 — information_schema order_items = confirms column is `quantity`
--
-- -----------------------------------------------------------------------------
-- THE 35 AFFECTED FUNCTIONS
-- -----------------------------------------------------------------------------
-- Stock management (5):
--   apply_stock_deltas (2 signatures), reserve_online_stock (2 signatures),
--   release_online_stock, release_reserved_stock, sync_org_product_to_stores
--
-- Sync/engine (4):
--   get_changes_since (2 signatures), sync_batch_upsert, sync_from_device
--
-- Store management (7):
--   get_my_stores, get_store_categories, get_store_products, get_store_stats,
--   get_org_inventory_overview, get_org_sales_summary, check_stock_alert
--
-- Triggers (6):
--   update_account_balance, update_loyalty_points, update_stock_on_return,
--   update_stock_on_return_item, update_stock_on_sale, update_stock_on_sale_item
--
-- Generation (3):
--   generate_daily_summary, generate_order_number, generate_receipt_no
--
-- Auth/membership (3):
--   user_has_store_access, get_user_org_role, check_cashier_by_phone
--
-- Plan/tier (2):
--   check_plan_limit, get_or_assign_default_tier
--
-- Other (5):
--   confirm_delivery, get_daily_summary, increment_coupon_usage,
--   release_reserved_stock (body fix in Part B)
--
-- -----------------------------------------------------------------------------
-- DESIGN RATIONALE
-- -----------------------------------------------------------------------------
-- Part A (ALTER FUNCTION): config-only hardening. Matches v50 methodology —
--   zero body drift risk, symmetric forward/reverse rollback, fast audit.
--   Chosen over CREATE OR REPLACE (which would require re-pasting every
--   function body verbatim and risks transcription errors).
--
-- Part B (CREATE OR REPLACE for release_reserved_stock): required because
--   the fix is a body change (column rename + AUTH GATE + search_path).
--   Cannot be done via ALTER FUNCTION.
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED
-- -----------------------------------------------------------------------------
-- Applied to Supabase production on 2026-04-21 via SQL Editor in a single
-- atomic BEGIN..COMMIT block. V-POST verification:
--   V-POST-A: 47 hardened functions total (35 new + 10 v50 helpers + 2 pre)
--   V-POST-B: release_reserved_stock confirmed has oi.quantity + AUTH GATE
--             + search_path config
--   V-POST-C: 0 SECURITY DEFINER functions on public.* lack search_path
--
-- Flutter tests: cashier 600/600, alhai_sync 358/358 — baselines preserved
-- (no client-side code touched this migration).
--
-- -----------------------------------------------------------------------------
-- DEFERRED — AUTH GATE re-application for remaining RPCs
-- -----------------------------------------------------------------------------
-- v37 originally added body-level AUTH GATES to 16 RPCs (auth.uid() null
-- check + store membership verification in some cases). This migration
-- closes only the search_path CVE (config-level). The AUTH GATE work
-- needs to be reapplied separately — a body-level migration with
-- per-RPC verbatim copies from v37, plus optionally RPC-level role
-- checks for cross-tenant protection.
--
-- Today's fix applies AUTH GATE to release_reserved_stock (the one with
-- the column bug) because we're already rewriting its body. Other 16 RPCs
-- still lack AUTH GATE but have the CVE closed.
--
-- Backlog item: "RPC AUTH GATE Re-Apply session" — estimated 2-3h.
-- =============================================================================


-- =============================================================================
-- V-PRE — Starting baseline (expected: 35 unhardened SECURITY DEFINER funcs)
-- =============================================================================
--
-- SELECT COUNT(*) AS unhardened_count
-- FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.prosecdef = true
--   AND p.proconfig IS NULL;
--
-- Expected: 35.


-- =============================================================================
-- APPLY BLOCK — atomic: 34 ALTER FUNCTION + 1 CREATE OR REPLACE
-- =============================================================================
BEGIN;

-- ############################################################
-- PART A: 34 × ALTER FUNCTION SET search_path (config-only)
-- ############################################################

ALTER FUNCTION public.apply_stock_deltas(p_store_id text, p_deltas jsonb)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.apply_stock_deltas(p_org_id text, p_store_id text, p_deltas jsonb)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.check_cashier_by_phone(p_phone text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.check_plan_limit(p_org_id text, p_resource text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.check_stock_alert()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.confirm_delivery(p_order_id text, p_confirmation_code text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.generate_daily_summary(p_store_id text, p_date date)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.generate_order_number(p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.generate_receipt_no(p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_changes_since(p_store_id text, p_table_name text, p_since timestamp with time zone, p_limit integer)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_changes_since(p_table text, p_org_id text, p_since timestamp with time zone)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_daily_summary(p_store_id text, p_date date)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_my_stores()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_or_assign_default_tier(p_org_id text, p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_org_inventory_overview(p_org_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_org_sales_summary(p_org_id text, p_from date, p_to date)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_store_categories(p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_store_products(p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_store_stats(p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.get_user_org_role()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.increment_coupon_usage(coupon_code text, p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.release_online_stock(p_product_id text, p_qty double precision)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.reserve_online_stock(p_product_id text, p_qty double precision)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.reserve_online_stock(p_store_id text, p_items jsonb)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.sync_batch_upsert(p_table_name text, p_records jsonb)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.sync_from_device(p_table_name text, p_records jsonb, p_store_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.sync_org_product_to_stores(p_org_product_id text)
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_account_balance()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_loyalty_points()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_stock_on_return()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_stock_on_return_item()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_stock_on_sale()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.update_stock_on_sale_item()
  SET search_path TO 'public', 'auth';
ALTER FUNCTION public.user_has_store_access(p_store_id text)
  SET search_path TO 'public', 'auth';


-- ############################################################
-- PART B: release_reserved_stock (body fix + AUTH GATE + search_path)
-- ############################################################
-- Fix: `oi.qty` → `oi.quantity` (live column name is `quantity`)
-- Add: AUTH GATE (auth.uid() null check) matching v37 intent
-- Add: SET search_path = public, auth (CVE hardening)
-- Preserve: original SECURITY DEFINER, original logic flow, original signature

CREATE OR REPLACE FUNCTION public.release_reserved_stock(
  p_order_id text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $function$
BEGIN
  -- AUTH GATE: must be authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Update products.online_reserved_qty by joining back to order_items.
  -- FIX (v68): oi.qty was the original code; live column is oi.quantity.
  UPDATE public.products p
  SET online_reserved_qty = GREATEST(0, p.online_reserved_qty - oi.quantity),
      updated_at = NOW()
  FROM public.order_items oi
  WHERE oi.order_id = p_order_id
    AND p.id = oi.product_id;
END;
$function$;

COMMIT;


-- =============================================================================
-- V-POST-A — All 35 now hardened + v50's 10 + 2 pre-existing = 47 total
-- =============================================================================
--
-- SELECT COUNT(*) AS hardened_count
-- FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.prosecdef = true
--   AND p.proconfig IS NOT NULL
--   AND 'search_path=public, auth' = ANY(p.proconfig);
--
-- Expected: 47 (confirmed on apply).


-- =============================================================================
-- V-POST-B — release_reserved_stock body fix verified
-- =============================================================================
--
-- SELECT p.proname, p.prosecdef, p.proconfig, p.prosrc
-- FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public' AND p.proname = 'release_reserved_stock';
--
-- Expected:
--   - prosecdef = true
--   - proconfig = ['search_path=public, auth']
--   - prosrc contains 'oi.quantity' (NOT 'oi.qty')
--   - prosrc contains 'IF auth.uid() IS NULL'


-- =============================================================================
-- V-POST-C — Zero remaining unhardened on public.*
-- =============================================================================
--
-- SELECT COUNT(*) AS unhardened_count
-- FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.prosecdef = true
--   AND p.proconfig IS NULL;
--
-- Expected: 0 (confirmed on apply).


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction (inverts v68 in one transaction)
-- =============================================================================
-- ⚠️  WARNING: Reverting re-opens CVE-2018-1058 on 35 functions AND restores
--     the oi.qty column bug in release_reserved_stock. Only for emergency.
--
-- BEGIN;
--
-- -- Part A rollback: remove search_path from 34 functions.
-- ALTER FUNCTION public.apply_stock_deltas(p_store_id text, p_deltas jsonb) RESET search_path;
-- ALTER FUNCTION public.apply_stock_deltas(p_org_id text, p_store_id text, p_deltas jsonb) RESET search_path;
-- ALTER FUNCTION public.check_cashier_by_phone(p_phone text) RESET search_path;
-- ALTER FUNCTION public.check_plan_limit(p_org_id text, p_resource text) RESET search_path;
-- ALTER FUNCTION public.check_stock_alert() RESET search_path;
-- ALTER FUNCTION public.confirm_delivery(p_order_id text, p_confirmation_code text) RESET search_path;
-- ALTER FUNCTION public.generate_daily_summary(p_store_id text, p_date date) RESET search_path;
-- ALTER FUNCTION public.generate_order_number(p_store_id text) RESET search_path;
-- ALTER FUNCTION public.generate_receipt_no(p_store_id text) RESET search_path;
-- ALTER FUNCTION public.get_changes_since(p_store_id text, p_table_name text, p_since timestamp with time zone, p_limit integer) RESET search_path;
-- ALTER FUNCTION public.get_changes_since(p_table text, p_org_id text, p_since timestamp with time zone) RESET search_path;
-- ALTER FUNCTION public.get_daily_summary(p_store_id text, p_date date) RESET search_path;
-- ALTER FUNCTION public.get_my_stores() RESET search_path;
-- ALTER FUNCTION public.get_or_assign_default_tier(p_org_id text, p_store_id text) RESET search_path;
-- ALTER FUNCTION public.get_org_inventory_overview(p_org_id text) RESET search_path;
-- ALTER FUNCTION public.get_org_sales_summary(p_org_id text, p_from date, p_to date) RESET search_path;
-- ALTER FUNCTION public.get_store_categories(p_store_id text) RESET search_path;
-- ALTER FUNCTION public.get_store_products(p_store_id text) RESET search_path;
-- ALTER FUNCTION public.get_store_stats(p_store_id text) RESET search_path;
-- ALTER FUNCTION public.get_user_org_role() RESET search_path;
-- ALTER FUNCTION public.increment_coupon_usage(coupon_code text, p_store_id text) RESET search_path;
-- ALTER FUNCTION public.release_online_stock(p_product_id text, p_qty double precision) RESET search_path;
-- ALTER FUNCTION public.reserve_online_stock(p_product_id text, p_qty double precision) RESET search_path;
-- ALTER FUNCTION public.reserve_online_stock(p_store_id text, p_items jsonb) RESET search_path;
-- ALTER FUNCTION public.sync_batch_upsert(p_table_name text, p_records jsonb) RESET search_path;
-- ALTER FUNCTION public.sync_from_device(p_table_name text, p_records jsonb, p_store_id text) RESET search_path;
-- ALTER FUNCTION public.sync_org_product_to_stores(p_org_product_id text) RESET search_path;
-- ALTER FUNCTION public.update_account_balance() RESET search_path;
-- ALTER FUNCTION public.update_loyalty_points() RESET search_path;
-- ALTER FUNCTION public.update_stock_on_return() RESET search_path;
-- ALTER FUNCTION public.update_stock_on_return_item() RESET search_path;
-- ALTER FUNCTION public.update_stock_on_sale() RESET search_path;
-- ALTER FUNCTION public.update_stock_on_sale_item() RESET search_path;
-- ALTER FUNCTION public.user_has_store_access(p_store_id text) RESET search_path;
--
-- -- Part B rollback: restore the original broken release_reserved_stock.
-- CREATE OR REPLACE FUNCTION public.release_reserved_stock(p_order_id text)
-- RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $function$
-- BEGIN
--   UPDATE public.products p
--   SET online_reserved_qty = GREATEST(0, p.online_reserved_qty - oi.qty),
--       updated_at = NOW()
--   FROM public.order_items oi
--   WHERE oi.order_id = p_order_id
--     AND p.id = oi.product_id;
-- END;
-- $function$;
--
-- COMMIT;
--
-- =============================================================================
-- END v68 — 35 functions hardened, 1 bug fixed
-- =============================================================================
