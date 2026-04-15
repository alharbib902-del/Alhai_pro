# Phase 4 Fix Report — Admin App (`apps/admin`)

**Branch:** `fix/phase4-blockers`
**Date:** 2026-04-15
**Source:** `acceptance_reports/phase4/admin_pos/ACCEPTANCE_REPORT_PHASE4_ADMIN_POS.md`

## Summary

| Metric | Value |
|--------|-------|
| Total defects | 10 (3 CRITICAL + 7 HIGH) |
| Fixed | 8 |
| Deferred | 2 (H4, H7 — require backend/infrastructure) |
| Tests before | 361 |
| Tests after | 365 (+4 new) |
| Analyzer errors | 0 |
| Analyzer warnings | 0 (24 pre-existing infos) |

## Fix Details

| # | ID | Severity | Title | Status | Commit | Files Changed |
|---|-----|----------|-------|--------|--------|---------------|
| 1 | C1 | CRITICAL | Remove hardcoded VAT number | FIXED | `9592c4c` | `tax_settings_screen.dart` |
| 2 | C2 | CRITICAL | Encrypt shipping API keys | FIXED | `015af78` | `shipping_gateways_screen.dart` |
| 3 | C3 | CRITICAL | Prevent duplicate barcode | FIXED | `04f7be9` | `product_form_screen.dart`, `barcode_duplicate_check_test.dart` (+4 tests) |
| 4 | H1 | HIGH | Runtime permission enforcement | FIXED | `e76ff50` | `permission_provider.dart` (new), `permission_guard.dart` (new), 4 screens |
| 5 | H2 | HIGH | ZATCA submit button logic | FIXED | `c4be926` | `zatca_compliance_screen.dart` |
| 6 | H3 | HIGH | CSID certificate real status | FIXED | `c4be926` | `zatca_compliance_screen.dart` |
| 7 | H4 | HIGH | Product image upload | DEFERRED | `5b7d28c` | `product_form_screen.dart` (documented) |
| 8 | H5 | HIGH | Price change audit trail | FIXED | `f2b372a` | `product_form_screen.dart` |
| 9 | H6 | HIGH | WhatsApp API key encryption | FIXED | `c087974` | `whatsapp_management_screen.dart` |
| 10 | H7 | HIGH | New device OTP verification | DEFERRED | `d441dbb` | `security_settings_screen.dart` (documented) |

## Fix Descriptions

### C1 — Remove Hardcoded VAT Number (CRITICAL)
**Problem:** Tax number `310123456700003` was hardcoded as the default value in `TextEditingController`.
**Fix:** Changed to empty `TextEditingController()`. The `_loadSettings()` method already loads the real tax number from the database.

### C2 — Encrypt Shipping API Keys (CRITICAL)
**Problem:** Shipping gateway API keys were entered in a dialog but never persisted — controllers were local to the dialog, and the save button was a no-op.
**Fix:** API keys and account numbers now persist to `FlutterSecureStorage` via `SecureStorageService`. Existing keys are loaded and shown as masked hints (`****XXXX`).

### C3 — Prevent Duplicate Barcode (CRITICAL)
**Problem:** No uniqueness check when saving a product with a barcode that already exists for another product.
**Fix:** Before insert/update, calls `productsDao.getProductByBarcode()` to check for duplicates. If a duplicate is found (and it's not the same product being edited), shows an error snackbar with the conflicting product's name. Added 4 unit tests.

### H1 — Runtime Permission Enforcement (HIGH)
**Problem:** Sensitive screens lacked runtime permission checks — only GoRouter-level guards existed.
**Fix:** Created reusable infrastructure:
- `permission_provider.dart` — derives permission list from user role
- `permission_guard.dart` — widget that blocks access with "Access Denied" screen
- Applied to 4 screens: Tax Settings, Product Form, Users Management, ZATCA Compliance

### H2 — ZATCA Submit Button Logic (HIGH)
**Problem:** Submit button showed "Coming Soon" regardless of CSID certificate status.
**Fix:** Button is now disabled when no certificate is registered or certificate is expired. Label dynamically shows: "Register CSID first" / "Certificate expired — renew to submit" / "Submit to Authority".

### H3 — CSID Certificate Real Status (HIGH)
**Problem:** Certificate status always showed "Valid" without checking actual certificate state.
**Fix:** Loads real certificate info from `CertificateStorage`. Shows actual status: valid with expiry date (green), expiring soon with days remaining (yellow), expired (red), or not registered (warning). Icons change color accordingly.

### H4 — Product Image Upload (DEFERRED)
**Problem:** Image section shows placeholder without actual upload capability.
**Why deferred:** Requires Supabase Storage bucket configuration (infrastructure, not code). `image_picker` is in pubspec, DB has image columns, but no bucket is provisioned.
**Documented:** Implementation plan added as code comment in `product_form_screen.dart`.

### H5 — Price Change Audit Trail (HIGH)
**Problem:** No audit trail when product prices change.
**Fix:** After `updateProduct()`, compares old and new prices. If changed, logs to `audit_log` table via `AuditLogDao.log()` with `AuditAction.priceChange`, capturing old/new values and user info.

### H6 — WhatsApp API Key Encryption (HIGH)
**Problem:** WhatsApp API key and instance ID were entered in text fields but the save button only showed a snackbar — never actually persisted.
**Fix:** API key and instance ID now persist to `FlutterSecureStorage` via `SecureStorageService`. Existing values are loaded on screen init.

### H7 — New Device OTP Verification (DEFERRED)
**Problem:** No OTP verification when logging in from an unrecognized device.
**Why deferred:** Requires backend RPC functions (`is_known_device`, `register_device`), cross-package auth changes in `alhai_auth` (new `DeviceVerificationService`), and new UI screens. Estimated effort: 2-3 days.
**Documented:** Full implementation plan added as code comment in `security_settings_screen.dart`. Notes existing infrastructure: `active_sessions.device_id`, `WhatsAppOtpService`, `OtpService`.

## New Files Created

| File | Purpose |
|------|---------|
| `lib/core/providers/permission_provider.dart` | Role-based permission derivation |
| `lib/core/widgets/permission_guard.dart` | Reusable access-denied guard widget |
| `test/screens/products/barcode_duplicate_check_test.dart` | 4 tests for barcode uniqueness |

## Commits (chronological)

```
9592c4c fix(admin): remove hardcoded VAT number from tax settings (C1)
015af78 fix(admin): encrypt shipping API keys using FlutterSecureStorage (C2)
04f7be9 fix(admin): prevent duplicate barcode on product creation (C3)
e76ff50 fix(admin): enforce runtime permission checks on sensitive screens (H1)
c4be926 fix(admin): clarify ZATCA submission status and show actual CSID expiry (H2+H3)
5b7d28c docs(admin): document product image implementation plan (H4)
f2b372a fix(admin): log price changes to audit trail (H5)
c087974 fix(admin): encrypt WhatsApp API key storage (H6)
d441dbb docs(admin): document new device OTP implementation plan (H7)
349d798 fix(admin): add alhai_zatca dependency and remove unused import
```
