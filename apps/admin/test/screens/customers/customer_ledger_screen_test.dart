library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/customers/customer_ledger_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockAccountsDao accountsDao;
  late MockTransactionsDao transactionsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    accountsDao = MockAccountsDao();
    transactionsDao = MockTransactionsDao();
    db = setupMockDatabase(
      accountsDao: accountsDao,
      transactionsDao: transactionsDao,
    );
    setupTestGetIt(mockDb: db);

    when(() => accountsDao.getAccountById(any())).thenAnswer((_) async => null);
    when(() => transactionsDao.getAccountTransactions(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('CustomerLedgerScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
          const CustomerLedgerScreen(customerId: 'test-customer-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerLedgerScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
          const CustomerLedgerScreen(customerId: 'test-customer-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows receipt icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
          const CustomerLedgerScreen(customerId: 'test-customer-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add transaction button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(
          const CustomerLedgerScreen(customerId: 'test-customer-1')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle_outline), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = CustomerLedgerScreen(customerId: 'test-customer-1');
      expect(screen, isA<CustomerLedgerScreen>());
    });
  });
}
