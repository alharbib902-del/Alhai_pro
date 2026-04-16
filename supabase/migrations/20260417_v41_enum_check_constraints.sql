-- =============================================================================
-- Migration v41: enforce enum values at the database level via CHECK constraints.
-- Date: 2026-04-17
-- Author: Schema team
--
-- Background
--   Dart enums in packages/alhai_database/lib/src/enums/status_enums.dart
--   define the canonical values for OrderStatus, PaymentStatus, SaleStatus,
--   PaymentMethod, ShiftStatus, PurchaseStatus, TransferStatus,
--   SyncQueueStatus. But the Supabase columns are plain TEXT with no
--   CHECK constraint, so a buggy client or a raw SQL INSERT can write any
--   string and Supabase will happily accept it. Reports downstream then
--   break on the unexpected value.
--
-- Fix
--   Add NOT VALID CHECK constraints for every status-like column. NOT
--   VALID so the deploy doesn't fail on legacy rows; DO blocks below
--   surface the count of offending rows per table as NOTICEs so ops can
--   decide when to clean data and VALIDATE.
--
-- Rollback
--   ALTER TABLE public.<table> DROP CONSTRAINT IF EXISTS <constraint>;
-- =============================================================================

-- Helper to surface violations before validating
CREATE OR REPLACE FUNCTION pg_temp.report_enum_violations(
  p_table TEXT,
  p_column TEXT,
  p_allowed TEXT[]
) RETURNS VOID AS $$
DECLARE
  v_count BIGINT;
BEGIN
  EXECUTE format(
    'SELECT COUNT(*) FROM public.%I WHERE %I IS NOT NULL AND NOT (%I = ANY(%L))',
    p_table, p_column, p_column, p_allowed
  ) INTO v_count;
  IF v_count > 0 THEN
    RAISE NOTICE 'v41: %.% has % rows with values outside allowed set %', p_table, p_column, v_count, p_allowed;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- orders.status — OrderStatus enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'orders', 'status',
    ARRAY['created', 'confirmed', 'preparing', 'ready',
          'out_for_delivery', 'delivered', 'picked_up',
          'completed', 'cancelled', 'refunded']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.orders
  DROP CONSTRAINT IF EXISTS orders_status_valid;
ALTER TABLE public.orders
  ADD CONSTRAINT orders_status_valid
  CHECK (status IS NULL OR status IN (
    'created', 'confirmed', 'preparing', 'ready',
    'out_for_delivery', 'delivered', 'picked_up',
    'completed', 'cancelled', 'refunded'
  )) NOT VALID;

-- =============================================================================
-- sales.status — SaleStatus enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'sales', 'status',
    ARRAY['completed', 'voided', 'refunded']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.sales
  DROP CONSTRAINT IF EXISTS sales_status_valid;
ALTER TABLE public.sales
  ADD CONSTRAINT sales_status_valid
  CHECK (status IS NULL OR status IN (
    'completed', 'voided', 'refunded'
  )) NOT VALID;

-- =============================================================================
-- sales.payment_method — PaymentMethod enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'sales', 'payment_method',
    ARRAY['cash', 'card', 'mixed', 'credit']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.sales
  DROP CONSTRAINT IF EXISTS sales_payment_method_valid;
ALTER TABLE public.sales
  ADD CONSTRAINT sales_payment_method_valid
  CHECK (payment_method IS NULL OR payment_method IN (
    'cash', 'card', 'mixed', 'credit'
  )) NOT VALID;

-- =============================================================================
-- invoices.status — status values observed in v25/v38 ('draft','issued','void')
-- v38's ZATCA check already assumes status='issued' is a real value. Lock it.
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'invoices', 'status',
    ARRAY['draft', 'pending', 'issued', 'paid', 'void', 'cancelled']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.invoices
  DROP CONSTRAINT IF EXISTS invoices_status_valid;
ALTER TABLE public.invoices
  ADD CONSTRAINT invoices_status_valid
  CHECK (status IS NULL OR status IN (
    'draft', 'pending', 'issued', 'paid', 'void', 'cancelled'
  )) NOT VALID;

-- =============================================================================
-- shifts.status — ShiftStatus enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'shifts', 'status',
    ARRAY['open', 'closed']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.shifts
  DROP CONSTRAINT IF EXISTS shifts_status_valid;
ALTER TABLE public.shifts
  ADD CONSTRAINT shifts_status_valid
  CHECK (status IS NULL OR status IN ('open', 'closed')) NOT VALID;

-- =============================================================================
-- purchases.status — PurchaseStatus enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'purchases', 'status',
    ARRAY['draft', 'ordered', 'partial', 'received', 'cancelled']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.purchases
  DROP CONSTRAINT IF EXISTS purchases_status_valid;
ALTER TABLE public.purchases
  ADD CONSTRAINT purchases_status_valid
  CHECK (status IS NULL OR status IN (
    'draft', 'ordered', 'partial', 'received', 'cancelled'
  )) NOT VALID;

-- =============================================================================
-- stock_transfers.status — TransferStatus enum
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'stock_transfers', 'status',
    ARRAY['pending', 'approved', 'in_transit', 'completed', 'cancelled']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.stock_transfers
  DROP CONSTRAINT IF EXISTS stock_transfers_status_valid;
ALTER TABLE public.stock_transfers
  ADD CONSTRAINT stock_transfers_status_valid
  CHECK (status IS NULL OR status IN (
    'pending', 'approved', 'in_transit', 'completed', 'cancelled'
  )) NOT VALID;

-- =============================================================================
-- returns.status / returns.type — common return workflow states
-- =============================================================================
DO $$ BEGIN
  PERFORM pg_temp.report_enum_violations(
    'returns', 'status',
    ARRAY['pending', 'approved', 'rejected', 'completed', 'cancelled']
  );
EXCEPTION WHEN undefined_table OR undefined_column THEN NULL;
END $$;

ALTER TABLE public.returns
  DROP CONSTRAINT IF EXISTS returns_status_valid;
ALTER TABLE public.returns
  ADD CONSTRAINT returns_status_valid
  CHECK (status IS NULL OR status IN (
    'pending', 'approved', 'rejected', 'completed', 'cancelled'
  )) NOT VALID;

-- =============================================================================
-- Cleanup
-- =============================================================================
DROP FUNCTION IF EXISTS pg_temp.report_enum_violations(TEXT, TEXT, TEXT[]);

-- =============================================================================
-- Post-deploy: run `ALTER TABLE ... VALIDATE CONSTRAINT ...;` per table once
-- the NOTICEs above show zero offending rows. Example:
--   ALTER TABLE public.orders VALIDATE CONSTRAINT orders_status_valid;
-- =============================================================================
