/// Tests for Lite Active Orders Screen
///
/// Verifies rendering of order cards, filter tabs, loading state,
/// error state, empty state, and status display.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_orders_providers.dart';
import 'package:admin_lite/screens/orders/lite_active_orders_screen.dart';
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
  // Factory helpers
  // ===========================================================================

  OrderWithCustomer createTestOrder({
    String id = 'ord-1',
    String orderNumber = 'ORD-001',
    String status = 'confirmed',
    double total = 150.0,
    String? customerName = 'Customer A',
    DateTime? orderDate,
  }) {
    return OrderWithCustomer(
      id: id,
      orderNumber: orderNumber,
      status: status,
      total: total,
      orderDate: orderDate ?? DateTime(2026, 1, 15, 14, 30),
      customerName: customerName,
    );
  }

  // ===========================================================================
  // Helper
  // ===========================================================================

  Widget buildScreen({AsyncValue<List<OrderWithCustomer>>? ordersValue}) {
    return createTestWidget(
      const LiteActiveOrdersScreen(),
      overrides: [
        if (ordersValue != null)
          liteActiveOrdersProvider.overrideWith(
            (ref) => ordersValue.when(
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

  group('LiteActiveOrdersScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<OrderWithCustomer>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteActiveOrdersScreen(),
          overrides: [
            liteActiveOrdersProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteActiveOrdersScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows filter tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(ordersValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      // 5 filter chips: All, Confirmed, Preparing, Ready, Delivering
      expect(find.byType(FilterChip), findsNWidgets(5));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows order cards with data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'o1',
          orderNumber: 'ORD-001',
          status: 'confirmed',
          total: 150.0,
          customerName: 'Customer A',
        ),
        createTestOrder(
          id: 'o2',
          orderNumber: 'ORD-002',
          status: 'preparing',
          total: 200.0,
          customerName: 'Customer B',
        ),
      ];

      await tester.pumpWidget(
        buildScreen(ordersValue: AsyncValue.data(orders)),
      );
      await tester.pumpAndSettle();

      expect(find.text('#ORD-001'), findsOneWidget);
      expect(find.text('#ORD-002'), findsOneWidget);
      expect(find.text('Customer A'), findsOneWidget);
      expect(find.text('Customer B'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows status label on order cards', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final orders = [
        createTestOrder(id: 'o1', orderNumber: 'ORD-001', status: 'confirmed'),
      ];

      await tester.pumpWidget(
        buildScreen(ordersValue: AsyncValue.data(orders)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows order total with SAR', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final orders = [
        createTestOrder(id: 'o1', orderNumber: 'ORD-001', total: 250.0),
      ];

      await tester.pumpWidget(
        buildScreen(ordersValue: AsyncValue.data(orders)),
      );
      await tester.pumpAndSettle();

      expect(find.text('250 SAR'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button in app bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(ordersValue: const AsyncValue.data([])),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('handles error state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          ordersValue: AsyncValue.error(
            Exception('Network error'),
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
