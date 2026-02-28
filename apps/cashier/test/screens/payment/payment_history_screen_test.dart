import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/payment/payment_history_screen.dart';

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

  group('PaymentHistoryScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no payments', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows payment method filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => <OrdersTableData>[]);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));
      await tester.pumpAndSettle();

      // Payment method filter icons
      expect(find.byIcon(Icons.money_rounded), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
      expect(
          find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('displays payment cards when orders loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'order-1',
          total: 150.0,
          paymentMethod: 'cash',
          status: 'completed',
        ),
        createTestOrder(
          id: 'order-2',
          total: 250.0,
          paymentMethod: 'card',
          status: 'completed',
        ),
      ];

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => orders);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));
      await tester.pumpAndSettle();

      // Person icons on payment cards
      expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);
      // Time icons on payment cards
      expect(find.byIcon(Icons.access_time_rounded), findsWidgets);
    });

    testWidgets('shows summary stats section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final orders = [
        createTestOrder(
          id: 'order-1',
          total: 100.0,
          status: 'completed',
        ),
      ];

      when(() => ordersDao.getOrders(any()))
          .thenAnswer((_) async => orders);

      await tester
          .pumpWidget(createTestWidget(const PaymentHistoryScreen()));
      await tester.pumpAndSettle();

      // Summary stats should show "Payments" text
      expect(find.text('Payments'), findsOneWidget);
    });
  });
}
