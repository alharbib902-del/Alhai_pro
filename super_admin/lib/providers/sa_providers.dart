import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sa_stores_datasource.dart';
import '../data/sa_subscriptions_datasource.dart';
import '../data/sa_users_datasource.dart';
import '../data/sa_analytics_datasource.dart';
import '../data/models/sa_store_model.dart';
import '../data/models/sa_user_model.dart';
import '../data/models/sa_subscription_model.dart';
import '../data/models/sa_analytics_model.dart';

// ============================================================================
// SUPABASE CLIENT
// ============================================================================

final saSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ============================================================================
// DATASOURCES
// ============================================================================

final saStoresDatasourceProvider = Provider<SAStoresDatasource>((ref) {
  return SAStoresDatasource(ref.watch(saSupabaseClientProvider));
});

final saSubscriptionsDatasourceProvider =
    Provider<SASubscriptionsDatasource>((ref) {
  return SASubscriptionsDatasource(ref.watch(saSupabaseClientProvider));
});

final saUsersDatasourceProvider = Provider<SAUsersDatasource>((ref) {
  return SAUsersDatasource(ref.watch(saSupabaseClientProvider));
});

final saAnalyticsDatasourceProvider = Provider<SAAnalyticsDatasource>((ref) {
  return SAAnalyticsDatasource(ref.watch(saSupabaseClientProvider));
});

// ============================================================================
// DASHBOARD
// ============================================================================

/// Dashboard KPIs -- auto-refreshes when invalidated.
final saDashboardKPIsProvider =
    FutureProvider.autoDispose<SADashboardKPIs>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getDashboardKPIs();
});

/// Monthly revenue chart data.
final saMonthlyRevenueProvider =
    FutureProvider.autoDispose<List<SARevenueData>>((ref) async {
  final ds = ref.watch(saAnalyticsDatasourceProvider);
  return ds.getMonthlyRevenue();
});

/// Subscription distribution by plan (for pie chart).
final saSubscriptionDistributionProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getSubscriberCountByPlan();
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
final saStoreDetailProvider = FutureProvider.autoDispose
    .family<SAStore, String>((ref, storeId) async {
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

// ============================================================================
// SUBSCRIPTIONS
// ============================================================================

/// Subscription status filter.
final saSubsFilterProvider = StateProvider<String>((ref) => 'all');

/// Subscriptions list.
final saSubscriptionsListProvider =
    FutureProvider.autoDispose<List<SASubscription>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  final filter = ref.watch(saSubsFilterProvider);
  return ds.getSubscriptions(statusFilter: filter);
});

/// Subscription counts by status.
final saSubscriptionCountsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getSubscriptionCounts();
});

/// Plans list.
final saPlansListProvider =
    FutureProvider.autoDispose<List<SAPlan>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getPlans();
});

/// Subscriber count per plan.
final saSubscriberCountByPlanProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getSubscriberCountByPlan();
});

/// Billing invoices.
final saBillingInvoicesProvider =
    FutureProvider.autoDispose<List<SABillingInvoice>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getBillingInvoices();
});

/// Billing summary.
final saBillingSummaryProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.getBillingSummary();
});

/// MRR.
final saMRRProvider = FutureProvider.autoDispose<double>((ref) async {
  final ds = ref.watch(saSubscriptionsDatasourceProvider);
  return ds.calculateMRR();
});

// ============================================================================
// USERS
// ============================================================================

/// User search query.
final saUserSearchProvider = StateProvider<String>((ref) => '');

/// Platform users list.
final saUsersListProvider =
    FutureProvider.autoDispose<List<SAUser>>((ref) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  final search = ref.watch(saUserSearchProvider);
  return ds.getPlatformUsers(search: search.isEmpty ? null : search);
});

/// Single user detail.
final saUserDetailProvider = FutureProvider.autoDispose
    .family<SAUser, String>((ref, userId) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  return ds.getUser(userId);
});

/// Total user count.
final saTotalUserCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  return ds.getTotalUserCount();
});

// ============================================================================
// ANALYTICS
// ============================================================================

/// Revenue analytics period filter.
final saRevenuePeriodProvider =
    StateProvider<String>((ref) => 'last12Months');

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

// ============================================================================
// PLATFORM SETTINGS
// ============================================================================

/// Platform settings from store_settings or a platform_settings table.
final saPlatformSettingsProvider =
    FutureProvider.autoDispose<SAPlatformSettings>((ref) async {
  final client = ref.watch(saSupabaseClientProvider);
  try {
    final data = await client
        .from('platform_settings')
        .select('*')
        .single();
    return SAPlatformSettings.fromJson(data);
  } catch (_) {
    // Table may not exist yet, return defaults
    return const SAPlatformSettings();
  }
});
