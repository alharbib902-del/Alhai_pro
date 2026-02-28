import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/supplier.dart';

void main() {
  group('Supplier Model', () {
    Supplier createSupplier({
      String id = 'supplier-1',
      double balance = 0,
      bool isActive = true,
    }) {
      return Supplier(
        id: id,
        storeId: 'store-1',
        name: 'Test Supplier',
        phone: '+966500000001',
        balance: balance,
        isActive: isActive,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('hasBalance', () {
      test('should return true when balance is positive', () {
        final supplier = createSupplier(balance: 100.0);
        expect(supplier.hasBalance, isTrue);
      });

      test('should return true when balance is negative', () {
        final supplier = createSupplier(balance: -50.0);
        expect(supplier.hasBalance, isTrue);
      });

      test('should return false when balance is zero', () {
        final supplier = createSupplier(balance: 0);
        expect(supplier.hasBalance, isFalse);
      });
    });

    group('isOwed', () {
      test('should return true when balance is positive (store owes supplier)', () {
        final supplier = createSupplier(balance: 500.0);
        expect(supplier.isOwed, isTrue);
      });

      test('should return false when balance is zero', () {
        final supplier = createSupplier(balance: 0);
        expect(supplier.isOwed, isFalse);
      });

      test('should return false when balance is negative', () {
        final supplier = createSupplier(balance: -100.0);
        expect(supplier.isOwed, isFalse);
      });
    });

    group('serialization', () {
      test('should create Supplier from JSON', () {
        final json = {
          'id': 'supplier-1',
          'storeId': 'store-1',
          'name': 'Supplier A',
          'phone': '+966500000001',
          'email': 'supplier@example.com',
          'address': 'Riyadh',
          'balance': 150.0,
          'isActive': true,
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final supplier = Supplier.fromJson(json);

        expect(supplier.id, equals('supplier-1'));
        expect(supplier.name, equals('Supplier A'));
        expect(supplier.balance, equals(150.0));
        expect(supplier.isActive, isTrue);
      });

      test('should serialize to JSON and back', () {
        final supplier = createSupplier(balance: 200.0);
        final json = supplier.toJson();
        final restored = Supplier.fromJson(json);

        expect(restored.id, equals(supplier.id));
        expect(restored.balance, equals(200.0));
        expect(restored.name, equals(supplier.name));
      });
    });

    group('equality', () {
      test('should be equal for same data', () {
        final s1 = createSupplier(id: 's1', balance: 100.0);
        final s2 = createSupplier(id: 's1', balance: 100.0);
        expect(s1, equals(s2));
      });
    });
  });
}
