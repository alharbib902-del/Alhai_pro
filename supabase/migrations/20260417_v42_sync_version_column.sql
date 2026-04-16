-- =============================================================================
-- Migration v42: add `sync_version` column for optimistic concurrency control.
-- Date: 2026-04-17
-- Author: Schema team
--
-- Problem
--   Bidirectional sync tables (sales, customers, shifts, invoices, ...)
--   currently use only `updated_at` as their conflict marker. That's
--   insufficient:
--
--     1. Two clients offline-edit the same row in the same wall-clock
--        second. Both push. Second push wins silently (last-write-wins).
--        The first edit is lost with no trace.
--     2. Clock drift between devices causes "earlier" edits to clobber
--        "later" ones according to server clock.
--     3. There's no way for a client to say "I based my edit on version
--        N — reject my write if the server has moved past it."
--
-- Fix
--   Add a monotonically-increasing `sync_version BIGINT` column. On every
--   UPDATE or INSERT, bump it via trigger. Clients read the current
--   sync_version before editing and MUST include it in their push; the
--   server returns 409 CONFLICT if the submitted version no longer
--   matches. This is standard optimistic concurrency control.
--
-- Scope
--   Apply to the 10 highest-value bidirectional tables. Remaining tables
--   can be added in a follow-up migration (the trigger function is
--   generic — `sync_version_bump()` works for any table with the column).
--
--   Tables included here: sales, sale_items, returns, return_items,
--   shifts, cash_movements, invoices, customers, stock_transfers,
--   inventory_movements.
--
-- Rollout
--   1. Deploy this migration.
--   2. Ship client code that reads + sends sync_version. Clients that
--      DON'T send it are treated as trusted (no conflict check) so old
--      builds keep working until the forced-upgrade release.
--   3. Remove the trusted-fallback path once all clients ship the new
--      version (a follow-up migration can change the RPC to reject
--      missing sync_version).
-- =============================================================================

-- Generic trigger function: bumps sync_version on every UPDATE; sets to 1 on INSERT.
CREATE OR REPLACE FUNCTION public.sync_version_bump()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.sync_version IS NULL OR NEW.sync_version = 0 THEN
      NEW.sync_version := 1;
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Always bump, even if caller provided a value, so version is
    -- strictly server-monotonic.
    NEW.sync_version := COALESCE(OLD.sync_version, 0) + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sync_version_bump() IS
  'Bumps sync_version on every row mutation. Attach as BEFORE INSERT OR UPDATE '
  'trigger on any table participating in optimistic concurrency control.';

-- Helper to attach the column + trigger to one table, idempotent.
DO $$
DECLARE
  v_tables TEXT[] := ARRAY[
    'sales',
    'sale_items',
    'returns',
    'return_items',
    'shifts',
    'cash_movements',
    'invoices',
    'customers',
    'stock_transfers',
    'inventory_movements'
  ];
  v_table TEXT;
BEGIN
  FOREACH v_table IN ARRAY v_tables LOOP
    -- Skip if table doesn't exist in this project.
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = v_table
    ) THEN
      RAISE NOTICE 'v42: table public.% does not exist — skipping', v_table;
      CONTINUE;
    END IF;

    -- 1. Add column (NOT NULL with default 0 so legacy rows get a value).
    EXECUTE format(
      'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS sync_version BIGINT NOT NULL DEFAULT 0',
      v_table
    );

    -- 2. Drop + recreate trigger (idempotent).
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_%I_sync_version ON public.%I',
      v_table, v_table
    );
    EXECUTE format(
      'CREATE TRIGGER trg_%I_sync_version '
      'BEFORE INSERT OR UPDATE ON public.%I '
      'FOR EACH ROW EXECUTE FUNCTION public.sync_version_bump()',
      v_table, v_table
    );

    -- 3. Backfill existing rows to 1 (so optimistic checks don't all match 0).
    EXECUTE format(
      'UPDATE public.%I SET sync_version = 1 WHERE sync_version = 0',
      v_table
    );

    -- 4. Index on (id, sync_version) for fast conflict checks in
    --    optimistic update queries. Keep PK on id alone; this is a
    --    covering index for the conflict-detecting UPDATE.
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS idx_%I_sync_version ON public.%I (id, sync_version)',
      v_table, v_table
    );

    RAISE NOTICE 'v42: public.% — sync_version column + trigger installed', v_table;
  END LOOP;
END $$;

-- =============================================================================
-- Client contract (informational — enforcement ships in a follow-up migration)
--
-- On push (UPDATE), clients should execute:
--
--   UPDATE public.<table>
--     SET <fields> = ..., sync_version = sync_version + 1
--     WHERE id = $1 AND sync_version = $2;
--
-- where $2 is the sync_version the client started editing from. If
-- ROWS_AFFECTED = 0, the server has moved ahead: fetch the current row
-- and merge or prompt the user.
--
-- On push (INSERT), clients should include sync_version := 0; the trigger
-- upgrades to 1 automatically.
-- =============================================================================
