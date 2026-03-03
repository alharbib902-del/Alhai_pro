# Fix 03 — Idempotency Keys + Double-Press Protection

**Date:** 2026-03-01
**Status:** Complete
**Analysis time:** ~10 min | **Implementation time:** ~15 min

---

## Summary

Replaced all `DateTime.now().millisecondsSinceEpoch`-based IDs with UUID v4 to prevent duplicate transactions. Added double-press protection to the only unprotected submit flow.

## Changes

### 1. UUID Import + ID Replacement (13 files)

All `DateTime.now().millisecondsSinceEpoch` usages for record IDs replaced with `const Uuid().v4()`:

| # | File | Old Pattern | Line |
|---|------|-------------|------|
| 1 | `lib/screens/customers/new_transaction_screen.dart` | `'TXN-${DateTime.now()...}'` | 760 |
| 2 | `lib/screens/inventory/wastage_screen.dart` | `'WST-${DateTime.now()...}'` | 610 |
| 3 | `lib/screens/products/quick_add_product_screen.dart` | `'PRD-${DateTime.now()...}'` | 599 |
| 4 | `lib/screens/customers/customer_ledger_screen.dart` | `'ADJ-${DateTime.now()...}'` | 1009 |
| 5 | `lib/screens/inventory/transfer_inventory_screen.dart` | `'TRF-${DateTime.now()...}'` | 573 |
| 6 | `lib/screens/inventory/add_inventory_screen.dart` | `'MOV-${DateTime.now()...}'` | 597 |
| 7 | `lib/screens/inventory/edit_inventory_screen.dart` | `'MOV-${DateTime.now()...}'` | 652 |
| 8 | `lib/screens/inventory/remove_inventory_screen.dart` | `'MOV-${DateTime.now()...}'` | 555 |
| 9 | `lib/screens/inventory/stock_take_screen.dart` | `'STK-${...}-${hashCode}'` (loop) | 507 |
| 10 | `lib/screens/settings/add_payment_device_screen.dart` | `DateTime.now()...toString()` | 110 |
| 11 | `lib/screens/purchases/cashier_purchase_request_screen.dart` | `'PO-${DateTime.now()...}'` | 753 |
| 12 | `lib/screens/settings/printer_settings_screen.dart` | `DateTime.now()...toString()` | 280 |
| 13 | `lib/data/repositories/local_products_repository.dart` | `DateTime.now()...toString()` | 117 |

- `uuid` package was already in `pubspec.yaml` (v4.4.0)
- Added `import 'package:uuid/uuid.dart';` to 12 files (purchase_request already had it)

### 2. Double-Press Protection — `customer_ledger_screen.dart`

This was the **only** screen without a processing flag. All other submit screens already had `_isSaving`/`_isSubmitting`/`_isSending` flags with:
- Button `onPressed: _flag ? null : _handler`
- `CircularProgressIndicator` shown during processing
- Flag reset in `finally` block

**Added to customer_ledger_screen.dart:**
- `bool _isAdjusting = false;` state field
- FAB disabled (`onPressed: null`) while `_isAdjusting` is true
- FAB shows `CircularProgressIndicator` during processing
- `setState(() => _isAdjusting = true)` at start of `_handleSaveAdjustment()`
- `finally { if (mounted) setState(() => _isAdjusting = false); }` to reset

### Already Protected Screens (verified, no changes needed)

| Screen | Flag | Handler |
|--------|------|---------|
| `create_invoice_screen.dart` | `_isSubmitting` | `_submitInvoice()` |
| `new_transaction_screen.dart` | `_isSubmitting` | `_submitTransaction()` |
| `wastage_screen.dart` | `_isSaving` | `_saveWastage()` |
| `add_inventory_screen.dart` | `_isSaving` | `_saveInventory()` |
| `edit_inventory_screen.dart` | `_isSaving` | `_saveAdjustment()` |
| `remove_inventory_screen.dart` | `_isSaving` | `_removeInventory()` |
| `stock_take_screen.dart` | `_isSaving` | `_finalizeCount()` |
| `transfer_inventory_screen.dart` | `_isSaving` | `_submitTransfer()` |
| `quick_add_product_screen.dart` | `_isSaving` | `_saveProduct()` |
| `exchange_screen.dart` | `_isSubmitting` | `_submitExchange()` |
| `split_refund_screen.dart` | `_isSubmitting` | `_submitRefund()` |
| `cashier_purchase_request_screen.dart` | `_isSending` | `_sendRequest()` |
| `add_payment_device_screen.dart` | `_isSaving` | `_saveDevice()` |
| `apply_interest_screen.dart` | `_isApplying` | `_applyInterest()` |

## Verification

- `flutter analyze lib/` — 0 errors, 0 warnings (61 pre-existing info notices)
- `grep -rn "DateTime.now().millisecondsSinceEpoch" lib/` — 0 matches remaining
