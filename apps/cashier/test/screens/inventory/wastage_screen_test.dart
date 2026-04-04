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
    when(() => productsDao.searchProducts(any(), any()))
        .thenAnswer((_) async => []);
    when(() => inventoryDao.insertMovement(any())).thenAnswer((_) async => 1);
    when(() => productsDao.updateStock(any(), any()))
        .thenAnswer((_) async => 1);
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
      expect(find.text('Scan'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays quantity wasted field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Quantity Wasted'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays reason selection with wastage reasons',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      // Wastage reasons include Spillage
      expect(find.text('Spillage'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays photo card with tap to take photo', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Tap to take photo'), findsOneWidget);
      expect(find.text('Optional'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('record wastage button is disabled without data',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const WastageScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Record Wastage'), findsOneWidget);

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
