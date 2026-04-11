import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // transactions reference accounts via FK
    await db.accountsDao.insertAccount(
      AccountsTableCompanion.insert(
        id: 'acc-1',
        storeId: 'store-1',
        type: 'receivable',
        name: 'Test Acct',
        createdAt: DateTime(2025, 1, 1),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionsDao', () {
    test('insertTransaction and getAccountTransactions', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-1',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 500.0,
          balanceAfter: 500.0,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final txns = await db.transactionsDao.getAccountTransactions('acc-1');
      expect(txns, hasLength(1));
      expect(txns.first.amount, 500.0);
      expect(txns.first.type, 'invoice');
    });

    test('getAccountTransactionsByType filters by type', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-1',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 500.0,
          balanceAfter: 500.0,
          createdAt: DateTime(2025, 6, 15),
        ),
      );
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-2',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'payment',
          amount: -200.0,
          balanceAfter: 300.0,
          createdAt: DateTime(2025, 6, 16),
        ),
      );

      final payments = await db.transactionsDao.getAccountTransactionsByType(
        'acc-1',
        'payment',
      );
      expect(payments, hasLength(1));
      expect(payments.first.amount, -200.0);
    });

    test('getTransactionsInRange filters by date', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-jan',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 100.0,
          balanceAfter: 100.0,
          createdAt: DateTime(2025, 1, 15),
        ),
      );
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-jun',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 200.0,
          balanceAfter: 300.0,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final results = await db.transactionsDao.getTransactionsInRange(
        'acc-1',
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'tx-jun');
    });

    test('recordInvoice creates invoice transaction', () async {
      await db.transactionsDao.recordInvoice(
        id: 'tx-inv-1',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 350.0,
        balanceAfter: 350.0,
        saleId: 'sale-1',
      );

      final txns = await db.transactionsDao.getAccountTransactions('acc-1');
      expect(txns, hasLength(1));
      expect(txns.first.type, 'invoice');
      expect(txns.first.referenceId, 'sale-1');
      expect(txns.first.referenceType, 'sale');
    });

    test('recordPayment creates negative amount transaction', () async {
      await db.transactionsDao.recordPayment(
        id: 'tx-pay-1',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 150.0,
        balanceAfter: 200.0,
        paymentMethod: 'cash',
      );

      final txns = await db.transactionsDao.getAccountTransactions('acc-1');
      expect(txns, hasLength(1));
      expect(txns.first.type, 'payment');
      expect(txns.first.amount, -150.0); // negative for payments
    });

    test('recordInterest creates interest transaction', () async {
      await db.transactionsDao.recordInterest(
        id: 'tx-int-1',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 25.0,
        balanceAfter: 525.0,
        periodKey: '2025-06',
      );

      final txns = await db.transactionsDao.getAccountTransactions('acc-1');
      expect(txns.first.type, 'interest');
      expect(txns.first.periodKey, '2025-06');
    });

    test('hasInterestForPeriod detects duplicate interest', () async {
      await db.transactionsDao.recordInterest(
        id: 'tx-int-1',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 25.0,
        balanceAfter: 525.0,
        periodKey: '2025-06',
      );

      final hasInterest = await db.transactionsDao.hasInterestForPeriod(
        'acc-1',
        '2025-06',
      );
      expect(hasInterest, true);

      final noInterest = await db.transactionsDao.hasInterestForPeriod(
        'acc-1',
        '2025-07',
      );
      expect(noInterest, false);
    });

    test('getTotalPayments sums payment amounts', () async {
      await db.transactionsDao.recordPayment(
        id: 'tx-1',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 100.0,
        balanceAfter: 400.0,
        paymentMethod: 'cash',
      );
      await db.transactionsDao.recordPayment(
        id: 'tx-2',
        storeId: 'store-1',
        accountId: 'acc-1',
        amount: 200.0,
        balanceAfter: 200.0,
        paymentMethod: 'card',
      );

      final total = await db.transactionsDao.getTotalPayments('acc-1');
      expect(total, 300.0);
    });
  });
}
