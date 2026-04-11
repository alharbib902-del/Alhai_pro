import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeDeliveryRepository implements DeliveryRepository {
  @override
  Future<List<Delivery>> getMyDeliveries() async => [];
  @override
  Future<Delivery> getDelivery(String id) async => throw UnimplementedError();
  @override
  Future<Delivery?> getDeliveryByOrderId(String orderId) async => null;
  @override
  Future<Delivery> updateStatus(
    String deliveryId,
    DeliveryStatus status,
  ) async => throw UnimplementedError();
  @override
  Future<void> updateLocation({
    required String deliveryId,
    required double lat,
    required double lng,
  }) async {}
  @override
  Future<Delivery> acceptDelivery(String deliveryId) async =>
      throw UnimplementedError();
  @override
  Future<void> rejectDelivery(String deliveryId, {String? reason}) async {}
  @override
  Future<Delivery> markPickedUp(String deliveryId) async =>
      throw UnimplementedError();
  @override
  Future<Delivery> markDelivered(String deliveryId, {String? notes}) async =>
      throw UnimplementedError();
  @override
  Future<void> reportIssue(String deliveryId, String issue) async {}
}

void main() {
  late DeliveryService deliveryService;
  setUp(() {
    deliveryService = DeliveryService(FakeDeliveryRepository());
  });

  group('DeliveryService', () {
    test('should be created', () {
      expect(deliveryService, isNotNull);
    });
    test('getMyDeliveries should return list', () async {
      final deliveries = await deliveryService.getMyDeliveries();
      expect(deliveries, isA<List<Delivery>>());
    });
    test('getDeliveryByOrderId should return null for unknown', () async {
      expect(await deliveryService.getDeliveryByOrderId('unknown'), isNull);
    });
    test('updateLocation should not throw', () async {
      await deliveryService.updateLocation(
        deliveryId: 'd1',
        latitude: 24.7,
        longitude: 46.7,
      );
    });
    test('rejectDelivery should not throw', () async {
      await deliveryService.rejectDelivery('d1', reason: 'Too far');
    });
    test('reportIssue should not throw', () async {
      await deliveryService.reportIssue('d1', 'Address not found');
    });
  });
}
