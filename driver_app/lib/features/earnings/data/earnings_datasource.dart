import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for driver earnings data.
class EarningsDatasource {
  final SupabaseClient _client;

  EarningsDatasource(this._client);

  String get _driverId => _client.auth.currentUser!.id;

  /// Get deliveries for a date range with earnings.
  Future<List<Map<String, dynamic>>> getEarnings({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _client
        .from('deliveries')
        .select('id, delivery_fee, delivered_at, distance_km, status, orders:order_id(order_number)')
        .eq('driver_id', _driverId)
        .eq('status', 'delivered')
        .gte('delivered_at', from.toIso8601String())
        .lte('delivered_at', to.toIso8601String())
        .order('delivered_at', ascending: false);
  }

  /// Get earnings summary for a date range.
  Future<Map<String, dynamic>> getEarningsSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final deliveries = await getEarnings(from: from, to: to);

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
}
