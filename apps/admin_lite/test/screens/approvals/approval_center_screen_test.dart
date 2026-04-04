/// Tests for Approval Center Screen
///
/// Verifies rendering of filter tabs, refund cards, loading state,
/// error state, empty state, and status badges.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/approval_providers.dart';
import 'package:admin_lite/screens/approval_center_screen.dart';
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
  // Helper
  // ===========================================================================

  Widget buildScreen({
    AsyncValue<List<ReturnsTableData>>? refundsValue,
    AsyncValue<int>? countValue,
    ApprovalFilter? filter,
  }) {
    return createTestWidget(
      const ApprovalCenterScreen(),
      overrides: [
        if (refundsValue != null)
          pendingRefundsProvider.overrideWith(
            (ref) => refundsValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
        if (countValue != null)
          pendingApprovalsCountProvider.overrideWith(
            (ref) => countValue.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1)),
              error: (e, s) => Future.error(e, s),
            ),
          ),
        if (filter != null)
          approvalFilterProvider.overrideWith((ref) => filter),
      ],
    );
  }

  // ===========================================================================
  // Tests
  // ===========================================================================

  group('ApprovalCenterScreen', () {
    testWidgets('renders correctly with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use a Completer that never completes to keep the provider in loading state
      final completer = Completer<List<ReturnsTableData>>();

      await tester.pumpWidget(createTestWidget(
        const ApprovalCenterScreen(),
        overrides: [
          pendingRefundsProvider.overrideWith((ref) => completer.future),
          pendingApprovalsCountProvider.overrideWith((ref) async => 0),
        ],
      ));
      await tester.pump();

      expect(find.byType(ApprovalCenterScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows filter tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        refundsValue: const AsyncValue.data([]),
        countValue: const AsyncValue.data(0),
      ));
      await tester.pumpAndSettle();

      // Filter chips should be present
      expect(find.byType(FilterChip), findsNWidgets(4));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no refunds', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        refundsValue: const AsyncValue.data([]),
        countValue: const AsyncValue.data(0),
      ));
      await tester.pumpAndSettle();

      // Empty state icon
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refund cards with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final refunds = [
        createTestReturn(
          id: 'r1',
          returnNumber: 'RET-001',
          customerName: 'Customer A',
          status: 'pending',
          totalRefund: 50.0,
        ),
        createTestReturn(
          id: 'r2',
          returnNumber: 'RET-002',
          customerName: 'Customer B',
          status: 'approved',
          totalRefund: 75.0,
        ),
      ];

      await tester.pumpWidget(buildScreen(
        refundsValue: AsyncValue.data(refunds),
        countValue: const AsyncValue.data(1),
      ));
      await tester.pumpAndSettle();

      // Return numbers should be visible
      expect(find.text('#RET-001'), findsOneWidget);
      expect(find.text('#RET-002'), findsOneWidget);
      // Customer names
      expect(find.text('Customer A'), findsOneWidget);
      expect(find.text('Customer B'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('pending refund card shows approve and reject buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final refunds = [
        createTestReturn(
          id: 'r1',
          returnNumber: 'RET-001',
          status: 'pending',
        ),
      ];

      await tester.pumpWidget(buildScreen(
        refundsValue: AsyncValue.data(refunds),
        countValue: const AsyncValue.data(1),
      ));
      await tester.pumpAndSettle();

      // Approve and reject buttons via icons
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('approved refund card does not show action buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final refunds = [
        createTestReturn(
          id: 'r1',
          returnNumber: 'RET-001',
          status: 'approved',
        ),
      ];

      await tester.pumpWidget(buildScreen(
        refundsValue: AsyncValue.data(refunds),
        countValue: const AsyncValue.data(0),
      ));
      await tester.pumpAndSettle();

      // Should not show approve/reject action buttons
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows error state with retry button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        refundsValue: AsyncValue.error(Exception('Load error'), StackTrace.current),
        countValue: const AsyncValue.data(0),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows pending count badge in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(buildScreen(
        refundsValue: const AsyncValue.data([]),
        countValue: const AsyncValue.data(7),
      ));
      await tester.pumpAndSettle();

      // Badge showing count
      expect(find.text('7'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
