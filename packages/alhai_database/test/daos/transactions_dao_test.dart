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
          amount: 50000, // 500.00 in cents
          balanceAfter: 50000, // 500.00 in cents
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final txns = await db.transactionsDao.getAccountTransactions('acc-1');
      expect(txns, hasLength(1));
      expect(txns.first.amount, 50000); // 500.00 in cents
      expect(txns.first.type, 'invoice');
    });

    test('getAccountTransactionsByType filters by type', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-1',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 50000, // 500.00 in cents
          balanceAfter: 50000, // 500.00 in cents
          createdAt: DateTime(2025, 6, 15),
        ),
      );
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-2',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'payment',
          amount: -20000, // -200.00 in cents
          balanceAfter: 30000, // 300.00 in cents
          createdAt: DateTime(2025, 6, 16),
        ),
      );

      final payments = await db.transactionsDao.getAccountTransactionsByType(
        'acc-1',
        'payment',
      );
      expect(payments, hasLength(1));
      expect(payments.first.amount, -20000); // -200.00 in cents
    });

    test('getTransactionsInRange filters by date', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-jan',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 10000, // 100.00 in cents
          balanceAfter: 10000, // 100.00 in cents
          createdAt: DateTime(2025, 1, 15),
        ),
      );
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: 'tx-jun',
          storeId: 'store-1',
          accountId: 'acc-1',
          type: 'invoice',
          amount: 20000, // 200.00 in cents
          balanceAfter: 30000, // 300.00 in cents
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
      expect(txns.first.amount, -15000); // -150.00 in cents, negative for payments
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

    // ─── P0-27 deferred: supplier payable transaction ──────────────
    test(
      'recordSupplierPayable persists with type=invoice + reference=purchase',
      () async {
        await db.transactionsDao.recordSupplierPayable(
          id: 'tx-pay-1',
          storeId: 'store-1',
          accountId: 'acc-1',
          amount: 250.50,
          balanceAfter: 750.50,
          purchaseId: 'pur-xyz',
          description: 'استلام طلب شراء #PO-9001',
          createdBy: 'user-1',
        );

        final txns =
            await db.transactionsDao.getAccountTransactions('acc-1');
        expect(txns, hasLength(1));
        final tx = txns.first;
        expect(tx.type, 'invoice');
        expect(tx.amount, 25050); // 250.50 SAR as cents
        expect(tx.balanceAfter, 75050);
        expect(tx.referenceType, 'purchase');
        expect(tx.referenceId, 'pur-xyz');
        expect(tx.description, 'استلام طلب شراء #PO-9001');
        expect(tx.createdBy, 'user-1');
      },
    );
  });
}
