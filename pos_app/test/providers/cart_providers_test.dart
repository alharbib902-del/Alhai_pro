/// اختبارات مزودات السلة
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/providers/cart_providers.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

class MockCartPersistenceService extends Mock implements CartPersistenceService {}

class FakeCartState extends Fake implements CartState {}

// ============================================================================
// TEST DATA
// ============================================================================

void setUpTestFallbacks() {
  registerFallbackValue(FakeCartState());
}

Product _createTestProduct({
  String? id,
  String? name,
  double? price,
  int? stockQty,
}) {
  return Product(
    id: id ?? 'product-1',
    storeId: 'store-1',
    name: name ?? 'منتج اختبار',
    price: price ?? 25.0,
    stockQty: stockQty ?? 100,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  setUpAll(() {
    setUpTestFallbacks();
  });

  group('PosCartItem', () {
    test('يحسب السعر الفعلي بشكل صحيح', () {
      final product = _createTestProduct(price: 50.0);
      final item = PosCartItem(product: product, quantity: 2);

      expect(item.effectivePrice, 50.0);
      expect(item.total, 100.0);
    });

    test('يستخدم السعر المخصص إذا تم تحديده', () {
      final product = _createTestProduct(price: 50.0);
      final item = PosCartItem(
        product: product,
        quantity: 2,
        customPrice: 40.0,
      );

      expect(item.effectivePrice, 40.0);
      expect(item.total, 80.0);
    });

    test('copyWith يعمل بشكل صحيح', () {
      final product = _createTestProduct();
      final item = PosCartItem(product: product, quantity: 1);
      final newItem = item.copyWith(quantity: 5);

      expect(newItem.quantity, 5);
      expect(newItem.product, product);
    });
  });

  group('CartState', () {
    test('الحالة الأولية صحيحة', () {
      const state = CartState();

      expect(state.items, isEmpty);
      expect(state.discount, 0);
      expect(state.paymentMethod, PaymentMethod.cash);
      expect(state.customerId, isNull);
      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.itemCount, 0);
      expect(state.uniqueItemCount, 0);
      expect(state.subtotal, 0);
      expect(state.total, 0);
    });

    test('يحسب itemCount بشكل صحيح', () {
      final product1 = _createTestProduct(id: 'p1');
      final product2 = _createTestProduct(id: 'p2');

      final state = CartState(
        items: [
          PosCartItem(product: product1, quantity: 3),
          PosCartItem(product: product2, quantity: 2),
        ],
      );

      expect(state.itemCount, 5);
      expect(state.uniqueItemCount, 2);
    });

    test('يحسب subtotal و total بشكل صحيح', () {
      final product1 = _createTestProduct(id: 'p1', price: 10.0);
      final product2 = _createTestProduct(id: 'p2', price: 20.0);

      final state = CartState(
        items: [
          PosCartItem(product: product1, quantity: 2), // 20
          PosCartItem(product: product2, quantity: 3), // 60
        ],
        discount: 10.0,
      );

      expect(state.subtotal, 80.0);
      expect(state.total, 70.0);
    });
  });

  group('CartNotifier', () {
    late CartNotifier notifier;
    late MockCartPersistenceService mockPersistence;

    setUp(() {
      mockPersistence = MockCartPersistenceService();
      // Mock loadCart to return null (empty cart on startup)
      when(() => mockPersistence.loadCart()).thenAnswer((_) async => null);
      // Mock saveCart to do nothing
      when(() => mockPersistence.saveCart(any())).thenAnswer((_) async {});
      // Mock clearCart to do nothing
      when(() => mockPersistence.clearCart()).thenAnswer((_) async {});

      notifier = CartNotifier(mockPersistence);
    });

    test('الحالة الأولية فارغة', () {
      expect(notifier.state.isEmpty, isTrue);
    });

    group('addProduct', () {
      test('يضيف منتج جديد للسلة', () {
        final product = _createTestProduct();

        notifier.addProduct(product);

        expect(notifier.state.items.length, 1);
        expect(notifier.state.items.first.product, product);
        expect(notifier.state.items.first.quantity, 1);
      });

      test('يضيف منتج بكمية محددة', () {
        final product = _createTestProduct();

        notifier.addProduct(product, quantity: 5);

        expect(notifier.state.items.first.quantity, 5);
      });

      test('يضيف منتج بسعر مخصص', () {
        final product = _createTestProduct(price: 50.0);

        notifier.addProduct(product, customPrice: 40.0);

        expect(notifier.state.items.first.customPrice, 40.0);
        expect(notifier.state.items.first.effectivePrice, 40.0);
      });

      test('يزيد الكمية إذا كان المنتج موجود', () {
        final product = _createTestProduct();

        notifier.addProduct(product, quantity: 2);
        notifier.addProduct(product, quantity: 3);

        expect(notifier.state.items.length, 1);
        expect(notifier.state.items.first.quantity, 5);
      });
    });

    group('removeProduct', () {
      test('يزيل المنتج من السلة', () {
        final product = _createTestProduct();
        notifier.addProduct(product);

        notifier.removeProduct(product.id);

        expect(notifier.state.isEmpty, isTrue);
      });

      test('لا يفعل شيء إذا المنتج غير موجود', () {
        final product = _createTestProduct();
        notifier.addProduct(product);

        notifier.removeProduct('non-existent');

        expect(notifier.state.items.length, 1);
      });
    });

    group('updateQuantity', () {
      test('يُحدّث الكمية', () {
        final product = _createTestProduct();
        notifier.addProduct(product);

        notifier.updateQuantity(product.id, 10);

        expect(notifier.state.items.first.quantity, 10);
      });

      test('يزيل المنتج إذا كانت الكمية صفر', () {
        final product = _createTestProduct();
        notifier.addProduct(product);

        notifier.updateQuantity(product.id, 0);

        expect(notifier.state.isEmpty, isTrue);
      });

      test('يزيل المنتج إذا كانت الكمية سالبة', () {
        final product = _createTestProduct();
        notifier.addProduct(product);

        notifier.updateQuantity(product.id, -1);

        expect(notifier.state.isEmpty, isTrue);
      });
    });

    group('incrementQuantity', () {
      test('يزيد الكمية بواحد', () {
        final product = _createTestProduct();
        notifier.addProduct(product, quantity: 3);

        notifier.incrementQuantity(product.id);

        expect(notifier.state.items.first.quantity, 4);
      });
    });

    group('decrementQuantity', () {
      test('ينقص الكمية بواحد', () {
        final product = _createTestProduct();
        notifier.addProduct(product, quantity: 3);

        notifier.decrementQuantity(product.id);

        expect(notifier.state.items.first.quantity, 2);
      });

      test('يزيل المنتج إذا وصلت الكمية لصفر', () {
        final product = _createTestProduct();
        notifier.addProduct(product, quantity: 1);

        notifier.decrementQuantity(product.id);

        expect(notifier.state.isEmpty, isTrue);
      });
    });

    group('setCustomPrice', () {
      test('يُعيّن سعر مخصص', () {
        final product = _createTestProduct(price: 50.0);
        notifier.addProduct(product);

        notifier.setCustomPrice(product.id, 35.0);

        expect(notifier.state.items.first.customPrice, 35.0);
      });

      test('يُزيل السعر المخصص عند تمرير null', () {
        final product = _createTestProduct(price: 50.0);
        notifier.addProduct(product, customPrice: 35.0);

        notifier.setCustomPrice(product.id, null);

        expect(notifier.state.items.first.customPrice, isNull);
      });
    });

    group('setDiscount', () {
      test('يُعيّن الخصم', () {
        notifier.setDiscount(15.0);

        expect(notifier.state.discount, 15.0);
      });
    });

    group('setPaymentMethod', () {
      test('يُعيّن طريقة الدفع', () {
        notifier.setPaymentMethod(PaymentMethod.card);

        expect(notifier.state.paymentMethod, PaymentMethod.card);
      });
    });

    group('setCustomer', () {
      test('يُعيّن العميل', () {
        notifier.setCustomer('customer-123');

        expect(notifier.state.customerId, 'customer-123');
      });
    });

    group('setNotes', () {
      test('يُعيّن الملاحظات', () {
        notifier.setNotes('ملاحظة اختبار');

        expect(notifier.state.notes, 'ملاحظة اختبار');
      });
    });

    group('clear', () {
      test('يُفرّغ السلة بالكامل', () {
        final product = _createTestProduct();
        notifier.addProduct(product, quantity: 5);
        notifier.setDiscount(10.0);
        notifier.setCustomer('customer-1');
        notifier.setNotes('note');

        notifier.clear();

        expect(notifier.state.isEmpty, isTrue);
        expect(notifier.state.discount, 0);
        expect(notifier.state.customerId, isNull);
        expect(notifier.state.notes, isNull);
      });
    });
  });

  group('Provider Integration', () {
    late MockCartPersistenceService mockPersistence;

    setUp(() {
      mockPersistence = MockCartPersistenceService();
      when(() => mockPersistence.loadCart()).thenAnswer((_) async => null);
      when(() => mockPersistence.saveCart(any())).thenAnswer((_) async {});
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          cartPersistenceProvider.overrideWithValue(mockPersistence),
        ],
      );
    }

    test('cartItemCountProvider يُرجع عدد العناصر', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final product = _createTestProduct();
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 3);

      expect(container.read(cartItemCountProvider), 3);
    });

    test('cartSubtotalProvider يُرجع المجموع الفرعي', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final product = _createTestProduct(price: 25.0);
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 4);

      expect(container.read(cartSubtotalProvider), 100.0);
    });

    test('cartTotalProvider يُرجع الإجمالي بعد الخصم', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final product = _createTestProduct(price: 25.0);
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 4);
      container.read(cartStateProvider.notifier).setDiscount(20.0);

      expect(container.read(cartTotalProvider), 80.0);
    });

    test('isCartEmptyProvider يُرجع القيمة الصحيحة', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(isCartEmptyProvider), isTrue);

      container.read(cartStateProvider.notifier).addProduct(_createTestProduct());

      expect(container.read(isCartEmptyProvider), isFalse);
    });

    test('isProductInCartProvider يتحقق من وجود المنتج', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final product = _createTestProduct(id: 'test-product');
      container.read(cartStateProvider.notifier).addProduct(product);

      expect(container.read(isProductInCartProvider('test-product')), isTrue);
      expect(container.read(isProductInCartProvider('other-product')), isFalse);
    });

    test('cartItemByProductIdProvider يُرجع عنصر السلة', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final product = _createTestProduct(id: 'test-product');
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 7);

      final item = container.read(cartItemByProductIdProvider('test-product'));

      expect(item, isNotNull);
      expect(item?.quantity, 7);

      final notFound = container.read(cartItemByProductIdProvider('not-found'));
      expect(notFound, isNull);
    });
  });
}
