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

    // P1 #1/#2/#3 (2026-04-24): screen now pushes date filter down to SQL via
    // `getSalesByDateRange`. Default stub for both entry points.
    when(
      () => salesDao.getSalesByDateRange(
        any(),
        any(),
        any(),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => <SalesTableData>[]);
    when(
      () => salesDao.getAllSales(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => <SalesTableData>[]);

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

      final completer = Completer<List<SalesTableData>>();
      // Default filter is 'today' → dates are non-null → the screen calls
      // `getSalesByDateRange`, not `getAllSales`. Hold its future.
      when(
        () => salesDao.getSalesByDateRange(
          any(),
          any(),
          any(),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const PaymentReportsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(<SalesTableData>[]);

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
