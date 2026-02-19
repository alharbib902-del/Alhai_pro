/// اختبارات شاشة نقطة البيع
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:pos_app/providers/cart_providers.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockProductsRepository extends Mock implements ProductsRepository {}

// ============================================================================
// TEST HELPERS
// ============================================================================

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

Widget _createTestWidget({
  required Widget child,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Cart UI Tests', () {
    testWidgets('السلة الفارغة تعرض رسالة مناسبة', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final isEmpty = ref.watch(isCartEmptyProvider);
              return Scaffold(
                body: Center(
                  child: isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64),
                            SizedBox(height: 16),
                            Text('السلة فارغة'),
                          ],
                        )
                      : const Text('توجد عناصر'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('السلة فارغة'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('إضافة منتج تُحدّث عدد السلة', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartItemCountProvider);
              final product = _createTestProduct();

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('العدد: $count'),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product);
                      },
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('العدد: 0'), findsOneWidget);

      await tester.tap(find.text('إضافة'));
      await tester.pump();

      expect(find.text('العدد: 1'), findsOneWidget);

      await tester.tap(find.text('إضافة'));
      await tester.pump();

      expect(find.text('العدد: 2'), findsOneWidget);
    });

    testWidgets('إزالة منتج تُحدّث السلة', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartItemCountProvider);
              final product = _createTestProduct(id: 'test-product');

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('العدد: $count'),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product, quantity: 3);
                      },
                      child: const Text('إضافة'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).removeProduct('test-product');
                      },
                      child: const Text('إزالة'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // إضافة منتج
      await tester.tap(find.text('إضافة'));
      await tester.pump();
      expect(find.text('العدد: 3'), findsOneWidget);

      // إزالة المنتج
      await tester.tap(find.text('إزالة'));
      await tester.pump();
      expect(find.text('العدد: 0'), findsOneWidget);
    });

    testWidgets('تعديل الكمية يعمل بشكل صحيح', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartStateProvider);
              final product = _createTestProduct(id: 'test-product');
              final quantity = cartState.items.isEmpty ? 0 : cartState.items.first.quantity;

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('الكمية: $quantity'),
                    ElevatedButton(
                      key: const Key('add'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product);
                      },
                      child: const Text('إضافة'),
                    ),
                    ElevatedButton(
                      key: const Key('increment'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).incrementQuantity('test-product');
                      },
                      child: const Text('زيادة'),
                    ),
                    ElevatedButton(
                      key: const Key('decrement'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).decrementQuantity('test-product');
                      },
                      child: const Text('إنقاص'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // إضافة منتج
      await tester.tap(find.byKey(const Key('add')));
      await tester.pump();
      expect(find.text('الكمية: 1'), findsOneWidget);

      // زيادة الكمية
      await tester.tap(find.byKey(const Key('increment')));
      await tester.pump();
      expect(find.text('الكمية: 2'), findsOneWidget);

      await tester.tap(find.byKey(const Key('increment')));
      await tester.pump();
      expect(find.text('الكمية: 3'), findsOneWidget);

      // إنقاص الكمية
      await tester.tap(find.byKey(const Key('decrement')));
      await tester.pump();
      expect(find.text('الكمية: 2'), findsOneWidget);
    });

    testWidgets('عرض الإجمالي مع الضريبة', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartStateProvider);
              final subtotal = cartState.subtotal;
              final tax = subtotal * 0.15;
              final total = subtotal + tax - cartState.discount;
              final product = _createTestProduct(price: 100.0);

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('المجموع: ${subtotal.toStringAsFixed(2)}'),
                    Text('الضريبة: ${tax.toStringAsFixed(2)}'),
                    Text('الإجمالي: ${total.toStringAsFixed(2)}'),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product, quantity: 2);
                      },
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('المجموع: 0.00'), findsOneWidget);
      expect(find.text('الضريبة: 0.00'), findsOneWidget);
      expect(find.text('الإجمالي: 0.00'), findsOneWidget);

      await tester.tap(find.text('إضافة'));
      await tester.pump();

      expect(find.text('المجموع: 200.00'), findsOneWidget);
      expect(find.text('الضريبة: 30.00'), findsOneWidget);
      expect(find.text('الإجمالي: 230.00'), findsOneWidget);
    });

    testWidgets('تطبيق الخصم يُحدّث الإجمالي', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartStateProvider);
              final total = cartState.total;
              final discount = cartState.discount;
              final product = _createTestProduct(price: 100.0);

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('الخصم: ${discount.toStringAsFixed(2)}'),
                    Text('الإجمالي: ${total.toStringAsFixed(2)}'),
                    ElevatedButton(
                      key: const Key('add'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product);
                      },
                      child: const Text('إضافة'),
                    ),
                    ElevatedButton(
                      key: const Key('discount'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).setDiscount(20.0);
                      },
                      child: const Text('خصم'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // إضافة منتج
      await tester.tap(find.byKey(const Key('add')));
      await tester.pump();
      expect(find.text('الإجمالي: 100.00'), findsOneWidget);

      // تطبيق خصم
      await tester.tap(find.byKey(const Key('discount')));
      await tester.pump();
      expect(find.text('الخصم: 20.00'), findsOneWidget);
      expect(find.text('الإجمالي: 80.00'), findsOneWidget);
    });

    testWidgets('مسح السلة يُفرغها بالكامل', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final isEmpty = ref.watch(isCartEmptyProvider);
              final product = _createTestProduct();

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isEmpty ? 'فارغة' : 'غير فارغة'),
                    ElevatedButton(
                      key: const Key('add'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).addProduct(product, quantity: 5);
                        ref.read(cartStateProvider.notifier).setDiscount(10);
                        ref.read(cartStateProvider.notifier).setCustomer('customer-1');
                        ref.read(cartStateProvider.notifier).setNotes('ملاحظة');
                      },
                      child: const Text('إضافة'),
                    ),
                    ElevatedButton(
                      key: const Key('clear'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).clear();
                      },
                      child: const Text('مسح'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('فارغة'), findsOneWidget);

      // إضافة عناصر
      await tester.tap(find.byKey(const Key('add')));
      await tester.pump();
      expect(find.text('غير فارغة'), findsOneWidget);

      // مسح السلة
      await tester.tap(find.byKey(const Key('clear')));
      await tester.pump();
      expect(find.text('فارغة'), findsOneWidget);
    });
  });

  group('Product Card Tests', () {
    testWidgets('بطاقة المنتج تعرض المعلومات الصحيحة', (tester) async {
      final product = _createTestProduct(
        name: 'تفاح أحمر',
        price: 15.50,
        stockQty: 50,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.name),
                    Text('${product.price.toStringAsFixed(2)} ر.س'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('تفاح أحمر'), findsOneWidget);
      expect(find.text('15.50 ر.س'), findsOneWidget);
    });

    testWidgets('المنتج النافذ يظهر بشكل مختلف', (tester) async {
      final product = _createTestProduct(stockQty: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Column(
                children: [
                  if (product.isOutOfStock)
                    const Text('نفذ المخزون'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('نفذ المخزون'), findsOneWidget);
    });
  });

  group('Category Filter Tests', () {
    testWidgets('تصفية التصنيفات تعمل بشكل صحيح', (tester) async {
      String? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      Wrap(
                        children: [
                          FilterChip(
                            label: const Text('الكل'),
                            selected: selectedCategory == null,
                            onSelected: (_) {
                              setState(() => selectedCategory = null);
                            },
                          ),
                          FilterChip(
                            label: const Text('فواكه'),
                            selected: selectedCategory == 'fruits',
                            onSelected: (_) {
                              setState(() => selectedCategory = 'fruits');
                            },
                          ),
                          FilterChip(
                            label: const Text('خضروات'),
                            selected: selectedCategory == 'vegetables',
                            onSelected: (_) {
                              setState(() => selectedCategory = 'vegetables');
                            },
                          ),
                        ],
                      ),
                      Text('التصنيف: ${selectedCategory ?? 'الكل'}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('التصنيف: الكل'), findsOneWidget);

      await tester.tap(find.text('فواكه'));
      await tester.pump();
      expect(find.text('التصنيف: fruits'), findsOneWidget);

      await tester.tap(find.text('خضروات'));
      await tester.pump();
      expect(find.text('التصنيف: vegetables'), findsOneWidget);

      await tester.tap(find.text('الكل'));
      await tester.pump();
      expect(find.text('التصنيف: الكل'), findsOneWidget);
    });
  });

  group('Payment Method Tests', () {
    testWidgets('تغيير طريقة الدفع يعمل', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          child: Consumer(
            builder: (context, ref, _) {
              final paymentMethod = ref.watch(cartStateProvider).paymentMethod;

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('الطريقة: ${paymentMethod.name}'),
                    ElevatedButton(
                      key: const Key('cash'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).setPaymentMethod(PaymentMethod.cash);
                      },
                      child: const Text('نقد'),
                    ),
                    ElevatedButton(
                      key: const Key('card'),
                      onPressed: () {
                        ref.read(cartStateProvider.notifier).setPaymentMethod(PaymentMethod.card);
                      },
                      child: const Text('بطاقة'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('الطريقة: cash'), findsOneWidget);

      await tester.tap(find.byKey(const Key('card')));
      await tester.pump();
      expect(find.text('الطريقة: card'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cash')));
      await tester.pump();
      expect(find.text('الطريقة: cash'), findsOneWidget);
    });
  });
}
