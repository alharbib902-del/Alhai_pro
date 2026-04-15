# Independent Verification Report — Phase 4 CRITICALs

**Date:** 2026-04-15
**Verifier:** Claude (independent session — no participation in fixes)
**Branch:** `fix/phase4-blockers`
**Scope:** 5 CRITICALs only (C1, C2+H6, C3, CRITICAL-01, CRITICAL-02)
**Methodology:** Code review, grep-based sweep, static analysis, diff inspection

---

## Executive Summary

Of 5 CRITICALs verified, **1 passed cleanly, 3 are partial (functional but with gaps), and 1 failed** due to a discoverable MFA bypass route. The most severe finding is that the MFA guard (CRITICAL-02) can be bypassed by navigating directly to `/dashboard` after password auth — the GoRouter redirect does not enforce AAL2. The barcode duplicate check (C3) is UI-only with no database constraint, making it bypassable by sync or direct DB writes. The API encryption fixes (C2) work correctly on native but have a design inconsistency between shipping and WhatsApp screens. C1 (VAT hardcoded) is fully resolved.

---

## Fix-by-Fix Verification

### C1: VAT Hardcoded Removal

- **Status:** ✅ PASSED
- **Commit:** `9592c4c`
- **File:** `apps/admin/lib/screens/settings/business/tax_settings_screen.dart`

| Check | Result |
|-------|--------|
| Hardcoded value `310123456700003` removed from `TextEditingController` (line 38) | ✅ |
| Grep for `310123456700003` in all production code | ✅ Zero matches (only in reports/docs) |
| Grep for `31012345\|300000000\|3XXXX` in apps/admin + packages/ | ✅ Zero matches |
| `_loadSettings()` reads from DB via `getSettingsByPrefix` (line 61) | ✅ |
| New store with no settings → field shows empty (line 69: `if (settings[_kTaxNumber] != null)`) | ✅ |
| `_saveSettings()` persists user-entered value to DB (line 98) | ✅ |
| No fallback hardcoded value anywhere | ✅ |

**Verdict:** Clean fix. No residual hardcoded VAT numbers. New stores get empty field. Value loads from and saves to database correctly.

---

### C2 + H6: API Keys Encryption (Shipping + WhatsApp)

- **Status:** 🟡 PARTIAL
- **Commits:** `015af78` (shipping), `c087974` (WhatsApp)
- **Files:** `shipping_gateways_screen.dart`, `whatsapp_management_screen.dart`

| Check | Shipping | WhatsApp |
|-------|----------|----------|
| Uses `SecureStorageService.write()` on save | ✅ line 456 | ✅ line 757 |
| Uses `SecureStorageService.read()` on load | ✅ line 400 | ✅ line 121 |
| `obscureText: true` on API key field | ✅ line 427 | ✅ line 655 |
| Masked hint (****XXXX) for existing key | ✅ line 409-412 | ❌ Full key loaded into controller (line 125) |
| No `print`/`debugPrint`/`log` leaking keys | ✅ | ✅ |
| Error handler does not expose key | ✅ | ✅ |
| Native storage: FlutterSecureStorage with `encryptedSharedPreferences` | ✅ | ✅ |

**Issues Found:**

1. **Design inconsistency (WhatsApp):** Line 125 loads the full decrypted API key into `_apiKeyController.text`. While `obscureText: true` masks it visually, the full key resides in the controller. Shipping handles this better with masked hints + empty controller — WhatsApp should follow the same pattern.

2. **No key deletion path:** Both screens check `if (text.isNotEmpty)` before saving. If a user wants to remove/clear a stored key, there is no mechanism to do so.

3. **Web platform concern (pre-existing, not from this fix):** `SecureStorageService._WebStorage` uses XOR obfuscation with per-session random key. API keys stored on web are lost after page refresh (session key regenerates). This is a known architectural limitation documented in code comments (line 49-57 of `secure_storage_service.dart`).

**Verdict:** Core fix works — keys now persist in encrypted storage instead of transient TextEditingControllers. The WhatsApp masking inconsistency is a minor security hygiene issue, not a blocker.

---

### C3: Duplicate Barcode Prevention

- **Status:** 🟡 PARTIAL
- **Commit:** `04f7be9`
- **File:** `apps/admin/lib/screens/products/product_form_screen.dart` (lines 925-947)

| Check | Result |
|-------|--------|
| UI check before save: `getProductByBarcode(barcode, storeId)` | ✅ |
| New product + duplicate barcode → reject + error message | ✅ |
| Edit product + own barcode → allowed (line 930-931) | ✅ |
| Empty barcode → skips check (line 926) | ✅ |
| Barcode trimmed + sanitized (line 919) | ✅ |
| UNIQUE constraint on `barcode` in DB schema (`products_table.dart:48`) | ❌ **Missing** — `text().nullable()()` with no `unique()` |
| Bulk import bypass | ✅ N/A — no bulk import feature found |

**Critical Gaps:**

1. **❌ No database-level enforcement:** `products_table.dart` line 48 defines `barcode` as `text().nullable()()` with no `unique()` modifier. Indexes (`idx_products_barcode`, `idx_products_store_barcode`) are performance indexes, not uniqueness constraints. This means:
   - **Sync bypass:** Products synced from Supabase can create duplicate barcodes locally
   - **Race condition:** Two devices adding the same barcode simultaneously → both pass UI check → both insert
   - **Direct DB access:** Any code path that inserts products without going through `product_form_screen` bypasses the check

2. **⚠️ `getSingleOrNull()` with pre-existing duplicates:** If duplicate barcodes already exist in the DB (from before this fix), `getProductByBarcode()` uses `getSingleOrNull()` which throws when >1 result is found. This would crash the save flow with an unhelpful error.

3. **⚠️ Test theater:** The 4 tests (`barcode_duplicate_check_test.dart`) mock the DAO and verify mock responses. They don't exercise the actual `product_form_screen` widget — no `pumpWidget`, no UI interaction. They confirm that "if mock returns X, test gets X" which is tautological.

**Verdict:** UI-level guard works for the single-device, single-screen scenario. But lack of DB constraint means the fix is bypassable by sync, race conditions, or any non-UI code path. Recommend adding `unique()` modifier to `barcode` column (per store) via migration.

---

### CRITICAL-01: is_super_admin RPC Verification

- **Status:** 🟡 PARTIAL
- **Commit:** `011350e`
- **File:** `super_admin/lib/screens/auth/sa_login_screen.dart` (lines 94-113, 157-174)

| Check | Result |
|-------|--------|
| `is_super_admin()` SQL function exists in Supabase | ✅ Defined in migrations `20260223` + `20260414_v36` |
| Function checks `public.users WHERE id = auth.uid() AND role = 'super_admin'` | ✅ |
| Function uses `SECURITY DEFINER` (bypasses RLS) | ✅ |
| Client calls `client.rpc('is_super_admin')` after auth (line 160) | ✅ |
| RPC returns `true` → allow (line 162) | ✅ |
| RPC returns `false` → deny + logout (line 98-112) | ✅ |
| RPC throws exception → deny + logout (fail-closed) (line 167-172) | ✅ |
| Debug prints only in `kDebugMode` | ✅ |
| Audit logging for all outcomes | ✅ |

**Issues Found:**

1. **⚠️ Race condition with GoRouter:** After `signInWithEmailPassword` succeeds (step 1), `authStateProvider` updates to `authenticated + superAdmin`. The `_AuthNotifier` fires `notifyListeners()`, causing `_guardRedirect` to see an authenticated super admin on `/login` → redirect to `/dashboard`. This redirect can fire **before** the RPC check (step 3) or MFA check (step 4) complete. The user may briefly see the dashboard before being logged out if RPC fails. This is a transient flash rather than a persistent bypass, because the RPC failure triggers `logout()` which re-redirects to login.

2. **⚠️ Router guard is client-side only:** `_guardRedirect` (app_router.dart:87-119) checks `authState.user?.role` — a client-side JWT claim. A user whose role was revoked server-side but still has a valid JWT will pass the router guard until the token expires. The RPC check runs only during login, not on subsequent navigations.

3. **Tests:** Use `MockSupabaseClient` — reasonable for unit tests but no integration test of the actual login flow.

**Verdict:** The RPC verification is correctly implemented with fail-safe behavior. The SQL function exists and is properly deployed. The router guard race condition is a minor UI flash issue, not a persistent bypass. The session-based access limitation is a standard trade-off. Overall: functional security improvement.

---

### CRITICAL-02: MFA/TOTP Implementation

- **Status:** ❌ FAILED
- **Commit:** `0d25a5c`
- **Files:** `sa_mfa_screen.dart` (472 lines), `sa_login_screen.dart` (MFA check), `app_router.dart` (route)

| Check | Result |
|-------|--------|
| MFA screen renders enrollment + verification modes | ✅ |
| Uses Supabase MFA API (`mfa.challenge()` + `mfa.verify()`) | ✅ |
| 6-digit code validation (line 147) | ✅ |
| Failed attempt counter increments (line 190) | ✅ |
| 5-attempt lockout with 30-min duration (lines 44-45, 193-196) | ⚠️ See below |
| Audit logging for MFA success/failure/lockout | ✅ |
| Router guard enforces AAL2 for protected routes | ❌ **MISSING** |
| QR code rendering for enrollment | ❌ Placeholder only |
| Lockout persists across app restart | ❌ In-memory only |

**Critical Findings:**

#### Finding 1: MFA Bypass via Direct Navigation (SEVERITY: CRITICAL)

The GoRouter `_guardRedirect()` function in `app_router.dart` lines 87-119 checks:
```
authState.status == AuthStatus.authenticated
authState.user?.role == UserRole.superAdmin
```

It does **NOT** check `AuthenticatorAssuranceLevels.aal2`. After password auth + RPC verification (steps 1-3 in login flow), the user's auth status is `authenticated` with `superAdmin` role. At this point, before MFA completion, the user can:

1. Open browser DevTools (web) or deep-link (mobile)
2. Navigate directly to `/dashboard`
3. The router guard sees `authenticated + superAdmin` → allows access
4. MFA is bypassed entirely

**Required fix:** Add AAL2 check in `_guardRedirect`:
```dart
if (authState.status == AuthStatus.authenticated) {
  final client = /* get Supabase client */;
  final aal = client.auth.mfa.getAuthenticatorAssuranceLevel();
  if (aal.currentLevel != AuthenticatorAssuranceLevels.aal2) {
    if (path != SuperAdminRoutes.mfa) return SuperAdminRoutes.mfa;
  }
  // ... existing role check ...
}
```

#### Finding 2: Lockout is Client-Side and Bypassable

`_failedAttempts` (line 35) and `_lockoutUntil` (line 36) are **instance variables in widget state**. They reset to zero on:
- Page refresh (web)
- App restart (mobile)
- Navigating away from MFA screen and back

This gives an attacker unlimited brute-force attempts with no real lockout. With a 6-digit TOTP code (1,000,000 possibilities) and 30-second window, and no server-side rate limiting, this is exploitable.

**Required fix:** Store failed attempt counter in server-side (Supabase `audit_log` table query) or at minimum in `SecureStorageService`.

#### Finding 3: QR Code Not Rendered

Lines 297-323 show a grey placeholder icon with text "QR Code" instead of rendering `_totpUri` as an actual QR code. Users must use the manual secret entry (line 324-357) for enrollment. This is functional but poor UX that may lead users to skip MFA setup.

#### Finding 4: Test Theater

All 5 tests (`sa_mfa_screen_test.dart`) verify audit log insertion — none test:
- The MFA verification flow
- Lockout behavior
- AAL2 enforcement
- Enrollment flow
- Code validation logic

The "lockout logic" test (lines 118-136) creates a `DateTime` and checks arithmetic — it doesn't test any actual app code.

**Verdict:** The MFA implementation uses Supabase's API correctly, but the router guard bypass makes it ineffective as a security control. A user can skip MFA entirely after password auth. This needs to be fixed before merge.

---

## Cross-cutting Issues

### Static Analysis

| App | Issues | Severity |
|-----|--------|----------|
| `apps/admin` | 24 (1 warning, 23 info) | Low — mostly `use_build_context_synchronously` and style |
| `super_admin` | 0 | ✅ Clean |

The `shipping_gateways_screen.dart` has 3 `use_build_context_synchronously` warnings (lines 417, 469, 473) introduced by the C2 fix — these are about using context after async gaps with imprecise `mounted` checks. Low risk in practice.

### TODOs/FIXMEs in Fix Commits

None found. ✅

### Hardcoded Secrets in Diffs

None found. Grep for `api_key|secret|password` in diffs shows only variable names and storage key strings, no actual secret values. ✅

---

## Findings Summary

| # | Finding | Severity | Fix Required? | Affected |
|---|---------|----------|---------------|----------|
| F1 | MFA bypass: router guard doesn't check AAL2 | **CRITICAL** | ✅ Must fix before merge | CRITICAL-02 |
| F2 | MFA lockout is in-memory, bypassable by refresh | **HIGH** | ✅ Should fix before merge | CRITICAL-02 |
| F3 | No UNIQUE constraint on barcode in DB | **HIGH** | ⚠️ Should fix (adds migration) | C3 |
| F4 | QR code placeholder (not rendered) | **MEDIUM** | ⚠️ Should fix (add `qr_flutter`) | CRITICAL-02 |
| F5 | WhatsApp loads full API key into controller | **LOW** | Nice to have | C2/H6 |
| F6 | Router guard race condition (transient flash) | **LOW** | Nice to have | CRITICAL-01 |
| F7 | No API key deletion mechanism | **LOW** | Nice to have | C2/H6 |
| F8 | `getSingleOrNull` crashes on pre-existing duplicates | **LOW** | Nice to have | C3 |

---

## Final Recommendation

### ❌ REJECTED — 1 critical issue blocks merge

**Mandatory before merge (F1):**
- Add AAL2 enforcement in `_guardRedirect()` in `app_router.dart`. Without this, the entire MFA implementation (CRITICAL-02) is bypassable by direct URL navigation. This is a 5-10 line fix.

**Strongly recommended before merge (F2, F3):**
- Move MFA lockout counter to persistent storage (server-side preferred, `SecureStorageService` acceptable)
- Add `unique()` constraint on `(storeId, barcode)` in `products_table.dart` via database migration

**Can be deferred to next sprint (F4-F8):**
- QR code rendering with `qr_flutter`
- WhatsApp key masking consistency
- Router guard race condition
- API key deletion UI
- Pre-existing duplicate barcode handling

---

*Report generated by independent verification session. No production code was modified.*
