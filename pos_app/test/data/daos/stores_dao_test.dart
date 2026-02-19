/// اختبارات DAO المتاجر
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

Future<void> _insertTestStore(
  AppDatabase db, {
  required String id,
  String name = 'متجر اختبار',
  bool isActive = true,
  String? taxNumber,
  String? commercialReg,
}) async {
  await db.storesDao.insertStore(StoresTableCompanion.insert(
    id: id,
    name: name,
    isActive: Value(isActive),
    taxNumber: Value(taxNumber),
    commercialReg: Value(commercialReg),
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

  group('StoresDao', () {
    group('insertStore', () {
      test('يُضيف متجر جديد', () async {
        // Act
        final result = await db.storesDao.insertStore(
          StoresTableCompanion.insert(
            id: 'store-1',
            name: 'متجر الرياض',
            taxNumber: const Value('300000000000003'),
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getStoreById', () {
      test('يجد المتجر بالمعرف', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1', name: 'متجر الرياض');

        // Act
        final store = await db.storesDao.getStoreById('store-1');

        // Assert
        expect(store, isNotNull);
        expect(store!.name, 'متجر الرياض');
      });

      test('يُرجع null إذا لم يُوجد المتجر', () async {
        // Act
        final store = await db.storesDao.getStoreById('non-existent');

        // Assert
        expect(store, isNull);
      });
    });

    group('getAllStores', () {
      test('يُرجع جميع المتاجر', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1', name: 'متجر أ');
        await _insertTestStore(db, id: 'store-2', name: 'متجر ب');
        await _insertTestStore(db, id: 'store-3', name: 'متجر ج', isActive: false);

        // Act
        final stores = await db.storesDao.getAllStores();

        // Assert
        expect(stores.length, 3);
      });

      test('يُرتب المتاجر حسب الاسم', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1', name: 'متجر ب');
        await _insertTestStore(db, id: 'store-2', name: 'متجر أ');

        // Act
        final stores = await db.storesDao.getAllStores();

        // Assert
        expect(stores.first.name, 'متجر أ');
        expect(stores.last.name, 'متجر ب');
      });
    });

    group('getActiveStores', () {
      test('يُرجع المتاجر النشطة فقط', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1', name: 'متجر نشط 1', isActive: true);
        await _insertTestStore(db, id: 'store-2', name: 'متجر غير نشط', isActive: false);
        await _insertTestStore(db, id: 'store-3', name: 'متجر نشط 2', isActive: true);

        // Act
        final stores = await db.storesDao.getActiveStores();

        // Assert
        expect(stores.length, 2);
        expect(stores.every((s) => s.isActive), true);
      });
    });

    group('updateStore', () {
      test('يُحدّث بيانات المتجر', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1', name: 'اسم قديم');
        final original = await db.storesDao.getStoreById('store-1');

        // Act
        final updated = original!.copyWith(name: 'اسم جديد', taxNumber: const Value('310000000000003'));
        final result = await db.storesDao.updateStore(updated);

        // Assert
        expect(result, true);
        final fetched = await db.storesDao.getStoreById('store-1');
        expect(fetched!.name, 'اسم جديد');
        expect(fetched.taxNumber, '310000000000003');
      });
    });

    group('deleteStore', () {
      test('يحذف المتجر', () async {
        // Arrange
        await _insertTestStore(db, id: 'store-1');

        // Act
        final deleted = await db.storesDao.deleteStore('store-1');
        final store = await db.storesDao.getStoreById('store-1');

        // Assert
        expect(deleted, 1);
        expect(store, isNull);
      });

      test('يُرجع 0 إذا لم يُوجد المتجر', () async {
        // Act
        final deleted = await db.storesDao.deleteStore('non-existent');

        // Assert
        expect(deleted, 0);
      });
    });
  });
}
