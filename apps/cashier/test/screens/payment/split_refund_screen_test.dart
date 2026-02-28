import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/payment/split_refund_screen.dart';

void main() {
  late MockOrdersDao ordersDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    ordersDao = MockOrdersDao();
    db = setupMockDatabase(ordersDao: ordersDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('SplitRefundScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(id: 'order-1'));

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not-found state when order is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('Order not found'), findsOneWidget);
    });

    testWidgets('shows refund methods card when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
                paymentMethod: 'cash',
              ));

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Refund card icon
      expect(find.byIcon(Icons.assignment_return_rounded), findsWidgets);
    });

    testWidgets('shows refund summary card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
                paymentMethod: 'cash',
              ));

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Refund summary icon
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
      expect(find.text('Refund Summary'), findsOneWidget);
    });

    testWidgets('shows bottom bar with process refund button',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
                paymentMethod: 'cash',
              ));

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      expect(find.text('Process Refund'), findsOneWidget);
    });

    testWidgets('has back button in top bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
              ));

      await tester.pumpWidget(createTestWidget(
          const SplitRefundScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      // Title
      expect(find.text('Split Refund'), findsOneWidget);
    });
  });
}
