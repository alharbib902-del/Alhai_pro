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
    when(
      () => productsDao.searchProducts(any(), any()),
    ).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('PrintBarcodeScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrintBarcodeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search card with scan button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      // l10n.scan ("مسح") is the scan button label.
      expect(find.text('\u0645\u0633\u062d'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays barcode preview placeholder', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // P2 #16 (2026-04-24): "Barcode Preview" → Arabic "معاينة الباركود".
      expect(
        find.text(
          '\u0645\u0639\u0627\u064a\u0646\u0629 \u0627\u0644\u0628\u0627\u0631\u0643\u0648\u062f',
        ),
        findsOneWidget,
      );
      // Empty-state copy: "اختر منتج أولاً" (pre-existing, unchanged).
      expect(
        find.text(
          '\u0627\u062e\u062a\u0631 \u0645\u0646\u062a\u062c \u0623\u0648\u0644\u0627\u064b',
        ),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays label quantity card with quick chips', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // P2 #16 (2026-04-24): "Label Quantity" → Arabic "عدد الملصقات".
      expect(
        find.text(
          '\u0639\u062f\u062f \u0627\u0644\u0645\u0644\u0635\u0642\u0627\u062a',
        ),
        findsOneWidget,
      );
      // Quick quantity chips: 1, 5, 10, 20, 50
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('print button is disabled without product selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // FilledButton.icon creates a private subclass, use predicate.
      // P1 #17 (2026-04-24): the scan button is now also disabled with a
      // tooltip (camera plugin not wired) — so we still expect 2 FilledButtons
      // on-screen: [scan (disabled), print (disabled)].
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      expect(filledButtons, findsNWidgets(2));

      // The print button is the last FilledButton (bottom of layout).
      final printButton = tester.widget<FilledButton>(filledButtons.last);
      expect(printButton.onPressed, isNull);
      // And the scan button — also disabled.
      final scanButton = tester.widget<FilledButton>(filledButtons.first);
      expect(scanButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search triggers product search', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(() => productsDao.searchProducts(any(), any())).thenAnswer(
        (_) async => [
          createTestProduct(name: 'Test Prod', barcode: '1234567890123'),
        ],
      );

      await tester.pumpWidget(createTestWidget(const PrintBarcodeScreen()));
      await tester.pumpAndSettle();

      // Find and enter text in search field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Test');
      await tester.pumpAndSettle();

      verify(
        () => productsDao.searchProducts('Test', 'test-store-1'),
      ).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
