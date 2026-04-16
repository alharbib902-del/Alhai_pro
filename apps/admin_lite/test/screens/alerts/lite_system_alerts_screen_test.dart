/// Tests for Lite System Alerts Screen
///
/// Verifies rendering of system alerts, severity badges,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_lite/providers/lite_alerts_providers.dart';
import 'package:admin_lite/screens/alerts/lite_system_alerts_screen.dart';
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
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<List<SystemAlertData>>? alertsValue,
  }) {
    return createTestWidget(
      const LiteSystemAlertsScreen(),
      overrides: [
        if (alertsValue != null)
          liteSystemAlertsProvider.overrideWith(
            (ref) => alertsValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('LiteSystemAlertsScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<SystemAlertData>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteSystemAlertsScreen(),
          overrides: [
            liteSystemAlertsProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteSystemAlertsScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no alerts', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(alertsValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // Should show some empty state indicator
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows system alert cards with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final alerts = [
        SystemAlertData(
          title: 'Sync Pending',
          description: '15 items waiting to sync.',
          severity: 'HIGH',
          timestamp: DateTime.now(),
          actionLabel: 'Retry',
        ),
        SystemAlertData(
          title: 'Inventory Warning',
          description: '12 products below minimum stock.',
          severity: 'MEDIUM',
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildScreen(alertsValue: AsyncValue.data(alerts)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sync Pending'), findsOneWidget);
      expect(find.text('Inventory Warning'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows severity indicator', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final alerts = [
        SystemAlertData(
          title: 'High Alert',
          description: 'Critical issue detected.',
          severity: 'HIGH',
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildScreen(alertsValue: AsyncValue.data(alerts)),
      );
      await tester.pumpAndSettle();

      expect(find.text('HIGH'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows action button when actionLabel provided',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final alerts = [
        SystemAlertData(
          title: 'Sync Alert',
          description: 'Items need sync.',
          severity: 'HIGH',
          timestamp: DateTime.now(),
          actionLabel: 'Retry',
        ),
      ];

      await tester.pumpWidget(
        buildScreen(alertsValue: AsyncValue.data(alerts)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          alertsValue: AsyncValue.error(
            Exception('Load error'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
