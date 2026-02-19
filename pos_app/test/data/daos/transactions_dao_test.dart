import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Transactions DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('TransactionsDao', () {
    const testStoreId = 'store_123';
    const testAccountId = 'acc_001';

    TransactionsTableCompanion createTransaction({
      required String id,
      required String type,
      required double amount,
      required double balanceAfter,
      String? referenceId,
      String? referenceType,
      String? periodKey,
      String? paymentMethod,
      String? description,
      String? createdBy,
      DateTime? createdAt,
    }) {
      return TransactionsTableCompanion.insert(
        id: id,
        storeId: testStoreId,
        accountId: testAccountId,
        type: type,
        amount: amount,
        balanceAfter: balanceAfter,
        referenceId: Value(referenceId),
        referenceType: Value(referenceType),
        periodKey: Value(periodKey),
        paymentMethod: Value(paymentMethod),
        description: Value(description),
        createdBy: Value(createdBy),
        createdAt: createdAt ?? DateTime.now(),
      );
    }

    group('insertTransaction', () {
      test('يُضيف حركة جديدة بنجاح', () async {
        final transaction = createTransaction(
          id: 'txn_001',
          type: 'invoice',
          amount: 500,
          balanceAfter: 500,
        );

        final result = await database.transactionsDao.insertTransaction(transaction);
        expect(result, greaterThan(0));
      });
    });

    group('getAccountTransactions', () {
      test('يُرجع حركات الحساب', () async {
        await database.transactionsDao.insertTransaction(
          createTransaction(id: 'txn_001', type: 'invoice', amount: 500, balanceAfter: 500),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(id: 'txn_002', type: 'payment', amount: -200, balanceAfter: 300),
        );

        final result = await database.transactionsDao.getAccountTransactions(testAccountId);
        expect(result.length, 2);
      });

      test('يُرتب الحركات تنازلياً حسب التاريخ', () async {
        final now = DateTime.now();
        await database.transactionsDao.insertTransaction(
          createTransaction(
            id: 'txn_001',
            type: 'invoice',
            amount: 100,
            balanceAfter: 100,
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(
            id: 'txn_002',
            type: 'invoice',
            amount: 200,
            balanceAfter: 300,
            createdAt: now,
          ),
        );

        final result = await database.transactionsDao.getAccountTransactions(testAccountId);
        expect(result[0].id, 'txn_002'); // الأحدث أولاً
        expect(result[1].id, 'txn_001');
      });
    });

    group('getAccountTransactionsByType', () {
      test('يُرجع حركات من نوع محدد فقط', () async {
        await database.transactionsDao.insertTransaction(
          createTransaction(id: 'txn_001', type: 'invoice', amount: 500, balanceAfter: 500),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(id: 'txn_002', type: 'payment', amount: -200, balanceAfter: 300),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(id: 'txn_003', type: 'invoice', amount: 100, balanceAfter: 400),
        );

        final invoices = await database.transactionsDao.getAccountTransactionsByType(
          testAccountId,
          'invoice',
        );
        expect(invoices.length, 2);
        expect(invoices.every((t) => t.type == 'invoice'), isTrue);

        final payments = await database.transactionsDao.getAccountTransactionsByType(
          testAccountId,
          'payment',
        );
        expect(payments.length, 1);
      });
    });

    group('getTransactionsInRange', () {
      test('يُرجع حركات ضمن فترة زمنية', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final lastWeek = now.subtract(const Duration(days: 7));
        final lastMonth = now.subtract(const Duration(days: 30));

        await database.transactionsDao.insertTransaction(
          createTransaction(
            id: 'txn_old',
            type: 'invoice',
            amount: 100,
            balanceAfter: 100,
            createdAt: lastMonth,
          ),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(
            id: 'txn_week',
            type: 'invoice',
            amount: 200,
            balanceAfter: 300,
            createdAt: lastWeek,
          ),
        );
        await database.transactionsDao.insertTransaction(
          createTransaction(
            id: 'txn_yesterday',
            type: 'invoice',
            amount: 150,
            balanceAfter: 450,
            createdAt: yesterday,
          ),
        );

        // البحث في آخر 10 أيام
        final result = await database.transactionsDao.getTransactionsInRange(
          testAccountId,
          now.subtract(const Duration(days: 10)),
          now,
        );
        expect(result.length, 2); // txn_week و txn_yesterday فقط
      });
    });

    group('recordInvoice', () {
      test('يسجل فاتورة بشكل صحيح', () async {
        await database.transactionsDao.recordInvoice(
          id: 'txn_inv_001',
          storeId: testStoreId,
          accountId: testAccountId,
          amount: 750,
          balanceAfter: 750,
          saleId: 'sale_001',
          createdBy: 'user_001',
        );

        final transactions = await database.transactionsDao.getAccountTransactions(testAccountId);
        expect(transactions.length, 1);
        expect(transactions.first.type, 'invoice');
        expect(transactions.first.amount, 750);
        expect(transactions.first.referenceId, 'sale_001');
        expect(transactions.first.referenceType, 'sale');
      });
    });

    group('recordPayment', () {
      test('يسجل دفعة بشكل صحيح (مبلغ سالب)', () async {
        await database.transactionsDao.recordPayment(
          id: 'txn_pay_001',
          storeId: testStoreId,
          accountId: testAccountId,
          amount: 300, // المبلغ المُدخل موجب
          balanceAfter: 450,
          paymentMethod: 'cash',
          description: 'دفعة نقدية',
          createdBy: 'user_001',
        );

        final transactions = await database.transactionsDao.getAccountTransactions(testAccountId);
        expect(transactions.length, 1);
        expect(transactions.first.type, 'payment');
        expect(transactions.first.amount, -300); // يُحفظ سالباً
        expect(transactions.first.paymentMethod, 'cash');
        expect(transactions.first.description, 'دفعة نقدية');
      });
    });

    group('recordInterest', () {
      test('يسجل فائدة شهرية', () async {
        await database.transactionsDao.recordInterest(
          id: 'txn_int_001',
          storeId: testStoreId,
          accountId: testAccountId,
          amount: 50,
          balanceAfter: 550,
          periodKey: '2026-02',
          createdBy: 'system',
        );

        final transactions = await database.transactionsDao.getAccountTransactions(testAccountId);
        expect(transactions.length, 1);
        expect(transactions.first.type, 'interest');
        expect(transactions.first.periodKey, '2026-02');
      });
    });

    group('hasInterestForPeriod', () {
      test('يُرجع true إذا وُجدت فائدة للفترة', () async {
        await database.transactionsDao.recordInterest(
          id: 'txn_int_001',
          storeId: testStoreId,
          accountId: testAccountId,
          amount: 50,
          balanceAfter: 550,
          periodKey: '2026-02',
        );

        final hasInterest = await database.transactionsDao.hasInterestForPeriod(
          testAccountId,
          '2026-02',
        );
        expect(hasInterest, isTrue);
      });

      test('يُرجع false إذا لم تُوجد فائدة للفترة', () async {
        final hasInterest = await database.transactionsDao.hasInterestForPeriod(
          testAccountId,
          '2026-03',
        );
        expect(hasInterest, isFalse);
      });
    });
  });
}
