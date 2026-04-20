-- =============================================================================
-- Migration v63: Drop vestigial sync_queue.store_isolation policy
-- =============================================================================
-- Branch:   audit/sync-queue-investigation-20260422
-- Date:     2026-04-22
-- Type:     Vestigial policy cleanup. Zero risk, zero behavioral change.
-- Scope:    1 table (sync_queue), 1 DROP atomic.
--
-- -----------------------------------------------------------------------------
-- SUMMARY
-- -----------------------------------------------------------------------------
-- Drops a single vestigial policy:
--   sync_queue.store_isolation — cmd=ALL, roles={public}, qual=true, with_check=null
--
-- Name mismatch: the policy is named "store_isolation" but uses `qual=true`,
-- which is a functional wildcard (no store filter). It was flagged as an
-- anomaly during the comprehensive wildcard audit (commit 1ea56b4) and
-- deferred from W5 (v62) for investigation.
--
-- -----------------------------------------------------------------------------
-- INVESTIGATION EVIDENCE (see docs/sessions/sync-queue-investigation-20260422.md)
-- -----------------------------------------------------------------------------
-- - Zero `.from('sync_queue')` hits across all Dart source (apps/ + packages/).
-- - Zero `tableName: 'sync_queue'` sync-engine references (the queue doesn't
--   sync itself).
-- - `sync_queue` is a LOCAL Drift table at
--   packages/alhai_database/lib/src/tables/sync_queue_table.dart — the real
--   one every app uses.
-- - The Supabase-side `sync_queue` table has 0 rows and is functionally
--   orphaned (likely a historical leftover from early schema scaffolding).
-- - Schema has no `store_id` or `org_id` column, so "store_isolation" never
--   had a way to actually isolate by store anyway.
--
-- -----------------------------------------------------------------------------
-- WHY DROP (not redesign, not keep)
-- -----------------------------------------------------------------------------
-- - The policy's presence is misleading to reviewers who expect its name
--   ("store_isolation") to mean what it says.
-- - Dropping leaves RLS enabled with no policies → default-deny. Correct safe
--   state for an orphaned, unqueried table.
-- - If any future code ever calls `.from('sync_queue')`, RLS-deny fails fast —
--   a better signal than silent wildcard access.
-- - Dropping the table itself is a larger decision (possible FK implications,
--   schema-pruning scope); out of scope for this session.
--
-- -----------------------------------------------------------------------------
-- ALREADY APPLIED
-- -----------------------------------------------------------------------------
-- This migration file records work already applied to Supabase production on
-- 2026-04-22 via SQL Editor. Pre/Apply/Post verification confirmed green.
-- File exists for git-tracked audit trail + canonical rollback reference.
--
-- -----------------------------------------------------------------------------
-- CAMPAIGN CONTEXT
-- -----------------------------------------------------------------------------
-- Today's wildcard-cleanup campaign:
--   v58 — 2 S-0 anon (sales, sale_items)
--   v59 — 12 policies on 6 financial tables (W1)
--   v60 — 4 policies on 3 identity tables (W2 scope-reduced)
--   v61 — 21 policies on 10 operational tables + customers anon (W4)
--   v62 — 3 policies on categories (W5 scope-reduced)
-- v63 — 1 policy on sync_queue (vestigial) — this migration
--
-- After v63: 25 of 33 wildcards resolved (76%). 8 remaining, all blocked on
-- prerequisite sessions (Platform Admin RLS + Wildcard Gen 3 Bootstrap).
-- =============================================================================


-- =============================================================================
-- V63-PRE — Verify baseline (expected: 1 row)
-- =============================================================================
--
-- SELECT tablename, policyname, cmd, roles, qual, with_check
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename = 'sync_queue'
--   AND policyname = 'store_isolation';


-- =============================================================================
-- APPLY BLOCK — atomic: single DROP
-- =============================================================================
BEGIN;

-- sync_queue: vestigial "store_isolation" (qual=true, no store_id column anyway).
DROP POLICY "store_isolation" ON public.sync_queue;

COMMIT;


-- =============================================================================
-- V63-POST-A — Confirm drop succeeded (expected: 0 rows)
-- =============================================================================
--
-- Re-run the V63-PRE query verbatim. Expected: zero rows.


-- =============================================================================
-- V63-POST-B — Smoke count (expected: runs cleanly, returns 0)
-- =============================================================================
--
-- SELECT 'sync_queue' AS table_name, COUNT(*) FROM public.sync_queue;
--
-- Post-drop the table has no policies, so default-deny RLS applies. The count
-- above runs from a privileged context (SQL Editor); from app-layer auth it
-- would return RLS-deny instead — which is the intended safe state for an
-- orphaned table.


-- =============================================================================
-- ROLLBACK DDL — canonical reconstruction
-- =============================================================================
-- ℹ️  NOTE: Restoring this policy is functionally pointless. It was
--     vestigial before drop: `qual=true` let any role read/write, but no
--     app code ever queried the table. Restoration does not re-enable any
--     functionality. Included only for strict shape-preservation.
--
-- BEGIN;
--
-- CREATE POLICY "store_isolation" ON public.sync_queue
--   FOR ALL TO public USING (true);
--
-- COMMIT;
--
-- =============================================================================
-- END v63
-- =============================================================================
