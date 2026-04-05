import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/sales/exchange_screen.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('ExchangeScreen', () {
    testWidgets('renders without crashing', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      // Screen should render the Exchange title
      expect(find.text('Exchange'), findsOneWidget);
    });

    testWidgets('shows return and new items sections', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      // Both sections should be present
      expect(find.text('Items to Return'), findsOneWidget);
      expect(find.text('New Items to Add'), findsOneWidget);
    });

    testWidgets('has two search bars for return and new items', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      // Two search fields (one for return, one for new items)
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('shows difference and submit button in bottom bar',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Difference'), findsOneWidget);
      // Arabic l10n: submitExchange
      expect(
          find.text(
              '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0627\u0633\u062a\u0628\u062f\u0627\u0644'),
          findsOneWidget);
    });

    testWidgets('submit button is disabled when no items', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      // FilledButton.icon() creates a _FilledButtonWithIcon subclass,
      // so use byWidgetPredicate to find it.
      final buttonFinder = find.byWidgetPredicate((w) => w is FilledButton);
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('shows return and new items section icons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ExchangeScreen()));
      await tester.pumpAndSettle();

      // Return section icon
      expect(find.byIcon(Icons.assignment_return_rounded), findsOneWidget);
      // New items section icon
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);
    });
  });
}
