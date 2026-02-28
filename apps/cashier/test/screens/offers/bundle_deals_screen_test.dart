library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/offers/bundle_deals_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockDiscountsDao discountsDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    discountsDao = MockDiscountsDao();

    // BundleDealsScreen uses _db.discountsDao.getActiveDiscounts(storeId)
    // and filters for type == 'bundle' || type == 'buy_x_get_y'.
    when(() => discountsDao.getActiveDiscounts(any()))
        .thenAnswer((_) async => []);

    final db = setupMockDatabase(discountsDao: discountsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('BundleDealsScreen', () {
    testWidgets('renders with empty bundles', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const BundleDealsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BundleDealsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<DiscountsTableData>>();
      when(() => discountsDao.getActiveDiscounts(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const BundleDealsScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete([]);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const BundleDealsScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BundleDealsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const BundleDealsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BundleDealsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const BundleDealsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BundleDealsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
