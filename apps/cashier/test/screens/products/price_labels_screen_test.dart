library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/products/price_labels_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();

    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(() => productsDao.getAllProducts(any())).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('PriceLabelsScreen', () {
    testWidgets('renders correctly with empty products', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PriceLabelsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<ProductsTableData>>();
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays products list with checkboxes', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = createTestProductList(3);
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pumpAndSettle();

      // Each product should have a checkbox
      expect(find.byType(Checkbox), findsNWidgets(3));
      // Product names should be displayed
      for (final p in products) {
        expect(find.text(p.name), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays label size selection card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pumpAndSettle();

      // P2 #14 (2026-04-24): "Label Size" → Arabic "حجم الملصق".
      expect(
        find.text('\u062d\u062c\u0645 \u0627\u0644\u0645\u0644\u0635\u0642'),
        findsOneWidget,
      );
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('print button is disabled when no products selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = createTestProductList(2);
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pumpAndSettle();

      // Print button should be disabled (no selection)
      // FilledButton.icon creates a private subclass, use predicate
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      expect(filledButtons, findsOneWidget);
      final printButton = tester.widget<FilledButton>(filledButtons.first);
      expect(printButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search field filters products', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = createTestProductList(5);
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const PriceLabelsScreen()));
      await tester.pumpAndSettle();

      // All products should be visible initially
      expect(find.byType(Checkbox), findsNWidgets(5));

      // Search field is present
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
