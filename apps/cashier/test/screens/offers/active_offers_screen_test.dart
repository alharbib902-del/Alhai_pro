library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:cashier/screens/offers/active_offers_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockDiscountsDao discountsDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    discountsDao = MockDiscountsDao();

    // ActiveOffersScreen uses _db.discountsDao.getActiveDiscounts(storeId).
    when(
      () => discountsDao.getActiveDiscounts(any()),
    ).thenAnswer((_) async => []);

    final db = setupMockDatabase(discountsDao: discountsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('ActiveOffersScreen', () {
    testWidgets('renders with empty offers', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActiveOffersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveOffersScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers
      final completer = Completer<List<DiscountsTableData>>();
      when(
        () => discountsDao.getActiveDiscounts(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget(const ActiveOffersScreen()));
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
        createTestWidget(const ActiveOffersScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActiveOffersScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActiveOffersScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ActiveOffersScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has filter chips for offer types', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActiveOffersScreen()));
      await tester.pumpAndSettle();

      // Active offers screen uses custom InkWell chips for offer types
      // Verify known filter chip labels are present
      expect(
        find.text(
          '\u062e\u0635\u0645 \u0646\u0633\u0628\u0629 \u0645\u0626\u0648\u064a\u0629',
        ),
        findsOneWidget,
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
