import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;

import 'package:alhai_pos/src/providers/cart_providers.dart';
import '../helpers/pos_test_helpers.dart';

void main() {
  late MockCartPersistenceService mockPersistence;

  setUpAll(() {
    registerPosFallbackValues();
  });

  setUp(() {
    mockPersistence = MockCartPersistenceService();
    when(() => mockPersistence.loadCart()).thenAnswer((_) async => null);
    when(() => mockPersistence.saveCart(any())).thenAnswer((_) async {});
    when(() => mockPersistence.clearCart()).thenAnswer((_) async {});
    when(() => mockPersistence.saveHeldInvoice(any()))
        .thenAnswer((_) async {});
    when(() => mockPersistence.deleteHeldInvoice(any()))
        .thenAnswer((_) async {});
    when(() => mockPersistence.loadHeldInvoices())
        .thenAnswer((_) async => []);
  });

  group('PosCartItem', () {
    test('effectivePrice returns product price when no custom price', () {
      final item = createTestCartItem(price: 25.0);
      expect(item.effectivePrice, equals(25.0));
    });

    test('effectivePrice returns custom price when set', () {
      final item = createTestCartItem(price: 25.0, customPrice: 20.0);
      expect(item.effectivePrice, equals(20.0));
    });

    test('total is effectivePrice * quantity', () {
      final item = createTestCartItem(price: 10.0, quantity: 3);
      expect(item.total, equals(30.0));
    });

    test('total with custom price', () {
      final item =
          createTestCartItem(price: 10.0, quantity: 3, customPrice: 8.0);
      expect(item.total, equals(24.0));
    });

    test('copyWith updates fields', () {
      final item = createTestCartItem(price: 10.0, quantity: 2);
      final updated = item.copyWith(quantity: 5);

      expect(updated.quantity, equals(5));
      expect(updated.effectivePrice, equals(10.0));
    });

    test('copyWith clearCustomPrice removes custom price', () {
      final item =
          createTestCartItem(price: 10.0, customPrice: 8.0);
      final updated = item.copyWith(clearCustomPrice: true);

      expect(updated.customPrice, isNull);
      expect(updated.effectivePrice, equals(10.0));
    });

    test('toJson and fromJson roundtrip', () {
      final item =
          createTestCartItem(price: 15.0, quantity: 2, customPrice: 12.0);
      final json = item.toJson();
      final restored = PosCartItem.fromJson(json);

      expect(restored.product.id, equals(item.product.id));
      expect(restored.quantity, equals(2));
      expect(restored.customPrice, equals(12.0));
    });
  });

  group('CartState', () {
    test('empty cart state', () {
      const state = CartState();

      expect(state.items, isEmpty);
      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.itemCount, equals(0));
      expect(state.uniqueItemCount, equals(0));
      expect(state.subtotal, equals(0.0));
      expect(state.total, equals(0.0));
      expect(state.discount, equals(0.0));
    });

    test('itemCount sums all quantities', () {
      final state = createTestCartState(
        items: [
          createTestCartItem(productId: 'p1', quantity: 2),
          createTestCartItem(productId: 'p2', quantity: 3),
        ],
      );

      expect(state.itemCount, equals(5));
    });

    test('uniqueItemCount returns distinct products', () {
      final state = createTestCartState(
        items: [
          createTestCartItem(productId: 'p1', quantity: 2),
          createTestCartItem(productId: 'p2', quantity: 3),
          createTestCartItem(productId: 'p3', quantity: 1),
        ],
      );

      expect(state.uniqueItemCount, equals(3));
    });

    test('subtotal sums all item totals', () {
      final state = createTestCartState(
        items: [
          createTestCartItem(price: 10.0, quantity: 2), // 20
          createTestCartItem(
              productId: 'p2', price: 15.0, quantity: 1), // 15
        ],
      );

      expect(state.subtotal, equals(35.0));
    });

    test('total is subtotal minus discount', () {
      final state = createTestCartState(
        items: [
          createTestCartItem(price: 50.0, quantity: 2), // 100
        ],
        discount: 10.0,
      );

      expect(state.subtotal, equals(100.0));
      expect(state.total, equals(90.0));
    });

    test('copyWith updates fields correctly', () {
      final state = createTestCartState(discount: 5.0);
      final updated = state.copyWith(discount: 10.0);

      expect(updated.discount, equals(10.0));
      expect(updated.items.length, equals(state.items.length));
    });

    test('copyWith clearCustomer clears customer', () {
      final state = createTestCartState(
        customerId: 'c-1',
        customerName: 'Test Customer',
      );
      final updated = state.copyWith(clearCustomer: true);

      expect(updated.customerId, isNull);
      expect(updated.customerName, isNull);
    });

    test('toJson and fromJson roundtrip', () {
      final state = createTestCartState(
        discount: 5.0,
        customerId: 'c-1',
        customerName: 'Ahmed',
      );
      final json = state.toJson();
      final restored = CartState.fromJson(json);

      expect(restored.items.length, equals(state.items.length));
      expect(restored.discount, equals(5.0));
      expect(restored.customerId, equals('c-1'));
      expect(restored.customerName, equals('Ahmed'));
    });
  });

  group('CartNotifier', () {
    late CartNotifier notifier;

    setUp(() {
      notifier = CartNotifier(mockPersistence);
    });

    test('starts with empty cart', () {
      expect(notifier.state.isEmpty, isTrue);
    });

    test('addProduct adds new item', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product);

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.items.first.product.id, equals('p-1'));
      expect(notifier.state.items.first.quantity, equals(1));
    });

    test('addProduct with quantity', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product, quantity: 3);

      expect(notifier.state.items.first.quantity, equals(3));
      expect(notifier.state.subtotal, equals(30.0));
    });

    test('addProduct increments quantity for existing item', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product);
      notifier.addProduct(product);

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.items.first.quantity, equals(2));
    });

    test('addProduct with custom price', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product, customPrice: 8.0);

      expect(notifier.state.items.first.customPrice, equals(8.0));
      expect(notifier.state.items.first.effectivePrice, equals(8.0));
    });

    test('removeProduct removes item', () {
      final p1 = createTestProduct(id: 'p-1');
      final p2 = createTestProduct(id: 'p-2');
      notifier.addProduct(p1);
      notifier.addProduct(p2);
      notifier.removeProduct('p-1');

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.items.first.product.id, equals('p-2'));
    });

    test('updateQuantity changes quantity', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product);
      notifier.updateQuantity('p-1', 5);

      expect(notifier.state.items.first.quantity, equals(5));
    });

    test('updateQuantity with 0 removes item', () {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product);
      notifier.updateQuantity('p-1', 0);

      expect(notifier.state.items, isEmpty);
    });

    test('updateQuantity with negative removes item', () {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product);
      notifier.updateQuantity('p-1', -1);

      expect(notifier.state.items, isEmpty);
    });

    test('incrementQuantity adds 1', () {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product, quantity: 3);
      notifier.incrementQuantity('p-1');

      expect(notifier.state.items.first.quantity, equals(4));
    });

    test('decrementQuantity subtracts 1', () {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product, quantity: 3);
      notifier.decrementQuantity('p-1');

      expect(notifier.state.items.first.quantity, equals(2));
    });

    test('decrementQuantity from 1 removes item', () {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product, quantity: 1);
      notifier.decrementQuantity('p-1');

      expect(notifier.state.items, isEmpty);
    });

    test('setCustomPrice updates price', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product);
      notifier.setCustomPrice('p-1', 7.5);

      expect(notifier.state.items.first.customPrice, equals(7.5));
      expect(notifier.state.items.first.effectivePrice, equals(7.5));
    });

    test('setCustomPrice to null clears custom price', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product, customPrice: 8.0);
      notifier.setCustomPrice('p-1', null);

      expect(notifier.state.items.first.customPrice, isNull);
      expect(notifier.state.items.first.effectivePrice, equals(10.0));
    });

    test('setDiscount updates discount', () {
      notifier.setDiscount(15.0);
      expect(notifier.state.discount, equals(15.0));
    });

    test('setPaymentMethod updates payment method', () {
      notifier.setPaymentMethod(PaymentMethod.card);
      expect(notifier.state.paymentMethod, equals(PaymentMethod.card));
    });

    test('setCustomer updates customer info', () {
      notifier.setCustomer('c-1', customerName: 'Ahmed');

      expect(notifier.state.customerId, equals('c-1'));
      expect(notifier.state.customerName, equals('Ahmed'));
    });

    test('setCustomer with null clears customer', () {
      notifier.setCustomer('c-1', customerName: 'Ahmed');
      notifier.setCustomer(null);

      expect(notifier.state.customerId, isNull);
      expect(notifier.state.customerName, isNull);
    });

    test('setNotes updates notes', () {
      notifier.setNotes('Test note');
      expect(notifier.state.notes, equals('Test note'));
    });

    test('clear resets the cart', () {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product, quantity: 3);
      notifier.setDiscount(5.0);
      notifier.setCustomer('c-1', customerName: 'Ahmed');
      notifier.clear();

      expect(notifier.state.isEmpty, isTrue);
      expect(notifier.state.discount, equals(0.0));
      expect(notifier.state.customerId, isNull);
    });

    test('addProduct saves cart automatically', () async {
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product);

      // Allow async save to happen
      await Future.delayed(Duration.zero);

      verify(() => mockPersistence.saveCart(any())).called(greaterThan(0));
    });

    test('holdInvoice saves and clears cart', () async {
      final product = createTestProduct(id: 'p-1', price: 10.0);
      notifier.addProduct(product, quantity: 2);

      final invoice = await notifier.holdInvoice(name: 'Test Invoice');

      expect(invoice.name, equals('Test Invoice'));
      expect(invoice.cart.items.length, equals(1));
      expect(notifier.state.isEmpty, isTrue);
      verify(() => mockPersistence.saveHeldInvoice(any())).called(1);
    });

    test('restoreInvoice loads cart from held invoice', () async {
      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: createTestCartState(),
        name: 'Saved Invoice',
        createdAt: DateTime.now(),
      );

      await notifier.restoreInvoice(invoice);

      expect(notifier.state.items.length, equals(2));
      verify(() => mockPersistence.deleteHeldInvoice('inv-1')).called(1);
    });

    test('restoreInvoice holds current cart first if not empty', () async {
      // Add something to current cart
      final product = createTestProduct(id: 'p-1');
      notifier.addProduct(product);

      final invoice = HeldInvoice(
        id: 'inv-1',
        cart: createTestCartState(),
        createdAt: DateTime.now(),
      );

      await notifier.restoreInvoice(invoice);

      // Old cart should have been held
      verify(() => mockPersistence.saveHeldInvoice(any())).called(1);
      // And the held invoice deleted
      verify(() => mockPersistence.deleteHeldInvoice('inv-1')).called(1);
    });

    test('restoreFromCart directly sets state', () {
      final cart = createTestCartState();
      notifier.restoreFromCart(cart);

      expect(notifier.state.items.length, equals(2));
    });

    group('business logic calculations', () {
      test('subtotal with multiple items', () {
        notifier.addProduct(
            createTestProduct(id: 'p-1', price: 10.0), quantity: 3);
        notifier.addProduct(
            createTestProduct(id: 'p-2', price: 20.0), quantity: 2);

        // 10*3 + 20*2 = 70
        expect(notifier.state.subtotal, equals(70.0));
      });

      test('total with discount', () {
        notifier.addProduct(
            createTestProduct(id: 'p-1', price: 100.0), quantity: 1);
        notifier.setDiscount(15.0);

        expect(notifier.state.subtotal, equals(100.0));
        expect(notifier.state.total, equals(85.0));
      });

      test('total with custom prices and discount', () {
        notifier.addProduct(
          createTestProduct(id: 'p-1', price: 100.0),
          quantity: 2,
          customPrice: 80.0,
        );
        notifier.setDiscount(10.0);

        // 80*2 = 160 subtotal, 160-10 = 150 total
        expect(notifier.state.subtotal, equals(160.0));
        expect(notifier.state.total, equals(150.0));
      });
    });
  });

  group('HeldInvoice', () {
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
        cart: createTestCartState(), // 2 items: 2+1 = 3 total qty
        createdAt: DateTime.now(),
      );

      expect(invoice.description, contains('3'));
    });

    test('toJson and fromJson roundtrip', () {
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
  });

  group('HeldInvoicesNotifier', () {
    late HeldInvoicesNotifier notifier;

    setUp(() {
      when(() => mockPersistence.loadHeldInvoices())
          .thenAnswer((_) async => [
                HeldInvoice(
                  id: 'inv-1',
                  cart: const CartState(),
                  name: 'Invoice 1',
                  createdAt: DateTime.now(),
                ),
                HeldInvoice(
                  id: 'inv-2',
                  cart: const CartState(),
                  name: 'Invoice 2',
                  createdAt: DateTime.now(),
                ),
              ]);

      notifier = HeldInvoicesNotifier(mockPersistence);
    });

    test('loads invoices on init', () async {
      // Allow async loading
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.length, equals(2));
    });

    test('delete removes invoice', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.delete('inv-1');

      expect(notifier.state.length, equals(1));
      expect(notifier.state.first.id, equals('inv-2'));
      verify(() => mockPersistence.deleteHeldInvoice('inv-1')).called(1);
    });

    test('refresh reloads invoices', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.refresh();

      // loadHeldInvoices called on init + refresh
      verify(() => mockPersistence.loadHeldInvoices())
          .called(greaterThan(1));
    });
  });
}
