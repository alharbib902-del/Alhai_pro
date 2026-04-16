\# Technical Debt Log — Alhai Acceptance Project



\## Items deferred from Phase 1 verification (2026-04-14)



\### BUG-PHASE1-001: FK order in importFromJson(clearExisting: true)

\*\*Source:\*\* Fix #1 side-effect (Phase 1)

\*\*Severity:\*\* Medium

\*\*Location:\*\* packages/alhai\_database/lib/src/services/database\_backup\_service.dart

\*\*Issue:\*\* Deleting parent tables before children causes FK constraint violations

\*\*Target fix:\*\* Before Phase 3 (admin apps)

\*\*Estimated effort:\*\* 30 minutes



\### BUG-PHASE1-002: Silent catch in sync\_engine.dart:226

\*\*Source:\*\* P2.1 from Phase 1 verification

\*\*Severity:\*\* Medium (will become High in production)

\*\*Location:\*\* packages/alhai\_sync/lib/src/sync\_engine.dart:226

\*\*Issue:\*\* Exception is caught without logging

\*\*Target fix:\*\* Before Phase 5 (production hardening)

\*\*Estimated effort:\*\* 30 minutes



\### BUG-PHASE1-003: use\_build\_context\_synchronously in admin

\*\*Source:\*\* P2.2 from Phase 1 verification

\*\*Severity:\*\* Low

\*\*Location:\*\* apps/admin (specific file TBD during Phase 4 audit)

\*\*Issue:\*\* BuildContext used after async gap — potential rare crashes

\*\*Target fix:\*\* During Phase 4 (admin verification)

\*\*Estimated effort:\*\* 30 minutes



\---



\## Items deferred from Phase 2 verification (2026-04-14)



\### F2: cleanupSyncAuditLogs bypasses 6-year retention

\*\*Source:\*\* Independent verification F2 (P3)

\*\*Severity:\*\* Medium (compliance landmine)

\*\*Location:\*\* packages/alhai\_database/lib/src/daos/sync\_queue\_dao.dart:703

\*\*Issue:\*\* Raw `DELETE FROM audit\_log WHERE action='sync\_operation' AND created\_at < 7d`. This bypasses the 6-year retention policy mandated by Saudi VAT Article 66. Currently dead code (no callers), but exists as a latent compliance risk.

\*\*Resolution:\*\* Delete the cleanupSyncAuditLogs() method entirely, or refactor to enforce 6-year minimum.

\*\*Target fix:\*\* Before Phase 5 (production hardening)

\*\*Estimated effort:\*\* 30 minutes (just deletion)



\### F3: Race condition in returns provider

\*\*Source:\*\* Independent verification F3 (P3)

\*\*Severity:\*\* Medium

\*\*Location:\*\* packages/alhai\_pos/lib/src/providers/returns\_providers.dart:97-121

\*\*Issue:\*\* Read-then-update pattern without transaction. Concurrent returns could overwrite each other's stock updates. Low probability on single-device POS but Alhai is multi-tenant — some merchants run multiple POS devices simultaneously.

\*\*Resolution:\*\* Use atomic SQL `UPDATE products SET stock\_qty = stock\_qty + ? WHERE id = ?` inside a Drift transaction.

\*\*Target fix:\*\* During Phase 4 (admin audit) or Phase 5

\*\*Estimated effort:\*\* 1-2 hours



\### F4: StorageMonitor returns null (no platform channels)

\*\*Source:\*\* Independent verification F4 (P3 → CRITICAL before launch)

\*\*Severity:\*\* High before production

\*\*Location:\*\* packages/alhai\_database/lib/src/services/storage\_monitor.dart:76

\*\*Issue:\*\* `\_getStorageInfo()` always returns null. The monitor always reports "healthy" regardless of actual disk state. In production, `assertCanWrite()` will always pass even when device storage is full → POS will crash mid-sale.

\*\*Resolution:\*\* Implement platform channels:

&#x20; - Android: Kotlin StatFs

&#x20; - iOS: Swift NSFileManager.attributesOfFileSystem

\*\*Target fix:\*\* Before Phase 5 (production hardening) — MUST be done before any real device deployment

\*\*Estimated effort:\*\* 4-6 hours



\### F5: No over-return quantity validation

\*\*Source:\*\* Independent verification F5 (P4)

\*\*Severity:\*\* Low (data integrity gap)

\*\*Location:\*\* packages/alhai\_pos/lib/src/providers/returns\_providers.dart

\*\*Issue:\*\* Customer can return more units than originally purchased. The system allows infinite returns against a single sale.

\*\*Resolution:\*\* Calculate `previously\_returned + this\_return` and verify it doesn't exceed `original\_quantity`. Throw `InvalidReturnException` if exceeded.

\*\*Target fix:\*\* During Phase 4 (admin audit)

\*\*Estimated effort:\*\* 1 hour



\### F6: No zatca\_reported field as deletion guard

\*\*Source:\*\* Independent verification F6 (P4)

\*\*Severity:\*\* Design consideration

\*\*Location:\*\* packages/alhai\_database/lib/src/tables/sales.dart (would need migration)

\*\*Issue:\*\* A synced sale that hasn't been reported to ZATCA can be deleted after 6 years by DataRetentionService. There's no guard against deleting sales that haven't completed their ZATCA lifecycle.

\*\*Resolution:\*\* Add `zatca\_reported\_at` nullable timestamp field. Modify retention cleanup to require both `synced\_at IS NOT NULL` AND `zatca\_reported\_at IS NOT NULL`.

\*\*Target fix:\*\* Discussion needed — may not be required if business workflow ensures reporting completes within 24 hours

\*\*Estimated effort:\*\* 2 hours (migration + service update)



\### TECH-PHASE2-001: StorageMonitor needs platform channels

\*\*Source:\*\* Phase 2 fix #6 implementation note

\*\*Severity:\*\* Same as F4 above (duplicate)

\*\*Note:\*\* Merged with F4. See F4 for details.



\### TECH-PHASE2-002: XSD validation not implemented

\*\*Source:\*\* Phase 2 fix #4 implementation note

\*\*Severity:\*\* Medium

\*\*Location:\*\* packages/alhai\_zatca/lib/src/services/invoice\_xml\_validator.dart

\*\*Issue:\*\* Only structural validation is performed. Full UBL 2.1 XSD validation requires a C++ library with platform channels. Current structural validator catches \~90% of errors before ZATCA submission.

\*\*Resolution:\*\* Optional improvement. Consider before Phase 6 (security audit). Acceptable for current scope.

\*\*Target fix:\*\* Optional — not blocking

\*\*Estimated effort:\*\* 1 day



\### TECH-PHASE2-003: DataRetentionService not auto-scheduled

\*\*Source:\*\* Phase 2 fix #7 implementation note

\*\*Severity:\*\* High → CRITICAL before launch

\*\*Location:\*\* packages/alhai\_database/lib/src/services/data\_retention\_service.dart

\*\*Issue:\*\* Cleanup logic exists but is not auto-triggered. Must be manually scheduled via background task framework.

\*\*Resolution:\*\* Wire to:

&#x20; - Android: WorkManager (PeriodicWorkRequest)

&#x20; - iOS: Background Tasks framework (BGProcessingTaskRequest)

&#x20; Schedule daily execution at off-peak hours (3 AM local time).

\*\*Target fix:\*\* Before Phase 5 (production hardening)

\*\*Estimated effort:\*\* 3-4 hours



\---



\## Items deferred from POS audit (Phase 2)



\### H3-POS: Mada/Geidea payment gateway integration

\*\*Source:\*\* Phase 2 POS audit

\*\*Severity:\*\* High (blocker for production)

\*\*Location:\*\* apps/cashier/lib/services/payment/

\*\*Issue:\*\* Electronic payment processing currently uses mock implementations only. Cashier records Mada payments as "completed" without actual hardware integration.

\*\*Resolution:\*\* Requires:

&#x20; - Business agreement with Mada/Geidea/PayTabs

&#x20; - SDK integration

&#x20; - Hardware testing with real card terminal

\*\*Target fix:\*\* Before production launch

\*\*Estimated effort:\*\* 1 week + business decision



\### MED-POS: 60+ hardcoded Arabic strings in print service

\*\*Source:\*\* Phase 2 POS audit

\*\*Severity:\*\* Medium

\*\*Location:\*\* apps/cashier/lib/services/printing/sunmi\_print\_service.dart

\*\*Issue:\*\* Hardcoded Arabic strings prevent expansion to other markets. Saudi launch unaffected, but blocks 6 of 7 target language markets.

\*\*Resolution:\*\* Move all strings to alhai\_l10n with translations for: Bengali, Filipino, Hindi, Indonesian, Urdu, English.

\*\*Target fix:\*\* Before non-Saudi market launch

\*\*Estimated effort:\*\* 1 day



\---



\## Review Schedule



\- \*\*Before Phase 4 (Admin Suite):\*\* BUG-PHASE1-001, F3, F5

\- \*\*During Phase 4:\*\* BUG-PHASE1-003

\- \*\*Before Phase 5 (production hardening):\*\* BUG-PHASE1-002, F2, F4, TECH-PHASE2-003

\- \*\*Before Phase 6 (security audit):\*\* TECH-PHASE2-002

\- \*\*Before production launch:\*\* F4, H3-POS, TECH-PHASE2-003

\- \*\*Before non-Saudi launch:\*\* MED-POS

\- \*\*Discussion required:\*\* F6

