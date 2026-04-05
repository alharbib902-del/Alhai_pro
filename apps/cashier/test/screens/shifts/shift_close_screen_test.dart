import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/shifts/shift_close_screen.dart';

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

  group('ShiftCloseScreen', () {
    testWidgets('shows loading when openShiftProvider is loading',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final completer = Completer<ShiftsTableData?>();

      await tester.pumpWidget(createTestWidget(
        const ShiftCloseScreen(),
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
        const ShiftCloseScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => null),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
    });

    testWidgets('displays shift info when shift is open', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(
        id: 'shift-1',
        cashierName: '\u0643\u0627\u0634\u064a\u0631',
        openingCash: 500.0,
        totalSalesAmount: 1200.0,
        totalRefundsAmount: 100.0,
      );

      await tester.pumpWidget(createTestWidget(
        const ShiftCloseScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
          shiftMovementsProvider(shift.id).overrideWith(
            (ref) async => <CashMovementsTableData>[],
          ),
          shiftCashTotalsProvider(shift.id).overrideWith(
            (ref) async => (cashSales: 1200.0, cashRefunds: 100.0),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Shift info card should show
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      // Sales summary card
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('shows actual cash input field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const ShiftCloseScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
          shiftMovementsProvider(shift.id).overrideWith(
            (ref) async => <CashMovementsTableData>[],
          ),
          shiftCashTotalsProvider(shift.id).overrideWith(
            (ref) async => (cashSales: 0.0, cashRefunds: 0.0),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // Actual cash input field
      expect(find.byType(TextField), findsOneWidget);
      // Money icon prefix
      expect(find.byIcon(Icons.money_rounded), findsOneWidget);
    });

    testWidgets('close button is disabled when input is empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shift = createTestShift(id: 'shift-1');

      await tester.pumpWidget(createTestWidget(
        const ShiftCloseScreen(),
        overrides: [
          openShiftProvider.overrideWith((ref) async => shift),
          shiftMovementsProvider(shift.id).overrideWith(
            (ref) async => <CashMovementsTableData>[],
          ),
          shiftCashTotalsProvider(shift.id).overrideWith(
            (ref) async => (cashSales: 0.0, cashRefunds: 0.0),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // FilledButton.icon() creates a _FilledButtonWithIcon subclass,
      // so use byWidgetPredicate to find it.
      final buttonFinder = find.byWidgetPredicate(
        (w) => w is FilledButton,
      );
      expect(buttonFinder, findsWidgets);
      // The close button with lock icon should be disabled (onPressed == null)
      final button = tester.widget<FilledButton>(buttonFinder.last);
      expect(button.onPressed, isNull);
    });
  });
}
