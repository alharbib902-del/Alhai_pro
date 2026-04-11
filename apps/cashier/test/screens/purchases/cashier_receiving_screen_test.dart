library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/purchases/cashier_receiving_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockPurchasesDao purchasesDao;
  late MockProductsDao productsDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    purchasesDao = MockPurchasesDao();
    productsDao = MockProductsDao();

    // CashierReceivingScreen uses:
    //   _db.purchasesDao.getPurchasesByStatus(storeId, 'approved')
    when(
      () => purchasesDao.getPurchasesByStatus(any(), any()),
    ).thenAnswer((_) async => []);

    final db = setupMockDatabase(
      purchasesDao: purchasesDao,
      productsDao: productsDao,
    );
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('CashierReceivingScreen', () {
    testWidgets('renders with empty purchases', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const CashierReceivingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CashierReceivingScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<PurchasesTableData>>();
      when(
        () => purchasesDao.getPurchasesByStatus(any(), any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const CashierReceivingScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const CashierReceivingScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierReceivingScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const CashierReceivingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CashierReceivingScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('calls getPurchasesByStatus on init', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const CashierReceivingScreen()));
      await tester.pumpAndSettle();

      verify(
        () => purchasesDao.getPurchasesByStatus(any(), 'approved'),
      ).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
