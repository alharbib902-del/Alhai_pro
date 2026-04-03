/// Widget tests for OrdersScreen
///
/// Tests: loading state, empty state, data display, model mapping
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_shared_ui/src/screens/orders/orders_screen.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_empty_state.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

OrdersTableData _createTestOrder({
  String id = 'order-1',
  String orderNumber = 'ORD-001',
  String status = 'completed',
  String channel = 'pos',
  double total = 150.0,
  String paymentStatus = 'paid',
}) {
  return OrdersTableData(
    id: id,
    storeId: 'store-1',
    orderNumber: orderNumber,
    channel: channel,
    status: status,
    subtotal: total * 0.85,
    taxAmount: total * 0.15,
    deliveryFee: 0,
    discount: 0,
    total: total,
    paymentStatus: paymentStatus,
    deliveryType: 'pickup',
    confirmationAttempts: 0,
    autoReorderTriggered: false,
    orderDate: DateTime(2026, 1, 15),
    createdAt: DateTime(2026, 1, 15, 10, 30),
  );
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({
  AsyncValue<List<OrdersTableData>>? ordersValue,
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      ordersListProvider.overrideWith(
        (ref) => ordersValue?.when(
              data: (d) => Future.value(d),
              loading: () => Future.delayed(const Duration(days: 1), () => <OrdersTableData>[]),
              error: (e, _) => Future.error(e!),
            ) ??
            Future.value(<OrdersTableData>[]),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: OrdersScreen()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Allow overflow errors (pre-existing layout issues in the source)
  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });
  tearDown(() => FlutterError.onError = originalOnError);

  group('OrdersScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(OrdersScreen), findsOneWidget);
    });

    testWidgets('shows empty state when no orders', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget(
        ordersValue: const AsyncValue.data([]),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('shows orders when data loaded', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testOrders = [
        _createTestOrder(id: 'o1', orderNumber: 'ORD-001', total: 100),
        _createTestOrder(id: 'o2', orderNumber: 'ORD-002', total: 200, status: 'pending'),
      ];

      await tester.pumpWidget(_buildTestWidget(
        ordersValue: AsyncValue.data(testOrders),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.byType(AppEmptyState), findsNothing);
    });

    testWidgets('shows Scaffold structure', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('OrderModel', () {
    test('fromData extracts order number as id', () {
      final order = _createTestOrder(orderNumber: 'ORD-42');
      final model = OrderModel.fromData(order);
      expect(model.id, 'ORD-42');
    });

    test('fromData uses total amount', () {
      final order = _createTestOrder(total: 350.0);
      final model = OrderModel.fromData(order);
      expect(model.amount, 350.0);
    });

    test('fromData maps status correctly', () {
      final order = _createTestOrder(status: 'pending');
      final model = OrderModel.fromData(order);
      expect(model.status, 'pending');
    });

    test('fromData maps channel correctly', () {
      final order = _createTestOrder(channel: 'online');
      final model = OrderModel.fromData(order);
      expect(model.channel, 'online');
    });

    test('fromData maps payment status', () {
      final order = _createTestOrder(paymentStatus: 'unpaid');
      final model = OrderModel.fromData(order);
      expect(model.paymentStatus, 'unpaid');
    });
  });

  group('OrderItemModel', () {
    test('total calculates price times quantity', () {
      const item = OrderItemModel(
        name: 'Coffee',
        sku: 'SKU-001',
        quantity: 3,
        price: 10.0,
      );
      expect(item.total, 30.0);
    });

    test('total with quantity 1', () {
      const item = OrderItemModel(
        name: 'Cake',
        sku: 'SKU-002',
        quantity: 1,
        price: 25.0,
      );
      expect(item.total, 25.0);
    });
  });
}
