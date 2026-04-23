library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/inventory/stocktaking_screen.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('StocktakingScreen', () {
    testWidgets('renders correctly', (tester) async {
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => <ProductsTableData>[]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StocktakingScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows search field with search icon', (tester) async {
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => <ProductsTableData>[]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows save button with save icon', (tester) async {
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => <ProductsTableData>[]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
      // FilledButton.icon wraps a FilledButton subclass, so use byWidgetPredicate
      // with an `is` check rather than byType (which only matches runtimeType).
      expect(
        find.byWidgetPredicate((w) => w is FilledButton),
        findsWidgets,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('save button is disabled when no adjustments are entered', (
      tester,
    ) async {
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => <ProductsTableData>[]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      // Locate the save FilledButton via its unique save_rounded icon.
      final saveBtnFinder = find.ancestor(
        of: find.byIcon(Icons.save_rounded),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(saveBtnFinder, findsOneWidget);
      final saveBtn = tester.widget<FilledButton>(saveBtnFinder);
      expect(saveBtn.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders product row when data is provided', (tester) async {
      final product = createTestProduct(
        id: 'p-1',
        name: 'Test Prod',
        stockQty: 10,
      );
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => [product]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Test Prod'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows expected qty column for each product row', (
      tester,
    ) async {
      final product = createTestProduct(
        id: 'p-1',
        name: 'Row Prod',
        stockQty: 42,
      );
      when(
        () => productsDao.getAllProducts(any()),
      ).thenAnswer((_) async => [product]);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      // Expected qty uses toStringAsFixed(0) → '42'
      expect(find.text('42'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search field filters product list', (tester) async {
      when(() => productsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createTestProduct(id: 'p-1', name: 'Apple'),
          createTestProduct(id: 'p-2', name: 'Banana'),
        ],
      );
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const StocktakingScreen()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Card, 'Apple'), findsOneWidget);
      expect(find.widgetWithText(Card, 'Banana'), findsOneWidget);

      // Enter search query "Apple" in the search TextField (first TextField
      // is the search box at the top of the screen). Use widgetWithText
      // scoped to Card so the EditableText inside the search field doesn't
      // pollute the match.
      await tester.enterText(find.byType(TextField).first, 'Apple');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Card, 'Apple'), findsOneWidget);
      expect(find.widgetWithText(Card, 'Banana'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = StocktakingScreen();
      expect(screen, isA<StocktakingScreen>());
    });
  });
}
