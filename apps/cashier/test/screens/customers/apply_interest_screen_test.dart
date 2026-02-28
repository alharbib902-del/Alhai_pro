import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/customers/apply_interest_screen.dart';

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

  group('ApplyInterestScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => <AccountsTableData>[]);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no-accounts message when empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      // Return accounts with zero balance (no debt)
      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => [
                _createTestAccount(id: 'acc-1', balance: 0.0),
              ]);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('shows interest rate card with percent icon',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(id: 'acc-1', balance: 1000.0),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));
      await tester.pumpAndSettle();

      // Percent icon for rate card
      expect(find.byIcon(Icons.percent_rounded), findsWidgets);
      // Rate input field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows customer list with people icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(
            id: 'acc-1', name: '\u0639\u0645\u064a\u0644 1', balance: 1000.0),
        _createTestAccount(
            id: 'acc-2', name: '\u0639\u0645\u064a\u0644 2', balance: 500.0),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));
      await tester.pumpAndSettle();

      // People icon for customers section
      expect(find.byIcon(Icons.people_rounded), findsOneWidget);
      // Select All button
      expect(find.text('Select All'), findsOneWidget);
    });

    testWidgets('shows preview card with preview icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(id: 'acc-1', balance: 1000.0),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));
      await tester.pumpAndSettle();

      // Preview icon
      expect(find.byIcon(Icons.preview_rounded), findsOneWidget);
      // Preview text
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('apply button is disabled when no customers selected',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(id: 'acc-1', balance: 1000.0),
      ];

      when(() => accountsDao.getReceivableAccounts(any()))
          .thenAnswer((_) async => accounts);

      await tester
          .pumpWidget(createTestWidget(const ApplyInterestScreen()));
      await tester.pumpAndSettle();

      // Apply button should be disabled (no customers selected)
      // Use ancestor finder because FilledButton.icon creates a subclass
      final filledButtonFinder = find.ancestor(
        of: find.text('Apply Interest'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(filledButtonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(filledButtonFinder);
      expect(button.onPressed, isNull);
    });
  });
}
