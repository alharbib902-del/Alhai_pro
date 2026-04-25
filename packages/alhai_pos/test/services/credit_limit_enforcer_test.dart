import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/services/credit_limit_enforcer.dart';

import '../helpers/pos_test_helpers.dart';

/// P0-13 unit tests. The enforcer's branches all flow through the
/// private `_evaluate` method, but covering them via the public surface
/// (`check` + `checkByCustomer`) keeps the contract intact.
void main() {
  late MockAppDatabase mockDb;
  late MockAccountsDao mockAccounts;
  late CreditLimitEnforcer enforcer;

  AccountsTableData makeAccount({
    String id = 'acc-1',
    String customerId = 'cust-1',
    int balance = 0,
    int creditLimit = 0,
  }) {
    return AccountsTableData(
      id: id,
      storeId: 'store-1',
      type: 'receivable',
      customerId: customerId,
      name: 'Test Customer',
      balance: balance,
      creditLimit: creditLimit,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    mockDb = MockAppDatabase();
    mockAccounts = MockAccountsDao();
    when(() => mockDb.accountsDao).thenReturn(mockAccounts);
    enforcer = CreditLimitEnforcer(db: mockDb);
  });

  group('CreditLimitEnforcer.check', () {
    test('returns NoLimitSet when account is missing', () async {
      when(() => mockAccounts.getAccountById('acc-1'))
          .thenAnswer((_) async => null);
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 50000,
      );
      expect(result, isA<NoLimitSet>());
    });

    test('returns NoLimitSet when creditLimit is 0', () async {
      when(() => mockAccounts.getAccountById('acc-1'))
          .thenAnswer((_) async => makeAccount(balance: 10000, creditLimit: 0));
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 50000,
      );
      expect(result, isA<NoLimitSet>());
    });

    test('returns ok when projected balance is well under limit', () async {
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async =>
            makeAccount(balance: 10000, creditLimit: 100000), // 100/1000
      );
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 5000, // +50 → 150/1000 (15%)
      );
      expect(result, isA<CreditCheckOk>());
      final ok = result as CreditCheckOk;
      expect(ok.newBalanceCents, 15000);
    });

    test('returns warning when projected balance crosses 90%', () async {
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async =>
            makeAccount(balance: 80000, creditLimit: 100000), // 800/1000
      );
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 12000, // +120 → 920/1000 (92%)
      );
      expect(result, isA<CreditCheckWarning>());
      final warning = result as CreditCheckWarning;
      expect(warning.newBalanceCents, 92000);
      expect(warning.utilisation, closeTo(0.92, 0.001));
      expect(result.isWarning, isTrue);
      expect(result.isBlocked, isFalse);
    });

    test('returns exceeded when projected balance > limit', () async {
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async =>
            makeAccount(balance: 95000, creditLimit: 100000), // 950/1000
      );
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 10000, // +100 → 1050/1000 → over by 50
      );
      expect(result, isA<CreditCheckExceeded>());
      final exceeded = result as CreditCheckExceeded;
      expect(exceeded.newBalanceCents, 105000);
      expect(exceeded.overByCents, 5000);
      expect(result.isBlocked, isTrue);
    });

    test('payments (negative deltas) always pass even past the limit',
        () async {
      // Edge case: an account ALREADY over its limit (e.g. limit was
      // lowered after debt accumulated). A payment must never be
      // blocked — it's reducing the obligation, not creating it.
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async =>
            makeAccount(balance: 200000, creditLimit: 100000), // already over
      );
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: -50000, // -500 payment
      );
      expect(result, isA<CreditCheckOk>());
      final ok = result as CreditCheckOk;
      expect(ok.newBalanceCents, 150000); // still over but check passes
    });

    test('warning threshold is configurable', () async {
      final lenient = CreditLimitEnforcer(db: mockDb, warningThreshold: 0.95);
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async => makeAccount(balance: 80000, creditLimit: 100000),
      );
      final result = await lenient.check(
        accountId: 'acc-1',
        proposedDeltaCents: 12000, // +120 → 920/1000 (92%)
      );
      // 92% < 95% → still ok, not warning
      expect(result, isA<CreditCheckOk>());
    });

    test('exact-limit boundary: newBalance == limit is ok (not exceeded)',
        () async {
      when(() => mockAccounts.getAccountById('acc-1')).thenAnswer(
        (_) async => makeAccount(balance: 50000, creditLimit: 100000),
      );
      final result = await enforcer.check(
        accountId: 'acc-1',
        proposedDeltaCents: 50000, // exactly at limit
      );
      // 100% utilisation crosses the 90% warning threshold.
      expect(result, isA<CreditCheckWarning>());
      final warning = result as CreditCheckWarning;
      expect(warning.newBalanceCents, 100000);
      expect(warning.utilisation, 1.0);
    });
  });

  group('CreditLimitEnforcer.checkByCustomer', () {
    test('resolves account from (customerId, storeId) tuple', () async {
      when(() => mockAccounts.getCustomerAccount('cust-1', 'store-1'))
          .thenAnswer((_) async => makeAccount(balance: 10000, creditLimit: 100000));
      final result = await enforcer.checkByCustomer(
        customerId: 'cust-1',
        storeId: 'store-1',
        proposedDeltaCents: 5000,
      );
      expect(result, isA<CreditCheckOk>());
      verify(() => mockAccounts.getCustomerAccount('cust-1', 'store-1'))
          .called(1);
    });

    test('returns NoLimitSet when customer has no receivable account',
        () async {
      when(() => mockAccounts.getCustomerAccount('cust-1', 'store-1'))
          .thenAnswer((_) async => null);
      final result = await enforcer.checkByCustomer(
        customerId: 'cust-1',
        storeId: 'store-1',
        proposedDeltaCents: 50000,
      );
      expect(result, isA<NoLimitSet>());
    });
  });
}
