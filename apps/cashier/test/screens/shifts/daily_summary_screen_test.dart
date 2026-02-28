import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/shifts/daily_summary_screen.dart';

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

  group('DailySummaryScreen', () {
    testWidgets('shows loading when todayShiftsProvider is loading',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final completer = Completer<List<ShiftsTableData>>();

      await tester.pumpWidget(createTestWidget(
        const DailySummaryScreen(),
        overrides: [
          todayShiftsProvider.overrideWith(
            (ref) => completer.future,
          ),
        ],
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
    });

    testWidgets('shows no-shifts message when empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const DailySummaryScreen(),
        overrides: [
          todayShiftsProvider.overrideWith((ref) async => <ShiftsTableData>[]),
        ],
      ));
      await tester.pumpAndSettle();

      // No shifts icon
      expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
    });

    testWidgets('displays stats cards with shift data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shifts = [
        createTestShift(
          id: 'shift-1',
          totalSales: 10,
          totalSalesAmount: 1500.0,
          totalRefunds: 1,
          totalRefundsAmount: 100.0,
          openingCash: 500.0,
        ),
        createTestShift(
          id: 'shift-2',
          totalSales: 5,
          totalSalesAmount: 800.0,
          totalRefunds: 0,
          totalRefundsAmount: 0.0,
          openingCash: 300.0,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        const DailySummaryScreen(),
        overrides: [
          todayShiftsProvider.overrideWith((ref) async => shifts),
        ],
      ));
      await tester.pumpAndSettle();

      // Stats cards should show trending up (total sales)
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      // Returns icon
      expect(find.byIcon(Icons.assignment_return_rounded), findsOneWidget);
      // Wallet icon for net revenue
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('shows shift items in the shifts table', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shifts = [
        createTestShift(
          id: 'shift-1',
          cashierName: '\u0643\u0627\u0634\u064a\u0631 1',
          totalSales: 5,
          totalSalesAmount: 500.0,
          status: 'closed',
          closedAt: DateTime(2026, 1, 15, 16, 0),
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        const DailySummaryScreen(),
        overrides: [
          todayShiftsProvider.overrideWith((ref) async => shifts),
        ],
      ));
      await tester.pumpAndSettle();

      // Shifts table header icon
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('shows summary card with aggregated data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final shifts = [
        createTestShift(
          id: 'shift-1',
          totalSalesAmount: 1000.0,
          totalRefundsAmount: 50.0,
          openingCash: 500.0,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        const DailySummaryScreen(),
        overrides: [
          todayShiftsProvider.overrideWith((ref) async => shifts),
        ],
      ));
      await tester.pumpAndSettle();

      // Summary card icon
      expect(find.byIcon(Icons.summarize_rounded), findsOneWidget);
    });
  });
}
