import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // inventory_movements reference products via FK
    await db.productsDao.insertProduct(ProductsTableCompanion.insert(
      id: 'prod-1',
      storeId: 'store-1',
      name: 'P1',
      price: 10.0,
      createdAt: DateTime(2025, 1, 1),
    ));
  });

  tearDown(() async {
    await db.close();
  });

  group('InventoryDao', () {
    test('insertMovement and getMovementsByProduct', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -2,
          previousQty: 100,
          newQty: 98,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -2);
      expect(movements.first.type, 'sale');
    });

    test('recordSaleMovement creates negative quantity movement', () async {
      await db.inventoryDao.recordSaleMovement(
        id: 'mov-sale-1',
        productId: 'prod-1',
        storeId: 'store-1',
        qty: 5,
        previousQty: 100,
        saleId: 'sale-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -5); // negative for sales
      expect(movements.first.newQty, 95);
      expect(movements.first.type, 'sale');
      expect(movements.first.referenceType, 'sale');
      expect(movements.first.referenceId, 'sale-1');
    });

    test('recordPurchaseMovement creates positive quantity movement', () async {
      await db.inventoryDao.recordPurchaseMovement(
        id: 'mov-purchase-1',
        productId: 'prod-1',
        storeId: 'store-1',
        qty: 50,
        previousQty: 100,
        purchaseId: 'purchase-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, 50); // positive for purchases
      expect(movements.first.newQty, 150);
      expect(movements.first.type, 'purchase');
    });

    test('recordAdjustment creates correct movement', () async {
      await db.inventoryDao.recordAdjustment(
        id: 'mov-adj-1',
        productId: 'prod-1',
        storeId: 'store-1',
        newQty: 80,
        previousQty: 100,
        reason: 'تلف بضاعة',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements, hasLength(1));
      expect(movements.first.qty, -20);
      expect(movements.first.newQty, 80);
      expect(movements.first.reason, 'تلف بضاعة');
      expect(movements.first.type, 'adjustment');
    });

    test('getMovementsByProduct returns empty for unknown product', () async {
      final movements = await db.inventoryDao.getMovementsByProduct('unknown');
      expect(movements, isEmpty);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      await db.inventoryDao.markAsSynced('mov-1');

      final unsynced = await db.inventoryDao.getUnsyncedMovements();
      expect(unsynced, isEmpty);
    });

    test('getUnsyncedMovements returns movements without syncedAt', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 15),
        ),
      );
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-2',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'purchase',
          qty: 20,
          previousQty: 9,
          newQty: 29,
          createdAt: DateTime(2025, 6, 16),
        ),
      );
      await db.inventoryDao.markAsSynced('mov-1');

      final unsynced = await db.inventoryDao.getUnsyncedMovements();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'mov-2');
    });

    test('movements ordered by createdAt desc', () async {
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'sale',
          qty: -1,
          previousQty: 10,
          newQty: 9,
          createdAt: DateTime(2025, 6, 14),
        ),
      );
      await db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'mov-2',
          productId: 'prod-1',
          storeId: 'store-1',
          type: 'purchase',
          qty: 20,
          previousQty: 9,
          newQty: 29,
          createdAt: DateTime(2025, 6, 16),
        ),
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-1');
      expect(movements.first.id, 'mov-2'); // most recent first
    });
  });
}
