import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/dashboard/top_selling_list.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  final sampleProducts = [
    const TopSellingProduct(
      id: '1',
      name: 'Arabic Coffee',
      soldCount: 100,
      revenue: 5000,
      category: 'Drinks',
    ),
    const TopSellingProduct(
      id: '2',
      name: 'Cake',
      soldCount: 50,
      revenue: 2500,
      category: 'Food',
    ),
  ];

  group('TopSellingProduct', () {
    test('stores properties correctly', () {
      const product = TopSellingProduct(
        id: 'p1',
        name: 'Test Product',
        soldCount: 42,
        revenue: 1000,
        category: 'Cat1',
      );
      expect(product.id, 'p1');
      expect(product.name, 'Test Product');
      expect(product.soldCount, 42);
      expect(product.revenue, 1000);
      expect(product.category, 'Cat1');
      expect(product.imageUrl, isNull);
    });
  });

  group('TopSellingList', () {
    testWidgets('renders product names', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(TopSellingList(products: sampleProducts)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Arabic Coffee'), findsOneWidget);
      expect(find.text('Cake'), findsOneWidget);
    });

    testWidgets('renders view all button when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          TopSellingList(products: sampleProducts, onViewAll: () {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('limits display to 5 products', (tester) async {
      final manyProducts = List.generate(
        8,
        (i) => TopSellingProduct(
          id: '$i',
          name: 'Product $i',
          soldCount: i * 10,
          revenue: i * 100.0,
        ),
      );
      await tester.pumpWidget(
        createSimpleTestWidget(TopSellingList(products: manyProducts)),
      );
      await tester.pumpAndSettle();
      // Should only show first 5
      expect(find.text('Product 0'), findsOneWidget);
      expect(find.text('Product 4'), findsOneWidget);
      expect(find.text('Product 5'), findsNothing);
    });

    testWidgets('renders with empty list', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const TopSellingList(products: [])),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TopSellingList), findsOneWidget);
    });
  });
}
