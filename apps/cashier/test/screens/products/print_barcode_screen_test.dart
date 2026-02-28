library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/products/print_barcode_screen.dart';

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
    when(() => productsDao.searchProducts(any(), any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('PrintBarcodeScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrintBarcodeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search card with scan button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      expect(find.text('Scan'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays barcode preview placeholder', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Barcode Preview'), findsOneWidget);
      expect(find.text('Select a product first'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays label quantity card with quick chips',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Label Quantity'), findsOneWidget);
      // Quick quantity chips: 1, 5, 10, 20, 50
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('print button is disabled without product selected',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // Find the print button (last FilledButton)
      // FilledButton.icon creates a private subclass, use predicate
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      // Scan button + Print button
      expect(filledButtons, findsNWidgets(2));

      final printButton = tester.widget<FilledButton>(filledButtons.last);
      expect(printButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search triggers product search', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(() => productsDao.searchProducts(any(), any()))
          .thenAnswer((_) async => [
                createTestProduct(
                    name: 'Test Prod', barcode: '1234567890123'),
              ]);

      await tester.pumpWidget(
          createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // Find and enter text in search field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Test');
      await tester.pumpAndSettle();

      verify(() => productsDao.searchProducts('Test', 'test-store-1'))
          .called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
