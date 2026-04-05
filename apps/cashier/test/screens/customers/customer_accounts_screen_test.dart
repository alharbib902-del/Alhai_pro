import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/customers/customer_accounts_screen.dart';

/// Helper to create an [AccountsTableData] for testing.
AccountsTableData _createTestAccount({
  String id = 'acc-1',
  String storeId = 'test-store-1',
  String type = 'receivable',
  String? customerId = 'cust-1',
  String name = '\u0639\u0645\u064a\u0644 \u062a\u062c\u0631\u064a\u0628\u064a',
  String? phone = '0501234567',
  double balance = 500.0,
  double creditLimit = 5000.0,
  bool isActive = true,
  DateTime? lastTransactionAt,
  DateTime? createdAt,
}) {
  return AccountsTableData(
    id: id,
    storeId: storeId,
    type: type,
    customerId: customerId,
    name: name,
    phone: phone,
    balance: balance,
    creditLimit: creditLimit,
    isActive: isActive,
    lastTransactionAt: lastTransactionAt,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAccountsDao accountsDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    accountsDao = MockAccountsDao();
    db = setupMockDatabase(accountsDao: accountsDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('CustomerAccountsScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => <AccountsTableData>[]);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no accounts', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => <AccountsTableData>[]);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => <AccountsTableData>[]);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('displays account cards when data loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(
          id: 'acc-1',
          name: '\u0639\u0645\u064a\u0644 1',
          balance: 300.0,
        ),
        _createTestAccount(
          id: 'acc-2',
          name: '\u0639\u0645\u064a\u0644 2',
          balance: 700.0,
        ),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));
      await tester.pumpAndSettle();

      // Chevron icons on each card
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    });

    testWidgets('shows summary stats section', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(id: 'acc-1', balance: 500.0),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));
      await tester.pumpAndSettle();

      // Summary stats should show "Customers" text
      expect(find.text('\u0627\u0644\u0639\u0645\u0644\u0627\u0621'),
          findsOneWidget);
      expect(find.text('\u0645\u062a\u0623\u062e\u0631\u0629'), findsWidgets);
    });

    testWidgets('shows status filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => <AccountsTableData>[]);

      await tester.pumpWidget(createTestWidget(const CustomerAccountsScreen()));
      await tester.pumpAndSettle();

      // Filter chip icons
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });
}
