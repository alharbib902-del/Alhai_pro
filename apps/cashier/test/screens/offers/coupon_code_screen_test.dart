library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/offers/coupon_code_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // CouponCodeScreen uses _db.discountsDao.getActiveDiscounts()
    // for validation, but renders the form without calling DB on init.
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('CouponCodeScreen', () {
    testWidgets('renders the coupon input form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CouponCodeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CouponCodeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has text field for coupon code', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CouponCodeScreen()),
      );
      await tester.pumpAndSettle();

      // Coupon screen has a text input for the coupon code
      expect(find.byType(TextField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const CouponCodeScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CouponCodeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CouponCodeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CouponCodeScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows recent coupons section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CouponCodeScreen()),
      );
      await tester.pumpAndSettle();

      // The screen shows simulated recent coupon codes
      // (WELCOME10, SUMMER25, VIP50)
      expect(find.text('WELCOME10'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
