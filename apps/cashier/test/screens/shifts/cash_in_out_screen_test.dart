import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/shifts/cash_in_out_screen.dart';

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

  group('CashInOutScreen', () {
    testWidgets('shows loading when openShiftProvider is loading',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final completer = Completer<ShiftsTableData?>();

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith(
            (ref) => completer.future,
          ),
        ],
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(null);
    });

    testWidgets('shows no-shift message when no open shift', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => null),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
    });

    testWidgets('shows type selector with cash in/out options',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
        ],
      ));
      await tester.pumpAndSettle();

      // Type selector icon
      expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
      // Cash in icon (selected by default)
      expect(find.byIcon(Icons.add_circle_rounded), findsWidgets);
      // Cash out icon
      expect(find.byIcon(Icons.remove_circle_rounded), findsWidgets);
    });

    testWidgets('shows amount input field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
        ],
      ));
      await tester.pumpAndSettle();

      // Amount card icon
      expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
      // At least one text field for amount
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows reason card with note icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
        ],
      ));
      await tester.pumpAndSettle();

      // Reason card icon
      expect(find.byIcon(Icons.note_alt_rounded), findsOneWidget);
    });

    testWidgets('shows denomination counter button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const CashInOutScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
        ],
      ));
      await tester.pumpAndSettle();

      // Calculator icon for denomination counter
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
    });
  });
}
