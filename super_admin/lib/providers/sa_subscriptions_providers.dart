import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sa_subscriptions_datasource.dart';
import '../data/models/sa_subscription_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// DATASOURCE
// ============================================================================

final saSubscriptionsDatasourceProvider = Provider<SASubscriptionsDatasource>((
  ref,
) {
  return SASubscriptionsDatasource(ref.watch(saSupabaseClientProvider));
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
final saPlansListProvider = FutureProvider.autoDispose<List<SAPlan>>((
  ref,
) async {
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
