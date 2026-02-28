import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/delivery.dart';
import 'package:alhai_core/src/models/address.dart';
import 'package:alhai_core/src/models/enums/delivery_status.dart';

void main() {
  group('Delivery Model', () {
    Delivery createDelivery({
      String id = 'delivery-1',
      DeliveryStatus status = DeliveryStatus.assigned,
    }) {
      return Delivery(
        id: id,
        orderId: 'order-1',
        driverId: 'driver-1',
        status: status,
        pickupAddress: const Address(
          id: 'addr-1',
          label: 'Store',
          fullAddress: 'Store Address',
          city: 'Riyadh',
          lat: 24.7,
          lng: 46.6,
        ),
        deliveryAddress: const Address(
          id: 'addr-2',
          label: 'Home',
          fullAddress: 'Customer Address',
          city: 'Riyadh',
          lat: 24.8,
          lng: 46.7,
        ),
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('construction', () {
      test('should create delivery with required fields', () {
        final delivery = createDelivery();

        expect(delivery.id, equals('delivery-1'));
        expect(delivery.orderId, equals('order-1'));
        expect(delivery.driverId, equals('driver-1'));
        expect(delivery.status, equals(DeliveryStatus.assigned));
      });

      test('should have null optional fields by default', () {
        final delivery = createDelivery();

        expect(delivery.driverName, isNull);
        expect(delivery.driverPhone, isNull);
        expect(delivery.driverLat, isNull);
        expect(delivery.driverLng, isNull);
        expect(delivery.estimatedArrival, isNull);
        expect(delivery.pickedUpAt, isNull);
        expect(delivery.deliveredAt, isNull);
        expect(delivery.notes, isNull);
      });
    });

    group('serialization', () {
      test('should create Delivery from JSON', () {
        final json = {
          'id': 'delivery-1',
          'orderId': 'order-1',
          'driverId': 'driver-1',
          'status': 'assigned',
          'pickupAddress': {
            'id': 'a1',
            'label': 'Store',
            'fullAddress': 'Test',
            'city': 'Riyadh',
            'lat': 24.7,
            'lng': 46.6,
            'isDefault': false,
          },
          'deliveryAddress': {
            'id': 'a2',
            'label': 'Home',
            'fullAddress': 'Test',
            'city': 'Riyadh',
            'lat': 24.8,
            'lng': 46.7,
            'isDefault': false,
          },
          'driverName': 'Ahmed',
          'driverPhone': '+966500000001',
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final delivery = Delivery.fromJson(json);

        expect(delivery.id, equals('delivery-1'));
        expect(delivery.driverName, equals('Ahmed'));
        expect(delivery.pickupAddress.label, equals('Store'));
        expect(delivery.deliveryAddress.label, equals('Home'));
      });

      test('should serialize to JSON and back', () {
        final delivery = createDelivery();
        // Use json encode/decode to simulate real serialization round-trip
        final jsonStr = jsonEncode(delivery.toJson());
        final restored = Delivery.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        expect(restored.id, equals(delivery.id));
        expect(restored.status, equals(delivery.status));
        expect(restored.orderId, equals(delivery.orderId));
      });
    });
  });

  group('DeliveryStatus Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(DeliveryStatus.assigned.displayNameAr, equals('تم التعيين'));
      expect(DeliveryStatus.accepted.displayNameAr, equals('تم القبول'));
      expect(DeliveryStatus.pickedUp.displayNameAr, equals('تم الاستلام'));
      expect(DeliveryStatus.delivered.displayNameAr, equals('تم التوصيل'));
      expect(DeliveryStatus.failed.displayNameAr, equals('فشل التوصيل'));
      expect(DeliveryStatus.cancelled.displayNameAr, equals('ملغي'));
    });

    test('toApi should return name', () {
      expect(DeliveryStatus.assigned.toApi(), equals('assigned'));
      expect(DeliveryStatus.delivered.toApi(), equals('delivered'));
    });

    test('fromApi should parse correctly', () {
      expect(DeliveryStatusX.fromApi('assigned'), equals(DeliveryStatus.assigned));
      expect(DeliveryStatusX.fromApi('delivered'), equals(DeliveryStatus.delivered));
      expect(DeliveryStatusX.fromApi('unknown'), equals(DeliveryStatus.assigned));
    });
  });
}
