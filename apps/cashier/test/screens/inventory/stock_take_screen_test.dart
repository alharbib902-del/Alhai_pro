library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/inventory/stock_take_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;
  late MockCategoriesDao categoriesDao;
  late MockInventoryDao inventoryDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    categoriesDao = MockCategoriesDao();
    inventoryDao = MockInventoryDao();

    db = setupMockDatabase(
      productsDao: productsDao,
      categoriesDao: categoriesDao,
      inventoryDao: inventoryDao,
    );
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(() => categoriesDao.getAllCategories(any()))
        .thenAnswer((_) async => []);
    when(() => productsDao.getAllProducts(any())).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('StockTakeScreen', () {
    testWidgets('renders correctly with empty products', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StockTakeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completers to hold the future without pending timers
      final catCompleter = Completer<List<CategoriesTableData>>();
      final prodCompleter = Completer<List<ProductsTableData>>();
      when(() => categoriesDao.getAllCategories(any()))
          .thenAnswer((_) => catCompleter.future);
      when(() => productsDao.getAllProducts(any()))
          .thenAnswer((_) => prodCompleter.future);

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete futures to avoid pending timer issues
      catCompleter.complete([]);
      prodCompleter.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays products when data loads', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = createTestProductList(3);
      when(() => productsDao.getAllProducts(any()))
          .thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pumpAndSettle();

      // Verify product names are displayed
      for (final p in products) {
        expect(find.text(p.name), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows summary bar with total items count', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = createTestProductList(5);
      when(() => productsDao.getAllProducts(any()))
          .thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pumpAndSettle();

      // Summary bar shows Total Items count
      expect(
          find.text(
              '\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0639\u0646\u0627\u0635\u0631'),
          findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays category filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final categories = createTestCategoryList(2);
      when(() => categoriesDao.getAllCategories(any()))
          .thenAnswer((_) async => categories);

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pumpAndSettle();

      // All Categories chip is always shown
      for (final cat in categories) {
        expect(find.text(cat.name), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows Save Draft and Finalize buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StockTakeScreen()));
      await tester.pumpAndSettle();

      expect(
          find.text(
              '\u062d\u0641\u0638 \u0627\u0644\u0645\u0633\u0648\u062f\u0629'),
          findsOneWidget);
      expect(find.text('\u0625\u0646\u0647\u0627\u0621'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
