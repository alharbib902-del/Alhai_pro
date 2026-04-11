import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiCartItem', () {
    testWidgets('renders title and price', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCartItem(
            title: 'Apple Juice',
            priceAmount: 15.0,
            currency: 'SAR',
            quantity: 2,
            onQuantityChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Apple Juice'), findsOneWidget);
    });

    testWidgets('shows quantity control', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCartItem(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            quantity: 3,
            onQuantityChanged: (_) {},
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows remove button when onRemove is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCartItem(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            quantity: 1,
            onRemove: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('calls onRemove when delete is tapped', (tester) async {
      var removed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCartItem(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            quantity: 1,
            onRemove: () => removed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();

      expect(removed, isTrue);
    });

    testWidgets('renders leading widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCartItem(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            quantity: 1,
            leading: Icon(Icons.shopping_bag),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCartItem(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            quantity: 1,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Product'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
