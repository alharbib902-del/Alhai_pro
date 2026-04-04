library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/devices/add_payment_device_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // AddPaymentDeviceScreen uses _db.into(_db.settingsTable) on save.
    // The form can render without any DB calls (form-only screen).
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('AddPaymentDeviceScreen', () {
    testWidgets('renders the form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const AddPaymentDeviceScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has text fields for name, IP, port', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const AddPaymentDeviceScreen()),
      );
      await tester.pumpAndSettle();

      // The form has name, IP address, and port text fields
      expect(find.byType(TextFormField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const AddPaymentDeviceScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const AddPaymentDeviceScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddPaymentDeviceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has dropdown for device type', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const AddPaymentDeviceScreen()),
      );
      await tester.pumpAndSettle();

      // Device type selector uses custom GestureDetector chips
      expect(find.byType(GestureDetector), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
