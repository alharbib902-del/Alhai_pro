import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Model', () {
    test('should calculate profit margin correctly', () {
      final product = Product(
        id: '1',
        storeId: 'store1',
        name: 'Test Product',
        price: 100.0,
        costPrice: 60.0,
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
        price: 100.0,
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
        price: 100.0,
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
        price: 100.0,
        stockQty: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(product.isOutOfStock, isTrue);
    });
  });
}
