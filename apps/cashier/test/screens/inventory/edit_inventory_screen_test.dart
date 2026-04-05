library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/inventory/edit_inventory_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;
  late MockInventoryDao inventoryDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    inventoryDao = MockInventoryDao();

    db = setupMockDatabase(
      productsDao: productsDao,
      inventoryDao: inventoryDao,
    );
    setupTestGetIt(mockDb: db);

    // Default: product found
    when(() => productsDao.getProductById(any()))
        .thenAnswer((_) async => createTestProduct(
              id: 'prod-1',
              name: 'Test Product',
              barcode: '123456789',
              stockQty: 50,
            ));
    when(() => inventoryDao.insertMovement(any())).thenAnswer((_) async => 1);
    when(() => productsDao.updateStock(any(), any()))
        .thenAnswer((_) async => 1);
  });

  tearDown(() => tearDownTestGetIt());

  group('EditInventoryScreen', () {
    testWidgets('renders correctly with product data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'prod-1'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditInventoryScreen), findsOneWidget);
      // Product name may appear in both header and body
      expect(find.text('Test Product'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use a Completer to hold the future without pending timers
      final completer = Completer<ProductsTableData?>();
      when(() => productsDao.getProductById(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'prod-1'),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid pending timer issues
      completer.complete(createTestProduct());
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

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'nonexistent'),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays current stock and adjustment fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'prod-1'),
      ));
      await tester.pumpAndSettle();

      // Current stock should show 50.0 (stockQty is double, may appear in multiple places)
      expect(find.text('50.0'), findsWidgets);
      // Adjustment card title (Arabic l10n)
      expect(
          find.text(
              '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0643\u0645\u064a\u0629'),
          findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays reason selection options', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'prod-1'),
      ));
      await tester.pumpAndSettle();

      // Reason options
      expect(find.text('Received'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('save button is disabled when no adjustment entered',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
        const EditInventoryScreen(productId: 'prod-1'),
      ));
      await tester.pumpAndSettle();

      // Find the save button - it should be disabled (no amount entered)
      // FilledButton.icon creates a subclass, so use predicate
      final saveButton = find.byWidgetPredicate((w) => w is FilledButton);
      expect(saveButton, findsOneWidget);

      // The onPressed should be null since no adjustment entered
      final button = tester.widget<FilledButton>(saveButton);
      expect(button.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
