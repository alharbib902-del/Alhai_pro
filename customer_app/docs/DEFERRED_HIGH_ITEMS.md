# Deferred HIGH Items — Customer App Phase 5

## H3: OTP Rate Limiting

**Status:** DEFERRED — requires Supabase project configuration

**Problem:** Client-side 5-attempt lockout resets on app kill. Attacker
can brute-force OTP (1M combinations for 6-digit code).

**Fix plan:**
1. Verify Supabase Auth has server-side rate limiting enabled in
   project settings (Authentication > Rate Limits)
2. If not configured: set max 5 OTP attempts per phone per hour
3. Add IP-based rate limiting at edge (Cloudflare/WAF)
4. Consider moving to WhatsApp OTP with WasenderAPI rate limits

**Effort:** 2-3 hours (config) + backend changes

---

## H5: Account Deletion (PDPL Compliance)

**Status:** DEFERRED — requires backend RPC + UI design

**Problem:** Saudi PDPL (Personal Data Protection Law) requires ability
to delete personal data. App Store and Play Store both require account
deletion functionality. Currently only logout exists.

**Fix plan:**
1. Create Supabase RPC: `delete_user_account()`
   - Delete user data from: addresses, cart, preferences
   - Anonymize orders (keep for legal/tax records, remove PII)
   - Revoke auth session and delete auth.users entry
2. Add UI in profile screen:
   - "حذف الحساب" button (red, danger style)
   - Confirmation dialog with password/OTP re-entry
   - Warning about permanent deletion
3. Clear local data (SharedPreferences, SecureStorage)
4. Navigate to login screen after deletion

**Effort:** 1 day (RPC + UI + tests)

---

## H7: English Localization

**Status:** DEFERRED — full l10n migration project

**Problem:** `en` is declared in `supportedLocales` but no `.arb` files
exist. Some screens mix Arabic hardcoded strings with Material defaults,
causing inconsistent UI for English-language device users.

**Fix plan:**
1. Option A (quick): Remove `en` from `supportedLocales` until ready
2. Option B (proper): Create full l10n infrastructure:
   - Extract all Arabic strings to `lib/l10n/app_ar.arb`
   - Add English translations in `lib/l10n/app_en.arb`
   - Use `AppLocalizations.of(context)` throughout all screens
   - Test RTL/LTR switching
   - Update Material delegates

**Effort:** 3-5 days (major refactor touching every screen)
