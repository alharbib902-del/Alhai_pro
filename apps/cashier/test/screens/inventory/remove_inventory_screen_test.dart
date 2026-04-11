library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/inventory/remove_inventory_screen.dart';

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
    when(
      () => productsDao.searchProducts(any(), any()),
    ).thenAnswer((_) async => []);
    when(() => inventoryDao.insertMovement(any())).thenAnswer((_) async => 1);
    when(
      () => productsDao.updateStock(any(), any()),
    ).thenAnswer((_) async => 1);
  });

  tearDown(() => tearDownTestGetIt());

  group('RemoveInventoryScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveInventoryScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search card with scan button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      expect(find.text('\u0645\u0633\u062d'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays quantity to remove field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '\u0627\u0644\u0643\u0645\u064a\u0629 \u0627\u0644\u0645\u0631\u0627\u062f \u0633\u062d\u0628\u0647\u0627',
        ),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays reason selection options', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      // Reason options
      expect(find.text('\u0645\u0628\u0627\u0639'), findsOneWidget);
      expect(find.text('\u0645\u0646\u0642\u0648\u0644'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('save button is disabled without product and quantity', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      // Find the confirm removal button (last FilledButton)
      // FilledButton.icon creates a subclass, so use predicate
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      // Scan button + Confirm Removal button
      expect(filledButtons, findsNWidgets(2));

      // The confirm button should be disabled
      final confirmButton = tester.widget<FilledButton>(filledButtons.last);
      expect(confirmButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search triggers product search', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => productsDao.searchProducts(any(), any()),
      ).thenAnswer((_) async => [createTestProduct(name: 'Water')]);

      await tester.pumpWidget(createTestWidget(const RemoveInventoryScreen()));
      await tester.pumpAndSettle();

      // Enter search text
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Water');
      await tester.pumpAndSettle();

      verify(
        () => productsDao.searchProducts('Water', 'test-store-1'),
      ).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
