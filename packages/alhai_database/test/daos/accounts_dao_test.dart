import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // Accounts reference customers via FK
    await db.customersDao.insertCustomer(
      CustomersTableCompanion.insert(
        id: 'cust-1',
        storeId: 'store-1',
        name: 'Cust 1',
        createdAt: DateTime(2025, 1, 1),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  AccountsTableCompanion makeAccount({
    String id = 'acc-1',
    String storeId = 'store-1',
    String type = 'receivable',
    String name = 'حساب أحمد محمد',
    String? customerId = 'cust-1',
    double balance = 500.0,
  }) {
    return AccountsTableCompanion.insert(
      id: id,
      storeId: storeId,
      type: type,
      name: name,
      customerId: Value(customerId),
      balance: Value((balance * 100).round()),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('AccountsDao', () {
    test('insertAccount and getAccountById', () async {
      await db.accountsDao.insertAccount(makeAccount());

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account, isNotNull);
      expect(account!.name, 'حساب أحمد محمد');
      expect(account.balance, 50000); // 500.00 SAR as int cents
      expect(account.type, 'receivable');
    });

    test('getAllAccounts returns accounts for store', () async {
      await db.accountsDao.insertAccount(makeAccount());
      await db.accountsDao.insertAccount(
        makeAccount(id: 'acc-2', name: 'حساب خالد', type: 'payable'),
      );

      final accounts = await db.accountsDao.getAllAccounts('store-1');
      expect(accounts, hasLength(2));
    });

    test('getReceivableAccounts filters by type', () async {
      await db.accountsDao.insertAccount(
        makeAccount(id: 'acc-r', type: 'receivable'),
      );
      await db.accountsDao.insertAccount(
        makeAccount(id: 'acc-p', name: 'مورد', type: 'payable'),
      );

      final receivables = await db.accountsDao.getReceivableAccounts('store-1');
      expect(receivables, hasLength(1));
      expect(receivables.first.type, 'receivable');
    });

    test('getPayableAccounts filters by type', () async {
      await db.accountsDao.insertAccount(
        makeAccount(id: 'acc-r', type: 'receivable'),
      );
      await db.accountsDao.insertAccount(
        makeAccount(id: 'acc-p', name: 'مورد', type: 'payable'),
      );

      final payables = await db.accountsDao.getPayableAccounts('store-1');
      expect(payables, hasLength(1));
      expect(payables.first.type, 'payable');
    });

    test('getCustomerAccount finds by customerId and storeId', () async {
      await db.accountsDao.insertAccount(makeAccount());

      final account = await db.accountsDao.getCustomerAccount(
        'cust-1',
        'store-1',
      );
      expect(account, isNotNull);
      expect(account!.customerId, 'cust-1');
    });

    test('updateBalance changes balance', () async {
      await db.accountsDao.insertAccount(makeAccount(balance: 500.0));

      await db.accountsDao.updateBalance('acc-1', 750.0);

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.balance, 75000); // 750.00 SAR as int cents
      expect(account.lastTransactionAt, isNotNull);
    });

    test('addToBalance increases balance', () async {
      await db.accountsDao.insertAccount(makeAccount(balance: 500.0));

      await db.accountsDao.addToBalance('acc-1', 200.0);

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.balance, 70000); // 700.00 SAR as int cents
    });

    test('subtractFromBalance decreases balance', () async {
      await db.accountsDao.insertAccount(makeAccount(balance: 500.0));

      await db.accountsDao.subtractFromBalance('acc-1', 150.0);

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.balance, 35000); // 350.00 SAR as int cents
    });

    test('markAsSynced sets syncedAt', () async {
      await db.accountsDao.insertAccount(makeAccount());

      await db.accountsDao.markAsSynced('acc-1');

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.syncedAt, isNotNull);
    });

    // ─── P0-27 deferred: supplier payable helpers ────────────────────
    group('supplier payable', () {
      test('getSupplierAccount returns null when none exists', () async {
        final result =
            await db.accountsDao.getSupplierAccount('sup-1', 'store-1');
        expect(result, isNull);
      });

      test(
        'getOrCreateSupplierPayable creates the account on first call',
        () async {
          final created = await db.accountsDao.getOrCreateSupplierPayable(
            supplierId: 'sup-1',
            storeId: 'store-1',
            supplierName: 'مورد تجريبي',
          );

          expect(created.id, 'pay_sup-1_store-1');
          expect(created.type, 'payable');
          expect(created.supplierId, 'sup-1');
          expect(created.name, 'مورد تجريبي');
          expect(created.balance, 0);
        },
      );

      test(
        'getOrCreateSupplierPayable returns existing account on second call',
        () async {
          final first = await db.accountsDao.getOrCreateSupplierPayable(
            supplierId: 'sup-1',
            storeId: 'store-1',
            supplierName: 'مورد',
          );
          final second = await db.accountsDao.getOrCreateSupplierPayable(
            supplierId: 'sup-1',
            storeId: 'store-1',
            supplierName: 'مورد آخر — تجاهَل', // different name
          );

          expect(second.id, first.id);
          // Existing row's name preserved — getOrCreate doesn't update.
          expect(second.name, 'مورد');
        },
      );

      test(
        'getSupplierAccount only returns rows where type=payable',
        () async {
          // Insert a receivable row for sup-1 (an unusual but valid
          // case — a supplier who's also a customer for some reason).
          // The supplier-payable lookup must skip it.
          await db.accountsDao.insertAccount(
            AccountsTableCompanion.insert(
              id: 'acc-recv-sup-1',
              storeId: 'store-1',
              type: 'receivable',
              supplierId: const Value('sup-1'),
              name: 'مورد كعميل',
              createdAt: DateTime(2025, 1, 1),
            ),
          );

          final result =
              await db.accountsDao.getSupplierAccount('sup-1', 'store-1');
          expect(result, isNull);
        },
      );

      test('getSupplierAccount scoped by storeId', () async {
        await db.accountsDao.getOrCreateSupplierPayable(
          supplierId: 'sup-1',
          storeId: 'store-1',
          supplierName: 'مورد',
        );

        final wrongStore = await db.accountsDao.getSupplierAccount(
          'sup-1',
          'store-2',
        );
        expect(wrongStore, isNull);
      });
    });
  });
}
