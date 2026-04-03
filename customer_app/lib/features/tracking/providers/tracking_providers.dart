import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../data/delivery_datasource.dart';

/// Real-time delivery tracking for an order.
final deliveryTrackingProvider =
    StreamProvider.family<Delivery, String>((ref, orderId) {
  final datasource = locator<DeliveryDatasource>();
  return datasource.trackDelivery(orderId);
});

/// Real-time order status changes.
final orderStatusTrackingProvider =
    StreamProvider.family<OrderStatus, String>((ref, orderId) {
  final datasource = locator<DeliveryDatasource>();
  return datasource.trackOrderStatus(orderId);
});

/// Real-time driver location.
final driverLocationProvider =
    StreamProvider.family<Map<String, dynamic>?, String>(
        (ref, driverId) {
  final datasource = locator<DeliveryDatasource>();
  return datasource.trackDriverLocation(driverId);
});

/// Driver info (name, phone, image).
final driverInfoProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
        (ref, driverId) {
  final datasource = locator<DeliveryDatasource>();
  return datasource.getDriverInfo(driverId);
});
