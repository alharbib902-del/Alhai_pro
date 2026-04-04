import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/sa_subscription_model.dart';

/// Datasource for subscription and billing management.
/// Queries: subscriptions, plans, billing_invoices.
class SASubscriptionsDatasource {
  final SupabaseClient _client;

  SASubscriptionsDatasource(this._client);

  // ========================================================================
  // SUBSCRIPTIONS
  // ========================================================================

  /// Fetch all subscriptions with store and plan info.
  Future<List<SASubscription>> getSubscriptions({
    String? statusFilter,
  }) async {
    var query = _client.from('subscriptions').select('''
      id, status, start_date, end_date, store_id,
      stores(id, name),
      plans(id, name, slug, monthly_price)
    ''').order('created_at', ascending: false);

    if (statusFilter != null && statusFilter != 'all') {
      query = query.eq('status', statusFilter);
    }

    final data = await query;
    return (data as List)
        .map((e) => SASubscription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get subscription counts by status.
  Future<Map<String, int>> getSubscriptionCounts() async {
    final results = await Future.wait([
      _client
          .from('subscriptions')
          .select('id')
          .eq('status', 'active')
          .count(CountOption.exact),
      _client
          .from('subscriptions')
          .select('id')
          .eq('status', 'trial')
          .count(CountOption.exact),
      _client
          .from('subscriptions')
          .select('id')
          .eq('status', 'expired')
          .count(CountOption.exact),
    ]);

    return {
      'active': results[0].count,
      'trial': results[1].count,
      'expired': results[2].count,
    };
  }

  // ========================================================================
  // PLANS
  // ========================================================================

  /// Fetch all available plans.
  Future<List<SAPlan>> getPlans() async {
    final data = await _client
        .from('plans')
        .select('*')
        .order('monthly_price', ascending: true);
    return (data as List)
        .map((e) => SAPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get subscriber count per plan.
  Future<Map<String, int>> getSubscriberCountByPlan() async {
    final data = await _client
        .from('subscriptions')
        .select('plan_id, plans(slug)')
        .eq('status', 'active');

    final counts = <String, int>{};
    for (final row in data as List) {
      final slug =
          (row['plans'] as Map<String, dynamic>?)?['slug'] as String? ??
              'unknown';
      counts[slug] = (counts[slug] ?? 0) + 1;
    }
    return counts;
  }

  /// Create a new plan.
  Future<SAPlan> createPlan({
    required String name,
    required String slug,
    required double monthlyPrice,
    required double yearlyPrice,
    required int maxBranches,
    required int maxProducts,
    required int maxUsers,
    List<String> features = const [],
  }) async {
    final data = await _client.from('plans').insert({
      'name': name,
      'slug': slug,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'max_branches': maxBranches,
      'max_products': maxProducts,
      'max_users': maxUsers,
      'features': features,
    }).select().single();
    return SAPlan.fromJson(data);
  }

  /// Update an existing plan.
  Future<void> updatePlan(String planId, Map<String, dynamic> updates) async {
    await _client.from('plans').update(updates).eq('id', planId);
  }

  // ========================================================================
  // BILLING / INVOICES
  // ========================================================================

  /// Fetch billing invoices.
  Future<List<SABillingInvoice>> getBillingInvoices() async {
    final data = await _client.from('billing_invoices').select('''
      id, invoice_number, amount, status, issued_at, due_at,
      stores(id, name),
      plans(id, name, slug)
    ''').order('issued_at', ascending: false);
    return (data as List)
        .map((e) => SABillingInvoice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get billing summary (paid, unpaid, overdue totals).
  Future<Map<String, double>> getBillingSummary() async {
    final data = await _client
        .from('billing_invoices')
        .select('amount, status');

    double paid = 0, unpaid = 0, overdue = 0;
    for (final row in data as List) {
      final amount = (row['amount'] as num?)?.toDouble() ?? 0;
      switch (row['status'] as String?) {
        case 'paid':
          paid += amount;
        case 'unpaid':
          unpaid += amount;
        case 'overdue':
          overdue += amount;
      }
    }

    return {'paid': paid, 'unpaid': unpaid, 'overdue': overdue};
  }

  /// Calculate MRR from active subscriptions.
  Future<double> calculateMRR() async {
    final data = await _client
        .from('subscriptions')
        .select('plans(monthly_price)')
        .eq('status', 'active');

    double mrr = 0;
    for (final row in data as List) {
      final price =
          (row['plans'] as Map<String, dynamic>?)?['monthly_price'] as num?;
      if (price != null) mrr += price.toDouble();
    }
    return mrr;
  }
}
