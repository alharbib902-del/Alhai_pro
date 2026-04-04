import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';

class DeliveryDatasource {
  final SupabaseClient _client;

  DeliveryDatasource(this._client);

  Future<Delivery?> getDeliveryByOrderId(String orderId) async {
    try {
      final data = await _client
          .from('deliveries')
          .select()
          .eq('order_id', orderId)
          .limit(1)
          .single()
          .timeout(AppConstants.networkTimeout);
      return _deliveryFromRow(data);
    } catch (_) {
      return null;
    }
  }

  /// Stream real-time delivery updates for an order.
  Stream<Delivery> trackDelivery(String orderId) {
    return _client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('No delivery found');
          return _deliveryFromRow(rows.first);
        });
  }

  /// Stream real-time order status updates.
  Stream<OrderStatus> trackOrderStatus(String orderId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) {
          if (rows.isEmpty) return OrderStatus.created;
          final status = rows.first['status'] as String? ?? 'created';
          return OrderStatus.values.firstWhere(
            (s) => s.name == status,
            orElse: () => OrderStatus.created,
          );
        });
  }

  /// Stream real-time driver location.
  Stream<Map<String, dynamic>?> trackDriverLocation(String driverId) {
    return _client
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  /// Get driver info (name, phone, image).
  Future<Map<String, dynamic>?> getDriverInfo(String driverId) async {
    try {
      return await _client
          .from('users')
          .select('id, name, phone, image_url')
          .eq('id', driverId)
          .single()
          .timeout(AppConstants.networkTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<void> confirmDelivery(String orderId, String code) async {
    await _client.rpc('confirm_delivery', params: {
      'p_order_id': orderId,
      'p_confirmation_code': code,
    });
  }

  Delivery _deliveryFromRow(Map<String, dynamic> row) {
    return Delivery(
      id: row['id'] as String,
      orderId: row['order_id'] as String,
      driverId: row['driver_id'] as String,
      status: DeliveryStatus.values.firstWhere(
        (s) => s.name == (row['status'] as String? ?? 'assigned'),
        orElse: () => DeliveryStatus.assigned,
      ),
      pickupAddress: Address(
        id: '',
        label: 'Store',
        fullAddress: row['pickup_address'] as String? ?? '',
        city: '',
        lat: (row['pickup_lat'] as num?)?.toDouble() ?? 0,
        lng: (row['pickup_lng'] as num?)?.toDouble() ?? 0,
      ),
      deliveryAddress: Address(
        id: '',
        label: 'Customer',
        fullAddress: row['delivery_address'] as String? ?? '',
        city: '',
        lat: (row['delivery_lat'] as num?)?.toDouble() ?? 0,
        lng: (row['delivery_lng'] as num?)?.toDouble() ?? 0,
      ),
      driverName: row['driver_name'] as String?,
      driverPhone: row['driver_phone'] as String?,
      driverLat: (row['driver_lat'] as num?)?.toDouble(),
      driverLng: (row['driver_lng'] as num?)?.toDouble(),
      estimatedArrival: row['estimated_arrival'] != null
          ? DateTime.parse(row['estimated_arrival'] as String)
          : null,
      pickedUpAt: row['picked_up_at'] != null
          ? DateTime.parse(row['picked_up_at'] as String)
          : null,
      deliveredAt: row['delivered_at'] != null
          ? DateTime.parse(row['delivered_at'] as String)
          : null,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(
        row['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
