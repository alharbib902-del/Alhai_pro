import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/payment/split_receipt_screen.dart';

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

  group('SplitReceiptScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(id: 'order-1'));

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not-found state when order is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('Order not found'), findsOneWidget);
    });

    testWidgets('shows order summary card when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
                paymentMethod: 'cash',
              ));

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Order summary card icon
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('shows payment breakdown card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
                paymentMethod: 'cash',
              ));

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Payment breakdown icon
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);
    });

    testWidgets('shows QR code card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
              ));

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // QR code icon
      expect(find.byIcon(Icons.qr_code_rounded), findsOneWidget);
    });

    testWidgets('shows print and share action buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrderById(any()))
          .thenAnswer((_) async => createTestOrder(
                id: 'order-1',
                total: 200.0,
              ));

      await tester.pumpWidget(
          createTestWidget(const SplitReceiptScreen(orderId: 'order-1')));
      await tester.pumpAndSettle();

      // Print button
      expect(find.byIcon(Icons.print_rounded), findsOneWidget);
      // Share button
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });
  });
}
