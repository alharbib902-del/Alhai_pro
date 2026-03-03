# Fix 01 — Compilation Errors & Warnings Log

**Date:** 2026-03-01
**Before:** 16 errors, 69 warnings (149 total issues)
**After:** 0 errors, 0 warnings (64 info-only issues)

---

## Errors Fixed (16 → 0)

### 1. Ambiguous Extension Member Access (7 errors)

**Root Cause:** Both `AlhaiContextExtensions` (from `alhai_design_system`) and `ResponsiveExtension` (from `alhai_shared_ui/responsive_builder.dart`) define `isMobile`, `isDesktop`, `isTablet`, `screenWidth`, `screenHeight` on `BuildContext`. Files importing `alhai_shared_ui` get both, causing ambiguity.

**Fix:** Added `hide ResponsiveExtension` to the `alhai_shared_ui` import in affected files.

| File | Lines |
|------|-------|
| `lib/screens/customers/customer_ledger_screen.dart` | 137 |
| `lib/screens/products/cashier_categories_screen.dart` | 121, 122, 323, 335 |
| `lib/screens/reports/custom_report_screen.dart` | 240, 241 |

### 2. int/double Type Mismatch (9 errors)

**Root Cause:** `InventoryMovementsTableCompanion.insert()` and `PurchaseItemsTableCompanion.insert()` expect `double` for `qty`, `previousQty`, `newQty` fields, but code passed `int` values from `int.tryParse()` or `stockQty` (which is `int`).

**Fix:** Added `.toDouble()` to int values passed to Drift companion constructors.

| File | Lines | Fields Fixed |
|------|-------|--------------|
| `lib/screens/inventory/add_inventory_screen.dart` | 599-601 | qty, previousQty, newQty |
| `lib/screens/inventory/edit_inventory_screen.dart` | 645-647 | qty, previousQty, newQty |
| `lib/screens/purchases/cashier_purchase_request_screen.dart` | 784, 786 | qty, total |
| `test/helpers/test_factories.dart` | 130 | qty |

### 3. Linter-Revealed Errors (5 additional errors found after initial fixes)

**a. `navigatorObservers` on `MaterialApp.router` (1 error)**
- `lib/main.dart:251` — `MaterialApp.router` doesn't support `navigatorObservers`
- **Fix:** Moved `SentryNavigatorObserver` to `GoRouter(observers: [...])` in `lib/router/cashier_router.dart`

**b. `addBreadcrumb` undefined method (4 errors)**
- Missing `import '../../core/services/sentry_service.dart'` in 4 files
- **Fix:** Added the import to:
  - `lib/screens/payment/split_receipt_screen.dart`
  - `lib/screens/shifts/cash_in_out_screen.dart`
  - `lib/screens/shifts/shift_close_screen.dart`
  - `lib/screens/shifts/shift_open_screen.dart`

---

## Warnings Fixed (69 → 0)

### 1. `unnecessary_non_null_assertion` (67 warnings)

**Root Cause:** `AppLocalizations.of(context)` returns non-nullable `AppLocalizations`, making `!` unnecessary.

**Fix:** Removed `!` from `AppLocalizations.of(context)!` in 45 files across all screen directories.

### 2. `unnecessary_null_comparison` (1 warning)

**Root Cause:** `cashier_shell.dart:138` — `if (l10n == null) return item.label;` where `l10n` is assigned from `AppLocalizations.of(context)` (non-nullable).

**Fix:** Removed the dead null-check branch.

### 3. `unused_import` (1 warning)

**Root Cause:** `lib/main.dart` imported `sentry_flutter` directly, but after moving `SentryNavigatorObserver` to the router, the import became unused.

**Fix:** Removed unused `import 'package:sentry_flutter/sentry_flutter.dart'`.

---

## Files Modified (52 total)

- `lib/main.dart`
- `lib/router/cashier_router.dart`
- `lib/ui/cashier_shell.dart`
- `lib/screens/customers/` (5 files)
- `lib/screens/inventory/` (6 files)
- `lib/screens/offers/` (3 files)
- `lib/screens/payment/` (3 files)
- `lib/screens/products/` (5 files)
- `lib/screens/purchases/` (2 files)
- `lib/screens/reports/` (2 files)
- `lib/screens/sales/` (4 files)
- `lib/screens/settings/` (10 files)
- `lib/screens/shifts/` (4 files)
- `test/helpers/test_factories.dart`

## Remaining (info-only, not blocking)

- 61x `deprecated_member_use` — `LazyScreen` in router (pre-existing, not in scope)
- 3x `prefer_const_declarations` — test helpers (pre-existing, not in scope)
