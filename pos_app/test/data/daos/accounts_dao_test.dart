import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Accounts DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AccountsDao', () {
    const testStoreId = 'store_123';
    const testAccountId = 'acc_001';

    AccountsTableCompanion createAccount({
      required String id,
      required String name,
      String type = 'receivable',
      String? customerId,
      String? supplierId,
      String? phone,
      double balance = 0,
      double creditLimit = 1000,
      bool isActive = true,
    }) {
      return AccountsTableCompanion.insert(
        id: id,
        storeId: testStoreId,
        type: type,
        name: name,
        customerId: Value(customerId),
        supplierId: Value(supplierId),
        phone: Value(phone),
        balance: Value(balance),
        creditLimit: Value(creditLimit),
        isActive: Value(isActive),
        createdAt: DateTime.now(),
      );
    }

    group('insertAccount', () {
      test('يُضيف حساب جديد بنجاح', () async {
        final account = createAccount(
          id: testAccountId,
          name: 'محمد علي',
          customerId: 'cust_001',
          phone: '0501234567',
        );

        final result = await database.accountsDao.insertAccount(account);
        expect(result, greaterThan(0));

        final fetched = await database.accountsDao.getAccountById(testAccountId);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'محمد علي');
        expect(fetched.phone, '0501234567');
      });
    });

    group('getAccountById', () {
      test('يجد الحساب بالمعرف', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'أحمد سعيد'),
        );

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result, isNotNull);
        expect(result!.name, 'أحمد سعيد');
      });

      test('يُرجع null إذا لم يُوجد الحساب', () async {
        final result = await database.accountsDao.getAccountById('non_existent');
        expect(result, isNull);
      });
    });

    group('getAllAccounts', () {
      test('يُرجع جميع الحسابات للمتجر', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_001', name: 'عميل 1'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_002', name: 'عميل 2'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_003', name: 'مورد 1', type: 'payable'),
        );

        final result = await database.accountsDao.getAllAccounts(testStoreId);
        expect(result.length, 3);
      });

      test('يُرتب الحسابات حسب الاسم', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_001', name: 'محمد'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_002', name: 'أحمد'),
        );

        final result = await database.accountsDao.getAllAccounts(testStoreId);
        expect(result[0].name, 'أحمد');
        expect(result[1].name, 'محمد');
      });
    });

    group('getReceivableAccounts', () {
      test('يُرجع حسابات العملاء فقط', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_001', name: 'عميل 1', type: 'receivable'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_002', name: 'مورد 1', type: 'payable'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_003', name: 'عميل 2', type: 'receivable'),
        );

        final result = await database.accountsDao.getReceivableAccounts(testStoreId);
        expect(result.length, 2);
        expect(result.every((a) => a.type == 'receivable'), isTrue);
      });
    });

    group('getPayableAccounts', () {
      test('يُرجع حسابات الموردين فقط', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_001', name: 'عميل 1', type: 'receivable'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_002', name: 'مورد 1', type: 'payable'),
        );
        await database.accountsDao.insertAccount(
          createAccount(id: 'acc_003', name: 'مورد 2', type: 'payable'),
        );

        final result = await database.accountsDao.getPayableAccounts(testStoreId);
        expect(result.length, 2);
        expect(result.every((a) => a.type == 'payable'), isTrue);
      });
    });

    group('getCustomerAccount', () {
      test('يجد حساب العميل', () async {
        await database.accountsDao.insertAccount(
          createAccount(
            id: testAccountId,
            name: 'عميل مميز',
            customerId: 'cust_123',
          ),
        );

        final result = await database.accountsDao.getCustomerAccount(
          'cust_123',
          testStoreId,
        );
        expect(result, isNotNull);
        expect(result!.name, 'عميل مميز');
      });

      test('يُرجع null إذا لم يُوجد حساب للعميل', () async {
        final result = await database.accountsDao.getCustomerAccount(
          'non_existent',
          testStoreId,
        );
        expect(result, isNull);
      });
    });

    group('updateAccount', () {
      test('يُحدّث بيانات الحساب', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'اسم قديم'),
        );

        final fetched = await database.accountsDao.getAccountById(testAccountId);
        final updated = fetched!.copyWith(name: 'اسم جديد');

        await database.accountsDao.updateAccount(updated);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.name, 'اسم جديد');
      });
    });

    group('updateBalance', () {
      test('يُحدّث رصيد الحساب', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل', balance: 100),
        );

        await database.accountsDao.updateBalance(testAccountId, 250);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.balance, 250);
      });

      test('يُحدّث تاريخ آخر حركة', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل'),
        );

        final before = DateTime.now();
        await database.accountsDao.updateBalance(testAccountId, 100);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.lastTransactionAt, isNotNull);
        expect(result.lastTransactionAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      });
    });

    group('addToBalance', () {
      test('يُضيف للرصيد', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل', balance: 100),
        );

        await database.accountsDao.addToBalance(testAccountId, 50);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.balance, 150);
      });
    });

    group('subtractFromBalance', () {
      test('يخصم من الرصيد', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل', balance: 100),
        );

        await database.accountsDao.subtractFromBalance(testAccountId, 30);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.balance, 70);
      });

      test('يمكن أن يصبح الرصيد سالباً', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل', balance: 50),
        );

        await database.accountsDao.subtractFromBalance(testAccountId, 100);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.balance, -50);
      });
    });

    group('markAsSynced', () {
      test('يُعيّن تاريخ المزامنة', () async {
        await database.accountsDao.insertAccount(
          createAccount(id: testAccountId, name: 'عميل'),
        );

        await database.accountsDao.markAsSynced(testAccountId);

        final result = await database.accountsDao.getAccountById(testAccountId);
        expect(result!.syncedAt, isNotNull);
      });
    });
  });
}
