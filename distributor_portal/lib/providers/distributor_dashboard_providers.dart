/// Dashboard and prefetching providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Dashboard ──────────────────────────────────────────────────

final dashboardKpisProvider = FutureProvider<DashboardKpis>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getDashboardKpis();
});

// ─── Prefetching ───────────────────────────────────────────────

/// Prefetch all dashboard data (KPIs + categories) in parallel.
/// Call this once when the shell loads to warm the caches.
final prefetchDashboardDataProvider = FutureProvider<void>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  await Future.wait([
    ds.getDashboardKpis(),
    ds.getCategories(),
    ds.getOrgSettings(),
  ]);
});
