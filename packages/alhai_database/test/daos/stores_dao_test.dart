import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  StoresTableCompanion makeStore({
    String id = 'store-1',
    String name = 'متجر الرياض',
    bool isActive = true,
  }) {
    return StoresTableCompanion.insert(
      id: id,
      name: name,
      isActive: Value(isActive),
      phone: const Value('0112345678'),
      city: const Value('الرياض'),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('StoresDao', () {
    test('insertStore and getStoreById', () async {
      await db.storesDao.insertStore(makeStore());

      final store = await db.storesDao.getStoreById('store-1');
      expect(store, isNotNull);
      expect(store!.name, 'متجر الرياض');
      expect(store.city, 'الرياض');
    });

    test('getStoreById returns null for non-existent', () async {
      final store = await db.storesDao.getStoreById('non-existent');
      expect(store, isNull);
    });

    test('getAllStores returns all stores', () async {
      await db.storesDao.insertStore(makeStore());
      await db.storesDao
          .insertStore(makeStore(id: 'store-2', name: 'متجر جدة'));

      final stores = await db.storesDao.getAllStores();
      expect(stores, hasLength(2));
    });

    test('getActiveStores excludes inactive', () async {
      await db.storesDao.insertStore(makeStore(isActive: true));
      await db.storesDao.insertStore(makeStore(
        id: 'store-2',
        name: 'متجر مغلق',
        isActive: false,
      ));

      final active = await db.storesDao.getActiveStores();
      expect(active, hasLength(1));
      expect(active.first.name, 'متجر الرياض');
    });

    test('deleteStore removes store', () async {
      await db.storesDao.insertStore(makeStore());

      final deleted = await db.storesDao.deleteStore('store-1');
      expect(deleted, 1);

      final store = await db.storesDao.getStoreById('store-1');
      expect(store, isNull);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.storesDao.insertStore(makeStore());

      await db.storesDao.markAsSynced('store-1');

      final store = await db.storesDao.getStoreById('store-1');
      expect(store!.syncedAt, isNotNull);
    });
  });
}
