/// Unit tests for held_invoices_providers
///
/// Tests: dbHeldInvoicesCountProvider, HeldInvoice model behavior
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_pos/src/providers/cart_providers.dart';
import 'package:alhai_pos/src/providers/held_invoices_providers.dart';

import '../helpers/pos_test_helpers.dart';

void main() {
  group('dbHeldInvoicesCountProvider', () {
    test('returns 0 when invoices list is empty', () {
      final container = ProviderContainer(
        overrides: [
          dbHeldInvoicesListProvider.overrideWith((ref) => Future.value([])),
        ],
      );
      addTearDown(container.dispose);

      // Allow the future to complete
      container.read(dbHeldInvoicesListProvider);
      final count = container.read(dbHeldInvoicesCountProvider);

      // Before data loads, returns 0
      expect(count, equals(0));
    });
  });

  group('HeldInvoice model integration', () {
    test('description returns name when set', () {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: const CartState(),
        name: 'Custom Name',
        createdAt: DateTime.now(),
      );

      expect(invoice.description, equals('Custom Name'));
    });

    test('description returns customer name when no invoice name', () {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: createTestCartState(customerName: 'Ahmed'),
        createdAt: DateTime.now(),
      );

      expect(invoice.description, equals('Ahmed'));
    });

    test('description returns item count when no names', () {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: createTestCartState(),
        createdAt: DateTime.now(),
      );

      expect(invoice.description, contains('3'));
    });

    test('HeldInvoice toJson and fromJson roundtrip', () {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: createTestCartState(discount: 5.0),
        name: 'Test',
        createdAt: DateTime(2026, 1, 15, 10, 30),
      );

      final json = invoice.toJson();
      final restored = HeldInvoice.fromJson(json);

      expect(restored.id, equals('inv-1'));
      expect(restored.name, equals('Test'));
      expect(restored.cart.discount, equals(5.0));
      expect(restored.createdAt, equals(DateTime(2026, 1, 15, 10, 30)));
    });

    test('HeldInvoice with empty cart', () {
      final invoice = HeldInvoice(
        id: 'inv-empty',
        cart: const CartState(),
        createdAt: DateTime.now(),
      );

      expect(invoice.cart.isEmpty, isTrue);
      expect(invoice.cart.itemCount, equals(0));
    });

    test('HeldInvoice cart preserves items', () {
      final cart = createTestCartState(
        items: [
          createTestCartItem(
            productId: 'p1',
            productName: 'Product A',
            price: 1000,
            quantity: 3,
          ),
        ],
      );

      final invoice = HeldInvoice(
        id: 'inv-items',
        cart: cart,
        createdAt: DateTime.now(),
      );

      expect(invoice.cart.items.length, equals(1));
      expect(invoice.cart.items.first.product.name, equals('Product A'));
      expect(invoice.cart.items.first.quantity, equals(3));
    });

    test('HeldInvoice with null name', () {
      final invoice = HeldInvoice(
        id: 'inv-no-name',
        cart: const CartState(),
        createdAt: DateTime.now(),
      );

      expect(invoice.name, isNull);
    });
  });
}
