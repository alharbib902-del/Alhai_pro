library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/reports/payment_reports_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockSalesDao salesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    salesDao = MockSalesDao();

    // Wave 8 (P0-33): screen now uses a single SQL aggregate
    // (`aggregatePaymentBreakdownRaw`) instead of pulling rows then
    // folding in Dart. Default stub returns the empty breakdown so
    // tests don't have to spell it out.
    when(
      () => salesDao.aggregatePaymentBreakdownRaw(
        any(),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => RawPaymentBreakdown.empty);

    final db = setupMockDatabase(salesDao: salesDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('PaymentReportsScreen', () {
    testWidgets('renders with empty orders', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentReportsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Wave 8 (P0-33): the screen now awaits the SQL aggregate, not
      // a row-list fetch. Hold its future to keep the loading state
      // visible while we assert.
      final completer = Completer<RawPaymentBreakdown>();
      when(
        () => salesDao.aggregatePaymentBreakdownRaw(
          any(),
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const PaymentReportsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(RawPaymentBreakdown.empty);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const PaymentReportsScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentReportsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentReportsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has date filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentReportsScreen()));
      await tester.pumpAndSettle();

      // Payment reports has date filter options rendered as custom InkWell chips
      expect(find.byType(InkWell), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
