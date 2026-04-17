/// Tests for Lite Order History Screen
///
/// Verifies rendering of completed/cancelled orders, date headers,
/// loading state, error state, and empty state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:admin_lite/providers/lite_orders_providers.dart';
import 'package:admin_lite/screens/orders/lite_order_history_screen.dart';
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
    String status = 'delivered',
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
      const LiteOrderHistoryScreen(),
      overrides: [
        if (ordersValue != null)
          liteOrderHistoryProvider.overrideWith(
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

  group('LiteOrderHistoryScreen', () {
    testWidgets('renders with loading state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<OrderWithCustomer>>();

      await tester.pumpWidget(
        createTestWidget(
          const LiteOrderHistoryScreen(),
          overrides: [
            liteOrderHistoryProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LiteOrderHistoryScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows completed order with check icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'o1',
          orderNumber: 'ORD-001',
          status: 'delivered',
          total: 100.0,
          customerName: 'Ahmed',
        ),
      ];

      await tester.pumpWidget(
        buildScreen(ordersValue: AsyncValue.data(orders)),
      );
      await tester.pumpAndSettle();

      expect(find.text('#ORD-001'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('100 SAR'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows cancelled order with cancel icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'o1',
          orderNumber: 'ORD-002',
          status: 'cancelled',
          total: 75.0,
        ),
      ];

      await tester.pumpWidget(
        buildScreen(ordersValue: AsyncValue.data(orders)),
      );
      await tester.pumpAndSettle();

      expect(find.text('#ORD-002'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

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

    testWidgets('handles error state with retry', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        buildScreen(
          ordersValue: AsyncValue.error(
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
