# Customer App — Phase 5 Fix Report

## Summary

| Metric | Value |
|--------|-------|
| Total defects reported | 10 (5 CRITICAL + 5 HIGH) |
| Fixed | 7 (5 CRITICAL + 2 HIGH) |
| Deferred | 3 (H3, H5, H7) |
| Tests before | 75 (existing) |
| Tests after | 107 (+32 new) |
| Analyzer errors | 0 |
| Analyzer warnings | 0 |
| Analyzer infos | 1 (pre-existing) |

## Fixes

| # | ID | Severity | Title | Status | Commit |
|---|-----|----------|-------|--------|--------|
| 1 | C1 | CRITICAL | Auth Guard on Router | FIXED | `c409df9` |
| 2 | C2 | CRITICAL | IDOR in getOrder | FIXED | `de5b4ff` |
| 3 | C3 | CRITICAL | IDOR in cancelOrder | FIXED | `f0ebd40` |
| 4 | C4 | CRITICAL | VAT 15% Calculation | FIXED | `e6089d8` |
| 5 | C5 | CRITICAL | ZATCA QR Code in Receipt | FIXED | `422f549` |
| 6 | H1 | HIGH | Certificate Pinning | FIXED | `57ab16e` |
| 7 | H2 | HIGH | IDOR in setDefaultAddress | FIXED | `78572f7` |
| 8 | H4 | HIGH | debugPrint Guards | FIXED | `4e9820c` |
| 9 | H6 | HIGH | debugLogDiagnostics in Router | FIXED | `c409df9` (with C1) |
| 10 | H3 | HIGH | OTP Rate Limiting | DEFERRED | - |
| 11 | H5 | HIGH | Account Deletion (PDPL) | DEFERRED | - |
| 12 | H7 | HIGH | English Localization | DEFERRED | - |

## Fix Descriptions

### C1 + H6: Auth Guard on Router
Added `redirect` callback to GoRouter that redirects unauthenticated users to `/auth/login` for all protected routes (`/home`, `/orders`, `/checkout`, etc.) and redirects authenticated users away from auth routes to `/home`. Changed `debugLogDiagnostics: true` to `debugLogDiagnostics: kDebugMode`. 11 unit tests cover all redirect scenarios.

### C2: IDOR in getOrder
`getOrder(id)` now requires authentication and adds `.eq('customer_id', userId)` filter, preventing users from accessing other users' orders. Changed from `.single()` to `.maybeSingle()` with null check to return a clear "access denied" error.

### C3: IDOR in cancelOrder
`cancelOrder(id)` now verifies order ownership via `customer_id` filter before allowing cancellation. Also validates order status — cannot cancel orders that are already `delivered` or `cancelled`. The update query includes a `customer_id` double-check.

### C4: VAT 15% Calculation
Added `alhai_zatca` dependency and integrated `VatCalculator.vatFromNet()` for 15% VAT calculation. Checkout screen now displays: subtotal, VAT (15%), delivery fee, and total. Order creation includes `tax_amount` and `delivery_fee` in the database insert. 6 unit tests verify calculations.

### C5: ZATCA QR Code in Receipt
Added `qr_flutter` and `hijri` dependencies. Order detail screen now shows a ZATCA receipt section with: TLV-encoded QR code (simplified Phase 1, tags 1-5), Hijri date alongside Gregorian date, VAT amount, and total with VAT. Uses placeholder VAT number pending store settings lookup. 5 unit tests.

### H1: Certificate Pinning
Added `crypto` dependency for SHA-256 computation. In `kReleaseMode`, `badCertificateCallback` validates server certificate fingerprint against pinned values using constant-time comparison. In `kDebugMode`, pinning is skipped. Fail-closed design. Note: actual Supabase certificate fingerprints must be added before production release.

### H2: IDOR in setDefaultAddress
Added `.eq('user_id', _userId)` filter to the second query in `setDefaultAddress()`, preventing users from setting another user's address as their default.

### H4: debugPrint Guards
Wrapped 8 unguarded `debugPrint` calls with `if (kDebugMode)` in: `auth_datasource.dart` (4 calls), `otp_screen.dart` (1), `cart_provider.dart` (2), `addresses_screen.dart` (1). Added `foundation.dart` imports where missing.

## Deferred Items

| ID | Title | Reason | Documentation |
|----|-------|--------|---------------|
| H3 | OTP Rate Limiting | Requires Supabase project configuration, not client-side fix | `docs/DEFERRED_HIGH_ITEMS.md` |
| H5 | Account Deletion | Requires backend RPC + UI design for PDPL compliance | `docs/DEFERRED_HIGH_ITEMS.md` |
| H7 | English Localization | Full l10n migration project (3-5 days) | `docs/DEFERRED_HIGH_ITEMS.md` |

## Migration Notes

- **C4 (VAT):** If `tax_amount` column doesn't exist in the `orders` table, run:
  ```sql
  ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax_amount NUMERIC DEFAULT 0;
  ```
- **C5 (ZATCA QR):** Uses placeholder VAT number `300000000000003`. Store-level VAT numbers should be fetched from store settings when available.
- **H1 (Cert Pinning):** `_pinnedFingerprints` list is empty — must add actual Supabase certificate fingerprints before production release.

## Commits (chronological)

1. `c409df9` fix(customer_app): add auth guard to router (C1 + H6)
2. `de5b4ff` fix(customer_app): add customer_id filter to getOrder (C2 IDOR)
3. `f0ebd40` fix(customer_app): validate ownership before cancelOrder (C3 IDOR)
4. `e6089d8` fix(customer_app): add VAT 15% calculation using alhai_zatca (C4)
5. `422f549` fix(customer_app): add ZATCA QR code and Hijri date to receipt (C5)
6. `57ab16e` fix(customer_app): add certificate pinning for MITM protection (H1)
7. `78572f7` fix(customer_app): add user_id filter to setDefaultAddress (H2 IDOR)
8. `4e9820c` fix(customer_app): guard debugPrint calls with kDebugMode (H4)
9. `b1c2cee` docs(customer_app): document deferred HIGH items (H3, H5, H7)
