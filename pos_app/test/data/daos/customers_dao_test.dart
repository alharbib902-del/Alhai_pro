/// اختبارات DAO العملاء
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Future<void> _insertTestCustomer(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'عميل اختبار',
  String? phone,
  String? email,
  bool isActive = true,
}) async {
  await db.customersDao.insertCustomer(CustomersTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    phone: Value(phone),
    email: Value(email),
    isActive: Value(isActive),
    createdAt: DateTime.now(),
  ));
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('CustomersDao', () {
    group('insertCustomer', () {
      test('يُضيف عميل جديد', () async {
        // Act
        final result = await db.customersDao.insertCustomer(
          CustomersTableCompanion.insert(
            id: 'cust-1',
            storeId: 'store-1',
            name: 'أحمد محمد',
            phone: const Value('0501234567'),
            email: const Value('ahmed@example.com'),
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getCustomerById', () {
      test('يجد العميل بالمعرف', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', name: 'أحمد');

        // Act
        final customer = await db.customersDao.getCustomerById('cust-1');

        // Assert
        expect(customer, isNotNull);
        expect(customer!.name, 'أحمد');
        expect(customer.storeId, 'store-1');
      });

      test('يُرجع null إذا لم يُوجد العميل', () async {
        // Act
        final customer = await db.customersDao.getCustomerById('non-existent');

        // Assert
        expect(customer, isNull);
      });
    });

    group('getAllCustomers', () {
      test('يُرجع جميع عملاء المتجر', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1');
        await _insertTestCustomer(db, id: 'cust-2', storeId: 'store-1');
        await _insertTestCustomer(db, id: 'cust-3', storeId: 'store-2');

        // Act
        final customers = await db.customersDao.getAllCustomers('store-1');

        // Assert
        expect(customers.length, 2);
      });

      test('يُرتب العملاء حسب الاسم', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', name: 'يوسف');
        await _insertTestCustomer(db, id: 'cust-2', storeId: 'store-1', name: 'أحمد');

        // Act
        final customers = await db.customersDao.getAllCustomers('store-1');

        // Assert
        expect(customers.first.name, 'أحمد');
        expect(customers.last.name, 'يوسف');
      });
    });

    group('getActiveCustomers', () {
      test('يُرجع العملاء النشطين فقط', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', isActive: true);
        await _insertTestCustomer(db, id: 'cust-2', storeId: 'store-1', isActive: false);
        await _insertTestCustomer(db, id: 'cust-3', storeId: 'store-1', isActive: true);

        // Act
        final customers = await db.customersDao.getActiveCustomers('store-1');

        // Assert
        expect(customers.length, 2);
      });
    });

    group('searchCustomers', () {
      test('يبحث بالاسم', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', name: 'أحمد محمد');
        await _insertTestCustomer(db, id: 'cust-2', storeId: 'store-1', name: 'أحمد علي');
        await _insertTestCustomer(db, id: 'cust-3', storeId: 'store-1', name: 'خالد سعد');

        // Act
        final results = await db.customersDao.searchCustomers('أحمد', 'store-1');

        // Assert
        expect(results.length, 2);
      });

      test('يبحث برقم الهاتف', () async {
        // Arrange
        await _insertTestCustomer(
          db,
          id: 'cust-1',
          storeId: 'store-1',
          name: 'أحمد',
          phone: '0501234567',
        );
        await _insertTestCustomer(
          db,
          id: 'cust-2',
          storeId: 'store-1',
          name: 'خالد',
          phone: '0559876543',
        );

        // Act
        final results = await db.customersDao.searchCustomers('050123', 'store-1');

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 'cust-1');
      });

      test('لا يُرجع عملاء متجر آخر', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', name: 'أحمد');
        await _insertTestCustomer(db, id: 'cust-2', storeId: 'store-2', name: 'أحمد');

        // Act
        final results = await db.customersDao.searchCustomers('أحمد', 'store-1');

        // Assert
        expect(results.length, 1);
        expect(results.first.storeId, 'store-1');
      });
    });

    group('getCustomerByPhone', () {
      test('يجد العميل برقم الهاتف', () async {
        // Arrange
        await _insertTestCustomer(
          db,
          id: 'cust-1',
          storeId: 'store-1',
          name: 'أحمد',
          phone: '0501234567',
        );

        // Act
        final customer = await db.customersDao.getCustomerByPhone('0501234567', 'store-1');

        // Assert
        expect(customer, isNotNull);
        expect(customer!.id, 'cust-1');
      });

      test('يُرجع null إذا لم يُوجد الرقم', () async {
        // Act
        final customer = await db.customersDao.getCustomerByPhone('0000000000', 'store-1');

        // Assert
        expect(customer, isNull);
      });
    });

    group('updateCustomer', () {
      test('يُحدّث بيانات العميل', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1', name: 'اسم قديم');
        final original = await db.customersDao.getCustomerById('cust-1');

        // Act
        final updated = original!.copyWith(name: 'اسم جديد', phone: const Value('0551112222'));
        final result = await db.customersDao.updateCustomer(updated);

        // Assert
        expect(result, true);
        final fetched = await db.customersDao.getCustomerById('cust-1');
        expect(fetched!.name, 'اسم جديد');
        expect(fetched.phone, '0551112222');
      });
    });

    group('deleteCustomer', () {
      test('يحذف العميل', () async {
        // Arrange
        await _insertTestCustomer(db, id: 'cust-1', storeId: 'store-1');

        // Act
        final deleted = await db.customersDao.deleteCustomer('cust-1');
        final customer = await db.customersDao.getCustomerById('cust-1');

        // Assert
        expect(deleted, 1);
        expect(customer, isNull);
      });

      test('يُرجع 0 إذا لم يُوجد العميل', () async {
        // Act
        final deleted = await db.customersDao.deleteCustomer('non-existent');

        // Assert
        expect(deleted, 0);
      });
    });
  });
}
