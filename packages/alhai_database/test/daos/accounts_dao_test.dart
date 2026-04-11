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
      balance: Value(balance),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('AccountsDao', () {
    test('insertAccount and getAccountById', () async {
      await db.accountsDao.insertAccount(makeAccount());

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account, isNotNull);
      expect(account!.name, 'حساب أحمد محمد');
      expect(account.balance, 500.0);
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
      expect(account!.balance, 750.0);
      expect(account.lastTransactionAt, isNotNull);
    });

    test('addToBalance increases balance', () async {
      await db.accountsDao.insertAccount(makeAccount(balance: 500.0));

      await db.accountsDao.addToBalance('acc-1', 200.0);

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.balance, 700.0);
    });

    test('subtractFromBalance decreases balance', () async {
      await db.accountsDao.insertAccount(makeAccount(balance: 500.0));

      await db.accountsDao.subtractFromBalance('acc-1', 150.0);

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.balance, 350.0);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.accountsDao.insertAccount(makeAccount());

      await db.accountsDao.markAsSynced('acc-1');

      final account = await db.accountsDao.getAccountById('acc-1');
      expect(account!.syncedAt, isNotNull);
    });
  });
}
