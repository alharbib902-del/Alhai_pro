# Independent Verification Report — Phase 2 Fixes

**Date:** 2026-04-14
**Verifier:** Claude (independent session — zero prior involvement)
**Branch:** `fix/phase2-blockers`
**Scope:** 6 active fixes (Fix #2 was reverted)
**Method:** Code audit + 56 new independent verification tests

---

## Executive Summary

All 6 active fixes function as designed at the database/XML layer. The branch
is **conditionally ready to merge** subject to 3 findings that should be
addressed before or shortly after merge:

1. **Ghost Bug (P2):** `createReturnTransaction()` will crash at runtime due
   to `Variable.withReal()` in `customStatement()`. Currently unused in
   production but is a public API landmine.
2. **Latent Bypass (P3):** `cleanupSyncAuditLogs()` in `sync_queue_dao.dart`
   can delete audit_log entries after 7 days (vs. the mandated 6 years).
   Currently dead code but should be removed.
3. **Storage Monitor No-Op (P3):** `_getStorageInfo()` always returns `null`,
   so the monitor always reports "healthy". Acceptable as scaffolding but must
   get real platform channel implementation before production release.

---

## Fix-by-Fix Verification

### Fix #1: Audit Log Retention (944d7ec)

**Status:** `PARTIAL`

**Evidence:**
- `RetentionPolicy.auditLogRetention = Duration(days: 2190)` (6 years) — confirmed
- Legal documentation (Saudi VAT Art. 66) present in code comments
- `canDeleteAuditLog()` helper uses `>` (strictly greater than) — correct
- `cleanupOldLogs()` has runtime assertion: `olderThan.inDays >= 2190`
- Only deletes synced records (`syncedAt.isNotNull()`) — unsynced are protected

**Issue Found:**
- `sync_queue_dao.dart:703` — `cleanupSyncAuditLogs()` does raw
  `DELETE FROM audit_log WHERE action='sync_operation' AND created_at < 7d`.
  This bypasses the 6-year retention. **Currently dead code** (no callers),
  but exists as a latent compliance risk.

**Recommendation:** Delete `cleanupSyncAuditLogs()` or enforce the 6-year minimum.

**New tests:** `packages/alhai_database/test/verification/audit_retention_verification_test.dart` (12 tests, all passing)

---

### Fix #2 Revert: SignaturePolicyIdentifier (d934352 -> b130a4f)

**Status:** `PASSED` — revert is complete

**Evidence:**
- Only 1 reference to "SignaturePolicyIdentifier" in entire `alhai_zatca/`: a
  comment on line 78 of `invoice_xml_validator.dart` documenting the removal
- Zero references to `MISSING_SIGNATURE_POLICY`, `WRONG_POLICY_URN`,
  `1.2.250.1.97.1.0.1`, or `urn:oid:1.2.250`
- `xades_signer.dart:120-144` `_buildSignedProperties()` contains no policy identifier
- `validateSigned()` simply delegates to `validate()` — no policy checks
- Zero test references to SignaturePolicyIdentifier

---

### Fix #3: CountrySubentity (1873cdc)

**Status:** `PASSED`

**Evidence:**
- Seller PostalAddress element ordering confirmed UBL 2.1 compliant:
  `StreetName > BuildingNumber > [PlotIdentification] > [CitySubdivisionName] > CityName > PostalZone > [CountrySubentity] > Country`
- `CountrySubentity` with value "Makkah Region" renders correctly
- `CountrySubentity` omitted entirely when `seller.region == null` (not empty element)
- `Country` element preserved even when `CountrySubentity` is absent
- Buyer PostalAddress follows same correct ordering

**New tests:** `packages/alhai_zatca/test/verification/country_subentity_order_test.dart` (5 tests, all passing)

---

### Fix #4: XML Validator with Cascade Fix (652e17c -> 9abf221)

**Status:** `PASSED`

**Evidence:**
- `validate()` passes on a fully valid invoice XML
- `validateSigned()` works without requiring SignaturePolicyIdentifier (cascade fix verified)
- Detects missing required elements: ID, IssueDate, TaxTotal, LegalMonetaryTotal, InvoiceLine
- Detects wrong root element (`<Order>` instead of `<Invoice>`)
- Handles malformed XML: `PARSE_ERROR` for broken tags, empty strings, non-XML input
- `validateSigned()` also handles malformed input gracefully

**New tests:** `packages/alhai_zatca/test/verification/validator_independence_test.dart` (12 tests, all passing)

---

### Fix #5: Inventory Restock on Returns (118b795)

**Status:** `PARTIAL`

**Evidence — what works:**
- `recordReturnMovement()` records positive qty (restock direction correct)
- `newQty = previousQty + qty` math is correct
- Movement records track `referenceType='return'` and `referenceId`
- Partial and cumulative returns accumulate correctly
- `refund_reason_screen.dart` (production code path) restocks correctly

**Issues Found:**

1. **Ghost Bug (P2):** `createReturnTransaction()` (`app_database.dart:1356`)
   passes `Variable.withReal()` and `Variable.withString()` to
   `customStatement()`, but `customStatement` expects raw Dart values. This
   causes `ArgumentError` at runtime. The method is currently **unused** in
   production — the actual flow goes through `refund_reason_screen.dart` which
   calls `productsDao.updateStock()` and `inventoryDao.insertMovement()`
   directly. **Fix:** Change `[Variable.withReal(entry.value), Variable.withString(entry.key)]`
   to `[entry.value, entry.key]`.

2. **Race Condition (P3):** `createReturn()` in `returns_providers.dart:97-121`
   reads current stock (`getProductById`), then updates (`updateStock`) without
   a transaction. Concurrent returns could overwrite each other. The
   `refund_reason_screen.dart` code path also has this pattern. Low probability
   on single-device POS but should use atomic SQL
   (`stock_qty = stock_qty + ?`) in a transaction.

3. **No Over-Return Prevention (P4):** Neither code path validates that total
   returned quantity does not exceed original sale quantity.

**New tests:** `packages/alhai_database/test/verification/return_restocking_verification_test.dart` (5 tests, all passing)

---

### Fix #6: Storage Monitoring (03a2f4b)

**Status:** `PARTIAL`

**Evidence — what works:**
- `StorageStatus` enum: `healthy`, `warning`, `critical`, `full` — all 4 states
- `checkStorage()` classification logic correct:
  - `< 0.80` = healthy
  - `0.80–0.90` = warning
  - `0.90–0.95` = critical
  - `>= 0.95` = full
- `assertCanWrite()` throws `StorageFullException` only on `full` status
- Override mechanism (`setOverrideStatus`) works correctly for testing

**Limitation:**
- `_getStorageInfo()` always returns `null` (line 76): *"A production
  implementation would use platform channels (StatFs on Android,
  NSFileManager on iOS). For now, expose the API with a fallback."*
- This means `checkStorage()` **always returns `StorageStatus.healthy`** in
  production. The monitoring infrastructure exists but does not actually
  monitor anything yet.
- Acceptable as scaffolding / API contract, but must implement platform
  channels before production release.

**New tests:** `packages/alhai_database/test/verification/storage_monitor_verification_test.dart` (12 tests, all passing)

---

### Fix #7: Sales Retention Policy (894e520)

**Status:** `PASSED`

**Evidence:**
- `RetentionPolicy.salesRetention = Duration(days: 2190)` — 6 years, confirmed
- `_cleanupOldSales()` correctly requires both:
  - `createdAt < cutoff` (older than 6 years)
  - `syncedAt.isNotNull()` (must be synced to server)
  - `deletedAt.isNull()` (not already soft-deleted)
- Unsynced sales are NEVER deleted regardless of age — verified
- 5-year-old synced sale preserved — verified
- 7-year-old synced sale deleted — verified
- Exact boundary (2190 days) preserved by strict `<` — verified
- Sale items deleted after parent sale (trigger bypass: parent deleted first,
  then orphaned children) — verified
- Sync queue cleanup: only `status='completed'` items > 30 days — verified
- `pending` and `failed` sync items never deleted — verified

**Observation:** No `zatca_reported` field exists in the database. A synced sale
that hasn't been reported to ZATCA can be deleted after 6 years. If ZATCA
reporting status is needed as a deletion guard, this field should be added.
This is a design consideration, not a bug in the current scope.

**New tests:** `packages/alhai_database/test/verification/retention_verification_test.dart` (9 tests, all passing)

---

## Cross-cutting Results

### Full Test Suite Results

| Package | Tests | Skipped | Result |
|---------|-------|---------|--------|
| alhai_zatca | 850 | 1 | All passed |
| alhai_database | 487 | 1 | All passed |
| alhai_pos | 559 | 0 | All passed |
| alhai_sync | 358 | 0 | All passed |
| **Total** | **2,254** | **2** | **All passed** |

### Static Analysis

| Package | Errors | Warnings | Info |
|---------|--------|----------|------|
| alhai_zatca | 0 | 1 (unused import) | 2 |
| alhai_database | 0 | 0 | 17 |

No new errors introduced by Phase 2 fixes.

### Git Commit History (main..fix/phase2-blockers)

```
fd0debc docs(phase2): document Fix #2 revert with evidence and cascade fix
9abf221 fix(zatca): align validator with signer after Fix #2 revert
b130a4f revert(zatca): remove SignaturePolicyIdentifier — not used by ZATCA SDK
4e2fed8 docs: add Phase 2 blockers fix report
894e520 fix(database): add sales retention policy — 6-year legal minimum
03a2f4b feat(pos): add storage monitoring with proactive alerts
118b795 fix(pos): restock inventory on partial returns
652e17c feat(zatca): add built-in invoice validator for ZATCA Phase 2 compliance
1873cdc fix(zatca): add CountrySubentity to PostalAddress per UBL 2.1 spec
d934352 fix(zatca): add SignaturePolicyIdentifier required by ZATCA Phase 2
944d7ec fix(database): enforce 6-year audit log retention per Saudi VAT law
a897b01 chore: ignore test coverage outputs
```

Fix #2 (`d934352`) is properly reverted by `b130a4f` and its cascade fixed by `9abf221`.

---

## New Tests Added During Verification

| File | Tests | Package |
|------|-------|---------|
| `test/verification/audit_retention_verification_test.dart` | 12 | alhai_database |
| `test/verification/country_subentity_order_test.dart` | 5 | alhai_zatca |
| `test/verification/validator_independence_test.dart` | 12 | alhai_zatca |
| `test/verification/return_restocking_verification_test.dart` | 5 | alhai_database |
| `test/verification/storage_monitor_verification_test.dart` | 12 | alhai_database |
| `test/verification/retention_verification_test.dart` | 9 | alhai_database |
| **Total** | **55** | |

---

## Findings Summary

### Priority 2 — Fix Before Merge (or Accept Risk)

| # | Fix | Finding | Impact |
|---|-----|---------|--------|
| F1 | Fix #5 | `createReturnTransaction()` crashes at runtime (`Variable.withReal` in `customStatement`) | Dead code today. Will crash if ever called. One-line fix. |

### Priority 3 — Fix Soon After Merge

| # | Fix | Finding | Impact |
|---|-----|---------|--------|
| F2 | Fix #1 | `cleanupSyncAuditLogs()` bypasses 6-year audit retention with 7-day TTL | Dead code. Compliance risk if called. Delete the method. |
| F3 | Fix #5 | `createReturn()` in providers has read-update race (no transaction) | Low probability on single POS device. Use atomic SQL. |
| F4 | Fix #6 | `_getStorageInfo()` returns null — monitor always says "healthy" | Scaffolding only. Need platform channels for production. |

### Priority 4 — Track for Future

| # | Fix | Finding | Impact |
|---|-----|---------|--------|
| F5 | Fix #5 | No over-return quantity validation | Customer could return more than purchased. |
| F6 | Fix #7 | No `zatca_reported` field — synced-but-unreported sales can be deleted | Design consideration for ZATCA compliance maturity. |

---

## Final Recommendation

### `CONDITIONAL` — Branch is ready to merge with 1 minor fix recommended

Branch `fix/phase2-blockers` is **mostly ready**. All 6 active fixes verified
independently with 55 new tests and 2,254 total tests passing.

**Before merge (recommended):**
- Fix F1: Change `Variable.withReal(entry.value)` to `entry.value` and
  `Variable.withString(entry.key)` to `entry.key` in
  `app_database.dart:1356-1357`. This is a one-line fix to prevent a future
  runtime crash.

**Acceptable to defer to Phase 4:**
- F2: Delete `cleanupSyncAuditLogs()` from `sync_queue_dao.dart`
- F3: Wrap return restocking in a transaction
- F4: Implement platform channels for storage monitoring
- F5: Add over-return quantity validation
- F6: Consider `zatca_reported` field for deletion guard

**If the team chooses to merge now without F1:** acceptable risk, since
`createReturnTransaction` is currently unused. But it should be the first
fix in Phase 4.
