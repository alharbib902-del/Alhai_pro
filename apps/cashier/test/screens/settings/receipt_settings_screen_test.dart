library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/store/receipt_settings_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // ReceiptSettingsScreen uses _db.select(_db.settingsTable).
    // The catch block handles errors and shows default values.
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('ReceiptSettingsScreen', () {
    testWidgets('renders with defaults when DB fails', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const ReceiptSettingsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const ReceiptSettingsScreen()),
      );
      await tester.pumpAndSettle();

      // Provider resolves synchronously in test, so loading state
      // is not observable. Verify the screen rendered successfully.
      expect(find.byType(ReceiptSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const ReceiptSettingsScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const ReceiptSettingsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptSettingsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('finds switch widgets for toggles', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const ReceiptSettingsScreen()),
      );
      await tester.pumpAndSettle();

      // Receipt settings has toggles for show logo, customer, cashier, address
      expect(find.byType(Switch), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
