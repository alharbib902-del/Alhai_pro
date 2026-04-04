library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/products/quick_add_product_screen.dart';

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
    when(() => categoriesDao.getAllCategories(any()))
        .thenAnswer((_) async => []);
    when(() => productsDao.insertProduct(any())).thenAnswer((_) async => 1);
  });

  tearDown(() => tearDownTestGetIt());

  group('QuickAddProductScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(QuickAddProductScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator while loading categories',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<CategoriesTableData>>();
      when(() => categoriesDao.getAllCategories(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays product info card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Product Info'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays barcode card with scan button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Scan'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays pricing card with quantity chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pricing Info'), findsOneWidget);
      // Quick quantity chips
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('category dropdown shows loaded categories', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final categories = createTestCategoryList(3);
      when(() => categoriesDao.getAllCategories(any()))
          .thenAnswer((_) async => categories);

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      // Category dropdown should be present
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
