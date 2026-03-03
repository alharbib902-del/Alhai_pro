# Fix 12 — Security Fixes Log

## Date: 2026-03-01 (Phase 1) + 2026-03-01 (Phase 2 — Deep Audit)

---

### 1. Session Timeout (15 min inactivity auto-lock)

**Created:** `lib/services/session_manager.dart`
- `SessionManager` class with 15-minute inactivity timer
- Resets on any pointer interaction (taps, mouse movement)
- Calls `authNotifier.logout()` on timeout (router guard redirects to login)
- `SessionTimeoutWrapper` widget wraps the entire app in `main.dart`
- Listens for app lifecycle changes (resume resets timer)

**Modified:** `lib/main.dart`
- Wrapped `MaterialApp.router` child with `SessionTimeoutWrapper`

---

### 2. Multi-tenancy Leak Fixes (storeId filters)

**Phase 1 fixes (previous session):**
- `returns_dao.dart` — `getReturnsBySaleId()` now requires `storeId` parameter
- `sales_dao.dart` — `getUnsyncedSales()` accepts optional `storeId` filter
- `products_dao.dart` — `getUnsyncedProducts()` accepts optional `storeId` filter
- `inventory_dao.dart` — `getUnsyncedMovements()` accepts optional `storeId` filter
- `whatsapp_messages_dao.dart` — `getAllMessages()` now requires `storeId` parameter

**Phase 2 fixes (this session — deep DAO audit):**

| DAO | Method | Fix |
|-----|--------|-----|
| `customers_dao.dart` | `getCustomerWithStats()` | Added required `storeId` param + `AND store_id = ?` to SQL |
| `sale_items_dao.dart` | `getProductSalesCount()` | Added required `storeId` param + `INNER JOIN sales` with `store_id` filter |
| `transactions_dao.dart` | `getAccountTransactions()` | Added optional `storeId` param with filter |
| `transactions_dao.dart` | `getAccountTransactionsByType()` | Added optional `storeId` param with filter |
| `transactions_dao.dart` | `getTransactionsInRange()` | Added optional `storeId` param with filter |
| `inventory_dao.dart` | `getMovementsByProduct()` | Added optional `storeId` param with filter |
| `orders_dao.dart` | `getOrderByNumber()` | Added optional `storeId` param with filter |

**Caller updates:**
- `product_detail_screen.dart` — passes `storeId` to `getProductSalesCount()` and `getMovementsByProduct()`
- `sale_items_dao_test.dart` — updated test to insert sale records and pass `storeId`

**Not changed (UUID-based getById methods):** `getProductById`, `getSaleById`, `getOrderById`, `getCustomerById` etc. use globally-unique UUIDs — no cross-tenant risk.

---

### 3. LIMIT Added to Heavy Queries

**Phase 1 (previous session):**
- `products_dao.dart` — `getAllProducts(limit: 5000)`, `searchProducts()` fallback `..limit(200)`, `getLowStockProducts()` `LIMIT 500`
- `sales_dao.dart` — `getAllSales(limit: 1000)`, `getSalesByDate(limit: 1000)`, `getSalesByDateRange(limit: 5000)`
- `returns_dao.dart` — `getAllReturns(limit: 1000)`, `getReturnsByDateRange(limit: 5000)`

**Phase 2 (this session — comprehensive LIMIT audit):**

| DAO | Method | Limit |
|-----|--------|-------|
| `customers_dao.dart` | `getAllCustomers()` | 500 |
| `customers_dao.dart` | `getActiveCustomers()` | 500 |
| `sales_dao.dart` | `getUnsyncedSales()` | 500 |
| `orders_dao.dart` | `getOrders()` | 500 |
| `orders_dao.dart` | `getOrdersByStatus()` | 500 |
| `orders_dao.dart` | `getPendingOrders()` | 200 |
| `transactions_dao.dart` | `getAccountTransactions()` | 200 |
| `transactions_dao.dart` | `getAccountTransactionsByType()` | 200 |
| `transactions_dao.dart` | `getTransactionsInRange()` | 500 |
| `inventory_dao.dart` | `getMovementsByProduct()` | 200 |
| `inventory_dao.dart` | `getUnsyncedMovements()` | 500 |
| `products_dao.dart` | `getUnsyncedProducts()` | 500 |
| `accounts_dao.dart` | `getAllAccounts()` | 500 |
| `accounts_dao.dart` | `getReceivableAccounts()` | 500 |
| `accounts_dao.dart` | `getPayableAccounts()` | 500 |
| `suppliers_dao.dart` | `getAllSuppliers()` | 500 |
| `suppliers_dao.dart` | `getActiveSuppliers()` | 500 |
| `purchases_dao.dart` | `getAllPurchases()` | 500 |
| `purchases_dao.dart` | `getPurchasesByStatus()` | 500 |
| `discounts_dao.dart` | `getAllDiscounts()` | 200 |
| `discounts_dao.dart` | `getActiveDiscounts()` | 200 |
| `discounts_dao.dart` | `getAllCoupons()` | 200 |
| `discounts_dao.dart` | `getAllPromotions()` | 200 |
| `expenses_dao.dart` | `getAllExpenses()` | 500 |
| `expenses_dao.dart` | `getExpensesByDateRange()` | 1000 |
| `shifts_dao.dart` | `getShiftsByDateRange()` | 500 |

---

### 4. Demo-store Fallback Removed

**16 files fixed** — replaced `?? 'demo-store'` with `!` (null assertion):
- `apply_interest_screen.dart`, `create_invoice_screen.dart`, `customer_ledger_screen.dart`
- `new_transaction_screen.dart`, `cashier_receiving_screen.dart`, `cashier_purchase_request_screen.dart`
- `split_refund_screen.dart`, `edit_inventory_screen.dart`, `add_inventory_screen.dart`
- `wastage_screen.dart`, `stock_take_screen.dart`, `remove_inventory_screen.dart`
- `transfer_inventory_screen.dart`, `cash_in_out_screen.dart`, `edit_price_screen.dart`
- `exchange_screen.dart`

**9 files fixed** — replaced `?? kDefaultStoreId` with `!`:
- `add_payment_device_screen.dart`, `backup_screen.dart` (x3), `payment_devices_screen.dart`
- `receipt_settings_screen.dart` (x2), `tax_settings_screen.dart` (x2)

**1 file fixed** — `local_products_repository.dart`:
- Replaced `kDefaultStoreId` fallback with `StateError` throw

---

### 5. Logout with Full Session Cleanup

**Created:** `lib/services/logout_service.dart`
- `performFullLogout()` function that:
  1. Stops inactivity timer (`sessionManagerProvider.dispose()`)
  2. Clears store selection (`currentStoreIdProvider = null`)
  3. Clears session-related SharedPreferences
  4. Calls `authNotifier.logout()` (clears tokens, Supabase, secure storage)

---

### 6. debugPrint Protected in Release Builds

All `debugPrint`/`print()` calls in `lib/` are guarded with `if (kDebugMode)`:
- `sentry_service.dart` — 3 calls
- `main.dart` — 2 calls
- `auto_print_setup.dart` — 2 calls
- `printing_providers.dart` — 1 call

---

### 7. debugLogDiagnostics Guarded in GoRouter

**Modified:** `lib/router/cashier_router.dart`
- `debugLogDiagnostics: kDebugMode` — only logs in debug builds

---

## Files Modified (Phase 2)

### Shared packages (`packages/alhai_database/lib/src/daos/`):
- `customers_dao.dart` — storeId + LIMIT
- `sale_items_dao.dart` — storeId
- `transactions_dao.dart` — storeId + LIMIT
- `inventory_dao.dart` — storeId + LIMIT
- `orders_dao.dart` — storeId + LIMIT
- `sales_dao.dart` — LIMIT on unsynced
- `products_dao.dart` — LIMIT on unsynced
- `accounts_dao.dart` — LIMIT
- `suppliers_dao.dart` — LIMIT
- `purchases_dao.dart` — LIMIT
- `discounts_dao.dart` — LIMIT
- `expenses_dao.dart` — LIMIT
- `shifts_dao.dart` — LIMIT

### Shared UI:
- `product_detail_screen.dart` — updated callers for new storeId params

### Tests:
- `sale_items_dao_test.dart` — updated for new storeId param

---

## Phase 3 — Final Demo-Store Cleanup (2026-03-01)

### Additional demo-store fallbacks fixed in shared packages:

1. **`packages/alhai_database/lib/src/repositories/local_products_repository.dart:101`**
   - Was: `final storeId = defaultStoreId ?? 'store_demo_001';`
   - Now: throws `StateError` if `defaultStoreId == null`

2. **`packages/alhai_pos/lib/src/screens/pos/pos_screen.dart:334`**
   - Was: `final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';`
   - Now: throws `StateError` if provider returns null
