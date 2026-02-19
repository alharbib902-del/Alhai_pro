/// اختبارات DAO الموردين
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

Future<void> _insertTestSupplier(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'مورد اختبار',
  String? phone,
  String? email,
  bool isActive = true,
  double balance = 0.0,
}) async {
  await db.suppliersDao.insertSupplier(SuppliersTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    phone: Value(phone),
    email: Value(email),
    isActive: Value(isActive),
    balance: Value(balance),
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

  group('SuppliersDao', () {
    group('insertSupplier', () {
      test('inserts a new supplier', () async {
        // Act
        final result = await db.suppliersDao.insertSupplier(
          SuppliersTableCompanion.insert(
            id: 'sup-1',
            storeId: 'store-1',
            name: 'مورد جديد',
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getSupplierById', () {
      test('finds supplier by id', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', name: 'مورد الفواكه');

        // Act
        final supplier = await db.suppliersDao.getSupplierById('sup-1');

        // Assert
        expect(supplier, isNotNull);
        expect(supplier!.name, 'مورد الفواكه');
      });

      test('returns null when supplier not found', () async {
        // Act
        final supplier = await db.suppliersDao.getSupplierById('non-existent');

        // Assert
        expect(supplier, isNull);
      });
    });

    group('getAllSuppliers', () {
      test('returns all suppliers for the store', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1');
        await _insertTestSupplier(db, id: 'sup-2', storeId: 'store-1');
        await _insertTestSupplier(db, id: 'sup-3', storeId: 'store-2');

        // Act
        final suppliers = await db.suppliersDao.getAllSuppliers('store-1');

        // Assert
        expect(suppliers.length, 2);
      });

      test('orders suppliers by name', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', name: 'مورد ب');
        await _insertTestSupplier(db, id: 'sup-2', storeId: 'store-1', name: 'مورد أ');

        // Act
        final suppliers = await db.suppliersDao.getAllSuppliers('store-1');

        // Assert
        expect(suppliers.first.name, 'مورد أ');
        expect(suppliers.last.name, 'مورد ب');
      });
    });

    group('getActiveSuppliers', () {
      test('returns only active suppliers', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', isActive: true);
        await _insertTestSupplier(db, id: 'sup-2', storeId: 'store-1', isActive: false);
        await _insertTestSupplier(db, id: 'sup-3', storeId: 'store-1', isActive: true);

        // Act
        final suppliers = await db.suppliersDao.getActiveSuppliers('store-1');

        // Assert
        expect(suppliers.length, 2);
      });
    });

    group('searchSuppliers', () {
      test('searches by name', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', name: 'مورد الفواكه');
        await _insertTestSupplier(db, id: 'sup-2', storeId: 'store-1', name: 'مورد الخضار');
        await _insertTestSupplier(db, id: 'sup-3', storeId: 'store-1', name: 'شركة التوزيع');

        // Act
        final results = await db.suppliersDao.searchSuppliers('مورد', 'store-1');

        // Assert
        expect(results.length, 2);
      });

      test('searches by phone', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', name: 'مورد 1', phone: '0501234567');
        await _insertTestSupplier(db, id: 'sup-2', storeId: 'store-1', name: 'مورد 2', phone: '0559876543');

        // Act
        final results = await db.suppliersDao.searchSuppliers('050123', 'store-1');

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 'sup-1');
      });
    });

    group('updateBalance', () {
      test('updates supplier balance', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', balance: 100.0);

        // Act
        await db.suppliersDao.updateBalance('sup-1', 250.0);
        final supplier = await db.suppliersDao.getSupplierById('sup-1');

        // Assert
        expect(supplier!.balance, 250.0);
      });

      test('sets updatedAt on balance update', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1');

        // Act
        await db.suppliersDao.updateBalance('sup-1', 500.0);
        final supplier = await db.suppliersDao.getSupplierById('sup-1');

        // Assert
        expect(supplier!.updatedAt, isNotNull);
      });
    });

    group('updateSupplier', () {
      test('updates supplier data', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1', name: 'اسم قديم');
        final supplier = await db.suppliersDao.getSupplierById('sup-1');

        // Act
        final updated = supplier!.copyWith(name: 'اسم جديد');
        final result = await db.suppliersDao.updateSupplier(updated);

        // Assert
        expect(result, true);
        final fetched = await db.suppliersDao.getSupplierById('sup-1');
        expect(fetched!.name, 'اسم جديد');
      });
    });

    group('deleteSupplier', () {
      test('deletes the supplier', () async {
        // Arrange
        await _insertTestSupplier(db, id: 'sup-1', storeId: 'store-1');

        // Act
        final deleted = await db.suppliersDao.deleteSupplier('sup-1');
        final supplier = await db.suppliersDao.getSupplierById('sup-1');

        // Assert
        expect(deleted, 1);
        expect(supplier, isNull);
      });

      test('returns 0 when supplier does not exist', () async {
        // Act
        final deleted = await db.suppliersDao.deleteSupplier('non-existent');

        // Assert
        expect(deleted, 0);
      });
    });
  });
}
