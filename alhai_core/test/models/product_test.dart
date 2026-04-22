import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Model', () {
    test('should calculate profit margin correctly', () {
      // C-4 Stage B: SAR × 100 = cents
      final product = Product(
        id: '1',
        storeId: 'store1',
        name: 'Test Product',
        price: 10000,
        costPrice: 6000,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.profitMargin, closeTo(66.67, 0.01));
    });

    test('should return null profit margin when costPrice is null', () {
      final product = Product(
        id: '1',
        storeId: 'store1',
        name: 'Test Product',
        price: 10000,
        stockQty: 10,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.profitMargin, isNull);
    });

    test('should detect low stock correctly', () {
      final product = Product(
        id: '1',
        storeId: 'store1',
        name: 'Test Product',
        price: 10000,
        stockQty: 1,
        minQty: 5,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.isLowStock, isTrue);
      expect(product.isOutOfStock, isFalse);
    });

    test('should detect out of stock correctly', () {
      final product = Product(
        id: '1',
        storeId: 'store1',
        name: 'Test Product',
        price: 10000,
        stockQty: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.isOutOfStock, isTrue);
    });

    group('Money getters (C-4)', () {
      test('priceMoney wraps the int-cents price as SAR Money', () {
        final product = Product(
          id: '1',
          storeId: 'store1',
          name: 'Test Product',
          price: 3780,
          stockQty: 10,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(product.priceMoney, Money.fromCents(3780));
        expect(product.priceMoney.cents, 3780);
        expect(product.priceMoney.currencyCode, 'SAR');
        expect(product.priceMoney.toDouble(), 37.80);
      });

      test(
        'costPriceMoney wraps costPrice as SAR Money when set',
        () {
          final product = Product(
            id: '1',
            storeId: 'store1',
            name: 'Test Product',
            price: 10000,
            costPrice: 6500,
            stockQty: 10,
            isActive: true,
            createdAt: DateTime.now(),
          );

          expect(product.costPriceMoney, Money.fromCents(6500));
          expect(product.costPriceMoney!.cents, 6500);
        },
      );

      test('costPriceMoney returns null when costPrice is null', () {
        final product = Product(
          id: '1',
          storeId: 'store1',
          name: 'Test Product',
          price: 10000,
          stockQty: 10,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(product.costPrice, isNull);
        expect(product.costPriceMoney, isNull);
      });

      test('Money getters preserve precision on arithmetic', () {
        // 37.80 SAR × 3 items. The cents-int path yields exactly 11340
        // (113.40 SAR). The double path is 37.8 × 3 = 113.400000000001
        // under IEEE 754 — the whole reason C-4 exists.
        final product = Product(
          id: '1',
          storeId: 'store1',
          name: 'Test Product',
          price: 3780,
          stockQty: 10,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final total = product.priceMoney * 3;
        expect(total.cents, 11340);
        expect(total.toDouble(), 113.40);
      });
    });
  });
}
