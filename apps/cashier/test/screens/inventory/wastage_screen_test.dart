library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/inventory/wastage_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

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

  group('WastageScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(WastageScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays search card with scan button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('\u0645\u0633\u062d'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays quantity wasted field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '\u0627\u0644\u0643\u0645\u064a\u0629 \u0627\u0644\u0645\u0647\u062f\u0631\u0629',
        ),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays reason selection with wastage reasons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      // Wastage reasons include Spillage
      expect(find.text('\u0627\u0646\u0633\u0643\u0627\u0628'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays photo card with tap to take photo', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('\u0635\u0648\u0631\u0629'), findsOneWidget);
      expect(
        find.text(
          '\u0627\u0646\u0642\u0631 \u0644\u0627\u0644\u062a\u0642\u0627\u0637 \u0635\u0648\u0631\u0629',
        ),
        findsOneWidget,
      );
      expect(
        find.text('\u0627\u062e\u062a\u064a\u0627\u0631\u064a'),
        findsWidgets,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('record wastage button is disabled without data', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u0647\u062f\u0631',
        ),
        findsOneWidget,
      );

      // Find the last FilledButton (Record Wastage)
      // FilledButton.icon creates a subclass, so use predicate
      final filledButtons = find.byWidgetPredicate((w) => w is FilledButton);
      final recordButton = tester.widget<FilledButton>(filledButtons.last);
      expect(recordButton.onPressed, isNull);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
