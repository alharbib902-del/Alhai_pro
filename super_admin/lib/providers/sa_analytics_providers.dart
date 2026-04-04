import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sa_analytics_datasource.dart';
import '../data/models/sa_analytics_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// DATASOURCE
// ============================================================================

final saAnalyticsDatasourceProvider = Provider<SAAnalyticsDatasource>((ref) {
  return SAAnalyticsDatasource(ref.watch(saSupabaseClientProvider));
});

// ============================================================================
// ANALYTICS
// ============================================================================

/// Revenue analytics period filter.
final saRevenuePeriodProvider = StateProvider<String>((ref) => 'last12Months');

/// Revenue by plan breakdown.
final saRevenueByPlanProvider =
    FutureProvider.autoDispose<List<SARevenueByPlan>>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getRevenueByPlan();
});

/// Top stores by revenue.
final saTopStoresByRevenueProvider =
    FutureProvider.autoDispose<List<SATopStoreRevenue>>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getTopStoresByRevenue();
});

/// Top stores by transactions.
final saTopStoresByTransactionsProvider =
    FutureProvider.autoDispose<List<SATopStoreTransactions>>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getTopStoresByTransactions();
});

/// Active users per store (for bar chart).
final saActiveUsersPerStoreProvider =
    FutureProvider.autoDispose<List<SAActiveUsersPerStore>>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getActiveUsersPerStore();
});

/// Average daily transactions.
final saAvgDailyTransactionsProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getAvgDailyTransactions();
});

// ============================================================================
// SYSTEM HEALTH
// ============================================================================

/// System health check.
final saSystemHealthProvider =
    FutureProvider.autoDispose<SASystemHealth>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getSystemHealth();
});
