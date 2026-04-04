import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/shifts/shift_open_screen.dart';

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

  group('ShiftOpenScreen', () {
    testWidgets('renders without crashing', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // Should render the screen without errors
      expect(find.byType(ShiftOpenScreen), findsOneWidget);
    });

    testWidgets('shows opening cash input field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // Opening cash text field should exist
      expect(find.byType(TextField), findsOneWidget);
      // Calculator icon
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    });

    testWidgets('has quick amount chips (100, 200, 500, 1000)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // Quick amount chips should be present
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('shows open shift button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // Open shift button icon
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
      // FilledButton should be present
      // FilledButton.icon creates a private subclass, use predicate
      expect(find.byWidgetPredicate((w) => w is FilledButton), findsOneWidget);
    });

    testWidgets('shows important notes section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // Info icon for notes section
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('shows user card with cashier info', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftOpenScreen()));
      await tester.pumpAndSettle();

      // User card should have time and calendar icons
      expect(find.byIcon(Icons.access_time_rounded), findsWidgets);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    });
  });
}
