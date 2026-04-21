import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  ProductsTableCompanion makeProduct({
    required String id,
    String storeId = 'store-1',
    required String name,
    // C-4 Stage B: SAR × 100 = cents
    int price = 1000,
    double stockQty = 100,
    double minQty = 5,
    bool isActive = true,
  }) {
    return ProductsTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      price: price,
      stockQty: Value(stockQty),
      minQty: Value(minQty),
      isActive: Value(isActive),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('Batch Stock Update Performance', () {
    setUp(() async {
      db = createTestDatabase();
      await seedTestData(db);

      // Seed 100 products for stock updates
      for (int i = 0; i < 100; i++) {
        await db.productsDao.insertProduct(
          makeProduct(
            id: 'prod_$i',
            name: 'Product $i - منتج $i',
            stockQty: (100 + i).toDouble(),
          ),
        );
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('batchUpdateStock for 100 products completes under 1s', () async {
      // Build a map of stock updates for all 100 products
      final stockUpdates = <String, double>{};
      for (int i = 0; i < 100; i++) {
        stockUpdates['prod_$i'] = (50 + (i * 2)).toDouble();
      }

      final sw = Stopwatch()..start();
      await db.productsDao.batchUpdateStock(stockUpdates);
      sw.stop();

      // Verify the updates were applied
      final product0 = await db.productsDao.getProductById('prod_0');
      expect(product0!.stockQty, 50);
      final product99 = await db.productsDao.getProductById('prod_99');
      expect(product99!.stockQty, 248); // 50 + 99*2

      expect(
        sw.elapsedMilliseconds,
        lessThan(1000),
        reason:
            'Batch stock update for 100 products should complete under 1s '
            '(actual: ${sw.elapsedMilliseconds}ms)',
      );
    });

    test('individual updateStock for 100 products completes under 2s', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        await db.productsDao.updateStock('prod_$i', (75 + i).toDouble());
      }
      sw.stop();

      // Verify
      final product50 = await db.productsDao.getProductById('prod_50');
      expect(product50!.stockQty, 125);

      expect(
        sw.elapsedMilliseconds,
        lessThan(2000),
        reason:
            'Individual stock updates for 100 products should complete under 2s '
            '(actual: ${sw.elapsedMilliseconds}ms)',
      );
    });
  });

  group('Low Stock Query Performance', () {
    setUp(() async {
      db = createTestDatabase();
      await seedTestData(db);

      // Seed 1000 products: 200 with low stock, 800 with adequate stock
      for (int i = 0; i < 1000; i++) {
        final isLowStock = i < 200;
        await db.productsDao.insertProduct(
          makeProduct(
            id: 'prod_$i',
            name: 'Product $i',
            stockQty: isLowStock
                ? (i % 5).toDouble()
                : (50 + i).toDouble(), // Low stock: 0-4, Normal: 50+
            minQty: 10.0, // Threshold at 10
          ),
        );
      }
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'getLowStockProducts with 1000 products completes under 100ms',
      () async {
        final sw = Stopwatch()..start();
        final lowStock = await db.productsDao.getLowStockProducts('store-1');
        sw.stop();

        expect(
          lowStock,
          hasLength(200),
          reason: 'Should find exactly 200 low-stock products',
        );
        // Verify they are actually low stock
        for (final product in lowStock) {
          expect(product.stockQty, lessThanOrEqualTo(product.minQty));
        }

        expect(
          sw.elapsedMilliseconds,
          lessThan(100),
          reason:
              'Low stock query with 1000 products should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)',
        );
      },
    );

    test(
      'getLowStockWithCategory with 1000 products completes under 200ms',
      () async {
        final sw = Stopwatch()..start();
        final lowStockWithCat = await db.productsDao.getLowStockWithCategory(
          'store-1',
        );
        sw.stop();

        expect(lowStockWithCat, hasLength(200));

        expect(
          sw.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Low stock with category JOIN should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)',
        );
      },
    );
  });

  group('Inventory Movement History Performance', () {
    setUp(() async {
      db = createTestDatabase();
      await seedTestData(db);

      // Seed products that inventory movements reference
      for (int i = 0; i < 20; i++) {
        await db.productsDao.insertProduct(
          makeProduct(id: 'prod_$i', name: 'Product $i'),
        );
      }

      // Seed 500 inventory movements for various products
      for (int i = 0; i < 500; i++) {
        await db.inventoryDao.insertMovement(
          InventoryMovementsTableCompanion.insert(
            id: 'mov_$i',
            productId: 'prod_${i % 20}',
            storeId: 'store-1',
            type: i % 3 == 0
                ? 'sale'
                : (i % 3 == 1 ? 'purchase' : 'adjustment'),
            qty: (i % 3 == 0 ? -(1 + i % 5) : (1 + i % 10)).toDouble(),
            previousQty: 100.0,
            newQty: (i % 3 == 0 ? (100 - (1 + i % 5)) : (100 + (1 + i % 10)))
                .toDouble(),
            createdAt: DateTime(2025, 6, (i % 30) + 1, i % 24),
          ),
        );
      }
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'getMovementsByProduct with 500 total movements completes under 200ms',
      () async {
        // Product 0 should have ~25 movements (500 / 20)
        final sw = Stopwatch()..start();
        final movements = await db.inventoryDao.getMovementsByProduct('prod_0');
        sw.stop();

        expect(
          movements,
          isNotEmpty,
          reason: 'Should find movements for prod_0',
        );
        expect(
          sw.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Movement history query should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)',
        );
      },
    );

    test(
      'getMovementsWithProductName with pagination completes under 200ms',
      () async {
        // Products are already created in setUp

        final sw = Stopwatch()..start();
        final movements = await db.inventoryDao.getMovementsWithProductName(
          'store-1',
          limit: 50,
          offset: 0,
        );
        sw.stop();

        expect(movements, isNotEmpty);
        expect(movements.length, lessThanOrEqualTo(50));
        expect(
          sw.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Movements with product name JOIN should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)',
        );
      },
    );

    test(
      'getUnsyncedMovements with 500 movements completes under 200ms',
      () async {
        final sw = Stopwatch()..start();
        final unsynced = await db.inventoryDao.getUnsyncedMovements();
        sw.stop();

        expect(
          unsynced,
          hasLength(500),
          reason: 'All 500 movements should be unsynced',
        );
        expect(
          sw.elapsedMilliseconds,
          lessThan(200),
          reason:
              'Unsynced movements query should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)',
        );
      },
    );
  });
}
