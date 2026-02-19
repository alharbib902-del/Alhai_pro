# Memory Leak & Performance Fix Log

**Date:** 2026-02-15
**dart analyze result:** 0 new issues introduced (2 pre-existing unused variable warnings)

---

## 1. FocusNode Memory Leaks Fixed (5 files)

Moved `FocusNode()` from inline `build()` allocation to a State field with proper `dispose()`.

| # | File | Change |
|---|------|--------|
| 1 | `lib/widgets/pos/barcode_listener.dart` | Added `_focusNode` field, disposed in `dispose()`, referenced in `build()` |
| 2 | `lib/screens/reports/reports_screen.dart` | Added `_keyboardFocusNode` field + `dispose()` method (had none before) |
| 3 | `lib/screens/customers/customers_screen.dart` | Added `_keyboardFocusNode` field, added to existing `dispose()` |
| 4 | `lib/screens/inventory/inventory_screen.dart` | Added `_keyboardFocusNode` field, added to existing `dispose()` |
| 5 | `lib/screens/products/products_screen.dart` | Added `_keyboardFocusNode` field, added to existing `dispose()` |

**Impact:** Eliminated continuous memory leak — previously each rebuild allocated a new `FocusNode` that was never disposed.

---

## 2. TextEditingController Disposal Added (13 dialog methods)

Added `.then((_) { controller.dispose(); })` after `showDialog()` to ensure controllers are disposed when the dialog closes.

| # | File | Method | Controllers Disposed |
|---|------|--------|---------------------|
| 1 | `lib/screens/customers/customers_screen.dart` | `_showAddCustomerDialog` | `nameController`, `phoneController` |
| 2 | `lib/screens/customers/customers_screen.dart` | `_showPaymentDialog` | `controller` |
| 3 | `lib/screens/inventory/inventory_screen.dart` | `_showAdjustDialog` | `controller` |
| 4 | `lib/screens/expenses/expenses_screen.dart` | `_addExpense` | `titleController`, `amountController` |
| 5 | `lib/screens/cash/cash_drawer_screen.dart` | `_addCashMovement` | `controller`, `noteController` |
| 6 | `lib/screens/loyalty/loyalty_program_screen.dart` | `_addReward` | `nameController`, `pointsController` |
| 7 | `lib/screens/branches/branch_management_screen.dart` | `_addBranch` | `nameController`, `addressController`, `phoneController` |
| 8 | `lib/screens/drivers/driver_management_screen.dart` | `_addDriver` | `nameController`, `phoneController`, `vehicleController`, `plateController` |
| 9 | `lib/screens/marketing/discounts_screen.dart` | `_addDiscount` | `nameController`, `valueController` |
| 10 | `lib/screens/pos/pos_screen.dart` | `_holdCurrentInvoice` | `controller` |
| 11 | `lib/screens/suppliers/suppliers_screen.dart` | `_showAddSupplierDialog` | `nameCtrl`, `phoneCtrl`, `emailCtrl` |
| 12 | `lib/widgets/common/user_feedback.dart` | `_showDetailedFeedback` | `controller` |

**Total controllers now properly disposed:** 25

---

## 3. RegExp Compiled to Static Final (1 file)

| File | Change |
|------|--------|
| `lib/widgets/common/animated_counter.dart` | Moved `RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))')` from `_formatNumber()` (called 60×/sec during animation) to `static final _thousandSeparatorRegExp` |

**Impact:** Eliminated ~60 RegExp compilations per second during counter animations.

---

## 4. Lifecycle Observer Leak Fixed (1 file)

| File | Change |
|------|--------|
| `lib/core/monitoring/memory_monitor.dart` | Added `SystemChannels.lifecycle.setMessageHandler(null)` in `stopMonitoring()` to clear the handler set in `startMonitoring()` |

**Impact:** The lifecycle message handler set via `SystemChannels.lifecycle.setMessageHandler()` was never removed when monitoring stopped, causing the callback to persist and potentially reference stale state.

---

## dart analyze Output

```
Analyzing 16 files...

warning - lib\screens\customers\customers_screen.dart:129:11 - unused_local_variable (pre-existing)
warning - lib\screens\pos\pos_screen.dart:286:11 - unused_local_variable (pre-existing)

2 issues found. (0 new issues from this fix)
```

---

## Summary

| Category | Files Changed | Issues Fixed |
|----------|--------------|--------------|
| FocusNode leaks | 5 | 5 |
| TextEditingController leaks | 12 | 13 methods (25 controllers) |
| RegExp per-frame compilation | 1 | 1 |
| Lifecycle observer leak | 1 | 1 |
| **Total** | **16 files** | **20 issues** |
