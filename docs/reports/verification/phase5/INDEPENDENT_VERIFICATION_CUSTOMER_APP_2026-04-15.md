# Independent Verification Report — Customer App Phase 5 CRITICALs

**Date:** 2026-04-15
**Verifier:** Claude (independent session — no prior involvement in fixes)
**Branch:** `fix/phase5-customer-app`
**Scope:** 5 CRITICALs (C1-C5) across 9 commits
**Method:** Source code audit, schema cross-reference, test analysis, static analysis
**Tests:** 107 passing, 1 analyzer info (unrelated)

---

## Executive Summary

Of 5 CRITICALs verified, **1 fully passes**, **4 are partial**. Two ghost bugs were discovered: (1) `store_name` column missing from Supabase `orders` table causes ZATCA QR to always use a generic seller name, and (2) RLS policy restricts customer order updates to `status = 'created'` only, creating a data consistency gap when `cancelOrder` releases stock but the subsequent UPDATE is blocked by RLS for non-`created` orders. The placeholder VAT number `300000000000003` in C5 is a ZATCA compliance violation. Test quality is weak — 3 of 5 test files duplicate logic locally instead of testing production code (test theater).

---

## Fix-by-Fix Verification

### C1 + H6: Auth Guard on Router

- **Status:** `PARTIAL`
- **Commit:** `c409df9`
- **Files:** `app_router.dart`, `auth_guard_test.dart`

**What works:**
- Redirect logic correct: unauthenticated users redirected from protected routes to `/auth/login`
- Authenticated users redirected from auth routes (except splash) to `/home`
- Public routes correctly defined: `/`, `/auth/*`, `/onboarding/*`
- `debugLogDiagnostics: kDebugMode` — H6 fixed correctly (line 52)
- `AppSupabase.isAuthenticated` checks `currentSession != null` — sound approach

**Issues found:**

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| C1-1 | Test theater | MEDIUM | `auth_guard_test.dart` creates a LOCAL `authRedirect()` function (lines 15-31) that duplicates the redirect logic. It does NOT test `AppRouter.router.redirect`. If production logic diverges, tests still pass. |
| C1-2 | No `refreshListenable` | LOW | GoRouter redirect only evaluates on navigation events. No `refreshListenable` is hooked to `authStateChangesProvider`. If a session expires mid-usage, user stays on protected route until next navigation. Logout flow manually calls `context.go('/auth/login')` (line 115 of profile_screen.dart), so explicit logout works. |

**Evidence:**
- `app_router.dart:53-73` — redirect callback
- `auth_guard_test.dart:15-31` — duplicated logic (not imported from production)
- `supabase_client.dart:116` — `isAuthenticated` getter
- `app_providers.dart:14-15` — `authStateChangesProvider` exists but not connected to router

---

### C2: getOrder IDOR Protection

- **Status:** `PARTIAL`
- **Commit:** `de5b4ff`
- **Files:** `orders_datasource.dart`, `idor_protection_test.dart`

**What works:**
- Auth check: `userId == null → throw StateError` (line 114-115)
- Ownership filter: `.eq('customer_id', userId)` (line 121)
- Safe query: `.maybeSingle()` instead of `.single()` (line 122)
- Generic error: `'Order not found or access denied'` — no info leakage (line 126)
- `getOrders` (line 144-196) also has `customer_id` filter — consistent

**Issues found:**

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| C2-1 | Test theater | MEDIUM | `idor_protection_test.dart` creates local `getOrderWithOwnershipCheck()` function simulating the logic. Does not test actual `OrdersDatasource.getOrder`. |
| C2-2 | Realtime bypass paths (mitigated by RLS) | LOW | `delivery_datasource.dart:44-56` and `orders_providers.dart:30-33` use `.stream(primaryKey: ['id']).eq('id', orderId)` without `customer_id` filter. However, Supabase RLS policy `orders_customer_read` (`customer_id = auth.uid()`) blocks unauthorized access server-side. Defense-in-depth is incomplete at app layer but server-side protection is sound. |

**Evidence:**
- `orders_datasource.dart:113-127` — fixed getOrder
- `idor_protection_test.dart:12-22` — duplicated logic
- `supabase_init.sql` — `orders_customer_read` RLS policy confirms server-side protection
- `delivery_datasource.dart:44-56` — no app-layer customer_id filter

---

### C3: cancelOrder IDOR Protection

- **Status:** `PARTIAL`
- **Commit:** `f0ebd40`
- **Files:** `orders_datasource.dart`, `idor_protection_test.dart`

**What works:**
- Auth check (line 199-200)
- Ownership verification via SELECT with `customer_id` filter (lines 203-209)
- Status check blocks `delivered` and `cancelled` (line 216)
- Double-check on UPDATE with `customer_id` filter (line 234)

**Issues found:**

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| C3-1 | TOCTOU race condition | MEDIUM | Between ownership+status check (step 1, line 203-213) and UPDATE (step 3, line 226-235), status could change. UPDATE has no status guard — only checks `id` and `customer_id`. A store could mark order as `delivered` between steps 1 and 3. |
| C3-2 | RLS blocks non-created updates | HIGH | `orders_customer_update_created` RLS policy only allows UPDATE when `status = 'created'`. Application code allows cancellation for `confirmed`, `preparing`, `ready`, etc. For non-`created` orders: `release_reserved_stock` RPC (step 2) executes successfully, but the subsequent UPDATE (step 3) is silently blocked by RLS. **Result: stock released without order being cancelled.** |
| C3-3 | Incomplete status transitions | LOW | Code blocks `delivered` and `cancelled` but allows `in_transit`. Business question: should a customer cancel an order already being delivered? |
| C3-4 | Test theater | MEDIUM | Same local simulation pattern. Tests `cancelOrderWithOwnershipCheck()` function, not actual code. |

**Evidence:**
- `orders_datasource.dart:198-236` — cancelOrder implementation
- `supabase_init.sql` — `orders_customer_update_created` RLS: `USING (customer_id = auth.uid() AND status = 'created')`
- RPC `release_reserved_stock` runs before UPDATE — if UPDATE fails, stock is already released

**C3-2 is the most significant finding in this audit. The RLS policy and application logic are in conflict, creating a data consistency gap.**

---

### C4: VAT Calculation

- **Status:** `PASSED`
- **Commit:** `e6089d8`
- **Files:** `orders_datasource.dart`, `checkout_screen.dart`, `vat_calculation_test.dart`

**What works:**
- `VatCalculator.vatFromNet(netAmount: subtotal)` — correct API call (line 39)
- Formula: `total = subtotal + taxAmount + deliveryFee` (line 40) — correct
- `tax_amount` column exists in Supabase `orders` table: `DECIMAL(10,2) DEFAULT 0` — confirmed in `supabase_init.sql`
- `delivery_fee` column exists — confirmed
- Checkout screen displays subtotal, VAT (15%), delivery fee, total separately — correct UI
- Tests use the REAL `VatCalculator` class — **not test theater** (first genuine test file)
- `_orderFromRow` reads `tax_amount` with null-safe fallback `?? 0` (line 255)

**Notes (non-blocking):**

| # | Note | Severity | Detail |
|---|------|----------|--------|
| C4-N1 | Delivery fee VAT | INFO | Delivery fee added without VAT. In Saudi Arabia, delivery services are VATable. Either fee is assumed VAT-inclusive (undocumented) or VAT on delivery is missing. |
| C4-N2 | Rounding doc mismatch | INFO | `_round2` docstring says "banker's rounding" but implementation uses standard `roundToDouble()` (rounds 0.5 away from zero). Functionally correct for ZATCA Phase 1. |

**Evidence:**
- `orders_datasource.dart:39-40` — VAT calculation
- `orders_datasource.dart:50-51` — tax_amount and delivery_fee saved
- `supabase_init.sql` — `tax_amount DECIMAL(10,2) DEFAULT 0` confirmed
- `vat_calculator.dart:51-56` — `vatFromNet` implementation verified

---

### C5: ZATCA QR Code + Hijri Date

- **Status:** `PARTIAL`
- **Commit:** `422f549`
- **Files:** `order_detail_screen.dart`, `zatca_receipt_test.dart`

**What works:**
- `ZatcaTlvEncoder().encodeSimplified()` — correct Phase 1 TLV encoding (tags 1-5)
- TLV format compliant: tag (1 byte) + length + value with UTF-8 encoding
- Hijri date conversion via `HijriCalendar.fromDate()` — works offline, algorithmic
- QR rendered via `qr_flutter` `QrImageView` widget
- Receipt hidden when `vatAmount <= 0` — correct fallback
- Base64 output suitable for QR rendering

**Issues found:**

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| C5-1 | **GHOST BUG: `store_name` always null** | HIGH | `_orderFromRow` reads `row['store_name']` (line 246) but `orders` table has NO `store_name` column. `order.storeName` is always `null`, so receipt uses fallback `'المتجر'` ("The Store"). **Tag 1 (seller name) is generic for every order.** |
| C5-2 | **Placeholder VAT number** | HIGH | `const defaultVatNumber = '300000000000003'` (line 383) — ZATCA sandbox test number. `stores.tax_number` column exists but is never queried. **Tag 2 (VAT number) is fake for every order.** No TODO marker — only `// Placeholder` comment. |
| C5-3 | Combined effect: non-compliant QR | HIGH | Tags 1 and 2 are both wrong. The QR code is ZATCA non-compliant. If scanned by ZATCA inspectors, it will show a generic store name with a test VAT number. |
| C5-4 | No fallback for stores without VAT | MEDIUM | If a store has no `tax_number`, the code still generates a QR with the placeholder. Should display a message instead. |

**Evidence:**
- `order_detail_screen.dart:369-383` — ghost bug: storeName fallback + placeholder VAT
- `supabase_init.sql` — `orders` table has NO `store_name` column; `stores` table has `tax_number TEXT`
- `orders_datasource.dart:246` — `storeName: row['store_name'] as String?` → always null
- `zatca_tlv_encoder.dart:73-89` — `encodeSimplified` correctly encodes tags 1-5

**TLV Phase compliance:** Phase 1 simplified (tags 1-5) is acceptable for B2C simplified invoices even in 2026. Phase 2 (tags 1-9) is only required for standard/B2B invoices.

---

## Cross-cutting Issues

### Test Quality Summary

| Test File | Tests Real Code? | Verdict |
|-----------|------------------|---------|
| `auth_guard_test.dart` | NO — duplicates redirect logic locally | Test theater |
| `idor_protection_test.dart` | NO — simulates ownership check locally | Test theater |
| `vat_calculation_test.dart` | YES — imports and tests real VatCalculator | Genuine |
| `zatca_receipt_test.dart` | PARTIALLY — tests real TLV encoder but not widget behavior | Mixed |

**3 of 4 test files exhibit test theater.** They test local copies of business logic, not the actual production classes. If production code changes, these tests still pass — providing false confidence.

### Static Analysis

- 107 tests passing
- 1 analyzer info (unrelated to fixes): `curly_braces_in_flow_control_structures` in `login_screen.dart:89`

### Schema Verification

| Column | Table | Exists in Supabase? | Used by Code? |
|--------|-------|---------------------|---------------|
| `tax_amount` | `orders` | YES (DECIMAL(10,2)) | YES — C4 writes, C5 reads |
| `delivery_fee` | `orders` | YES (DECIMAL(10,2)) | YES — C4 writes |
| `store_name` | `orders` | **NO** | YES — C5 reads (always null) |
| `tax_number` | `stores` | YES (TEXT) | **NO** — C5 uses placeholder instead |
| `cancellation_reason` | `orders` | YES (TEXT) | YES — C3 writes |
| `cancelled_at` | `orders` | YES (TIMESTAMPTZ) | YES — C3 writes |

### Pending Integrations

1. **Certificate pinning fingerprints:** Empty array at `supabase_client.dart:36-40` with TODO
2. **Store VAT number lookup:** Required for ZATCA compliance but not implemented
3. **Store name in order context:** Requires either denormalization (add column) or join query

---

## Findings Summary

| ID | Severity | Category | Description | Must Fix Before Merge? |
|----|----------|----------|-------------|------------------------|
| C1-1 | MEDIUM | Test theater | Auth guard tests duplicate logic locally, don't test actual router | No (tests functional but fragile) |
| C1-2 | LOW | Missing feature | No `refreshListenable` for reactive auth state changes | No |
| C2-1 | MEDIUM | Test theater | IDOR tests duplicate logic locally | No |
| C2-2 | LOW | Defense-in-depth | Realtime streams lack app-layer customer_id filter (mitigated by RLS) | No |
| **C3-2** | **HIGH** | **Data consistency** | **RLS blocks non-`created` order updates but `cancelOrder` releases stock for any status. Stock released without cancellation for `confirmed`/`preparing`/`ready` orders.** | **YES** |
| C3-1 | MEDIUM | Race condition | TOCTOU between status check and update in cancelOrder | Recommended |
| C3-3 | LOW | Business logic | `in_transit` orders not blocked from cancellation | Review needed |
| C3-4 | MEDIUM | Test theater | Cancel tests duplicate logic locally | No |
| C4-N1 | INFO | Business logic | Delivery fee VAT treatment undocumented | No |
| **C5-1** | **HIGH** | **Ghost bug** | **`store_name` always null — QR tag 1 (seller) is generic "المتجر"** | **YES** |
| **C5-2** | **HIGH** | **Compliance** | **Placeholder VAT number `300000000000003` — QR tag 2 is fake** | **YES** |
| C5-3 | HIGH | Combined | QR code is ZATCA non-compliant (tags 1+2 wrong) | YES (consequence of C5-1 + C5-2) |
| C5-4 | MEDIUM | Missing logic | No fallback for stores without VAT registration | Recommended |

---

## Final Recommendation

### `CONDITIONAL` — 3 items MUST be fixed before merge

**Must Fix (blocking merge):**

1. **C3-2: RLS vs cancelOrder conflict** — Either:
   - Update RLS policy to allow cancellation for more statuses, OR
   - Restrict `cancelOrder` to `created` status only, OR
   - Use a server-side RPC function that runs with elevated privileges to handle cancellation atomically

2. **C5-1: Store name ghost bug** — Either:
   - Add store name to order via a join in `getOrder` query: `.select('*, order_items(*), stores(name, tax_number)')`, OR
   - Denormalize: add `store_name` column to orders and populate at creation

3. **C5-2: Placeholder VAT number** — Either:
   - Fetch store's `tax_number` (see C5-1 solution), OR
   - If store has no `tax_number`, hide the ZATCA receipt section entirely (don't show fake QR)

**Recommended (non-blocking but important):**

4. Refactor test files C1/C2/C3 to test actual production classes (eliminate test theater)
5. Add status guard to cancelOrder UPDATE query: `.neq('status', 'delivered').neq('status', 'cancelled')`
6. Add `refreshListenable` to GoRouter for reactive auth state

---

*This report was generated by an independent verification session with no access to or knowledge of the fix development process. All findings are based solely on source code analysis and schema cross-referencing.*
