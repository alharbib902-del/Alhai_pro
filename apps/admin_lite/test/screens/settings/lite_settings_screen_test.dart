/// Tests for Lite Settings Screen
///
/// Verifies rendering of settings sections: Appearance, Notifications,
/// Alert Thresholds, Security, App Info, and Logout button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_lite/screens/settings/lite_settings_screen.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerLiteFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('LiteSettingsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LiteSettingsScreen), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows appearance section with language and theme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // Appearance section icons
      expect(find.byIcon(Icons.palette_outlined), findsWidgets);
      expect(find.byIcon(Icons.language), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows notification toggle switches', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // 4 toggle switches (low stock, expiry, shifts, refund)
      expect(find.byType(Switch), findsNWidgets(4));
      // Notification section icon
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('toggles a notification switch', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // All switches should start as ON (true)
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      expect(switches.first.value, isTrue);

      // Tap the first switch to toggle it off
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // After toggling, the first switch should be OFF
      final updatedSwitches = tester.widgetList<Switch>(find.byType(Switch));
      expect(updatedSwitches.first.value, isFalse);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows alert threshold controls', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // Alert threshold section icon
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      // Increase/decrease buttons (2 thresholds x 2 buttons)
      expect(find.byIcon(Icons.add), findsNWidgets(2));
      expect(find.byIcon(Icons.remove), findsNWidgets(2));

      // Default values - threshold displays as "10 {units_localized}"
      expect(find.textContaining('10'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('increases low stock threshold', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // Tap the first "add" icon to increase low stock threshold
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('11'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows security section with PIN and sync', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // Security section
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows app info section with version', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Al-HAI Lite'), findsOneWidget);
      expect(find.text('v2.4.0'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows logout button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LiteSettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to find the logout button
      await tester.scrollUntilVisible(
        find.byIcon(Icons.logout),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
