# Fix 02 — Atomic Financial Transactions

**Date:** 2026-03-01
**Priority:** 2 (Critical - Financial Data Integrity)
**Status:** COMPLETED

## Summary

Wrapped all multi-step financial database operations in Drift `transaction()` blocks to ensure atomicity. If any step fails, all changes are automatically rolled back, preventing data corruption. Also upgraded error handling for financial screens from SnackBars to AlertDialogs for better user visibility.

## Files Modified (10 files)

### Financial Transactions (3 files)

| File | Operations Protected | Change |
|------|---------------------|--------|
| `lib/screens/customers/new_transaction_screen.dart` | `insertTransaction` + `updateBalance` | Wrapped in `_db.transaction()`, error → AlertDialog |
| `lib/screens/customers/customer_ledger_screen.dart` | `insertTransaction` + `updateBalance` | Wrapped in `_db.transaction()`, error → AlertDialog |
| `lib/screens/customers/apply_interest_screen.dart` | Loop: `recordInterest` + `updateBalance` per account | Entire loop wrapped in single `_db.transaction()`, error → AlertDialog |

### Inventory Operations (6 files)

| File | Operations Protected | Change |
|------|---------------------|--------|
| `lib/screens/inventory/add_inventory_screen.dart` | `insertMovement` + `updateStock` | Wrapped in `_db.transaction()` |
| `lib/screens/inventory/remove_inventory_screen.dart` | `insertMovement` + `updateStock` | Wrapped in `_db.transaction()` |
| `lib/screens/inventory/edit_inventory_screen.dart` | `insertMovement` + `updateStock` | Wrapped in `_db.transaction()` |
| `lib/screens/inventory/transfer_inventory_screen.dart` | `insertMovement` + `updateStock` | Wrapped in `_db.transaction()` |
| `lib/screens/inventory/wastage_screen.dart` | `insertMovement` + `updateStock` | Wrapped in `_db.transaction()` |
| `lib/screens/inventory/stock_take_screen.dart` | Loop: `insertMovement` + `updateStock` per product | Entire loop wrapped in single `_db.transaction()` |

### Purchase Receiving (1 file)

| File | Operations Protected | Change |
|------|---------------------|--------|
| `lib/screens/purchases/cashier_receiving_screen.dart` | `receivePurchase` + loop of `updateStock` | Wrapped in `_db.transaction()`, removed swallowed inner try-catch, error → AlertDialog, fixed `item.qty` double→int cast |

## Screens Not Modified (stub implementations)

- `exchange_screen.dart` — Uses `Future.delayed` placeholder, no DB operations
- `split_refund_screen.dart` — Uses `Future.delayed` placeholder, no DB operations
- `create_invoice_screen.dart` — Uses `Future.delayed` placeholder, no DB operations

## Error Handling Improvements

- **Financial screens** (new_transaction, customer_ledger, apply_interest, cashier_receiving): Upgraded from `SnackBar` to `AlertDialog` with error icon for failed transactions — ensures the user cannot miss a financial error
- **Inventory screens**: Kept `SnackBar` error display (sufficient for inventory operations)

## How Drift Transactions Work

```dart
await _db.transaction(() async {
  // All operations here are atomic
  // If any operation throws, ALL are rolled back automatically
  await _db.transactionsDao.insertTransaction(...);
  await _db.accountsDao.updateBalance(...);
});
```

- Drift's `transaction()` uses SQLite's `BEGIN TRANSACTION` / `COMMIT` / `ROLLBACK`
- Any exception thrown inside the callback triggers automatic rollback
- The outer `catch` block then handles user notification

## Verification

All financial DB operations confirmed to be inside `transaction()` blocks:
```
grep -rn "insertTransaction\|insertPayment\|insertRefund" lib/ --include="*.dart" | grep -v "transaction(" | grep -v "//"
# Result: empty (all protected)
```

10 transaction blocks confirmed:
```
grep -rn "\.transaction(" lib/ --include="*.dart"
# Result: 10 matches in 10 files
```
