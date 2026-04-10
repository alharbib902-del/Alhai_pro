import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiProductCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const SizedBox(
          width: 200,
          child: AlhaiProductCard(
            title: 'Apple Juice',
            priceAmount: 15.0,
            currency: 'SAR',
            ctaMode: AlhaiProductCardCtaMode.none,
          ),
        ),
      ));

      expect(find.text('Apple Juice'), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createTestWidget(
        SizedBox(
          width: 200,
          child: AlhaiProductCard(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            ctaMode: AlhaiProductCardCtaMode.none,
            onTap: () => tapped = true,
          ),
        ),
      ));

      await tester.tap(find.text('Product'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows discount label when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const SizedBox(
          width: 200,
          child: AlhaiProductCard(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            ctaMode: AlhaiProductCardCtaMode.none,
            originalPriceAmount: 15.0,
            discountLabel: '-20%',
          ),
        ),
      ));

      expect(find.text('-20%'), findsOneWidget);
    });

    testWidgets('shows add button when ctaMode is add', (tester) async {
      await tester.pumpWidget(createTestWidget(
        SizedBox(
          width: 200,
          child: AlhaiProductCard(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            ctaMode: AlhaiProductCardCtaMode.add,
            addButtonLabel: 'Add',
            onAdd: () {},
          ),
        ),
      ));

      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('shows quantity control when ctaMode is quantity',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        SizedBox(
          width: 200,
          child: AlhaiProductCard(
            title: 'Product',
            priceAmount: 10.0,
            currency: 'SAR',
            ctaMode: AlhaiProductCardCtaMode.quantity,
            quantity: 3,
            onQuantityChanged: (_) {},
          ),
        ),
      ));

      expect(find.text('3'), findsOneWidget);
    });

    test('AlhaiProductCardCtaMode has expected values', () {
      expect(AlhaiProductCardCtaMode.values.length, 3);
      expect(AlhaiProductCardCtaMode.values,
          contains(AlhaiProductCardCtaMode.add));
      expect(AlhaiProductCardCtaMode.values,
          contains(AlhaiProductCardCtaMode.quantity));
      expect(AlhaiProductCardCtaMode.values,
          contains(AlhaiProductCardCtaMode.none));
    });
  });
}
