import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for driver delivery operations using Supabase directly.
class DeliveryDatasource {
  final SupabaseClient _client;

  DeliveryDatasource(this._client);

  String get _driverId => _client.auth.currentUser!.id;

  /// Get all deliveries for the current driver.
  Future<List<Map<String, dynamic>>> getMyDeliveries({
    String? statusFilter,
  }) async {
    var query = _client
        .from('deliveries')
        .select('*, orders:order_id(*)')
        .eq('driver_id', _driverId);

    if (statusFilter != null) {
      query = query.eq('status', statusFilter);
    }

    return await query.order('created_at', ascending: false);
  }

  /// Get active deliveries (not completed/failed/cancelled).
  Future<List<Map<String, dynamic>>> getActiveDeliveries() async {
    return await _client
        .from('deliveries')
        .select('*, orders:order_id(*)')
        .eq('driver_id', _driverId)
        .not('status', 'in', '(delivered,failed,cancelled)')
        .order('created_at', ascending: false);
  }

  /// Get completed deliveries.
  Future<List<Map<String, dynamic>>> getCompletedDeliveries({
    int limit = 50,
  }) async {
    return await _client
        .from('deliveries')
        .select('*, orders:order_id(*)')
        .eq('driver_id', _driverId)
        .inFilter('status', ['delivered', 'failed', 'cancelled'])
        .order('delivered_at', ascending: false)
        .limit(limit);
  }

  /// Get a single delivery by ID.
  Future<Map<String, dynamic>?> getDelivery(String id) async {
    return await _client
        .from('deliveries')
        .select('*, orders:order_id(*, order_items:order_items(*))')
        .eq('id', id)
        .maybeSingle();
  }

  /// Stream deliveries assigned to this driver (Realtime).
  Stream<List<Map<String, dynamic>>> streamMyDeliveries() {
    return _client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false);
  }

  /// Stream new assignments (status = assigned).
  Stream<List<Map<String, dynamic>>> streamNewAssignments() {
    return _client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false);
  }

  /// Update delivery status via RPC (with server-side validation).
  Future<Map<String, dynamic>> updateStatus(
    String deliveryId,
    String newStatus, {
    String? notes,
  }) async {
    final result = await _client.rpc('update_delivery_status', params: {
      'p_delivery_id': deliveryId,
      'p_new_status': newStatus,
      'p_notes': notes,
    });
    return result as Map<String, dynamic>;
  }

  /// Accept a delivery assignment.
  Future<Map<String, dynamic>> acceptDelivery(String deliveryId) async {
    return updateStatus(deliveryId, 'accepted');
  }

  /// Reject a delivery assignment.
  Future<Map<String, dynamic>> rejectDelivery(
    String deliveryId, {
    String? reason,
  }) async {
    return updateStatus(deliveryId, 'cancelled', notes: reason);
  }

  /// Update driver location on active delivery.
  Future<void> updateDriverLocation(
    String deliveryId,
    double lat,
    double lng,
  ) async {
    await _client
        .from('deliveries')
        .update({
          'driver_lat': lat,
          'driver_lng': lng,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', deliveryId);

    // Also upsert to driver_locations for real-time tracking
    await _client.from('driver_locations').upsert({
      'driver_id': _driverId,
      'lat': lat,
      'lng': lng,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
