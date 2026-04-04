import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sa_analytics_datasource.dart';
import '../data/sa_subscriptions_datasource.dart';
import '../data/models/sa_analytics_model.dart';

// ============================================================================
// SUPABASE CLIENT
// ============================================================================

final saSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ============================================================================
// DASHBOARD KPIs
// ============================================================================

/// Dashboard KPIs -- auto-refreshes when invalidated.
final saDashboardKPIsProvider =
    FutureProvider.autoDispose<SADashboardKPIs>((ref) async {
  final ds = SAAnalyticsDatasource(ref.watch(saSupabaseClientProvider));
  return ds.getDashboardKPIs();
});

/// Monthly revenue chart data.
final saMonthlyRevenueProvider =
    FutureProvider.autoDispose<List<SARevenueData>>((ref) async {
  final ds = SAAnalyticsDatasource(ref.watch(saSupabaseClientProvider));
  return ds.getMonthlyRevenue();
});

/// Subscription distribution by plan (for pie chart).
final saSubscriptionDistributionProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final ds = SASubscriptionsDatasource(ref.watch(saSupabaseClientProvider));
  return ds.getSubscriberCountByPlan();
});
