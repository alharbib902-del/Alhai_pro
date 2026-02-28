import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiPriceText', () {
    testWidgets('renders price with currency', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText(amount: 25.50, currency: 'SAR'),
      ));

      expect(find.byType(AlhaiPriceText), findsOneWidget);
      expect(find.textContaining('25.5'), findsOneWidget);
      expect(find.textContaining('SAR'), findsOneWidget);
    });

    testWidgets('renders whole number without decimals', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText(amount: 100, currency: 'SAR'),
      ));

      // Should show "100 SAR" (no decimal for whole numbers)
      expect(find.text('100 SAR'), findsOneWidget);
    });

    testWidgets('renders with decimal', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText(amount: 99.99, currency: 'SAR'),
      ));

      expect(find.textContaining('99.99'), findsOneWidget);
    });

    testWidgets('shows original price with strikethrough when discounted', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText(
          amount: 75,
          currency: 'SAR',
          originalAmount: 100,
        ),
      ));

      // Both prices should be present
      expect(find.textContaining('75'), findsAtLeast(1));
      expect(find.textContaining('100'), findsAtLeast(1));
    });

    testWidgets('does not show original price when not discounted', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText(
          amount: 100,
          currency: 'SAR',
          originalAmount: 50, // original < current => no discount
        ),
      ));

      // Only the current price should be a simple Text widget (not a Row)
      expect(find.text('100 SAR'), findsOneWidget);
    });

    testWidgets('compact variant renders', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiPriceText.compact(amount: 50, currency: 'SAR'),
      ));

      expect(find.byType(AlhaiPriceText), findsOneWidget);
    });

    group('size variants', () {
      testWidgets('regular size renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiPriceText(
            amount: 10,
            currency: 'SAR',
            size: AlhaiPriceTextSize.regular,
          ),
        ));

        expect(find.byType(AlhaiPriceText), findsOneWidget);
      });

      testWidgets('large size renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiPriceText(
            amount: 10,
            currency: 'SAR',
            size: AlhaiPriceTextSize.large,
          ),
        ));

        expect(find.byType(AlhaiPriceText), findsOneWidget);
      });

      testWidgets('compact size renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiPriceText(
            amount: 10,
            currency: 'SAR',
            size: AlhaiPriceTextSize.compact,
          ),
        ));

        expect(find.byType(AlhaiPriceText), findsOneWidget);
      });
    });
  });
}
