/// Tests for Lite Dashboard Screen
///
/// Verifies rendering of stat cards, quick actions, recent activity,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_lite/providers/lite_dashboard_providers.dart';
import 'package:admin_lite/screens/dashboard/lite_dashboard_screen.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerLiteFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  // ===========================================================================
  // Helper to build widget with provider overrides
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<LiteStatsData>? statsValue,
    AsyncValue<List<ActivityEntry>>? activityValue,
  }) {
    return createTestWidget(
      const LiteDashboardScreen(),
      overrides: [
        if (statsValue != null)
          liteStatsProvider.overrideWith(
            (ref) => statsValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
        if (activityValue != null)
          recentActivityProvider.overrideWith(
            (ref) => activityValue.when(
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

  group('LiteDashboardScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use a Completer that never completes to keep the provider in loading state
      final completer = Completer<LiteStatsData>();

      await tester.pumpWidget(createTestWidget(
        const LiteDashboardScreen(),
        overrides: [
          liteStatsProvider.overrideWith((ref) => completer.future),
        ],
      ));
      await tester.pump();

      expect(find.byType(LiteDashboardScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows stat cards with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final stats = createTestLiteStats(
        pendingApprovals: 3,
        todaySales: 1500,
        lowStockCount: 5,
        activeShifts: 2,
        salesChangePercent: 15.5,
      );

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(stats),
        activityValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      // Stat values should be visible
      expect(find.text('3'), findsWidgets); // pendingApprovals
      expect(find.text('1500'), findsOneWidget); // todaySales
      expect(find.text('5'), findsWidgets); // lowStockCount
      expect(find.text('2'), findsWidgets); // activeShifts

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows sales change percentage indicator', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final stats = createTestLiteStats(salesChangePercent: 15.5);

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(stats),
        activityValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      // Should show the percentage
      expect(find.text('15.5%'), findsOneWidget);
      // Should show up arrow for positive change
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no recent activities', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final stats = createTestLiteStats();

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(stats),
        activityValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      // Empty state icon for no activities
      expect(find.byIcon(Icons.history_toggle_off), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state with retry button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        statsValue:
            AsyncValue.error(Exception('Network error'), StackTrace.current),
      ));
      await tester.pumpAndSettle();

      // Error icon and retry button
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows recent activities', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final activities = [
        createTestActivity(
            id: 'a1', action: 'saleCreate', description: 'Sale completed'),
        createTestActivity(
            id: 'a2', action: 'login', description: 'User logged in'),
      ];

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(createTestLiteStats()),
        activityValue: AsyncValue.data(activities),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sale completed'), findsOneWidget);
      expect(find.text('User logged in'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows quick actions section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(createTestLiteStats()),
        activityValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      // Quick action icons should be visible
      expect(find.byIcon(Icons.approval_rounded), findsWidgets);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsWidgets);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has RefreshIndicator for pull to refresh', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        statsValue: AsyncValue.data(createTestLiteStats()),
        activityValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
