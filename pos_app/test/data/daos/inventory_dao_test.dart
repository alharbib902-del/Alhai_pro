import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';

// ===========================================
// Inventory DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('InventoryDao', () {
    const testStoreId = 'store_123';
    const testProductId = 'prod_001';
    const testUserId = 'user_001';

    group('insertMovement', () {
      test('يُدرج حركة مخزون جديدة', () async {
        final movement = InventoryMovementsTableCompanion.insert(
          id: 'mov_001',
          productId: testProductId,
          storeId: testStoreId,
          type: 'sale',
          qty: -5,
          previousQty: 100,
          newQty: 95,
          createdAt: DateTime.now(),
        );

        final result = await database.inventoryDao.insertMovement(movement);
        expect(result, greaterThan(0));
      });
    });

    group('getMovementsByProduct', () {
      test('يُرجع حركات منتج معين', () async {
        // إضافة حركات لمنتجات مختلفة
        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_001',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -5,
            previousQty: 100,
            newQty: 95,
            createdAt: DateTime.now(),
          ),
        );

        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_002',
            productId: 'prod_002',
            storeId: testStoreId,
            type: 'sale',
            qty: -3,
            previousQty: 50,
            newQty: 47,
            createdAt: DateTime.now(),
          ),
        );

        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_003',
            productId: testProductId,
            storeId: testStoreId,
            type: 'purchase',
            qty: 20,
            previousQty: 95,
            newQty: 115,
            createdAt: DateTime.now(),
          ),
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements.length, 2);
        expect(movements.every((m) => m.productId == testProductId), isTrue);
      });

      test('يُرتب الحركات تنازلياً حسب التاريخ', () async {
        final now = DateTime.now();

        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_001',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -5,
            previousQty: 100,
            newQty: 95,
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        );

        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_002',
            productId: testProductId,
            storeId: testStoreId,
            type: 'purchase',
            qty: 20,
            previousQty: 95,
            newQty: 115,
            createdAt: now,
          ),
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements[0].id, 'mov_002'); // الأحدث أولاً
        expect(movements[1].id, 'mov_001');
      });
    });

    group('getTodayMovements', () {
      test('يُرجع حركات اليوم فقط', () async {
        final now = DateTime.now();

        // حركة اليوم
        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_today',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -5,
            previousQty: 100,
            newQty: 95,
            createdAt: now,
          ),
        );

        // حركة أمس
        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_yesterday',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -3,
            previousQty: 103,
            newQty: 100,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        );

        final todayMovements =
            await database.inventoryDao.getTodayMovements(testStoreId);
        expect(todayMovements.length, 1);
        expect(todayMovements.first.id, 'mov_today');
      });
    });

    group('recordSaleMovement', () {
      test('يُسجل حركة بيع بكمية سالبة', () async {
        await database.inventoryDao.recordSaleMovement(
          id: 'sale_mov_001',
          productId: testProductId,
          storeId: testStoreId,
          qty: 5,
          previousQty: 100,
          saleId: 'sale_001',
          userId: testUserId,
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements.length, 1);
        expect(movements.first.type, 'sale');
        expect(movements.first.qty, -5); // سالب للبيع
        expect(movements.first.newQty, 95);
      });
    });

    group('recordPurchaseMovement', () {
      test('يُسجل حركة شراء بكمية موجبة', () async {
        await database.inventoryDao.recordPurchaseMovement(
          id: 'purchase_mov_001',
          productId: testProductId,
          storeId: testStoreId,
          qty: 50,
          previousQty: 100,
          purchaseId: 'purchase_001',
          userId: testUserId,
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements.length, 1);
        expect(movements.first.type, 'purchase');
        expect(movements.first.qty, 50); // موجب للشراء
        expect(movements.first.newQty, 150);
      });
    });

    group('recordAdjustment', () {
      test('يُسجل تعديل مخزون بزيادة', () async {
        await database.inventoryDao.recordAdjustment(
          id: 'adj_001',
          productId: testProductId,
          storeId: testStoreId,
          newQty: 110,
          previousQty: 100,
          reason: 'جرد',
          userId: testUserId,
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements.length, 1);
        expect(movements.first.type, 'adjustment');
        expect(movements.first.qty, 10); // الفرق
        expect(movements.first.reason, 'جرد');
      });

      test('يُسجل تعديل مخزون بنقصان', () async {
        await database.inventoryDao.recordAdjustment(
          id: 'adj_002',
          productId: testProductId,
          storeId: testStoreId,
          newQty: 90,
          previousQty: 100,
          reason: 'تالف',
          userId: testUserId,
        );

        final movements =
            await database.inventoryDao.getMovementsByProduct(testProductId);
        expect(movements.length, 1);
        expect(movements.first.qty, -10); // سالب للنقصان
      });
    });

    group('markAsSynced', () {
      test('يُحدد الحركة كمزامنة', () async {
        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_001',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -5,
            previousQty: 100,
            newQty: 95,
            createdAt: DateTime.now(),
          ),
        );

        await database.inventoryDao.markAsSynced('mov_001');

        final unsynced = await database.inventoryDao.getUnsyncedMovements();
        expect(unsynced, isEmpty);
      });
    });

    group('getUnsyncedMovements', () {
      test('يُرجع الحركات غير المزامنة', () async {
        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_001',
            productId: testProductId,
            storeId: testStoreId,
            type: 'sale',
            qty: -5,
            previousQty: 100,
            newQty: 95,
            createdAt: DateTime.now(),
          ),
        );

        await database.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_002',
            productId: testProductId,
            storeId: testStoreId,
            type: 'purchase',
            qty: 20,
            previousQty: 95,
            newQty: 115,
            createdAt: DateTime.now(),
          ),
        );

        final unsynced = await database.inventoryDao.getUnsyncedMovements();
        expect(unsynced.length, 2);
      });
    });
  });
}
