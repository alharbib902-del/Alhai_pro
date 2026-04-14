# Phase 1 Fix Report - Pre-Phase-2 Blockers

## Executive Summary

| # | Title | Status | Tests |
|---|-------|--------|-------|
| 1 | SQL Injection in Backup Import | FIXED | 3/3 pass |
| 2 | Sales Append-Only (ZATCA) | FIXED | 4/4 pass |
| 3 | Sync Isolate Offload | FIXED | 3/3 pass |
| 4 | Column Injection in Conflict Resolver | FIXED | 2/2 pass |
| 5 | Dev OTP Hardening | VERIFIED | Analysis-only (type b) |
| 6 | Migration Rollback Strategy | FIXED | 3/3 pass |

**Total new tests: 15 | All passing**

---

## Fix #1: SQL Injection in Backup Import (CRITICAL)

**Files modified:**
- `packages/alhai_database/lib/src/services/database_backup_service.dart`

**Changes:**
- Added `_getAllowedColumns(String tableName)` method that queries `_db.allTables` for the Drift schema column whitelist
- In `importFromJson()`, all columns from the JSON backup are validated against the whitelist before SQL interpolation
- Invalid columns throw `ArgumentError` with a log message for audit
- Also fixed a pre-existing bug: `Variable` objects were passed to `customStatement` instead of raw values

**Test output (3/3):**
```
00:00 +3: All tests passed!
```
- Valid backup round-trip: PASS
- Unknown column name: ArgumentError thrown
- SQL injection column ("name); DROP TABLE sales; --"): ArgumentError thrown, sales table intact

---

## Fix #2: Sales Append-Only (CRITICAL - ZATCA Blocker)

**Files modified:**
- `packages/alhai_database/lib/src/app_database.dart` (migration v23 + triggers)
- `packages/alhai_database/lib/src/tables/sales_table.dart` (reference_invoice_id)
- `packages/alhai_database/lib/src/daos/sales_dao.dart` (updateSale guard)
- `packages/alhai_sync/lib/src/strategies/push_strategy.dart` (append-only push guard)
- `packages/alhai_sync/lib/src/conflict_resolver.dart` (comment update)
- `alhai_core/lib/src/exceptions/app_exception.dart` (AppendOnlyViolationException)

**SQL Trigger (trg_sales_append_only):**
```sql
CREATE TRIGGER IF NOT EXISTS trg_sales_append_only
BEFORE UPDATE ON sales
FOR EACH ROW
WHEN OLD.status IN ('completed', 'paid', 'refunded')
  AND NOT (NEW.status = 'voided' AND OLD.status IN ('completed', 'paid'))
  AND (NEW.subtotal IS NOT OLD.subtotal OR NEW.total IS NOT OLD.total
       OR NEW.status IS NOT OLD.status OR ...)
BEGIN
  SELECT RAISE(ABORT, 'Sales with status completed/paid/refunded are immutable.');
END
```

Companion triggers on `sale_items` block DELETE and UPDATE when the parent sale is completed.

**Exception:** Voiding (completed -> voided) is explicitly allowed as a legitimate accounting operation.

**Infrastructure:** `reference_invoice_id` column added to sales table for future Credit/Debit Note support.

**Test output (4/4):**
```
00:00 +4: All tests passed!
```
- Draft sale update: PASS
- Completed sale financial update: AppendOnlyViolationException thrown
- Completed sale technical field (syncedAt): PASS
- Delete sale_items of completed sale: blocked by DB trigger

---

## Fix #3: Sync Isolate Offload (CRITICAL)

**Option chosen: A (compute for JSON serialization)**

**Rationale:** Lower risk, minimal architecture changes. Full isolate (option B) would require Drift IsolateDatabase refactoring across all apps.

**Files modified:**
- `packages/alhai_sync/lib/src/sync_manager.dart`
- `packages/alhai_sync/lib/src/strategies/push_strategy.dart`

**Changes:**
- JSON payloads > 50KB are decoded via `compute()` on a background isolate
- Top-level `_decodeJsonPayload` / `_decodePayload` functions (required by compute)
- `Stopwatch`-based performance logging per push cycle
- Warning logged when cycle exceeds 3 seconds

**Benchmark (1000 items, 269KB payload):**
```
Main thread: 14ms | Isolate: 11ms
```

**Test output (3/3):**
```
00:00 +3: All tests passed!
```

---

## Fix #4: Column Injection in Conflict Resolver (HIGH)

**File modified:**
- `packages/alhai_sync/lib/src/conflict_resolver.dart`

**Changes:**
- Added `_getAllowedColumns(AppDatabase db, String tableName)` static method
- `resolveConflict()` now filters server payload columns against the Drift schema whitelist before SQL interpolation
- Rejected columns are logged for security audit

**Test output (2/2):**
```
00:00 +2: All tests passed!
```
- Malicious column injection: filtered, product inserted safely, sales table intact
- Valid columns: upsert succeeds normally

---

## Fix #5: Dev OTP Hardening (HIGH)

**Protection type before:** (b) `kDebugMode` compile-time constant
**Protection type after:** (b) No change needed

**Analysis:**
- `WhatsAppConfig.isDevMode`: Returns `false` when `kReleaseMode` is true (line 132 of `whatsapp_config.dart`). This is a compile-time guard.
- `login_screen.dart:54`: `static const String _devOtp = '123456'` is used only inside `if (kDebugMode)` blocks (lines 303, 897).
- `login_screen.dart:314`: `_userPassword ?? _devOtp` is inside the `kDebugMode` branch - dead code in release builds.
- `kDebugMode` is `const bool` from `package:flutter/foundation.dart` - Dart tree-shakes entire dead code branches guarded by `false` constants in release mode.

**Decompilation test:** Could not be completed - release APK build fails due to pre-existing R8/signing configuration issues unrelated to OTP. The decompilation step should be performed in the CI/CD pipeline where signing is configured.

**No code changes required** - protection is already compile-time safe.

---

## Fix #6: Migration Rollback Strategy (HIGH)

**Files modified:**
- `packages/alhai_database/lib/src/app_database.dart`
- `alhai_core/lib/src/exceptions/app_exception.dart`

**Changes:**
1. **MigrationFailedException** - New exception class carrying `fromVersion`, `toVersion`, `backupPath`, and `originalError`
2. **Pre-migration backup ID capture** - The backup ID is now stored and logged on failure
3. **Downgrade guard** - `onUpgrade` rejects `from > to` with `UnsupportedError`
4. **Migration failure wrapping** - Failed migrations throw `MigrationFailedException` with the backup ID for recovery

**Note:** The existing codebase already had pre-migration backup (via `backupService.createPreMigrationBackup`). This fix adds structured error reporting and downgrade prevention.

**Test output (3/3):**
```
00:00 +3: All tests passed!
```

---

## Git Commits

| Hash | Message |
|------|---------|
| `a1c0083` | fix(database): prevent SQL injection via column name whitelist in backup import |
| `faed640` | fix(database,sync): enforce append-only immutability on completed sales (ZATCA) |
| `6121f36` | perf(sync): offload JSON decode to isolate for payloads >50KB |
| `058176e` | fix(sync): prevent column injection in conflict resolver SQL building |
| `44a3c52` | fix(sync): fix nullable productId type in stock_delta_sync |
| `b3f638e` | fix(database): add migration failure handling and downgrade guard |
| `2e4ed5d` | fix(database): update tests for schema v23 and append-only triggers |

---

## Acceptance Test Results

### alhai_database
```
00:48 +416 ~1: All tests passed!
```
- **416 passed**, 0 failed, 1 skipped

### alhai_sync
```
00:25 +358: All tests passed!
```
- **358 passed**, 0 failed

### alhai_core
- Exception classes compile cleanly. No dedicated test suite exists for exception models.

### alhai_auth
- No code changes made (Fix #5 was analysis-only). Existing tests unaffected.

---

## Warnings and Limitations

1. **Release APK decompilation test (Fix #5):** Could not be performed due to pre-existing R8/signing configuration issues. The OTP protection is verified through code analysis (compile-time `kDebugMode` guards). Recommend running decompilation test in CI.

2. **Credit/Debit Note UI (Fix #2):** Only the database infrastructure (`reference_invoice_id`) is in place. The Credit Note creation flow (UI + API) is out of scope for this phase.

3. **Drift code regeneration side effects:** Schema version bump to v23 required regenerating Drift code. This exposed a pre-existing nullable `productId` issue in `stock_delta_sync.dart` (fixed in commit `44a3c52`) and `stock_deltas_dao.dart`.

4. **Sync isolate (Fix #3):** Option A (compute for JSON only) was chosen. For truly heavy sync loads (10K+ items), Option B (full isolate with DriftIsolate) should be considered in a future phase.

5. **Backup clearExisting FK order (Fix #1):** The `importFromJson(clearExisting: true)` path fails due to FK constraint violations when deleting parent tables before children. This is a pre-existing bug outside the scope of this fix.

---

## Recommendation

**PASS with caveats** - All 6 fixes are implemented and tested:

- 2 CRITICAL SQL injection vectors closed (Fix #1, #4)
- ZATCA append-only compliance enforced at DB trigger + DAO + sync levels (Fix #2)
- UI thread blocking mitigated for large sync payloads (Fix #3)
- Dev OTP verified compile-time safe (Fix #5)
- Migration failure handling with backup recovery path (Fix #6)

**Remaining for Phase 2:**
- Credit/Debit Note UI flow
- ZATCA QR code generation and signing
- Release APK decompilation verification in CI
- Full isolate sync (Option B) if performance issues persist
