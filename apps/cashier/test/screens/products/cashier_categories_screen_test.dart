library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/products/cashier_categories_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;
  late MockCategoriesDao categoriesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    categoriesDao = MockCategoriesDao();

    db = setupMockDatabase(
      productsDao: productsDao,
      categoriesDao: categoriesDao,
    );
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(
      () => categoriesDao.getAllCategories(any()),
    ).thenAnswer((_) async => []);
    when(
      () => productsDao.getProductsByCategory(any(), any()),
    ).thenAnswer((_) async => []);
    // P1 #19 (2026-04-24): initial counts now come from a single GROUP BY
    // query (`countByCategory`) rather than N+1 `getProductsByCategory`.
    when(
      () => productsDao.countByCategory(any()),
    ).thenAnswer((_) async => <String, int>{});
  });

  tearDown(() => tearDownTestGetIt());

  group('CashierCategoriesScreen', () {
    testWidgets('renders correctly with empty categories', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashierCategoriesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<CategoriesTableData>>();
      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays category grid when categories load', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final categories = createTestCategoryList(4);
      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) async => categories);
      // Supply counts so the grid card's "N products" badge has data.
      when(
        () => productsDao.countByCategory(any()),
      ).thenAnswer(
        (_) async => {for (final c in categories) c.id: 2},
      );

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pumpAndSettle();

      // Verify category names are displayed
      for (final cat in categories) {
        expect(find.text(cat.name), findsOneWidget);
      }
      // Verify grid view is present
      expect(find.byType(GridView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search bar for categories', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pumpAndSettle();

      // Search field should be present
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no categories', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('tapping category loads products', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final categories = [createTestCategory(id: 'cat-1', name: 'Drinks')];
      final products = [
        createTestProduct(id: 'p1', name: 'Cola', categoryId: 'cat-1'),
      ];

      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) async => categories);
      when(
        () => productsDao.countByCategory(any()),
      ).thenAnswer((_) async => {'cat-1': 1});
      when(
        () => productsDao.getProductsByCategory('cat-1', any()),
      ).thenAnswer((_) async => products);

      await tester.pumpWidget(
        createTestWidget(const CashierCategoriesScreen()),
      );
      await tester.pumpAndSettle();

      // Tap the category card
      await tester.tap(find.text('Drinks'));
      await tester.pumpAndSettle();

      // P1 #19 (2026-04-24): initial load no longer calls
      // `getProductsByCategory` per-category. Only the tap-to-open flow does,
      // so the expected call count drops from 2 → 1.
      verify(
        () => productsDao.getProductsByCategory('cat-1', 'test-store-1'),
      ).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
