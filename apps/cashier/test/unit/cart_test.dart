import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:alhai_pos/alhai_pos.dart';

/// Helper to create a Product for cart tests
Product _product({
  String id = 'p1',
  String name = 'Test Product',
  double price = 25.0,
  double stockQty = 100,
}) {
  return Product(
    id: id,
    storeId: 'store-1',
    name: name,
    price: price,
    stockQty: stockQty,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  // ==========================================================================
  // PosCartItem
  // ==========================================================================
  group('PosCartItem', () {
    test('effectivePrice returns product price when no custom price', () {
      final item = PosCartItem(product: _product(price: 50.0));
      expect(item.effectivePrice, equals(50.0));
    });

    test('effectivePrice returns custom price when set', () {
      final item = PosCartItem(
        product: _product(price: 50.0),
        customPrice: 40.0,
      );
      expect(item.effectivePrice, equals(40.0));
    });

    test('total = effectivePrice * quantity', () {
      final item = PosCartItem(product: _product(price: 30.0), quantity: 3);
      expect(item.total, equals(90.0));
    });

    test('total with custom price', () {
      final item = PosCartItem(
        product: _product(price: 30.0),
        quantity: 4,
        customPrice: 20.0,
      );
      expect(item.total, equals(80.0));
    });

    test('default quantity is 1', () {
      final item = PosCartItem(product: _product());
      expect(item.quantity, equals(1));
    });

    test('JSON roundtrip preserves all fields', () {
      final item = PosCartItem(
        product: _product(id: 'p99', price: 15.5),
        quantity: 3,
        customPrice: 12.0,
      );
      final json = item.toJson();
      final restored = PosCartItem.fromJson(json);

      expect(restored.product.id, equals('p99'));
      expect(restored.quantity, equals(3));
      expect(restored.customPrice, equals(12.0));
      expect(restored.effectivePrice, equals(12.0));
    });
  });

  // ==========================================================================
  // CartState
  // ==========================================================================
  group('CartState', () {
    group('empty cart', () {
      test('default state is empty', () {
        const cart = CartState();
        expect(cart.isEmpty, isTrue);
        expect(cart.isNotEmpty, isFalse);
        expect(cart.itemCount, equals(0));
        expect(cart.uniqueItemCount, equals(0));
        expect(cart.subtotal, equals(0.0));
        expect(cart.total, equals(0.0));
      });
    });

    group('subtotal & total calculations', () {
      test('subtotal sums all item totals', () {
        final cart = CartState(
          items: [
            PosCartItem(
              product: _product(id: 'a', price: 10.0),
              quantity: 2,
            ), // 20
            PosCartItem(
              product: _product(id: 'b', price: 15.0),
              quantity: 3,
            ), // 45
          ],
        );
        expect(cart.subtotal, equals(65.0));
      });

      test('total = subtotal - discount', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 100.0), quantity: 1)],
          discount: 20.0,
        );
        expect(cart.subtotal, equals(100.0));
        expect(cart.total, equals(80.0));
      });

      test('total equals subtotal when no discount', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 50.0), quantity: 2)],
        );
        expect(cart.total, equals(cart.subtotal));
        expect(cart.total, equals(100.0));
      });
    });

    group('itemCount & uniqueItemCount', () {
      test('itemCount sums quantities', () {
        final cart = CartState(
          items: [
            PosCartItem(product: _product(id: 'a'), quantity: 3),
            PosCartItem(product: _product(id: 'b'), quantity: 2),
          ],
        );
        expect(cart.itemCount, equals(5));
      });

      test('uniqueItemCount counts distinct products', () {
        final cart = CartState(
          items: [
            PosCartItem(product: _product(id: 'a'), quantity: 3),
            PosCartItem(product: _product(id: 'b'), quantity: 2),
            PosCartItem(product: _product(id: 'c'), quantity: 1),
          ],
        );
        expect(cart.uniqueItemCount, equals(3));
      });
    });

    group('discount', () {
      test('flat discount reduces total', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 200.0), quantity: 1)],
          discount: 50.0,
        );
        expect(cart.total, equals(150.0));
      });

      test('percentage discount simulation (manually set amount)', () {
        // 10% of 200 = 20
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 200.0), quantity: 1)],
          discount: 20.0,
        );
        expect(cart.total, equals(180.0));
      });

      test('zero discount leaves total unchanged', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 100.0), quantity: 1)],
          discount: 0.0,
        );
        expect(cart.total, equals(100.0));
      });
    });

    group('edge cases', () {
      test('product with zero price', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 0.0), quantity: 5)],
        );
        expect(cart.subtotal, equals(0.0));
        expect(cart.total, equals(0.0));
      });

      test('single item with quantity 1', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 99.99), quantity: 1)],
        );
        expect(cart.subtotal, closeTo(99.99, 0.001));
        expect(cart.itemCount, equals(1));
      });

      test('large quantity', () {
        final cart = CartState(
          items: [PosCartItem(product: _product(price: 5.0), quantity: 1000)],
        );
        expect(cart.subtotal, equals(5000.0));
      });
    });

    group('copyWith', () {
      test('preserves existing values', () {
        final original = CartState(
          items: [PosCartItem(product: _product(), quantity: 2)],
          discount: 10.0,
          customerId: 'c1',
          customerName: 'Test Customer',
        );
        final copy = original.copyWith(discount: 15.0);

        expect(copy.items.length, equals(1));
        expect(copy.discount, equals(15.0));
        expect(copy.customerId, equals('c1'));
        expect(copy.customerName, equals('Test Customer'));
      });

      test('clearCustomer removes customer info', () {
        final cart = CartState(
          items: [],
          customerId: 'c1',
          customerName: 'Name',
        );
        final cleared = cart.copyWith(clearCustomer: true);

        expect(cleared.customerId, isNull);
        expect(cleared.customerName, isNull);
      });
    });

    group('JSON serialization', () {
      test('roundtrip preserves state', () {
        final cart = CartState(
          items: [
            PosCartItem(product: _product(id: 'p1', price: 25.0), quantity: 3),
            PosCartItem(
              product: _product(id: 'p2', price: 10.0),
              quantity: 1,
              customPrice: 8.0,
            ),
          ],
          discount: 5.0,
          customerId: 'cust-1',
          customerName: 'أحمد',
          notes: 'test note',
        );

        final json = cart.toJson();
        final restored = CartState.fromJson(json);

        expect(restored.items.length, equals(2));
        expect(restored.subtotal, equals(cart.subtotal));
        expect(restored.discount, equals(5.0));
        expect(restored.customerId, equals('cust-1'));
        expect(restored.customerName, equals('أحمد'));
        expect(restored.notes, equals('test note'));
      });

      test('fromJson handles missing fields gracefully', () {
        final cart = CartState.fromJson({});
        expect(cart.isEmpty, isTrue);
        expect(cart.discount, equals(0.0));
      });
    });
  });

  // ==========================================================================
  // HeldInvoice
  // ==========================================================================
  group('HeldInvoice', () {
    test('description returns name when set', () {
      final invoice = HeldInvoice(
        id: '1',
        cart: CartState(items: [PosCartItem(product: _product(), quantity: 2)]),
        name: 'VIP Order',
        createdAt: DateTime.now(),
      );
      expect(invoice.description, equals('VIP Order'));
    });

    test('description returns customer name when no invoice name', () {
      final invoice = HeldInvoice(
        id: '1',
        cart: CartState(
          items: [PosCartItem(product: _product(), quantity: 1)],
          customerName: 'محمد',
        ),
        createdAt: DateTime.now(),
      );
      expect(invoice.description, equals('محمد'));
    });

    test('description returns item count when no name or customer', () {
      final invoice = HeldInvoice(
        id: '1',
        cart: CartState(items: [PosCartItem(product: _product(), quantity: 3)]),
        createdAt: DateTime.now(),
      );
      expect(invoice.description, contains('3'));
    });

    test('JSON roundtrip', () {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: CartState(
          items: [PosCartItem(product: _product(), quantity: 2)],
          discount: 5.0,
        ),
        name: 'Test Invoice',
        createdAt: DateTime(2026, 3, 1, 12, 0),
      );

      final json = invoice.toJson();
      final restored = HeldInvoice.fromJson(json);

      expect(restored.id, equals('inv-1'));
      expect(restored.name, equals('Test Invoice'));
      expect(restored.cart.items.length, equals(1));
      expect(restored.cart.discount, equals(5.0));
      expect(restored.createdAt.year, equals(2026));
    });
  });
}
