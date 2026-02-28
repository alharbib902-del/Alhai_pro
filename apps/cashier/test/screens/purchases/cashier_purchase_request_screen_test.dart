library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/purchases/cashier_purchase_request_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockProductsDao productsDao;
  late MockPurchasesDao purchasesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    purchasesDao = MockPurchasesDao();

    // CashierPurchaseRequestScreen uses:
    //   _db.productsDao.searchProducts(query, storeId) on search
    //   _db.purchasesDao.insertPurchase() and insertPurchaseItems() on submit
    // No DB calls on init - it's a form screen.
    when(() => productsDao.searchProducts(any(), any()))
        .thenAnswer((_) async => []);

    final db = setupMockDatabase(
      productsDao: productsDao,
      purchasesDao: purchasesDao,
    );
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('CashierPurchaseRequestScreen', () {
    testWidgets('renders the purchase request form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierPurchaseRequestScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierPurchaseRequestScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has search text field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierPurchaseRequestScreen()),
      );
      await tester.pumpAndSettle();

      // The screen has text fields for product search and notes
      expect(find.byType(TextField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const CashierPurchaseRequestScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierPurchaseRequestScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierPurchaseRequestScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierPurchaseRequestScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierPurchaseRequestScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierPurchaseRequestScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
