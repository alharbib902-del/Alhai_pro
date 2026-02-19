/// اختبارات widgets السلة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/providers/cart_providers.dart';

// ============================================================================
// SIMPLE CART WIDGETS FOR TESTING
// ============================================================================

/// عنصر سلة بسيط للاختبار
class CartItemWidget extends ConsumerWidget {
  final PosCartItem item;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(item.product.name),
        subtitle: Text('${item.quantity} × ${item.effectivePrice.toStringAsFixed(2)} ر.س'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('decrement-btn'),
              icon: const Icon(Icons.remove),
              onPressed: () => onQuantityChanged?.call(item.quantity - 1),
            ),
            Text('${item.quantity}'),
            IconButton(
              key: const Key('increment-btn'),
              icon: const Icon(Icons.add),
              onPressed: () => onQuantityChanged?.call(item.quantity + 1),
            ),
            IconButton(
              key: const Key('remove-btn'),
              icon: const Icon(Icons.delete),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// ملخص السلة للاختبار
class CartSummaryWidget extends ConsumerWidget {
  const CartSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartStateProvider).discount;
    final total = ref.watch(cartTotalProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع الفرعي:'),
                Text(
                  '${subtotal.toStringAsFixed(2)} ر.س',
                  key: const Key('subtotal-value'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الخصم:'),
                Text(
                  '${discount.toStringAsFixed(2)} ر.س',
                  key: const Key('discount-value'),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${total.toStringAsFixed(2)} ر.س',
                  key: const Key('total-value'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// زر السلة للاختبار
class CartBadgeWidget extends ConsumerWidget {
  final VoidCallback? onTap;

  const CartBadgeWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    final isEmpty = ref.watch(isCartEmptyProvider);

    return Stack(
      children: [
        IconButton(
          key: const Key('cart-icon'),
          icon: const Icon(Icons.shopping_cart),
          onPressed: onTap,
        ),
        if (!isEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              key: const Key('cart-badge'),
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$itemCount',
                key: const Key('cart-count'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// TEST DATA
// ============================================================================

Product _createTestProduct({
  String? id,
  String? name,
  double? price,
}) {
  return Product(
    id: id ?? 'product-1',
    storeId: 'store-1',
    name: name ?? 'منتج اختبار',
    price: price ?? 25.0,
    stockQty: 100,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('CartItemWidget', () {
    testWidgets('يعرض معلومات المنتج', (tester) async {
      final product = _createTestProduct(name: 'تفاح', price: 15.0);
      final item = PosCartItem(product: product, quantity: 3);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartItemWidget(item: item),
            ),
          ),
        ),
      );

      expect(find.text('تفاح'), findsOneWidget);
      expect(find.text('3 × 15.00 ر.س'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('يستدعي onRemove عند الضغط على زر الحذف', (tester) async {
      final product = _createTestProduct();
      final item = PosCartItem(product: product);
      var removed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartItemWidget(
                item: item,
                onRemove: () => removed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('remove-btn')));
      expect(removed, isTrue);
    });

    testWidgets('يستدعي onQuantityChanged عند الزيادة', (tester) async {
      final product = _createTestProduct();
      final item = PosCartItem(product: product, quantity: 2);
      int? newQuantity;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartItemWidget(
                item: item,
                onQuantityChanged: (qty) => newQuantity = qty,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('increment-btn')));
      expect(newQuantity, 3);
    });

    testWidgets('يستدعي onQuantityChanged عند الإنقاص', (tester) async {
      final product = _createTestProduct();
      final item = PosCartItem(product: product, quantity: 5);
      int? newQuantity;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartItemWidget(
                item: item,
                onQuantityChanged: (qty) => newQuantity = qty,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('decrement-btn')));
      expect(newQuantity, 4);
    });
  });

  group('CartSummaryWidget', () {
    testWidgets('يعرض القيم الصحيحة عندما السلة فارغة', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CartSummaryWidget()),
          ),
        ),
      );

      expect(find.byKey(const Key('subtotal-value')), findsOneWidget);
      expect(find.text('0.00 ر.س'), findsNWidgets(3)); // subtotal, discount, total
    });

    testWidgets('يعرض القيم الصحيحة بعد إضافة منتجات', (tester) async {
      final container = ProviderContainer();

      // إضافة منتجات
      final product = _createTestProduct(price: 50.0);
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 2);
      container.read(cartStateProvider.notifier).setDiscount(10.0);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: CartSummaryWidget()),
          ),
        ),
      );

      expect(find.text('100.00 ر.س'), findsOneWidget); // subtotal
      expect(find.text('10.00 ر.س'), findsOneWidget); // discount
      expect(find.text('90.00 ر.س'), findsOneWidget); // total
    });
  });

  group('CartBadgeWidget', () {
    testWidgets('لا يعرض الشارة عندما السلة فارغة', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CartBadgeWidget()),
          ),
        ),
      );

      expect(find.byKey(const Key('cart-icon')), findsOneWidget);
      expect(find.byKey(const Key('cart-badge')), findsNothing);
    });

    testWidgets('يعرض الشارة مع العدد الصحيح', (tester) async {
      final container = ProviderContainer();

      final product = _createTestProduct();
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 5);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: CartBadgeWidget()),
          ),
        ),
      );

      expect(find.byKey(const Key('cart-badge')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('يستدعي onTap عند الضغط', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartBadgeWidget(onTap: () => tapped = true),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('cart-icon')));
      expect(tapped, isTrue);
    });

    testWidgets('يُحدّث الشارة عند تغيير السلة', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: CartBadgeWidget()),
          ),
        ),
      );

      // السلة فارغة في البداية
      expect(find.byKey(const Key('cart-badge')), findsNothing);

      // إضافة منتج
      final product = _createTestProduct();
      container.read(cartStateProvider.notifier).addProduct(product, quantity: 3);

      await tester.pump();

      // الشارة تظهر الآن
      expect(find.byKey(const Key('cart-badge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
