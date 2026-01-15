import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cart Model', () {
    test('should calculate total correctly', () {
      final cart = Cart(
        items: [
          CartItem(productId: '1', name: 'Item 1', unitPrice: 10.0, qty: 2),
          CartItem(productId: '2', name: 'Item 2', unitPrice: 25.0, qty: 1),
        ],
      );

      expect(cart.total, 45.0);
    });

    test('should calculate item count correctly', () {
      final cart = Cart(
        items: [
          CartItem(productId: '1', name: 'Item 1', unitPrice: 10.0, qty: 2),
          CartItem(productId: '2', name: 'Item 2', unitPrice: 25.0, qty: 3),
        ],
      );

      expect(cart.itemCount, 5);
    });

    test('should detect empty cart correctly', () {
      const cart = Cart();

      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
    });

    test('should detect non-empty cart correctly', () {
      final cart = Cart(
        items: [
          CartItem(productId: '1', name: 'Item 1', unitPrice: 10.0, qty: 1),
        ],
      );

      expect(cart.isEmpty, isFalse);
      expect(cart.isNotEmpty, isTrue);
    });
  });

  group('CartItem Model', () {
    test('should calculate line total correctly', () {
      const item = CartItem(
        productId: '1',
        name: 'Test Item',
        unitPrice: 15.0,
        qty: 3,
      );

      expect(item.lineTotal, 45.0);
    });

    test('should convert to OrderItem correctly', () {
      const cartItem = CartItem(
        productId: '1',
        name: 'Test Item',
        unitPrice: 15.0,
        qty: 3,
      );

      final orderItem = cartItem.toOrderItem();

      expect(orderItem.productId, '1');
      expect(orderItem.name, 'Test Item');
      expect(orderItem.unitPrice, 15.0);
      expect(orderItem.qty, 3);
      expect(orderItem.lineTotal, 45.0);
    });
  });
}
