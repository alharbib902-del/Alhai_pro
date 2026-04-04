import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for platform-wide analytics.
/// Aggregation queries on sales, orders, subscriptions.
class SAAnalyticsDatasource {
  final SupabaseClient _client;

  SAAnalyticsDatasource(this._client);

  // ========================================================================
  // REVENUE ANALYTICS
  // ========================================================================

  /// Get monthly revenue data for the last 12 months.
  /// Uses subscription payments from billing_invoices or calculates from
  /// active subscriptions x plan price.
  Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    // Try billing_invoices first, fallback to subscription-based calculation
    try {
      final data = await _client.rpc('sa_monthly_revenue');
      if (data is List && data.isNotEmpty) {
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {
      // RPC may not exist, use fallback
    }

    // Fallback: calculate from subscriptions + plans
    final subs = await _client
        .from('subscriptions')
        .select('created_at, plans(monthly_price)')
        .eq('status', 'active');

    final monthlyMap = <String, double>{};
    for (final row in subs as List) {
      final createdAt = row['created_at'] as String?;
      final price =
          (row['plans'] as Map<String, dynamic>?)?['monthly_price'] as num?;
      if (createdAt == null || price == null) continue;
      final dt = DateTime.tryParse(createdAt);
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      monthlyMap[key] = (monthlyMap[key] ?? 0) + price.toDouble();
    }

    final result = monthlyMap.entries.map((e) => {
          'month': e.key,
          'revenue': e.value,
        }).toList()
      ..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));

    return result;
  }

  /// Revenue breakdown by plan.
  Future<List<Map<String, dynamic>>> getRevenueByPlan() async {
    final data = await _client
        .from('subscriptions')
        .select('plans(name, slug, monthly_price)')
        .eq('status', 'active');

    final planRevenue = <String, Map<String, dynamic>>{};
    for (final row in data as List) {
      final plan = row['plans'] as Map<String, dynamic>?;
      if (plan == null) continue;
      final slug = plan['slug'] as String? ?? 'unknown';
      final price = (plan['monthly_price'] as num?)?.toDouble() ?? 0;
      final name = plan['name'] as String? ?? slug;

      if (!planRevenue.containsKey(slug)) {
        planRevenue[slug] = {
          'name': name,
          'slug': slug,
          'subscribers': 0,
          'revenue': 0.0,
        };
      }
      planRevenue[slug]!['subscribers'] =
          (planRevenue[slug]!['subscribers'] as int) + 1;
      planRevenue[slug]!['revenue'] =
          (planRevenue[slug]!['revenue'] as double) + price;
    }

    return planRevenue.values.toList();
  }

  /// Top stores by transaction count.
  Future<List<Map<String, dynamic>>> getTopStoresByRevenue({
    int limit = 5,
  }) async {
    try {
      final data = await _client.rpc(
        'sa_top_stores_by_revenue',
        params: {'p_limit': limit},
      );
      if (data is List && data.isNotEmpty) {
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {
      // RPC not available, fallback
    }

    // Fallback: join stores with sales count
    final stores = await _client
        .from('stores')
        .select('id, name')
        .eq('is_active', true)
        .limit(limit);

    final result = <Map<String, dynamic>>[];
    for (final store in stores as List) {
      final storeId = store['id'] as String;
      final salesResult = await _client
          .from('sales')
          .select('total_amount')
          .eq('store_id', storeId);

      double revenue = 0;
      for (final sale in salesResult as List) {
        revenue += (sale['total_amount'] as num?)?.toDouble() ?? 0;
      }

      result.add({
        'store_id': storeId,
        'store_name': store['name'],
        'revenue': revenue,
      });
    }

    result.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    return result.take(limit).toList();
  }

  // ========================================================================
  // USAGE ANALYTICS
  // ========================================================================

  /// Get total transaction count across all stores.
  Future<int> getTotalTransactionCount() async {
    final result = await _client
        .from('sales')
        .select('id')
        .count(CountOption.exact);
    return result.count;
  }

  /// Get average daily transactions (last 30 days).
  Future<double> getAvgDailyTransactions() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final result = await _client
        .from('sales')
        .select('id')
        .gte('created_at', thirtyDaysAgo)
        .count(CountOption.exact);
    return result.count / 30.0;
  }

  /// Top stores by transaction count.
  Future<List<Map<String, dynamic>>> getTopStoresByTransactions({
    int limit = 5,
  }) async {
    try {
      final data = await _client.rpc(
        'sa_top_stores_by_transactions',
        params: {'p_limit': limit},
      );
      if (data is List && data.isNotEmpty) {
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {
      // RPC not available
    }

    // Fallback
    final stores = await _client
        .from('stores')
        .select('id, name')
        .eq('is_active', true)
        .limit(limit);

    final result = <Map<String, dynamic>>[];
    for (final store in stores as List) {
      final storeId = store['id'] as String;
      final countResult = await _client
          .from('sales')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact);

      final productCount = await _client
          .from('products')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact);

      result.add({
        'store_id': storeId,
        'store_name': store['name'],
        'transactions': countResult.count,
        'avg_per_day': (countResult.count / 30.0).round(),
        'products': productCount.count,
      });
    }

    result.sort((a, b) =>
        (b['transactions'] as int).compareTo(a['transactions'] as int));
    return result.take(limit).toList();
  }

  /// Get per-store active user counts (for bar chart).
  Future<List<Map<String, dynamic>>> getActiveUsersPerStore({
    int limit = 8,
  }) async {
    final stores = await _client
        .from('stores')
        .select('id, name')
        .eq('is_active', true)
        .limit(limit);

    final result = <Map<String, dynamic>>[];
    for (final store in stores as List) {
      final storeId = store['id'] as String;
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      final countResult = await _client
          .from('app_users')
          .select('id')
          .eq('store_id', storeId)
          .gte('last_sign_in_at', thirtyDaysAgo)
          .count(CountOption.exact);

      result.add({
        'store_id': storeId,
        'store_name': store['name'],
        'active_users': countResult.count,
      });
    }

    result.sort((a, b) =>
        (b['active_users'] as int).compareTo(a['active_users'] as int));
    return result;
  }

  // ========================================================================
  // DASHBOARD KPIS
  // ========================================================================

  /// Get all dashboard KPIs in one call (reduces round trips).
  Future<Map<String, dynamic>> getDashboardKPIs() async {
    final results = await Future.wait([
      _client
          .from('stores')
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact), // 0: active stores
      _client
          .from('subscriptions')
          .select('id')
          .eq('status', 'active')
          .count(CountOption.exact), // 1: active subs
      _client
          .from('subscriptions')
          .select('id')
          .eq('status', 'trial')
          .count(CountOption.exact), // 2: trial subs
      _client
          .from('app_users')
          .select('id')
          .gte(
            'created_at',
            DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String(),
          )
          .count(CountOption.exact), // 3: new signups (30d)
    ]);

    // Calculate MRR
    final subsData = await _client
        .from('subscriptions')
        .select('plans(monthly_price)')
        .eq('status', 'active');
    double mrr = 0;
    for (final row in subsData as List) {
      final price =
          (row['plans'] as Map<String, dynamic>?)?['monthly_price'] as num?;
      if (price != null) mrr += price.toDouble();
    }

    return {
      'active_stores': results[0].count,
      'active_subscriptions': results[1].count,
      'trial_subscriptions': results[2].count,
      'new_signups': results[3].count,
      'mrr': mrr,
      'arr': mrr * 12,
    };
  }

  // ========================================================================
  // SYSTEM HEALTH (queries Supabase health endpoints)
  // ========================================================================

  /// Get basic system health info.
  /// In production this would call monitoring APIs; here we query DB stats.
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      // Simple health check: try a lightweight query
      final stopwatch = Stopwatch()..start();
      await _client.from('stores').select('id').limit(1);
      stopwatch.stop();

      return {
        'status': 'healthy',
        'db_response_ms': stopwatch.elapsedMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'degraded',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
