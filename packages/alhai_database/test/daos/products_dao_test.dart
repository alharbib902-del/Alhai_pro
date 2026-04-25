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

  // C-4 Stage B: SAR × 100 = cents
  ProductsTableCompanion makeProduct({
    String id = 'prod-1',
    String storeId = 'store-1',
    String name = 'حليب طازج',
    int price = 550,
    String? barcode,
    String? sku,
    String? categoryId,
    bool isActive = true,
    double stockQty = 100,
    double minQty = 5,
  }) {
    return ProductsTableCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      price: price,
      barcode: Value(barcode),
      sku: Value(sku),
      categoryId: Value(categoryId),
      isActive: Value(isActive),
      stockQty: Value(stockQty),
      minQty: Value(minQty),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('ProductsDao', () {
    test('insertProduct inserts and getAllProducts retrieves', () async {
      await db.productsDao.insertProduct(makeProduct());
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'عصير برتقال', price: 300),
      );

      final products = await db.productsDao.getAllProducts('store-1');
      expect(products, hasLength(2));
      // ordered by name asc
      expect(products.first.name, 'حليب طازج');
    });

    test('getProductById returns correct product', () async {
      await db.productsDao.insertProduct(makeProduct());

      final product = await db.productsDao.getProductById('prod-1');
      expect(product, isNotNull);
      expect(product!.name, 'حليب طازج');
      expect(product.price, 550);
      expect(product.storeId, 'store-1');
    });

    test('getProductById returns null for non-existent id', () async {
      final product = await db.productsDao.getProductById('non-existent');
      expect(product, isNull);
    });

    test('getProductByBarcode returns correct product', () async {
      await db.productsDao.insertProduct(makeProduct(barcode: '123456'));

      final product = await db.productsDao.getProductByBarcode(
        '123456',
        'store-1',
      );
      expect(product, isNotNull);
      expect(product!.id, 'prod-1');
    });

    test('getProductByBarcode returns null for wrong store', () async {
      await db.productsDao.insertProduct(makeProduct(barcode: '123456'));

      final product = await db.productsDao.getProductByBarcode(
        '123456',
        'other-store',
      );
      expect(product, isNull);
    });

    test('searchProducts finds by name', () async {
      await db.productsDao.insertProduct(makeProduct());
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'عصير برتقال'),
      );

      final results = await db.productsDao.searchProducts('حليب', 'store-1');
      expect(results, hasLength(1));
      expect(results.first.name, 'حليب طازج');
    });

    test('searchProducts finds by barcode', () async {
      await db.productsDao.insertProduct(
        makeProduct(barcode: 'BC001', sku: 'SKU001'),
      );

      final results = await db.productsDao.searchProducts('BC001', 'store-1');
      expect(results, hasLength(1));
    });

    test('updateProduct modifies data', () async {
      await db.productsDao.insertProduct(makeProduct());
      final product = await db.productsDao.getProductById('prod-1');
      final updated = product!.copyWith(name: 'حليب كامل الدسم', price: 600);

      await db.productsDao.updateProduct(updated);

      final fetched = await db.productsDao.getProductById('prod-1');
      expect(fetched!.name, 'حليب كامل الدسم');
      expect(fetched.price, 600);
    });

    test('updateStock changes stock quantity', () async {
      await db.productsDao.insertProduct(makeProduct(stockQty: 50));

      await db.productsDao.updateStock('prod-1', 30);

      final product = await db.productsDao.getProductById('prod-1');
      expect(product!.stockQty, 30);
    });

    test('deleteProduct removes product', () async {
      await db.productsDao.insertProduct(makeProduct());

      final deleted = await db.productsDao.deleteProduct('prod-1');
      expect(deleted, 1);

      final product = await db.productsDao.getProductById('prod-1');
      expect(product, isNull);
    });

    test('softDeleteProduct sets deletedAt and hides from active queries', () async {
      // Admin Tier A Q1: soft delete preserves the row for audit/reports
      // while hiding it from active-row queries that filter deletedAt.isNull().
      await db.productsDao.insertProduct(makeProduct(id: 'prod-soft'));

      final affected = await db.productsDao.softDeleteProduct('prod-soft');
      expect(affected, 1);

      // getProductById does NOT filter on deletedAt; row still retrievable
      final row = await db.productsDao.getProductById('prod-soft');
      expect(row, isNotNull);
      expect(row!.deletedAt, isNotNull);

      // Active-list query (getAllProducts) DOES filter deletedAt.isNull() —
      // soft-deleted row hidden from active users.
      final active = await db.productsDao.getAllProducts('store-1');
      expect(active.any((p) => p.id == 'prod-soft'), isFalse);

      // Second soft-delete on same row is a no-op (affected=0).
      final second = await db.productsDao.softDeleteProduct('prod-soft');
      expect(second, 0);
    });

    test('getProductsByCategory filters correctly', () async {
      // Create category parents for the FK constraint
      final now = DateTime(2025, 1, 1);
      await db.categoriesDao.insertCategory(
        CategoriesTableCompanion.insert(
          id: 'cat-1',
          storeId: 'store-1',
          name: 'Cat 1',
          createdAt: now,
        ),
      );
      await db.categoriesDao.insertCategory(
        CategoriesTableCompanion.insert(
          id: 'cat-2',
          storeId: 'store-1',
          name: 'Cat 2',
          createdAt: now,
        ),
      );

      await db.productsDao.insertProduct(makeProduct(categoryId: 'cat-1'));
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'جبنة بيضاء', categoryId: 'cat-2'),
      );

      final results = await db.productsDao.getProductsByCategory(
        'cat-1',
        'store-1',
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'prod-1');
    });

    test('getLowStockProducts returns products below min qty', () async {
      await db.productsDao.insertProduct(makeProduct(stockQty: 3, minQty: 5));
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'عصير', stockQty: 50, minQty: 5),
      );

      final lowStock = await db.productsDao.getLowStockProducts('store-1');
      expect(lowStock, hasLength(1));
      expect(lowStock.first.id, 'prod-1');
    });

    test('watchLowStockCount: emits 0 when no low-stock products', () async {
      await db.productsDao.insertProduct(
        makeProduct(stockQty: 50, minQty: 5),
      );
      final count = await db.productsDao.watchLowStockCount('store-1').first;
      expect(count, 0);
    });

    test(
      'watchLowStockCount: reacts to stock moving across the threshold',
      () async {
        await db.productsDao.insertProduct(
          makeProduct(stockQty: 50, minQty: 5),
        );
        await db.productsDao.insertProduct(
          makeProduct(id: 'prod-2', name: 'عصير', stockQty: 3, minQty: 5),
        );

        // Initial snapshot: only prod-2 is low.
        final stream = db.productsDao.watchLowStockCount('store-1');
        expect(await stream.first, 1);

        // Drop prod-1 below its min: the count must include it on next read.
        await db.productsDao.updateStock('prod-1', 2);
        expect(await stream.first, 2);

        // Soft-delete prod-2: low-stock count drops back to 1.
        await db.productsDao.softDeleteProduct('prod-2');
        expect(await stream.first, 1);
      },
    );

    test('markAsSynced sets syncedAt', () async {
      await db.productsDao.insertProduct(makeProduct());

      await db.productsDao.markAsSynced('prod-1');

      final product = await db.productsDao.getProductById('prod-1');
      expect(product!.syncedAt, isNotNull);
    });

    test('getUnsyncedProducts returns products without syncedAt', () async {
      await db.productsDao.insertProduct(makeProduct());
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'عصير'),
      );
      await db.productsDao.markAsSynced('prod-1');

      final unsynced = await db.productsDao.getUnsyncedProducts();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.id, 'prod-2');
    });

    test('getProductsPaginated respects limit and offset', () async {
      for (var i = 0; i < 10; i++) {
        await db.productsDao.insertProduct(
          makeProduct(id: 'prod-$i', name: 'منتج $i'),
        );
      }

      final page1 = await db.productsDao.getProductsPaginated(
        'store-1',
        offset: 0,
        limit: 3,
      );
      expect(page1, hasLength(3));

      final page2 = await db.productsDao.getProductsPaginated(
        'store-1',
        offset: 3,
        limit: 3,
      );
      expect(page2, hasLength(3));
      expect(page2.first.id, isNot(page1.last.id));
    });

    test('getProductsCount returns correct count', () async {
      for (var i = 0; i < 5; i++) {
        await db.productsDao.insertProduct(
          makeProduct(id: 'prod-$i', name: 'منتج $i'),
        );
      }

      final count = await db.productsDao.getProductsCount('store-1');
      expect(count, 5);
    });

    test('watchProducts emits on changes', () async {
      final stream = db.productsDao.watchProducts('store-1');
      final firstEmission = await stream.first;
      expect(firstEmission, isEmpty);

      await db.productsDao.insertProduct(makeProduct());
      final secondEmission = await stream.first;
      expect(secondEmission, hasLength(1));
    });

    test('upsertProduct inserts or updates', () async {
      await db.productsDao.upsertProduct(makeProduct());

      var product = await db.productsDao.getProductById('prod-1');
      expect(product!.price, 550);

      await db.productsDao.upsertProduct(makeProduct(price: 700));
      product = await db.productsDao.getProductById('prod-1');
      expect(product!.price, 700);
    });

    test('batchUpdateStock updates multiple products', () async {
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-1', stockQty: 50),
      );
      await db.productsDao.insertProduct(
        makeProduct(id: 'prod-2', name: 'عصير', stockQty: 30),
      );

      await db.productsDao.batchUpdateStock({'prod-1': 40, 'prod-2': 25});

      final p1 = await db.productsDao.getProductById('prod-1');
      final p2 = await db.productsDao.getProductById('prod-2');
      expect(p1!.stockQty, 40);
      expect(p2!.stockQty, 25);
    });

    test('quickFindByBarcode finds active product', () async {
      await db.productsDao.insertProduct(
        makeProduct(barcode: 'QF-001', isActive: true),
      );

      final product = await db.productsDao.quickFindByBarcode(
        'QF-001',
        'store-1',
      );
      expect(product, isNotNull);
      expect(product!.barcode, 'QF-001');
    });

    test('quickFindByBarcode ignores inactive product', () async {
      await db.productsDao.insertProduct(
        makeProduct(barcode: 'QF-002', isActive: false),
      );

      final product = await db.productsDao.quickFindByBarcode(
        'QF-002',
        'store-1',
      );
      expect(product, isNull);
    });

    test('getAllProducts returns empty for unknown store', () async {
      await db.productsDao.insertProduct(makeProduct());

      final products = await db.productsDao.getAllProducts('unknown-store');
      expect(products, isEmpty);
    });

    // ─── P1-5: SQL aggregate inventory valuation ───────────────────
    group('getInventoryValuationByCategory', () {
      Future<void> seedCategory(String id, {String storeId = 'store-1'}) {
        return db.categoriesDao.insertCategory(
          CategoriesTableCompanion.insert(
            id: id,
            storeId: storeId,
            name: 'cat-$id',
            createdAt: DateTime(2025, 1, 1),
          ),
        );
      }

      test('groups by category and sums cost * qty', () async {
        await seedCategory('cat-1');
        await seedCategory('cat-2');
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-cat1-a',
            storeId: 'store-1',
            name: 'A',
            price: 1000,
            costPrice: const Value(500),
            stockQty: const Value(10),
            categoryId: const Value('cat-1'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-cat1-b',
            storeId: 'store-1',
            name: 'B',
            price: 2000,
            costPrice: const Value(1500),
            stockQty: const Value(4),
            categoryId: const Value('cat-1'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-cat2',
            storeId: 'store-1',
            name: 'C',
            price: 3000,
            costPrice: const Value(2000),
            stockQty: const Value(2),
            categoryId: const Value('cat-2'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );

        final groups = await db.productsDao
            .getInventoryValuationByCategory('store-1');

        // 2 buckets: cat-1 (10*500 + 4*1500 = 11000c) and cat-2 (2*2000 = 4000c)
        expect(groups, hasLength(2));
        final byKey = {for (final g in groups) g.categoryKey: g};
        expect(byKey['cat-1']!.totalValueCents, 11000);
        expect(byKey['cat-1']!.totalQty, 14.0);
        expect(byKey['cat-1']!.productCount, 2);
        expect(byKey['cat-2']!.totalValueCents, 4000);
        expect(byKey['cat-2']!.totalQty, 2.0);
        expect(byKey['cat-2']!.productCount, 1);
      });

      test('null categoryId rolls into the "uncategorized" bucket', () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-uncat',
            storeId: 'store-1',
            name: 'No category',
            price: 1000,
            costPrice: const Value(500),
            stockQty: const Value(3),
            createdAt: DateTime(2025, 1, 1),
          ),
        );

        final groups = await db.productsDao
            .getInventoryValuationByCategory('store-1');
        expect(groups.first.categoryKey, 'uncategorized');
        expect(groups.first.totalValueCents, 1500);
      });

      test('null cost_price contributes 0 to value (P0-17 invariant)',
          () async {
        // Pre-fix: rows with null cost_price contributed `price` (sell)
        // to the inventory value, inflating balance-sheet assets by the
        // markup percentage. Post-fix the SQL now uses
        // COALESCE(cost_price, 0) so legacy null-cost rows show as
        // zero value (real money — they need a cost backfill, but
        // that's a separate operation, not silent inflation).
        await seedCategory('cat-1');
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-nullcost',
            storeId: 'store-1',
            name: 'Legacy',
            price: 5000,
            costPrice: const Value(null),
            stockQty: const Value(10),
            categoryId: const Value('cat-1'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );

        final groups = await db.productsDao
            .getInventoryValuationByCategory('store-1');
        expect(groups.first.totalValueCents, 0,
            reason: 'null cost_price must contribute 0, not the sell price');
        expect(groups.first.totalQty, 10.0);
      });

      test('store-scoped — does not leak across stores', () async {
        await seedCategory('cat-1', storeId: 'store-1');
        await seedCategory('cat-1-other', storeId: 'store-2');
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-1',
            storeId: 'store-1',
            name: 'A',
            price: 1000,
            costPrice: const Value(500),
            stockQty: const Value(5),
            categoryId: const Value('cat-1'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );
        // Different store, different category id (per-store FK) —
        // must not contribute to store-1's groups.
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-2',
            storeId: 'store-2',
            name: 'B',
            price: 1000,
            costPrice: const Value(999),
            stockQty: const Value(99),
            categoryId: const Value('cat-1-other'),
            createdAt: DateTime(2025, 1, 1),
          ),
        );

        final groups = await db.productsDao
            .getInventoryValuationByCategory('store-1');
        expect(groups, hasLength(1));
        expect(groups.first.totalValueCents, 2500);
      });
    });
  });
}
