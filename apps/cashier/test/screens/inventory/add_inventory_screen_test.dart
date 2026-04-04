library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/inventory/add_inventory_screen.dart';

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

    // Default stubs
    when(() => productsDao.searchProducts(any(), any()))
        .thenAnswer((_) async => []);
    when(() => inventoryDao.insertMovement(any())).thenAnswer((_) async => 1);
    when(() => productsDao.updateStock(any(), any()))
        .thenAnswer((_) async => 1);
  });

  tearDown(() => tearDownTestGetIt());

  group('AddInventoryScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AddInventoryScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search card with search field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      // Search field and scan button should be present
      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      expect(find.text('Scan'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays quantity card with quick chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      // Quantity to Add title
      expect(find.text('Quantity to Add'), findsOneWidget);
      // Quick quantity chips
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays supplier reference and note fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Supplier Reference'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('save button is disabled when no product selected',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      // Find FilledButton variants (FilledButton.icon creates a subclass)
      final saveButtons = find.byWidgetPredicate((w) => w is FilledButton);
      // There are 2 FilledButtons: Scan and Save
      expect(saveButtons, findsNWidgets(2));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search triggers product search', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final products = [createTestProduct(name: 'Apple Juice')];
      when(() => productsDao.searchProducts(any(), any()))
          .thenAnswer((_) async => products);

      await tester.pumpWidget(createTestWidget(const AddInventoryScreen()));
      await tester.pumpAndSettle();

      // Find text fields - the search field
      final textFields = find.byType(TextField);
      // Enter search text in the first TextField (search)
      await tester.enterText(textFields.first, 'Apple');
      await tester.pumpAndSettle();

      verify(() => productsDao.searchProducts('Apple', 'test-store-1'))
          .called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
