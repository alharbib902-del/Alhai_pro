import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/customers/create_invoice_screen.dart';

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

  group('CreateInvoiceScreen', () {
    testWidgets('renders without crashing', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CreateInvoiceScreen), findsOneWidget);
    });

    testWidgets('shows customer card with person icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      // Person icon for customer card
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('shows items card with shopping bag icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      // Shopping bag icon for items card
      expect(find.byIcon(Icons.shopping_bag_rounded), findsOneWidget);
    });

    testWidgets('shows totals card with calculator icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      // Calculator icon for totals card
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    });

    testWidgets('has finalize and save as draft buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Finalize Invoice'), findsOneWidget);
      expect(find.text('Save as Draft'), findsOneWidget);
    });

    testWidgets('finalize button is disabled when no items or customer',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester
          .pumpWidget(createTestWidget(const CreateInvoiceScreen()));
      await tester.pumpAndSettle();

      // Finalize button should be disabled
      // Use ancestor finder because FilledButton.icon creates a subclass
      final filledButtonFinder = find.ancestor(
        of: find.text('Finalize Invoice'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(filledButtonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(filledButtonFinder);
      expect(button.onPressed, isNull);
    });
  });
}
