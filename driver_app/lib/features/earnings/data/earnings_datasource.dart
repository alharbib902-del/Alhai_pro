import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/local_cache_service.dart';

/// Datasource for driver earnings data.
///
/// Every successful network response is written-through to [LocalCacheService].
/// When Supabase is unreachable the datasource falls back to cached data so
/// the driver can still review their earnings history offline.
class EarningsDatasource {
  final SupabaseClient _client;
  final LocalCacheService _cache;

  EarningsDatasource(this._client, this._cache);

  String get _driverId => _client.auth.currentUser!.id;

  /// Get deliveries for a date range with earnings.
  /// Falls back to cache on network failure.
  Future<List<Map<String, dynamic>>> getEarnings({
    required DateTime from,
    required DateTime to,
  }) async {
    final cacheKey = _periodKey(from, to);
    try {
      final result = await _client
          .from('deliveries')
          .select(
              'id, delivery_fee, delivered_at, distance_km, status, orders:order_id(order_number)')
          .eq('driver_id', _driverId)
          .eq('status', 'delivered')
          .gte('delivered_at', from.toIso8601String())
          .lte('delivered_at', to.toIso8601String())
          .order('delivered_at', ascending: false);

      // Write-through: persist so the earnings screen works offline.
      await _cache.cacheEarnings('list_$cacheKey', {'rows': result});
      return result;
    } catch (_) {
      final cached = await _cache.getCachedEarnings('list_$cacheKey');
      if (cached != null) {
        return (cached['rows'] as List).cast<Map<String, dynamic>>();
      }
      rethrow;
    }
  }

  /// Get earnings summary for a date range.
  /// Falls back to cache on network failure.
  Future<Map<String, dynamic>> getEarningsSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final cacheKey = _periodKey(from, to);
    try {
      final deliveries = await getEarnings(from: from, to: to);
      final summary = _buildSummary(deliveries);

      // Cache the computed summary alongside the raw rows.
      await _cache.cacheEarnings('summary_$cacheKey', summary);
      return summary;
    } catch (_) {
      // getEarnings already tried the cache for raw rows; try the summary.
      final cached = await _cache.getCachedEarnings('summary_$cacheKey');
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Build a summary map from a list of delivery rows.
  Map<String, dynamic> _buildSummary(List<Map<String, dynamic>> deliveries) {
    double totalEarnings = 0;
    double totalDistance = 0;

    for (final d in deliveries) {
      totalEarnings += (d['delivery_fee'] as num?)?.toDouble() ?? 0;
      totalDistance += (d['distance_km'] as num?)?.toDouble() ?? 0;
    }

    return {
      'total_earnings': totalEarnings,
      'total_deliveries': deliveries.length,
      'total_distance_km': totalDistance,
      'avg_per_delivery':
          deliveries.isNotEmpty ? totalEarnings / deliveries.length : 0,
      'deliveries': deliveries,
    };
  }

  /// Stable string key derived from a date range (yyyy-MM-dd format).
  String _periodKey(DateTime from, DateTime to) {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '${fmt(from)}_${fmt(to)}';
  }
}
