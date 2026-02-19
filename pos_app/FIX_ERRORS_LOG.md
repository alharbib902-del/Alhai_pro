# Fix: Silent Error Handling in 11 Screens

**Date:** 2026-02-15
**Issue:** Screens silently swallowed errors, showing blank content with no user feedback or retry option.
**Fix:** Added `AppErrorState` widget with retry callback to all affected screens.

---

## Pattern Applied

### Type A: Manual-load screens (setState pattern)

**Before:**
```dart
bool _isLoading = true;

Future<void> _loadData() async {
  try {
    // load data...
    setState(() => _isLoading = false);
  } catch (e) {
    setState(() => _isLoading = false);  // SILENT FAILURE
  }
}

// build: only checks _isLoading
```

**After:**
```dart
bool _isLoading = true;
String? _error;                          // NEW

Future<void> _loadData() async {
  setState(() { _isLoading = true; _error = null; });  // RESET
  try {
    // load data...
    setState(() => _isLoading = false);
  } catch (e) {
    setState(() { _isLoading = false; _error = e.toString(); });  // CAPTURE
  }
}

// build: checks _isLoading, then _error, then content
child: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _error != null
    ? AppErrorState.general(message: _error, onRetry: _loadData)  // NEW
    : SingleChildScrollView(...)
```

### Type B: Provider-based screens (Riverpod .when pattern)

**Before:**
```dart
ref.watch(provider).when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Center(child: Text('خطأ: $e')),  // PLAIN TEXT
  data: (data) => ...,
)
```

**After:**
```dart
ref.watch(provider).when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => AppErrorState.general(              // RICH UI
    message: e.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (data) => ...,
)
```

---

## Screens Fixed

### 1. `lib/screens/suppliers/suppliers_screen.dart`
- **Type:** Provider-based (Riverpod `.when`)
- **Provider:** `suppliersListProvider`
- **Change:** Replaced `Center(child: Text('خطأ: $e'))` with `AppErrorState.general(onRetry: () => ref.invalidate(suppliersListProvider))`
- **Import added:** `app_empty_state.dart`

### 2. `lib/screens/expenses/expenses_screen.dart`
- **Type:** Provider-based (Riverpod `.when`)
- **Provider:** `expensesStreamProvider`
- **Change:** Replaced `Center(child: Text('خطأ: $e'))` with `AppErrorState.general(onRetry: () => ref.invalidate(expensesStreamProvider))`
- **Import added:** `app_empty_state.dart`

### 3. `lib/screens/notifications/notifications_screen.dart`
- **Type:** Manual-load (setState)
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadData()` to reset error on start and capture on failure
  - Added `_error != null ? AppErrorState.general(onRetry: _loadData)` check in build
- **Import added:** `app_empty_state.dart`

### 4. `lib/screens/loyalty/loyalty_program_screen.dart`
- **Type:** Manual-load (setState) with TabBar
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadData()` to reset error on start and capture on failure
  - Added `if (_error != null) Expanded(child: AppErrorState.general(onRetry: _loadData))` before tab content
- **Import added:** `app_empty_state.dart`

### 5. `lib/screens/marketing/discounts_screen.dart`
- **Type:** Manual-load (setState)
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadData()` to reset error on start and capture on failure
  - Added `_error != null ? AppErrorState.general(onRetry: _loadData)` check in build
- **Import added:** `app_empty_state.dart`

### 6. `lib/screens/drivers/driver_management_screen.dart`
- **Type:** Manual-load (setState)
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadData()` to reset error on start and capture on failure
  - Added `_error != null ? AppErrorState.general(onRetry: _loadData)` check in build
- **Import added:** `app_empty_state.dart`

### 7. `lib/screens/branches/branch_management_screen.dart`
- **Type:** Manual-load (setState)
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadData()` to reset error on start and capture on failure
  - Added `_error != null ? AppErrorState.general(onRetry: _loadData)` check in build
- **Import added:** `app_empty_state.dart`

### 8. `lib/screens/sync/sync_status_screen.dart`
- **Type:** Manual-load (setState)
- **Changes:**
  - Added `String? _error` state variable
  - Modified `_loadStatus()` to reset error on start and capture on failure
  - Added `_error != null ? AppErrorState.general(onRetry: _loadStatus)` check in build
- **Import added:** `app_empty_state.dart`

### 9. `lib/screens/invoices/invoices_screen.dart`
- **Type:** Provider-based (Riverpod `.when`)
- **Provider:** `invoicesListProvider`
- **Change:** Replaced `Center(child: Text('خطأ: $e'))` with `AppErrorState.general(onRetry: () => ref.invalidate(invoicesListProvider))`
- **Import added:** `app_empty_state.dart`

### 10. `lib/screens/orders/orders_screen.dart`
- **Type:** Provider-based (Riverpod `.when`)
- **Provider:** `ordersListProvider`
- **Change:** Replaced `Center(child: Text('خطأ: $e'))` with `AppErrorState.general(onRetry: () => ref.invalidate(ordersListProvider))`
- **Import added:** `app_empty_state.dart`

### 11. `lib/screens/settings/settings_screen.dart`
- **Type:** Static (no data loading)
- **Change:** None -- this screen renders static settings categories with no async data loading, so there is no error to catch. No fix needed.

---

## Verification

```
$ dart analyze [all 10 files]
No issues found!
```

All 10 modified files pass Dart static analysis with zero errors or warnings.

---

## Summary

| # | Screen | Fix Type | Retry Target |
|---|--------|----------|-------------|
| 1 | Suppliers | Provider `.when` | `ref.invalidate(suppliersListProvider)` |
| 2 | Expenses | Provider `.when` | `ref.invalidate(expensesStreamProvider)` |
| 3 | Notifications | setState + `_error` | `_loadData()` |
| 4 | Loyalty Program | setState + `_error` | `_loadData()` |
| 5 | Discounts | setState + `_error` | `_loadData()` |
| 6 | Drivers | setState + `_error` | `_loadData()` |
| 7 | Branches | setState + `_error` | `_loadData()` |
| 8 | Sync Status | setState + `_error` | `_loadStatus()` |
| 9 | Invoices | Provider `.when` | `ref.invalidate(invoicesListProvider)` |
| 10 | Orders | Provider `.when` | `ref.invalidate(ordersListProvider)` |
| 11 | Settings | N/A (static) | N/A |

**Files modified:** 10
**Files skipped:** 1 (Settings -- static, no async operations)
**Analysis result:** 0 errors, 0 warnings
