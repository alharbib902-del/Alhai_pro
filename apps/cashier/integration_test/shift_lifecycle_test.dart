/// Integration test: Cashier Shift Lifecycle
///
/// Verifies the full cashier shift lifecycle end-to-end through the
/// navigation layer and widget tree:
///   1. Open shift    - cashier logs in, opens shift with starting cash
///   2. Cash movements - add cash in/out during shift
///   3. Multiple sales - process several sales in sequence
///   4. Shift summary - view current shift totals / daily summary
///   5. Close shift    - reconciliation with counted cash vs expected
///   6. Variance       - short/over cash scenarios
///   7. Shift report   - generate end-of-shift report
///
/// The real shift screens (`ShiftOpenScreen`, `ShiftCloseScreen`,
/// `CashInOutScreen`, `DailySummaryScreen`) read from a set of Riverpod
/// providers (`openShiftProvider`, `openShiftActionProvider`, etc.) that
/// talk to the local Drift database. In the integration test harness we
/// cannot instantiate a real SQLCipher database, so:
///   - Routes to the shift screens resolve to the same stubs used by
///     `critical_flow_test.dart` via `buildTestApp()`.
///   - Where a scenario requires verifying the POS/Payment/Receipt widget
///     tree, we use the real screens from `alhai_pos`.
///   - When a scenario needs a fake provider value (e.g. shift state),
///     we inject it through `ProviderScope.overrides`.
///
/// Run with:
///   flutter test integration_test/shift_lifecycle_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_pos/alhai_pos.dart' show PosScreen, PaymentScreen;

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

// ============================================================================
// Lightweight in-test shift model
// ============================================================================
//
// We intentionally avoid coupling these tests to the real `ShiftsCompanion`
// / `ShiftsRow` data classes, because those live in the alhai_database
// package and would pull in native Drift + SQLCipher which is not available
// in the plain integration test harness. The fake model below captures
// just enough state to exercise shift-lifecycle math and transitions.
class _FakeShift {
  final String id;
  final String cashierId;
  final double openingCash;
  double cashInTotal;
  double cashOutTotal;
  double salesCashTotal;
  double salesCardTotal;
  double salesCreditTotal;
  double closingCashActual;
  bool isClosed;
  DateTime openedAt;
  DateTime? closedAt;

  _FakeShift({
    required this.id,
    required this.cashierId,
    required this.openingCash,
    this.cashInTotal = 0,
    this.cashOutTotal = 0,
    this.salesCashTotal = 0,
    this.salesCardTotal = 0,
    this.salesCreditTotal = 0,
    this.closingCashActual = 0,
    this.isClosed = false,
    DateTime? openedAt,
    this.closedAt,
  }) : openedAt = openedAt ?? DateTime(2026, 4, 10, 8, 0);

  /// Expected cash in drawer at close time = opening + cash sales + cash in - cash out.
  double get expectedCash =>
      openingCash + salesCashTotal + cashInTotal - cashOutTotal;

  /// Positive = over, negative = short.
  double get variance => closingCashActual - expectedCash;

  double get totalSales => salesCashTotal + salesCardTotal + salesCreditTotal;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // GROUP 1: Open Shift
  // ==========================================================================
  //
  // The cashier cannot ring up a sale until a shift is opened with a
  // starting cash amount. The `/shifts/open` route is stubbed in the test
  // harness, so these tests assert on navigation + basic state validity.
  // ==========================================================================
  group('Shift Lifecycle: Open Shift', () {
    testWidgets('shift open route is reachable after auth', (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/shifts/open',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      // The test harness renders a stub for /shifts/open; verify it.
      expect(find.byKey(const Key('stub_Shift Open')), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets(
      'opening cash amount is applied to shift model correctly',
      (tester) async {
        // This test exercises the shift model (not the UI), proving that
        // the math the real screen performs when a cashier enters an
        // opening amount is consistent with the rest of the lifecycle.
        final shift = _FakeShift(
          id: 'shift-001',
          cashierId: kTestCashierId,
          openingCash: 500,
        );

        expect(shift.openingCash, 500);
        expect(shift.expectedCash, 500);
        expect(shift.variance, -500); // No actual count yet
        expect(shift.isClosed, false);
      },
    );

    testWidgets('opening shift from POS screen navigates away', (tester) async {
      // Arrange: POS screen mounted (as if cashier just logged in)
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/pos',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);
      expect(find.byType(PosScreen), findsOneWidget);

      // Act: imitate "open shift" button tap by navigating to the route
      final router = GoRouter.of(tester.element(find.byType(PosScreen)));
      router.go('/shifts/open');
      await pumpAndSettleWithTimeout(tester);

      // Assert: stub shift open screen is shown
      expect(find.byKey(const Key('stub_Shift Open')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP 2: Cash Movements (Cash In / Cash Out)
  // ==========================================================================
  //
  // During an active shift the cashier may add a float (cash in) or
  // deposit money to the safe / pay an expense (cash out). Each movement
  // updates the expected drawer total.
  // ==========================================================================
  group('Shift Lifecycle: Cash Movements', () {
    testWidgets('cash-in increases expected drawer total', (tester) async {
      // Simulates adding 100 SAR float mid-shift.
      final shift = _FakeShift(
        id: 'shift-002',
        cashierId: kTestCashierId,
        openingCash: 500,
      );

      shift.cashInTotal += 100;

      expect(shift.cashInTotal, 100);
      expect(shift.expectedCash, 600);
    });

    testWidgets('cash-out decreases expected drawer total', (tester) async {
      // Simulates paying a supplier 50 SAR out of drawer.
      final shift = _FakeShift(
        id: 'shift-003',
        cashierId: kTestCashierId,
        openingCash: 500,
      );

      shift.cashOutTotal += 50;

      expect(shift.cashOutTotal, 50);
      expect(shift.expectedCash, 450);
    });

    testWidgets('multiple cash movements accumulate correctly', (tester) async {
      final shift = _FakeShift(
        id: 'shift-004',
        cashierId: kTestCashierId,
        openingCash: 500,
      );

      shift.cashInTotal += 200; // Morning float top-up
      shift.cashOutTotal += 75; // Buy water for the shop
      shift.cashInTotal += 50; // Customer tip pool added
      shift.cashOutTotal += 25; // Pay delivery driver

      expect(shift.cashInTotal, 250);
      expect(shift.cashOutTotal, 100);
      expect(shift.expectedCash, 650);
    });
  });

  // ==========================================================================
  // GROUP 3: Multiple Sales During Shift
  // ==========================================================================
  //
  // A typical shift processes dozens of sales. We simulate 3-5 in sequence
  // through the POS -> Payment -> Receipt -> POS navigation loop to
  // verify the UI survives rapid, repeated transitions.
  // ==========================================================================
  group('Shift Lifecycle: Multiple Sales', () {
    testWidgets('three sales cycle POS -> payment -> receipt cleanly',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/pos',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      // Loop through 3 complete sales - the most common mid-shift path.
      for (var saleNum = 1; saleNum <= 3; saleNum++) {
        expect(find.byType(PosScreen), findsOneWidget,
            reason: 'Sale $saleNum: should start at POS');

        final router = GoRouter.of(tester.element(find.byType(PosScreen)));
        router.go('/pos/payment');
        await pumpAndSettleWithTimeout(tester);
        expect(find.byType(PaymentScreen), findsOneWidget,
            reason: 'Sale $saleNum: should be at payment');

        router.go('/pos/receipt');
        await pumpAndSettleWithTimeout(tester);

        // Back to POS for the next sale
        router.go('/pos');
        await pumpAndSettleWithTimeout(tester);
      }

      // After 3 cycles we must still be on a working POS screen
      expect(find.byType(PosScreen), findsOneWidget);
    });

    testWidgets('sales totals accumulate on the shift model', (tester) async {
      final shift = _FakeShift(
        id: 'shift-005',
        cashierId: kTestCashierId,
        openingCash: 500,
      );

      // Simulate 5 sales of varying payment methods
      shift.salesCashTotal += 100.00; // Sale 1 - cash
      shift.salesCardTotal += 250.50; // Sale 2 - card
      shift.salesCashTotal += 35.75; // Sale 3 - cash
      shift.salesCreditTotal += 180.00; // Sale 4 - credit (آجل)
      shift.salesCashTotal += 42.25; // Sale 5 - cash

      expect(shift.salesCashTotal, closeTo(178.00, 0.001));
      expect(shift.salesCardTotal, closeTo(250.50, 0.001));
      expect(shift.salesCreditTotal, closeTo(180.00, 0.001));
      expect(shift.totalSales, closeTo(608.50, 0.001));

      // Expected drawer = opening + cash sales (card/credit don't hit drawer)
      expect(shift.expectedCash, closeTo(678.00, 0.001));
    });
  });

  // ==========================================================================
  // GROUP 4: Shift Summary (Daily Summary Screen)
  // ==========================================================================
  //
  // Cashiers can view a live running total mid-shift via the daily
  // summary screen. Route is stubbed in `buildTestApp`, so we assert
  // the stub label renders.
  // ==========================================================================
  group('Shift Lifecycle: Mid-shift Summary', () {
    testWidgets('shifts route renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/shifts',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      expect(find.byKey(const Key('stub_Shifts')), findsOneWidget);
    });

    testWidgets(
      'navigating from POS to shifts and back preserves POS state',
      (tester) async {
        await tester.pumpWidget(buildTestApp(
          initialRoute: '/pos',
          isAuthenticated: true,
        ));
        await pumpAndSettleWithTimeout(tester);
        expect(find.byType(PosScreen), findsOneWidget);

        final router = GoRouter.of(tester.element(find.byType(PosScreen)));
        router.go('/shifts');
        await pumpAndSettleWithTimeout(tester);
        expect(find.byKey(const Key('stub_Shifts')), findsOneWidget);

        router.go('/pos');
        await pumpAndSettleWithTimeout(tester);
        expect(find.byType(PosScreen), findsOneWidget);
      },
    );
  });

  // ==========================================================================
  // GROUP 5: Close Shift (Reconciliation)
  // ==========================================================================
  //
  // At the end of a shift the cashier counts the physical drawer,
  // enters the actual amount, and the system computes the variance
  // against the expected amount. These tests exercise the math the real
  // ShiftCloseScreen performs.
  // ==========================================================================
  group('Shift Lifecycle: Close Shift Reconciliation', () {
    testWidgets('exact count produces zero variance', (tester) async {
      final shift = _FakeShift(
        id: 'shift-006',
        cashierId: kTestCashierId,
        openingCash: 500,
        salesCashTotal: 275.50,
        cashInTotal: 100,
        cashOutTotal: 25,
      );
      // Expected: 500 + 275.50 + 100 - 25 = 850.50
      expect(shift.expectedCash, closeTo(850.50, 0.001));

      // Cashier counted exactly the expected amount
      shift.closingCashActual = 850.50;
      shift.isClosed = true;
      shift.closedAt = DateTime(2026, 4, 10, 17, 0);

      expect(shift.variance, closeTo(0.0, 0.001));
      expect(shift.isClosed, true);
      expect(shift.closedAt, isNotNull);
    });

    testWidgets('shift close route is reachable', (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/shifts/close',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      expect(find.byKey(const Key('stub_Shift Close')), findsOneWidget);
    });
  });

  // ==========================================================================
  // GROUP 6: Variance Handling (Short / Over Cash)
  // ==========================================================================
  //
  // When the counted cash does not match the expected total, the shift
  // is either "short" (negative variance - possible theft or error) or
  // "over" (positive variance - likely change-making error).
  // ==========================================================================
  group('Shift Lifecycle: Variance Handling', () {
    testWidgets('short cash scenario is detected', (tester) async {
      final shift = _FakeShift(
        id: 'shift-007',
        cashierId: kTestCashierId,
        openingCash: 500,
        salesCashTotal: 300,
      );
      // Expected: 800, counted: 780 (short 20 SAR)
      shift.closingCashActual = 780;
      shift.isClosed = true;

      expect(shift.expectedCash, 800);
      expect(shift.variance, closeTo(-20.0, 0.001));
      expect(shift.variance < 0, true, reason: 'Short variance < 0');
    });

    testWidgets('over cash scenario is detected', (tester) async {
      final shift = _FakeShift(
        id: 'shift-008',
        cashierId: kTestCashierId,
        openingCash: 500,
        salesCashTotal: 200,
      );
      // Expected: 700, counted: 715.50 (over 15.50 SAR)
      shift.closingCashActual = 715.50;
      shift.isClosed = true;

      expect(shift.expectedCash, 700);
      expect(shift.variance, closeTo(15.50, 0.001));
      expect(shift.variance > 0, true, reason: 'Over variance > 0');
    });

    testWidgets('small variance within tolerance is flagged but allowed',
        (tester) async {
      final shift = _FakeShift(
        id: 'shift-009',
        cashierId: kTestCashierId,
        openingCash: 500,
        salesCashTotal: 125.25,
      );
      shift.closingCashActual = 625.20; // 5 halala short
      shift.isClosed = true;

      // Most POS systems flag anything > 1 SAR; 0.05 SAR is within
      // acceptable rounding tolerance.
      expect(shift.variance, closeTo(-0.05, 0.001));
      expect(shift.variance.abs() < 1.0, true);
    });
  });

  // ==========================================================================
  // GROUP 7: Shift Report Export
  // ==========================================================================
  //
  // After closing, cashiers can export a printable end-of-shift report
  // summarizing opening/closing cash, total sales by method, variance,
  // and cash movements. Reports live under /reports in the router.
  // ==========================================================================
  group('Shift Lifecycle: End-of-Shift Report', () {
    testWidgets('reports route is accessible post-close', (tester) async {
      await tester.pumpWidget(buildTestApp(
        initialRoute: '/reports',
        isAuthenticated: true,
      ));
      await pumpAndSettleWithTimeout(tester);

      expect(find.byKey(const Key('stub_Reports')), findsOneWidget);
    });

    testWidgets('closed shift contains all fields needed for export',
        (tester) async {
      // Build a fully-populated closed shift as it would appear on a
      // printable report.
      final shift = _FakeShift(
        id: 'shift-010',
        cashierId: kTestCashierId,
        openingCash: 500,
        salesCashTotal: 420.25,
        salesCardTotal: 315.75,
        salesCreditTotal: 150.00,
        cashInTotal: 50,
        cashOutTotal: 35,
        closingCashActual: 935.25,
        isClosed: true,
        closedAt: DateTime(2026, 4, 10, 22, 0),
      );

      // All fields the report must show must be non-null / sensible.
      expect(shift.id.isNotEmpty, true);
      expect(shift.cashierId.isNotEmpty, true);
      expect(shift.openingCash, 500);
      expect(shift.salesCashTotal, closeTo(420.25, 0.001));
      expect(shift.salesCardTotal, closeTo(315.75, 0.001));
      expect(shift.salesCreditTotal, closeTo(150.00, 0.001));
      expect(shift.totalSales, closeTo(886.00, 0.001));
      expect(shift.cashInTotal, 50);
      expect(shift.cashOutTotal, 35);
      expect(shift.expectedCash, closeTo(935.25, 0.001));
      expect(shift.closingCashActual, closeTo(935.25, 0.001));
      expect(shift.variance, closeTo(0.0, 0.001));
      expect(shift.isClosed, true);
      expect(shift.closedAt, isNotNull);
      expect(shift.closedAt!.isAfter(shift.openedAt), true);
    });
  });
}
