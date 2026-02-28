import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/store.dart';

void main() {
  group('Store Model', () {
    Store createStore({
      String id = 'store-1',
      String name = 'Test Store',
      bool isActive = true,
      WorkingHours? workingHours,
      double? deliveryRadius,
      double? minOrderAmount,
      double? deliveryFee,
    }) {
      return Store(
        id: id,
        name: name,
        address: 'Test Address',
        lat: 24.7136,
        lng: 46.6753,
        isActive: isActive,
        ownerId: 'owner-1',
        deliveryRadius: deliveryRadius,
        minOrderAmount: minOrderAmount,
        deliveryFee: deliveryFee,
        workingHours: workingHours,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('construction', () {
      test('should create store with required fields', () {
        final store = createStore();

        expect(store.id, equals('store-1'));
        expect(store.name, equals('Test Store'));
        expect(store.isActive, isTrue);
        expect(store.acceptsDelivery, isTrue);
        expect(store.acceptsPickup, isTrue);
      });

      test('should have null optional fields by default', () {
        final store = createStore();

        expect(store.phone, isNull);
        expect(store.email, isNull);
        expect(store.imageUrl, isNull);
        expect(store.logoUrl, isNull);
        expect(store.deliveryRadius, isNull);
        expect(store.workingHours, isNull);
      });
    });

    group('isOpenNow', () {
      test('should return true when no working hours set', () {
        final store = createStore();
        expect(store.isOpenNow(), isTrue);
      });
    });

    group('serialization', () {
      test('should create Store from JSON', () {
        final json = {
          'id': 'store-1',
          'name': 'My Store',
          'address': 'Riyadh',
          'lat': 24.7,
          'lng': 46.6,
          'isActive': true,
          'ownerId': 'owner-1',
          'acceptsDelivery': true,
          'acceptsPickup': false,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final store = Store.fromJson(json);

        expect(store.id, equals('store-1'));
        expect(store.name, equals('My Store'));
        expect(store.acceptsDelivery, isTrue);
        expect(store.acceptsPickup, isFalse);
      });

      test('should serialize to JSON and back', () {
        final store = createStore(
          deliveryRadius: 10.0,
          minOrderAmount: 50.0,
          deliveryFee: 15.0,
        );
        final json = store.toJson();
        final restored = Store.fromJson(json);

        expect(restored.id, equals(store.id));
        expect(restored.deliveryRadius, equals(10.0));
        expect(restored.minOrderAmount, equals(50.0));
        expect(restored.deliveryFee, equals(15.0));
      });
    });

    group('equality', () {
      test('should be equal for same data', () {
        final store1 = createStore(id: 'store-1', name: 'Store');
        final store2 = createStore(id: 'store-1', name: 'Store');
        expect(store1, equals(store2));
      });

      test('should not be equal for different ids', () {
        final store1 = createStore(id: 'store-1');
        final store2 = createStore(id: 'store-2');
        expect(store1, isNot(equals(store2)));
      });
    });
  });

  group('WorkingHours Model', () {
    test('should create with specific day hours', () {
      const hours = WorkingHours(
        monday: DayHours(open: '09:00', close: '22:00'),
        friday: DayHours(open: '14:00', close: '23:00', isClosed: false),
      );

      expect(hours.monday, isNotNull);
      expect(hours.monday!.open, equals('09:00'));
      expect(hours.friday, isNotNull);
      expect(hours.tuesday, isNull);
    });

    test('should serialize to JSON and back', () {
      const hours = WorkingHours(
        monday: DayHours(open: '09:00', close: '22:00'),
        saturday: DayHours(open: '10:00', close: '20:00'),
      );
      final jsonStr = jsonEncode(hours.toJson());
      final restored = WorkingHours.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );

      expect(restored.monday!.open, equals('09:00'));
      expect(restored.saturday!.close, equals('20:00'));
    });
  });

  group('DayHours Model', () {
    test('should create with open and close times', () {
      const hours = DayHours(open: '09:00', close: '22:00');

      expect(hours.open, equals('09:00'));
      expect(hours.close, equals('22:00'));
      expect(hours.isClosed, isFalse);
    });

    test('should support isClosed flag', () {
      const hours = DayHours(open: '00:00', close: '00:00', isClosed: true);
      expect(hours.isClosed, isTrue);
    });
  });
}
