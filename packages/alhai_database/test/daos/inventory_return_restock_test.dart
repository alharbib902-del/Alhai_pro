import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('InventoryDao.recordReturnMovement', () {
    test('records a positive return movement', () async {
      // Create a product first
      // C-4 Stage B: SAR × 100 = cents
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-return-1',
          name: 'Test Widget',
          storeId: 'store-1',
          price: 5000,
          createdAt: DateTime.now(),
        ),
      );
      await db.productsDao.updateStock('prod-return-1', 90.0);

      // Record return movement
      await db.inventoryDao.recordReturnMovement(
        id: 'mov-ret-1',
        productId: 'prod-return-1',
        storeId: 'store-1',
        qty: 3.0,
        previousQty: 90.0,
        returnId: 'ret-001',
        userId: 'user-1',
      );

      // Verify movement was recorded
      final movements = await db.inventoryDao.getMovementsByProduct(
        'prod-return-1',
      );
      expect(movements.length, equals(1));
      expect(movements.first.type, equals('return'));
      expect(movements.first.qty, equals(3.0));
      expect(movements.first.previousQty, equals(90.0));
      expect(movements.first.newQty, equals(93.0));
      expect(movements.first.referenceType, equals('return'));
      expect(movements.first.referenceId, equals('ret-001'));
    });

    test('return movement qty is positive (restock)', () async {
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-return-2',
          name: 'Another Widget',
          storeId: 'store-1',
          price: 2500,
          createdAt: DateTime.now(),
        ),
      );

      await db.inventoryDao.recordReturnMovement(
        id: 'mov-ret-2',
        productId: 'prod-return-2',
        storeId: 'store-1',
        qty: 5.0,
        previousQty: 50.0,
        returnId: 'ret-002',
      );

      final movements = await db.inventoryDao.getMovementsByProduct(
        'prod-return-2',
      );
      // qty should be positive (restocking)
      expect(movements.first.qty, greaterThan(0));
    });
  });

  group('Return restock — end-to-end stock verification', () {
    test('stock increases after return movement + updateStock', () async {
      // Setup: product with stock 100
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-e2e-1',
          name: 'E2E Widget',
          storeId: 'store-1',
          price: 1000,
          createdAt: DateTime.now(),
        ),
      );
      await db.productsDao.updateStock('prod-e2e-1', 100.0);

      // Simulate sale: stock goes to 90
      await db.productsDao.updateStock('prod-e2e-1', 90.0);
      await db.inventoryDao.recordSaleMovement(
        id: 'mov-sale-1',
        productId: 'prod-e2e-1',
        storeId: 'store-1',
        qty: 10.0,
        previousQty: 100.0,
        saleId: 'sale-001',
      );

      // Simulate partial return of 3 items
      final productBeforeReturn = await db.productsDao.getProductById(
        'prod-e2e-1',
      );
      final stockBefore = productBeforeReturn!.stockQty;
      expect(stockBefore, equals(90.0));

      // Restock
      final newStock = stockBefore + 3.0;
      await db.productsDao.updateStock('prod-e2e-1', newStock);
      await db.inventoryDao.recordReturnMovement(
        id: 'mov-ret-e2e',
        productId: 'prod-e2e-1',
        storeId: 'store-1',
        qty: 3.0,
        previousQty: stockBefore,
        returnId: 'ret-e2e-001',
      );

      // Verify stock is now 93
      final productAfterReturn = await db.productsDao.getProductById(
        'prod-e2e-1',
      );
      expect(productAfterReturn!.stockQty, equals(93.0));

      // Verify movement trail shows both sale and return
      final movements = await db.inventoryDao.getMovementsByProduct(
        'prod-e2e-1',
      );
      expect(movements.length, equals(2));
      final types = movements.map((m) => m.type).toSet();
      expect(types, containsAll(['sale', 'return']));
    });
  });
}
