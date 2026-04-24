import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/customers/customer_ledger_screen.dart';

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
    // C-4 Session 4: accounts.balance, credit_limit are int cents.
    balance: (balance * 100).round(),
    creditLimit: (creditLimit * 100).round(),
    isActive: isActive,
    lastTransactionAt: lastTransactionAt,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAccountsDao accountsDao;
  late MockTransactionsDao transactionsDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    accountsDao = MockAccountsDao();
    transactionsDao = MockTransactionsDao();
    db = setupMockDatabase(
      accountsDao: accountsDao,
      transactionsDao: transactionsDao,
    );
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('CustomerLedgerScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      // P1 #12: accountLedgerDataProvider is now a StreamProvider that
      // combines watchAccountById + watchAccountTransactions. It stays in
      // the "loading" state until BOTH streams have emitted at least once.
      // Use never-completing streams (Completer futures) so the first
      // frame observes the spinner. Avoid pumpAndSettle — it would hang
      // because the streams never emit.
      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer(
        (_) => Stream<AccountsTableData?>.fromFuture(
          Completer<AccountsTableData?>().future,
        ),
      );
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer(
        (_) => Stream<List<TransactionsTableData>>.fromFuture(
          Completer<List<TransactionsTableData>>().future,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      // No pumpAndSettle: settling would hang because the streams never emit.

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows customer info card after loading', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer(
        (_) => Stream.value(_createTestAccount(balance: 500.0)),
      );
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer((_) => Stream.value(<TransactionsTableData>[]));

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      await tester.pumpAndSettle();

      // Phone icon for customer info
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      // Back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows filter section with date and type filters', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer((_) => Stream.value(_createTestAccount()));
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer((_) => Stream.value(<TransactionsTableData>[]));

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      await tester.pumpAndSettle();

      // Calendar icon for date filter
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      // Filter icon for type filter
      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer((_) => Stream.value(_createTestAccount()));
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer((_) => Stream.value(<TransactionsTableData>[]));

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('shows FAB for manual adjustment', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer((_) => Stream.value(_createTestAccount()));
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer((_) => Stream.value(<TransactionsTableData>[]));

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      await tester.pumpAndSettle();

      // Hotfix 2026-04-24 (§ P0-28): manual adjustment FAB is restricted to
      // storeOwner/superAdmin. The default test user (no role stub) is
      // treated as non-authorized, so the FAB must be hidden.
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows refresh button in top bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.watchAccountById(any()),
      ).thenAnswer((_) => Stream.value(_createTestAccount()));
      when(
        () => transactionsDao.watchAccountTransactions(any()),
      ).thenAnswer((_) => Stream.value(<TransactionsTableData>[]));

      await tester.pumpWidget(
        createTestWidget(const CustomerLedgerScreen(id: 'acc-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
