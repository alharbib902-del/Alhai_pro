# sync_queue Investigation — 2026-04-22

**Purpose:** 20-minute read-only audit to determine whether the `store_isolation` policy with `qual=true` on Supabase's `public.sync_queue` should be dropped, redesigned, or left documented.

**Branch:** `audit/sync-queue-investigation-20260422`

**No migrations drafted. No drops attempted. Findings only.**

---

## 1. Background

During W5 pre-verification of pg_policies anomalies, the `sync_queue` table surfaced with this single policy:

| policyname | cmd | roles | qual | with_check |
|---|---|---|---|---|
| `store_isolation` | ALL | {public} | `true` | null |

Combined with:
- **0 rows** in the server-side table (as of 2026-04-22)
- Name mismatch: policy named "store_isolation" but `qual=true` is a functional wildcard (no store filter)

This triggered an "anomaly" classification. Was deferred from W5 (v62) for dedicated investigation.

---

## 2. Cross-app grep results

### Direct Supabase REST (`.from('sync_queue')`)

**Zero matches** across all Dart source:
- `apps/{cashier,admin,admin_lite}/lib/**`
- `customer_app/lib/**`, `driver_app/lib/**`, `distributor_portal/lib/**`
- `packages/*/lib/**`
- `super_admin/lib/**`

No app path reads, writes, updates, deletes, or upserts the `sync_queue` table via Supabase.

### Sync-engine enqueue (`tableName: 'sync_queue'`)

**Zero matches.** `sync_queue` is never passed as a `tableName` argument to the sync engine (expected — `sync_queue` IS the sync engine's queue; it would not sync itself).

### General `sync_queue` references (30+ files, representative sample)

| File | Nature |
|---|---|
| `packages/alhai_database/lib/src/tables/sync_queue_table.dart` | **Drift table definition** (local SQLite) |
| `packages/alhai_database/lib/src/app_database.dart` + `app_database.g.dart` | Drift integration |
| `packages/alhai_sync/lib/src/json_converter.dart:13` | Declares `sync_queue.payload` as JSONB column (serialization mapping only) |
| `packages/alhai_sync/lib/src/realtime_listener.dart:48,357` | **Comments only** — "check local pending changes in `sync_queue` before applying realtime updates" |
| `packages/alhai_sync/lib/src/conflict_resolver.dart:83,98` | **Comments only** — "stored in `sync_queue.last_error`" |
| `packages/alhai_sync/lib/src/strategies/push_strategy.dart` | Reads local Drift `sync_queue` to push pending ops |
| `packages/alhai_sync/lib/src/strategies/pull_strategy.dart` | Checks local Drift for pending writes |
| `packages/alhai_pos/lib/src/services/sale_service.dart` | Enqueues ops into local Drift |
| `packages/alhai_shared_ui/lib/src/providers/sync_providers.dart` | UI-level sync-status providers |
| `apps/cashier/lib/ui/cashier_shell.dart` | Badge showing pending-sync count from local |
| Doc / test / audit files | Historical references |

**All references point to the LOCAL Drift table, not a server-side one.**

---

## 3. Drift schema check

File: `packages/alhai_database/lib/src/tables/sync_queue_table.dart` (70 lines)

Schema columns:
- `id` (PK), `table_name`, `record_id`, `operation`, `payload` (JSON)
- `idempotency_key` (unique), `status`, `retry_count`, `max_retries`, `last_error`, `priority`
- `createdAt`, `lastAttemptAt`, `syncedAt`

**No `store_id` or `org_id` column.** The table has no tenancy partitioning on its own schema — each row carries `table_name` + `record_id` + `payload`, and the tenancy info (if any) lives inside the payload's target table or the operation's authenticated user context.

**Purpose** (from doc comment):
> "Sync queue table for offline operation — every operation is written here first then sent to the server."

This is an **offline-write buffer** pattern: app writes land in local Drift first, sync engine drains to Supabase asynchronously.

---

## 4. Architectural interpretation

### Intended design
- `sync_queue` is a **local-only Drift table** on each device.
- The sync engine reads its own rows, pushes them to Supabase (via the target `tableName` stored in each row), and marks rows `synced` locally.
- **Nothing in the intended design requires a server-side `sync_queue` table.**

### The server-side `sync_queue` table (Supabase) is an orphan
- Zero `.from('sync_queue')` calls in any app code.
- Zero sync-engine paths target `sync_queue` as a push destination.
- The server table exists (RLS policy is attached to it) but no code reads or writes it.
- The `store_isolation` policy with `qual=true` is consequently **vestigial** — protecting a table nothing queries.

### Likely origins
1. **Historical leftover**: the server mirror may have been created during early schema scaffolding (e.g., Supabase CLI migration sync from Drift schemas), then never wired into any code.
2. **Misnamed policy**: someone created the policy intending actual store-isolation but short-circuited with `qual=true` during development, then forgot to revisit.
3. **Stub for a future server-side sync feature** that never shipped (e.g., centralized sync-queue aggregation for ops visibility).

We can't definitively pick among these without git archaeology on earlier migrations (plan's v46-v55 era, not in this repo). All three lead to the same conclusion: the current server table + policy are unused.

### Why the policy can't break anything today
- With `qual=true` + 0 rows, reads return nothing and writes are allowed — but nothing reads or writes. Inert.
- Even if the policy were dropped and RLS defaulted to deny, still nothing reads or writes. Inert either way.

---

## 5. Recommendation: **DROP the policy** (keep the table)

### Why DROP over KEEP_DOCUMENTED

- The policy's presence is misleading — a reviewer seeing `store_isolation` with `qual=true` reasonably wonders if the design is intentional. Removing it eliminates the question.
- Dropping the policy leaves the table with RLS enabled but no policies → default-deny. This is the correct safe default for an orphaned table.
- If any future code ever calls `.from('sync_queue')`, it will fail fast with RLS-deny — better signal than silent wildcard access.

### Why not DROP the table

- The table likely lives in `supabase_init.sql` or a pre-v46 migration (not verified today — would require checking the initial-schema file).
- Dropping a table is a bigger decision than dropping an empty policy; may have FK implications; saves work for a dedicated schema-pruning pass later.
- No urgency — empty + orphaned + RLS-locked = harmless.

### Why not REDESIGN

- Would require knowing the intended use case. We don't, and the code evidence says there is no current use case.
- Introducing a real policy (e.g., `user_id = auth.uid()`) might cause confusion when someone tries to use the table "for real" in the future — they'd have to debug unexpected RLS denies against a policy designed for no current caller.

---

## 6. Next session task definition

**Task:** `fix/sync-queue-policy-drop` — 30-minute dedicated session:

1. Pre-verify: confirm policy still exists + 0 rows unchanged.
2. Draft migration `v6X` — 1 `DROP POLICY` on `public.sync_queue`.
3. Include rollback DDL with `qual=true` shape preserved.
4. Header references this investigation document.
5. Apply, POST-A verify, POST-C smoke count, Flutter baselines.
6. Commit + log dual-sync.

**Prerequisite:** none — this investigation cleared the path.

**Out of scope for that session:**
- Dropping the `sync_queue` server table itself (separate decision).
- Any Drift changes (local `sync_queue` unchanged — it's the one apps actually use).

---

## Summary

| Question | Answer |
|---|---|
| Is `sync_queue` accessed server-side via Supabase REST? | **No** — zero `.from('sync_queue')` in any app. |
| Is it Drift-only (local SQLite)? | **Yes** — `packages/alhai_database/lib/src/tables/sync_queue_table.dart` is the real one apps use. |
| Architectural intent of the qual=true policy? | **Vestigial** — likely a historical leftover on an orphaned server mirror. |
| Decision | **DROP the policy** in a dedicated follow-up session. Keep the table pending separate schema-pruning decision. |
