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
    when(
      () => categoriesDao.getAllCategories(any()),
    ).thenAnswer((_) async => []);
    when(() => productsDao.insertProduct(any())).thenAnswer((_) async => 1);
    // P1 #13 (2026-04-24): save flow checks for duplicate barcode via
    // getProductByBarcode before INSERT. Default to "not found".
    when(
      () => productsDao.getProductByBarcode(any(), any()),
    ).thenAnswer((_) async => null);
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

    testWidgets('shows loading indicator while loading categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<CategoriesTableData>>();
      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) => completer.future);

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

      // P2 #12 (2026-04-24): card title localized to Arabic.
      expect(
        find.text(
          '\u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0627\u0644\u0645\u0646\u062a\u062c',
        ),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays barcode card with disabled scan button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      // l10n.scan label still renders as "مسح"
      expect(find.text('\u0645\u0633\u062d'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // P2 #11 (2026-04-24): scan button is now disabled (coming soon).
      // FilledButton.icon constructs a private subclass (_FilledButtonWithIcon)
      // that still implements FilledButton — use a predicate finder so the
      // ancestor lookup captures it.
      final scanButton = find.ancestor(
        of: find.byIcon(Icons.camera_alt_rounded),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(scanButton, findsOneWidget);
      expect(tester.widget<FilledButton>(scanButton.first).onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays pricing card with quantity chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      // P2 #12 (2026-04-24): pricing card title localized to Arabic.
      expect(
        find.text(
          '\u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0627\u0644\u062a\u0633\u0639\u064a\u0631',
        ),
        findsOneWidget,
      );
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
      when(
        () => categoriesDao.getAllCategories(any()),
      ).thenAnswer((_) async => categories);

      await tester.pumpWidget(createTestWidget(const QuickAddProductScreen()));
      await tester.pumpAndSettle();

      // Category dropdown should be present
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
