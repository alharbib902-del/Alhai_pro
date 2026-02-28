library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:cashier/screens/products/edit_price_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;

  // Screen accesses product.updatedAt for price history, so it must be non-null
  final testProduct = createTestProduct(
    id: 'prod-1',
    name: 'Test Product',
    barcode: '123456789',
    price: 25.0,
    costPrice: 15.0,
    stockQty: 100,
  ).copyWith(updatedAt: Value(DateTime(2026, 1, 15)));

  setUpAll(() {
    registerCashierFallbackValues();
    // updateProduct(any()) needs a fallback for ProductsTableData
    registerFallbackValue(createTestProduct());
  });

  setUp(() {
    productsDao = MockProductsDao();

    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(() => productsDao.getProductById(any()))
        .thenAnswer((_) async => testProduct);
    when(() => productsDao.updateProduct(any()))
        .thenAnswer((_) async => true);
  });

  tearDown(() => tearDownTestGetIt());

  group('EditPriceScreen', () {
    testWidgets('renders correctly with product data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')));
      await tester.pumpAndSettle();

      expect(find.byType(EditPriceScreen), findsOneWidget);
      expect(find.text('Test Product'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<ProductsTableData?>();
      when(() => productsDao.getProductById(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete(testProduct);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows not found when product is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(() => productsDao.getProductById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'nonexistent')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays price comparison card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')));
      await tester.pumpAndSettle();

      expect(find.text('Price Comparison'), findsOneWidget);
      expect(find.text('Current Price'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('pre-fills current price in input field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')));
      await tester.pumpAndSettle();

      // The price input should be pre-filled with the current price
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Verify the price text is displayed
      expect(find.text('25.00'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays price history card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
