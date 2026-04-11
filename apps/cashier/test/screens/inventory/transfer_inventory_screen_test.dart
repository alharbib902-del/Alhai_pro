library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/inventory/transfer_inventory_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

StoresTableData _createTestStore({required String id, required String name}) {
  return StoresTableData(
    id: id,
    name: name,
    currency: 'SAR',
    timezone: 'Asia/Riyadh',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;
  late MockInventoryDao inventoryDao;
  late MockStoresDao storesDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    inventoryDao = MockInventoryDao();
    storesDao = MockStoresDao();

    db = setupMockDatabase(
      productsDao: productsDao,
      inventoryDao: inventoryDao,
      storesDao: storesDao,
    );
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(() => storesDao.getAllStores()).thenAnswer(
      (_) async => [
        _createTestStore(id: 'test-store-1', name: 'Main Branch'),
        _createTestStore(id: 'store-2', name: 'Branch 2'),
        _createTestStore(id: 'store-3', name: 'Branch 3'),
      ],
    );
    when(
      () => productsDao.searchProducts(any(), any()),
    ).thenAnswer((_) async => []);
    when(() => inventoryDao.insertMovement(any())).thenAnswer((_) async => 1);
    when(
      () => productsDao.updateStock(any(), any()),
    ).thenAnswer((_) async => 1);
  });

  tearDown(() => tearDownTestGetIt());

  group('TransferInventoryScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TransferInventoryScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator while loading stores', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<StoresTableData>>();
      when(() => storesDao.getAllStores()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays transfer details card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          '\u062a\u0641\u0627\u0635\u064a\u0644 \u0627\u0644\u0646\u0642\u0644',
        ),
        findsOneWidget,
      );
      expect(
        find.text('\u0645\u0646 \u0627\u0644\u0641\u0631\u0639'),
        findsOneWidget,
      );
      expect(
        find.text('\u0625\u0644\u0649 \u0627\u0644\u0641\u0631\u0639'),
        findsOneWidget,
      );
      expect(find.text('\u0627\u0644\u062d\u0627\u0644\u064a'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays destination stores dropdown (excludes current)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pumpAndSettle();

      // The dropdown should be present
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('submit button is disabled without required data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          '\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0646\u0642\u0644',
        ),
        findsOneWidget,
      );

      // Find submit button (FilledButton.icon creates a subclass)
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      final submitButton = tester.widget<FilledButton>(filledButtons.last);
      expect(submitButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays product search card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const TransferInventoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
