/// Riverpod providers for the Distributor Portal.
///
/// Wraps [DistributorDatasource] queries into async providers
/// that screens can watch for loading / data / error states.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import '../data/distributor_datasource.dart';
import '../data/models.dart';

// ─── Datasource singleton ───────────────────────────────────────

final distributorDatasourceProvider = Provider<DistributorDatasource>((ref) {
  return DistributorDatasource();
});

// ─── Auth state ─────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AppSupabase.client.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return AppSupabase.isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state changes to recompute
  ref.watch(authStateProvider);
  return AppSupabase.client.auth.currentUser;
});

// ─── Dashboard ──────────────────────────────────────────────────

final dashboardKpisProvider = FutureProvider<DashboardKpis>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getDashboardKpis();
});

// ─── Orders ─────────────────────────────────────────────────────

/// All orders — pass status filter via family.
final ordersProvider =
    FutureProvider.family<List<DistributorOrder>, String?>((ref, status) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrders(status: status);
});

/// Single order by ID.
final orderDetailProvider =
    FutureProvider.family<DistributorOrder?, String>((ref, orderId) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrderById(orderId);
});

/// Order items for a given order.
final orderItemsProvider =
    FutureProvider.family<List<DistributorOrderItem>, String>(
        (ref, orderId) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrderItems(orderId);
});

// ─── Products ───────────────────────────────────────────────────

final productsProvider =
    FutureProvider<List<DistributorProduct>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getProducts();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getCategories();
});

// ─── Reports ────────────────────────────────────────────────────

/// Report data — period is one of: day, week, month, year
final reportDataProvider =
    FutureProvider.family<ReportData, String>((ref, period) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getReportData(period: period);
});

// ─── Settings ───────────────────────────────────────────────────

final orgSettingsProvider = FutureProvider<OrgSettings?>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrgSettings();
});
