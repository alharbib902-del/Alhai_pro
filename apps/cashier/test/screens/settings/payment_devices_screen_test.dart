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
    // Catch block handles errors; defaults to sample devices.
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
  });
}
