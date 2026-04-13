import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/sentry_service.dart';
import 'models/sa_subscription_model.dart';

/// Datasource for subscription and billing management.
/// Queries: subscriptions, plans, billing_invoices.
class SASubscriptionsDatasource {
  final SupabaseClient _client;

  /// Creates a datasource bound to the given [SupabaseClient].
  SASubscriptionsDatasource(this._client);

  // ========================================================================
  // SUBSCRIPTIONS
  // ========================================================================

  /// Fetch all subscriptions with org info.
  ///
  /// Schema: subscriptions has org_id, plan (TEXT slug), current_period_start,
  /// current_period_end. No FK to plans table.
  /// Uses a batch lookup for store names to avoid N+1 queries.
  Future<List<SASubscription>> getSubscriptions({String? statusFilter}) async {
    var query = _client.from('subscriptions').select('''
      id, status, plan, org_id, amount, currency, billing_cycle,
      current_period_start, current_period_end, created_at
    ''');

    if (statusFilter != null && statusFilter != 'all') {
      query = query.eq('status', statusFilter);
    }

    final data = await query.order('created_at', ascending: false);

    // Collect distinct org_ids for a single batch lookup (fixes N+1)
    final rows = (data as List).cast<Map<String, dynamic>>();
    final orgIds = rows
        .map((r) => r['org_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    // Batch fetch store names for all org_ids in one query
    final orgToName = <String, String>{};
    if (orgIds.isNotEmpty) {
      try {
        final stores = await _client
            .from('stores')
            .select('org_id, name')
            .inFilter('org_id', orgIds);
        for (final store in stores as List) {
          final oid = store['org_id'] as String?;
          final name = store['name'] as String?;
          if (oid != null && name != null) {
            orgToName[oid] = name;
          }
        }
      } catch (e, st) {
        await reportError(
          e,
          stackTrace: st,
          hint: 'getSubscriptions: batch store name lookup',
        );
      }
    }

    return rows.map((json) {
      final orgId = json['org_id'] as String?;
      return SASubscription.fromSupabase(
        json,
        storeName: orgId != null ? orgToName[orgId] : null,
      );
    }).toList();
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

  /// Fetch all available plans from sa_plans table.
  /// Falls back to deriving plans from distinct subscription.plan slugs.
  Future<List<SAPlan>> getPlans() async {
    try {
      final data = await _client
          .from('sa_plans')
          .select('*')
          .order('monthly_price', ascending: true);
      return (data as List)
          .map((e) => SAPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'getPlans: sa_plans query failed, using fallback',
      );
      // sa_plans table may not exist yet; derive from subscriptions
      final data = await _client
          .from('subscriptions')
          .select('plan, amount, billing_cycle, features');
      final seen = <String, SAPlan>{};
      for (final row in data as List) {
        final slug = row['plan'] as String? ?? 'unknown';
        if (!seen.containsKey(slug)) {
          final amount = (row['amount'] as num?)?.toDouble() ?? 0;
          seen[slug] = SAPlan(
            id: slug,
            name: slug.replaceAll('_', ' '),
            slug: slug,
            monthlyPrice: amount,
            features: _parseFeatures(row['features']),
          );
        }
      }
      return seen.values.toList();
    }
  }

  List<String> _parseFeatures(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList().cast<String>();
    }
    if (raw is Map) return raw.keys.map((k) => k.toString()).toList();
    return [];
  }

  /// Get subscriber count per plan slug.
  Future<Map<String, int>> getSubscriberCountByPlan() async {
    final data = await _client
        .from('subscriptions')
        .select('plan')
        .eq('status', 'active');

    final counts = <String, int>{};
    for (final row in data as List) {
      final slug = row['plan'] as String? ?? 'unknown';
      counts[slug] = (counts[slug] ?? 0) + 1;
    }
    return counts;
  }

  /// Create a new plan in sa_plans table.
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
    try {
      final data = await _client
          .from('sa_plans')
          .insert({
            'name': name,
            'slug': slug,
            'monthly_price': monthlyPrice,
            'yearly_price': yearlyPrice,
            'max_branches': maxBranches,
            'max_products': maxProducts,
            'max_users': maxUsers,
            'features': features,
          })
          .select()
          .single();
      return SAPlan.fromJson(data);
    } catch (e) {
      // sa_plans table may not exist; return the plan object anyway
      return SAPlan(
        id: slug,
        name: name,
        slug: slug,
        monthlyPrice: monthlyPrice,
        yearlyPrice: yearlyPrice,
        maxBranches: maxBranches,
        maxProducts: maxProducts,
        maxUsers: maxUsers,
        features: features,
      );
    }
  }

  /// Update an existing plan.
  Future<void> updatePlan(String planId, Map<String, dynamic> updates) async {
    try {
      await _client.from('sa_plans').update(updates).eq('id', planId);
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'updatePlan: sa_plans update failed for planId=$planId',
      );
    }
  }

  // ========================================================================
  // BILLING / INVOICES
  // ========================================================================

  /// Fetch billing invoices from the invoices table.
  Future<List<SABillingInvoice>> getBillingInvoices() async {
    try {
      final data = await _client
          .from('invoices')
          .select('''
        id, invoice_number, total, status, issued_at, due_at, store_id,
        stores!inner(id, name)
      ''')
          .order('issued_at', ascending: false)
          .limit(100);
      return (data as List)
          .map(
            (e) => SABillingInvoice.fromJson({
              ...e as Map<String, dynamic>,
              'amount': e['total'], // map total -> amount
            }),
          )
          .toList();
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'getBillingInvoices: join query failed, trying without join',
      );
      // invoices table may not have FK to stores; try without join
      try {
        final data = await _client
            .from('invoices')
            .select(
              'id, invoice_number, total, status, issued_at, due_at, store_id',
            )
            .order('issued_at', ascending: false)
            .limit(100);
        return (data as List)
            .map(
              (e) => SABillingInvoice.fromJson({
                ...e as Map<String, dynamic>,
                'amount': e['total'],
              }),
            )
            .toList();
      } catch (e2, st2) {
        await reportError(
          e2,
          stackTrace: st2,
          hint: 'getBillingInvoices: fallback query also failed',
        );
        return [];
      }
    }
  }

  /// Get billing summary (paid, unpaid, overdue totals).
  Future<Map<String, double>> getBillingSummary() async {
    try {
      final data = await _client.from('invoices').select('total, status');

      double paid = 0, unpaid = 0, overdue = 0;
      for (final row in data as List) {
        final amount = (row['total'] as num?)?.toDouble() ?? 0;
        switch (row['status'] as String?) {
          case 'paid':
            paid += amount;
          case 'unpaid' || 'pending':
            unpaid += amount;
          case 'overdue':
            overdue += amount;
        }
      }

      return {'paid': paid, 'unpaid': unpaid, 'overdue': overdue};
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'getBillingSummary: invoices summary query failed',
      );
      return {'paid': 0, 'unpaid': 0, 'overdue': 0};
    }
  }

  /// Calculate MRR from active subscriptions.
  /// Uses the amount field directly since there's no plans FK.
  Future<double> calculateMRR() async {
    final data = await _client
        .from('subscriptions')
        .select('amount, billing_cycle')
        .eq('status', 'active');

    double mrr = 0;
    for (final row in data as List) {
      final amount = (row['amount'] as num?)?.toDouble() ?? 0;
      final cycle = row['billing_cycle'] as String? ?? 'monthly';
      if (cycle == 'yearly') {
        mrr += amount / 12;
      } else {
        mrr += amount;
      }
    }
    return mrr;
  }
}
