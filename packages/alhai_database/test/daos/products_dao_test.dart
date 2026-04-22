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
  });
}
