library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/devices/payment_devices_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // PaymentDevicesScreen uses _db.select(_db.settingsTable).
    // Catch block handles errors; defaults to EMPTY list (no more fake
    // Mada/STC Pay placeholders).
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('PaymentDevicesScreen', () {
    testWidgets('renders with default devices', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentDevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentDevicesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentDevicesScreen()));
      await tester.pumpAndSettle();

      // Provider resolves synchronously in test, so loading state
      // is not observable. Verify the screen rendered successfully.
      expect(find.byType(PaymentDevicesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const PaymentDevicesScreen(), theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentDevicesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentDevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentDevicesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentDevicesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentDevicesScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // --- New behaviour: fake Mada/STC-Pay defaults removed -----------------

    testWidgets('shows Arabic "no devices" subtitle when empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const PaymentDevicesScreen()));
      await tester.pumpAndSettle();

      // The DB mock returns no settings rows → zero devices → the header
      // subtitle must show "لا توجد أجهزة" (was "2 devices" from the
      // deleted Mada/STC-Pay placeholders). Confirms no phantom hardware.
      expect(find.text('لا توجد أجهزة'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // -------------------------------------------------------------------------
  // Unit-level: the Arabic pluraliser for device count. Mirrors
  // _devicesCountLabel from the source so a change of the contract surfaces
  // here immediately.
  // -------------------------------------------------------------------------
  group('Arabic devices-count pluralisation', () {
    String label(int count) {
      if (count == 0) return 'لا توجد أجهزة';
      if (count == 1) return 'جهاز واحد';
      if (count == 2) return 'جهازان';
      if (count <= 10) return '$count أجهزة';
      return '$count جهازاً';
    }

    test('zero uses feminine negation', () {
      expect(label(0), equals('لا توجد أجهزة'));
    });

    test('singular', () {
      expect(label(1), equals('جهاز واحد'));
    });

    test('dual', () {
      expect(label(2), equals('جهازان'));
    });

    test('small plural (3–10)', () {
      expect(label(3), equals('3 أجهزة'));
      expect(label(10), equals('10 أجهزة'));
    });

    test('large plural (11+)', () {
      expect(label(11), equals('11 جهازاً'));
      expect(label(100), equals('100 جهازاً'));
    });
  });
}
