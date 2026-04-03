import 'package:alhai_core/alhai_core.dart';

import 'delivery_datasource.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryDatasource _datasource;

  DeliveryRepositoryImpl(this._datasource);

  @override
  Future<Delivery?> getDeliveryByOrderId(String orderId) =>
      _datasource.getDeliveryByOrderId(orderId);

  @override
  Future<List<Delivery>> getMyDeliveries() {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<Delivery> getDelivery(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Delivery> updateStatus(String id, DeliveryStatus status) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  }) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<Delivery> acceptDelivery(String id) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<void> rejectDelivery(String id, {String? reason}) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<Delivery> markPickedUp(String id) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<Delivery> markDelivered(String id, {String? notes}) {
    throw UnimplementedError('N/A for customers');
  }

  @override
  Future<void> reportIssue(String id, String issue) {
    throw UnimplementedError('N/A for customers');
  }
}
