import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/customers/new_transaction_screen.dart';

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

  group('NewTransactionScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => <AccountsTableData>[]);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows customer selector card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      final accounts = [
        _createTestAccount(id: 'acc-1', name: '\u0639\u0645\u064a\u0644 1'),
      ];

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => accounts);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));
      await tester.pumpAndSettle();

      // Person icon for customer card
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      // Search field for customer selection
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows type selector with debt and payment options', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => [_createTestAccount()]);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));
      await tester.pumpAndSettle();

      // Type selector icon (may appear in header too)
      expect(find.byIcon(Icons.swap_vert_rounded), findsWidgets);
      // Debt arrow up and payment arrow down
      expect(find.byIcon(Icons.arrow_upward_rounded), findsWidgets);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsWidgets);
    });

    testWidgets('shows amount card with money icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => [_createTestAccount()]);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));
      await tester.pumpAndSettle();

      // Amount card icon
      expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
    });

    testWidgets('shows note card with note icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => [_createTestAccount()]);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));
      await tester.pumpAndSettle();

      // Note icon
      expect(find.byIcon(Icons.note_alt_rounded), findsOneWidget);
    });

    testWidgets('submit button is disabled when no account or amount', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => accountsDao.getReceivableAccounts(any()),
      ).thenAnswer((_) async => [_createTestAccount()]);

      await tester.pumpWidget(createTestWidget(const NewTransactionScreen()));
      await tester.pumpAndSettle();

      // Submit button should be disabled (no account selected, no amount)
      // Use ancestor finder because FilledButton.icon creates a subclass
      final filledButtonFinder = find.ancestor(
        of: find.text('Record Debt'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(filledButtonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(filledButtonFinder);
      expect(button.onPressed, isNull);
    });
  });
}
