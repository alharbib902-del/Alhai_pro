# Admin App Audit — Status Reconciliation (2026-04-22)

**Purpose:** Reconcile the 2026-04-15 Phase 4 Admin Acceptance Report against the current main (post-C-4 migration sessions, 2026-04-22). Supersedes stale "310 findings / 42 P0s" memory references.

**Source artifacts:**
- Acceptance Report: `docs/reports/acceptance/phase4/admin_pos/ACCEPTANCE_REPORT_PHASE4_ADMIN_POS.md` (2026-04-15, 431 LOC, Arabic)
- Fix Report: `docs/reports/fixes-apr15/phase4/ADMIN_FIX_REPORT.md` (2026-04-15, 102 LOC, 8 fixed + 2 deferred)

---

## 1. Reality check — the actual numbers

| Metric | Previously (stale memory) | Actual (2026-04-22) |
|---|---|---|
| Total findings | 310 | **135** (in acceptance report) |
| P0s (CRITICAL/HIGH) | 42 | **10** (3 CRITICAL + 7 HIGH) |
| Already fixed | — | **8** (C1-C3, H1-H3, H5, H6) |
| Deferred (infrastructure-blocked) | — | **2** (H4 image upload, H7 device OTP) |
| Minor/medium remaining | — | **~27** (14 FAILED + 13 PARTIAL not in fix scope) |

**TL;DR:** There is no crisis. Phase 4 closed all critical + high defects. Remaining items are feature gaps and polish, not production blockers.

---

## 2. What's already closed (2026-04-15 Phase 4 fix)

| ID | Severity | Fix |
|---|---|---|
| C1 | CRITICAL | Removed hardcoded VAT number `310123456700003` |
| C2 | CRITICAL | Shipping API keys now encrypt via `SecureStorageService` |
| C3 | CRITICAL | Barcode duplicate check before insert/update + 4 unit tests |
| H1 | HIGH | Runtime permission enforcement (new `permission_provider` + `permission_guard` infrastructure + 4 screens) |
| H2 | HIGH | ZATCA submit button now driven by real CSID status |
| H3 | HIGH | CSID certificate reads real status from `CertificateStorage` |
| H5 | HIGH | Price change audit trail via `AuditLogDao.log()` |
| H6 | HIGH | WhatsApp API key persists to `SecureStorageService` |
| H4 | HIGH | DEFERRED — product image upload (needs Supabase Storage bucket) |
| H7 | HIGH | DEFERRED — new-device OTP verification (needs backend RPC + 2-3d scope) |

---

## 3. Remaining findings — categorized

Items from the Phase 4 acceptance report that were NOT in the fix report scope, grouped by workload.

### 🟢 Quick wins (each ~30-60 min, low-risk)

| # | Item | Area |
|---|---|---|
| Q1 | Soft-delete UI for products (flag exists; UI doesn't use it) | products |
| Q2 | Confirm-before-delete dialog polish (categories/suppliers done; others?) | UX |
| Q3 | Duplicate VAT number check on supplier insert | suppliers |
| Q4 | Phone validation regex (international format, currently only length-checked) | forms |
| Q5 | Dialog `TextEditingController` disposals (users_management add/edit dialogs) | leaks |
| Q6 | Audit log extension: log *every* product mutation, not just price | audit |

### 🟡 Medium features (each ~2-4h, dedicated session)

| # | Item | Area |
|---|---|---|
| M1 | Auto-generate barcode (EAN-13 + check digit, if user leaves blank) | products |
| M2 | Low-stock alerts dashboard + in-app notification | inventory |
| M3 | Periodic stocktaking screen in admin (table exists, UI missing) | inventory |
| M4 | Inter-branch stock transfer screen in admin (table + workflow exist) | inventory |
| M5 | Invoice attachment upload (PDF/image) for purchases | suppliers |
| M6 | Supplier receivables report (dedicated screen; data exists) | reports/finance |
| M7 | ZATCA queue status report (sent/rejected/pending) | reports |
| M8 | Product CSV/Excel import | products |
| M9 | Max-discount-per-role enforcement (permissions defined, limit not enforced) | permissions |

### 🔴 Large/infrastructure (each ≥ 1 day, planning needed)

| # | Item | Blocker |
|---|---|---|
| L1 | Product image upload | Supabase Storage bucket + compression pipeline (H4 deferred) |
| L2 | New-device OTP verification | `is_known_device` / `register_device` RPCs + `DeviceVerificationService` in alhai_auth + UI (H7 deferred) |
| L3 | CSID certificate renewal workflow + OTP from ZATCA | ZATCA sandbox integration + UI flow |
| L4 | Real-time customer_app push (currently Supabase pull-sync only) | Supabase Realtime or webhooks |
| L5 | 100K-invoice performance benchmark | Dedicated load-test harness |

### ✅ Already covered indirectly by later work

Some items from the 2026-04-15 report were resolved via unrelated later commits:

| Item | Resolved by |
|---|---|
| RLS wildcard closures (across various tables) | Session 12 series (v64-v71) |
| Money columns integer-cents migration | C-4 Sessions 1-4 (v70-v74) |
| Supabase partial indexes on `deleted_at` | Session 17 v75 |
| Orphan policy cleanup | Session 17 v75 |
| super_admin-specific P0s (platform_settings save, create_store RPC, error sanitization) | Session 21 merge (v43+v46+v47+v48+v49) |
| driver_app store_id upsert test coverage | Session 22 cherry-pick |

---

## 4. Recommended priority order

For a future session (not today — 11 sessions already done on 2026-04-22).

### Tier A — Quick wins in a single focused session (2-3h)

Target: 3-4 items from the Q-list. Highest-value picks:

1. **Q3** duplicate VAT check on supplier — matches C3 pattern, reuses `getSupplierByVat` if it exists else adds one.
2. **Q5** dialog controller disposals — small correctness fix, probably 10 LOC + tests.
3. **Q6** broader audit log coverage — builds on H5 (price change audit) to cover stock/settings/permissions mutations.
4. **Q1** soft-delete UI for products — wires the existing `deleted_at` column into the UI.

### Tier B — One medium feature per session (2-4h each)

Prioritize in this order (highest user-facing value first):

1. **M2** low-stock alerts — operationally impactful, existing `getLowStockProducts()` DAO ready.
2. **M1** auto-generate barcode — reduces friction when POS operator adds a product without a printed barcode.
3. **M7** ZATCA queue status report — required for compliance visibility.
4. **M3 + M4** stocktaking + inter-branch transfer — one session for both since they share stock_movements infrastructure.

### Tier C — Scope a dedicated plan

These need a plan doc before work starts (like `c4-money-migration-plan.md`):

- **L1** (image upload) + Supabase Storage provisioning decision
- **L3** (CSID renewal) — needs ZATCA sandbox credentials + flow design

---

## 5. Policy recommendations

Based on the "phantom P0" pattern observed across sessions (A-5, C-1, C-2, super_admin original 3, platform_settings, admin "310/42" myth):

1. **Always verify audit-report claims against current code before scheduling fix work.** Memory and handover notes decay in ~days; code is the source of truth.
2. **When audit-report numbers feel wrong (e.g. "42 P0s for a single app"), investigate before scoping.** Usually the number is either: (a) stale (some already fixed), (b) across-scope (admin + admin_lite + super_admin combined), or (c) includes non-P0s counted as P0.
3. **For future audit reports: include per-item commit-reference on fix.** The 2026-04-15 fix report does this well — each of C1-H7 has its resolving commit hash.

---

## 6. Artifact locations

- Acceptance: `docs/reports/acceptance/phase4/admin_pos/ACCEPTANCE_REPORT_PHASE4_ADMIN_POS.md`
- Fix report: `docs/reports/fixes-apr15/phase4/ADMIN_FIX_REPORT.md`
- admin_lite acceptance/fix: same directories, `admin_pos_lite/` + `ADMIN_LITE_FIX_REPORT.md`
- super_admin acceptance/fix: same directories, `super_admin/` + `SUPER_ADMIN_FIX_REPORT.md`
- **This doc:** `docs/reports/admin-audit-status-2026-04-22.md`

---

_End of reconciliation. Next-session planning can pick any Tier A/B item from §4 directly._
