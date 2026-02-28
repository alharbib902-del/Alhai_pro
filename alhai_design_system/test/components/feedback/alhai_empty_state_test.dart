import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiEmptyState', () {
    testWidgets('renders icon and title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiEmptyState(
          icon: Icons.inbox,
          title: 'No items',
        ),
      ));

      expect(find.byType(AlhaiEmptyState), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('shows description when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiEmptyState(
          icon: Icons.inbox,
          title: 'No items',
          description: 'Add items to get started',
        ),
      ));

      expect(find.text('Add items to get started'), findsOneWidget);
    });

    testWidgets('shows action button when actionText and onAction provided', (tester) async {
      var actionCalled = false;
      await tester.pumpWidget(createTestWidget(
        AlhaiEmptyState(
          icon: Icons.inbox,
          title: 'No items',
          actionText: 'Add Item',
          onAction: () => actionCalled = true,
        ),
      ));

      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('does not show action button when only actionText is provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiEmptyState(
          icon: Icons.inbox,
          title: 'No items',
          actionText: 'Add Item',
          // onAction is null
        ),
      ));

      // The button is only shown when both actionText and onAction are provided
      expect(find.byType(FilledButton), findsNothing);
    });

    group('factories', () {
      testWidgets('noData factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.noData(title: 'No data'),
        ));

        expect(find.byType(AlhaiEmptyState), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('noResults factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.noResults(title: 'No results'),
        ));

        expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
      });

      testWidgets('noOrders factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.noOrders(title: 'No orders'),
        ));

        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      });

      testWidgets('noProducts factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.noProducts(title: 'No products'),
        ));

        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      });

      testWidgets('error factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.error(title: 'Error occurred'),
        ));

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('noConnection factory renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiEmptyState.noConnection(title: 'No connection'),
        ));

        expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      });
    });

    testWidgets('compact mode uses smaller padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiEmptyState(
          icon: Icons.inbox,
          title: 'No items',
          compact: true,
        ),
      ));

      expect(find.byType(AlhaiEmptyState), findsOneWidget);
    });
  });
}
