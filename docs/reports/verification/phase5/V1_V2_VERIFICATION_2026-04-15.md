# V1 + V2 Verification — Customer App Phase 5

**Auditor:** Independent (Claude Opus 4.6)
**Date:** 2026-04-15
**Branch:** fix/phase5-customer-app
**Scope:** V1 (commit 513325e) + V2 (commit 0149dcc) only

## Executive Summary

V1 correctly eliminates both ghost bugs (C5-1 and C5-2). Store name and VAT number now come from a real JOIN with the `stores` table, and the ZATCA receipt gracefully handles stores without VAT registration. V2 correctly fixes the RLS conflict (C3-2) by routing cancellation by order status, with a narrow residual TOCTOU for the `created` path that the documented backend RPC would fully resolve.

---

## V1 Verification (C5-1 + C5-2)

**Status: ✅ PASS**

### C5-1: Ghost `storeName` — FIXED

| Check | Result |
|-------|--------|
| `getOrder` has stores JOIN | ✅ `select('*, order_items(*), stores(name, tax_number)')` — line 119 |
| `getOrders` has stores JOIN | ✅ Same query — line 153 |
| `_orderFromRow` extracts from JOIN | ✅ `row['stores']['name']` — lines 283-284 |
| `Order.storeName` populated | ✅ From real data, not from non-existent `orders.store_name` column |

### C5-2: Placeholder VAT `300000000000003` — FIXED

| Check | Result |
|-------|--------|
| Placeholder in production code | ✅ Zero matches in `customer_app/lib/` |
| `storeVatNumber` field on Order model | ✅ `alhai_core/lib/src/models/order.dart:24` |
| Reads from stores JOIN (not hardcoded) | ✅ `store?['tax_number']` — line 285 |
| Fallback for missing VAT | ✅ Shows "هذا المتجر غير مسجّل في هيئة الزكاة والضريبة" — lines 380-397 |
| No fake QR generated | ✅ QR only when `vatNumber != null && vatNumber.isNotEmpty` |

### V1 Tests

6 tests in `zatca_receipt_v1_test.dart` — all pass:
- QR encodes real store name + VAT
- QR does NOT contain placeholder `300000000000003`
- Order model carries `storeVatNumber` from joined data
- Null VAT → `storeVatNumber` is null (fallback path)
- Empty VAT string → treated same as null
- TLV round-trip preserves all 5 tags

### V1 Minor Observation (non-blocking)

`createOrder` uses `.insert().select().single()` without the stores JOIN, so the returned Order has `storeName=null` and `storeVatNumber=null`. This is acceptable because the user immediately navigates to order detail (which calls `getOrder` with the JOIN).

---

## V2 Verification (C3-2)

**Status: 🟡 CONDITIONAL — 1 item noted**

### C3-2: RLS Conflict in `cancelOrder` — FIXED (with caveat)

| Check | Result |
|-------|--------|
| Ownership check before mutation | ✅ SELECT with `customer_id` filter — lines 219-229 |
| Terminal status rejection | ✅ `delivered`/`cancelled` → throw immediately — lines 234-236 |
| `status='created'` → direct UPDATE | ✅ RLS-allowed path, stock release + UPDATE — lines 239-254 |
| Other statuses → RPC | ✅ `cancel_order_by_customer` RPC call — lines 261-269 |
| RPC not deployed (42883) → user message | ✅ Arabic message "يرجى التواصل مع المتجر" — lines 272-276 |
| Other errors → rethrow | ✅ line 277 |
| `cancellation_reason` passed | ✅ Both paths pass the reason |

### V2 Documentation

`docs/BACKEND_RPC_REQUIRED.md` is complete:
- ✅ Full SQL with `SECURITY DEFINER`, `FOR UPDATE` row lock
- ✅ Ownership via `auth.uid()`
- ✅ Cancellable status whitelist (`created`, `confirmed`, `preparing`)
- ✅ Atomic stock release + status update in same transaction
- ✅ Testing checklist for backend team
- ✅ Impact description for pre-deployment period

### V2 Tests

7 tests in `cancel_order_v2_test.dart` — all pass:
- `canCancel` true only for created/confirmed
- Terminal statuses block cancellation
- `created` → direct UPDATE path
- Non-created → RPC path
- 42883 → RPC not deployed detection
- Stock release ordering validation
- Ownership check before mutation

### ⚠️ Residual TOCTOU — `status='created'` Path

**Scenario:** Between the ownership SELECT and the direct UPDATE, if a merchant changes the order from `created` → `confirmed`, then:
1. `release_reserved_stock` executes (stock freed) ✅
2. UPDATE blocked by RLS `orders_customer_update_created` (status no longer `created`) ❌
3. Result: stock released, order not cancelled — same C3-2 pattern but much narrower window

**Risk assessment: LOW**
- Window is milliseconds (between RPC and UPDATE)
- Requires merchant to confirm at exact same moment
- Pre-existing issue (not introduced by V2)
- The proposed backend RPC with `FOR UPDATE` lock would fully eliminate this

**Recommendation:** Deploy the `cancel_order_by_customer` RPC and route ALL statuses through it (including `created`). This eliminates both the RLS workaround and the TOCTOU.

---

## General Checks

| Check | Result |
|-------|--------|
| All tests pass | ✅ 121 tests, 0 failures |
| Analyzer | ✅ 1 pre-existing `info` (curly braces in `login_screen.dart:89`, unrelated) |
| No new ghost bugs in diff | ✅ Only pre-existing TODO in `supabase_client.dart` (H1 commit, out of scope) |

---

## New Findings

| ID | Severity | Description |
|----|----------|-------------|
| V2-TOCTOU | LOW | `created` path has narrow race window between stock release and UPDATE. Fully resolved once backend RPC is deployed. |

---

## Final Recommendation

### 🟡 CONDITIONAL — 1 item before merge

1. **Deploy backend RPC** `cancel_order_by_customer` (SQL provided in `docs/BACKEND_RPC_REQUIRED.md`) before this branch goes to production. The client-side fix is correct and safe for staging/testing, but the `created` path TOCTOU should not ship to production without the RPC safety net.

If the RPC is already deployed or will be deployed before production release: **✅ APPROVED — safe to merge**.
