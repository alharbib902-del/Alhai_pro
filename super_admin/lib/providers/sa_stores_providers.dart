import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sa_stores_datasource.dart';
import '../data/models/sa_store_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// DATASOURCE
// ============================================================================

final saStoresDatasourceProvider = Provider<SAStoresDatasource>((ref) {
  return SAStoresDatasource(ref.watch(saSupabaseClientProvider));
});

// ============================================================================
// STORES
// ============================================================================

/// Stores list filter state.
class StoresFilterState {
  final String status;
  final String plan;
  final String search;

  const StoresFilterState({
    this.status = 'all',
    this.plan = 'all',
    this.search = '',
  });

  StoresFilterState copyWith({String? status, String? plan, String? search}) {
    return StoresFilterState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      search: search ?? this.search,
    );
  }
}

final saStoresFilterProvider =
    StateProvider<StoresFilterState>((ref) => const StoresFilterState());

/// Filtered stores list.
final saStoresListProvider =
    FutureProvider.autoDispose<List<SAStore>>((ref) async {
  final ds = ref.watch(saStoresDatasourceProvider);
  final filter = ref.watch(saStoresFilterProvider);
  return ds.getStores(
    statusFilter: filter.status,
    planFilter: filter.plan,
    search: filter.search,
  );
});

/// Single store detail.
final saStoreDetailProvider =
    FutureProvider.autoDispose.family<SAStore, String>((ref, storeId) async {
  final ds = ref.watch(saStoresDatasourceProvider);
  return ds.getStore(storeId);
});

/// Store usage stats.
final saStoreUsageStatsProvider = FutureProvider.autoDispose
    .family<SAStoreUsageStats, String>((ref, storeId) async {
  final ds = ref.watch(saStoresDatasourceProvider);
  return ds.getStoreUsageStats(storeId);
});

/// Store owner info.
final saStoreOwnerProvider = FutureProvider.autoDispose
    .family<SAStoreOwner?, String>((ref, storeId) async {
  final ds = ref.watch(saStoresDatasourceProvider);
  return ds.getStoreOwner(storeId);
});
