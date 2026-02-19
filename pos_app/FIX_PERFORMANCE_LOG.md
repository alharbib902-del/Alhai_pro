# Performance Fix Log

**Date:** 2026-02-15
**dart analyze result:** 0 new issues introduced (4 pre-existing `AdaptiveIcon` errors, 1 pre-existing `unused_local_variable` warning)

---

## 1. Filter/Sort Caching in Build Methods (4 screens)

Moved heavy `where()`, `sort()`, `fold()`, and `where().length` operations from `build()` to cached/memoized methods that only recompute when inputs change.

### 1a. customers_screen.dart

| Change | Detail |
|--------|--------|
| Added cache fields | `_cachedFiltered`, `_lastFilterType`, `_lastSearchQuery`, `_lastSortBy`, `_lastSortAscending`, `_lastAccountsHash` |
| Replaced `_filteredCustomers` getter | Now checks if filter/sort/search inputs changed before recomputing |

**Impact:** Previously filtered + sorted + searched on every `build()` call. Now returns cached result when inputs haven't changed.

### 1b. inventory_screen.dart

| Change | Detail |
|--------|--------|
| Added cache fields | `_cachedFilteredProducts`, `_lastInventoryFilter`, `_lastInventorySort`, `_lastInventorySortAsc`, `_lastInventorySearch`, `_lastProductsLength` |
| Added `_getFilteredProducts()` method | Memoized filter + sort + search with cache invalidation |
| Optimized stats computation | Replaced 3 separate passes (`where` x2 + `fold` x1) with single `for` loop |
| Simplified `_buildInventoryContent()` | Now receives pre-filtered list instead of filtering inline |

**Impact:** Eliminated 3 redundant O(n) list traversals for stats + redundant filter/sort per build.

### 1c. orders_screen.dart

| Change | Detail |
|--------|--------|
| Added cache fields | `_cachedFilteredOrders`, `_lastTab`, `_lastChannel`, `_lastSearch`, `_lastOrdersCount` |
| Added caching to `_filterOrders()` | Returns cached result when tab/channel/search/count unchanged |
| Replaced 3 `where().length` calls | Single-pass `for` loop with `switch` for status counting |

**Impact:** Eliminated 3 separate O(n) traversals for stats counting, replaced with 1 pass. Filter results cached.

### 1d. returns_screen.dart

| Change | Detail |
|--------|--------|
| Moved `_filterReturns()` call | Called once in `build()` data callback, result passed to both `_buildStatsSection` and `_buildTableSection` |
| Updated `_buildStatsSection` | Parameter renamed from `allReturns` to `currentReturns`, removed internal `_filterReturns()` call |
| Updated `_buildTableSection` | Parameter renamed from `allReturns` to `filtered`, removed internal `_filterReturns()` call |

**Impact:** `_filterReturns()` was being called twice per build (once in stats, once in table). Now called once.

---

## 2. Sidebar Items Caching (1 file)

### dashboard_shell.dart

| Change | Detail |
|--------|--------|
| Added cache fields | `_cachedGroups` (List<SidebarGroup>?), `_cachedLocale` (Locale?) |
| Added `_getSidebarGroups()` method | Returns cached groups, rebuilds only when locale changes |
| Replaced both `DefaultSidebarItems.getGroups(context)` calls | Now use `_getSidebarGroups(context)` |

**Impact:** 60+ sidebar item objects were being recreated on every build. Now cached and only rebuilt on language change.

---

## 3. ConsumerStatefulWidget to ConsumerWidget Conversions (4 screens)

Converted screens that had no mutable state (no `setState()` calls, no `initState()`, no `dispose()`) from `ConsumerStatefulWidget` to `ConsumerWidget`, eliminating unnecessary State object overhead.

| # | File | Changes |
|---|------|---------|
| 1 | `lib/screens/dashboard/dashboard_screen.dart` | Removed `_DashboardScreenState`, converted to `ConsumerWidget` with `build(context, ref)`. Added `BuildContext context` parameter to `_refreshDashboard` and all builder methods. |
| 2 | `lib/screens/settings/settings_screen.dart` | Removed `_SettingsScreenState`, converted to `ConsumerWidget` with `build(context, ref)`. Added `BuildContext context` to `_buildContent` and `_getSettingsCategories`. |
| 3 | `lib/screens/shifts/shifts_screen.dart` | Removed `_ShiftsScreenState`, converted to `ConsumerWidget` with `build(context, ref)`. Added `BuildContext context` to `_buildContent`, `_buildCurrentShiftCard`, `_buildShiftsList`, `_buildShiftTile`, `_showShiftDetails`. |
| 4 | `lib/screens/expenses/expenses_screen.dart` | Removed `_ExpensesScreenState`, converted to `ConsumerWidget` with `build(context, ref)`. Added `BuildContext context` to `_buildContent`, `_buildExpensesList`, `_addExpense`, `_showFilterDialog`. Added `WidgetRef ref` to `_addExpense`. |

**Impact:** Eliminated unnecessary State object allocation and lifecycle overhead for screens that don't use mutable state.

---

## dart analyze Output

```
Analyzing 9 files...

error - lib\screens\customers\customers_screen.dart:584:15 - undefined_method (pre-existing)
error - lib\screens\customers\customers_screen.dart:1244:17 - undefined_method (pre-existing)
error - lib\screens\inventory\inventory_screen.dart:542:21 - creation_with_non_type (pre-existing)
error - lib\screens\inventory\inventory_screen.dart:1206:23 - creation_with_non_type (pre-existing)
warning - lib\screens\customers\customers_screen.dart:155:11 - unused_local_variable (pre-existing)

5 issues found. (0 new issues from this fix)
```

---

## Summary

| Category | Files Changed | Issues Fixed |
|----------|--------------|--------------|
| Filter/sort caching | 4 | 4 screens with heavy build() computations |
| Single-pass stats | 2 | Replaced 6 separate `where().length` calls with 2 single-pass loops |
| Duplicate filter call | 1 | `_filterReturns()` called once instead of twice |
| Sidebar items caching | 1 | 60+ objects cached, rebuild only on locale change |
| ConsumerStatefulWidget -> ConsumerWidget | 4 | 4 unnecessary State objects eliminated |
| **Total** | **9 files** | **11 optimizations** |
