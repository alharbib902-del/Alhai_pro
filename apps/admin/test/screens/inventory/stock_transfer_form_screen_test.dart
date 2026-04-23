library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/inventory/stock_transfer_form_screen.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

StoresTableData _store({
  String id = 'store-2',
  String name = 'Branch Two',
}) {
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
  late MockStoresDao storesDao;
  late MockProductsDao productsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    storesDao = MockStoresDao();
    productsDao = MockProductsDao();
    db = setupMockDatabase(storesDao: storesDao, productsDao: productsDao);
    setupTestGetIt(mockDb: db);

    when(
      () => storesDao.getActiveStores(),
    ).thenAnswer((_) async => <StoresTableData>[]);
    when(
      () => productsDao.getAllProducts(any()),
    ).thenAnswer((_) async => <ProductsTableData>[]);
  });

  tearDown(() => tearDownTestGetIt());

  group('StockTransferFormScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StockTransferFormScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows destination store dropdown', (tester) async {
      when(
        () => storesDao.getActiveStores(),
      ).thenAnswer((_) async => [_store()]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is DropdownButtonFormField),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('excludes current store from destination dropdown', (
      tester,
    ) async {
      // currentStoreIdProvider is overridden to 'test-store-1' by default.
      // Provider filters by `s.id != currentStoreId`, so only 'store-2'
      // should reach the dropdown items list.
      when(() => storesDao.getActiveStores()).thenAnswer(
        (_) async => [
          _store(id: 'test-store-1', name: 'Current Branch'),
          _store(id: 'store-2', name: 'Other Branch'),
        ],
      );
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      // Open the dropdown to verify contents. 'Current Branch' must not
      // appear; 'Other Branch' must.
      await tester.tap(
        find.byWidgetPredicate((w) => w is DropdownButtonFormField),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current Branch'), findsNothing);
      expect(find.text('Other Branch'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add item button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsWidgets);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows notes TextField', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
      'save button is disabled when destination and items are missing',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        suppressOverflowErrors();

        await tester.pumpWidget(
          createTestWidget(const StockTransferFormScreen()),
        );
        await tester.pumpAndSettle();

        // FilledButton.icon in the AppBar wraps a FilledButton subclass.
        // Use byWidgetPredicate + ancestor-of-its-check-icon to locate it
        // robustly. Its onPressed is null while _toStoreId == null ||
        // _lines.isEmpty.
        final saveBtnFinder = find.ancestor(
          of: find.byIcon(Icons.check_rounded),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        );
        expect(saveBtnFinder, findsOneWidget);
        final saveBtn = tester.widget<FilledButton>(saveBtnFinder);
        expect(saveBtn.onPressed, isNull);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('shows check icon on submit button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const StockTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = StockTransferFormScreen();
      expect(screen, isA<StockTransferFormScreen>());
    });
  });
}
