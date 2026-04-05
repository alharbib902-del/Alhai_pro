import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  ProductsTableCompanion makeProduct({
    required String id,
    String storeId = 'store-1',
    required String name,
    double price = 10.0,
    String? barcode,
    String? sku,
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
      isActive: Value(isActive),
      stockQty: Value(stockQty),
      minQty: Value(minQty),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('Product FTS Search Performance', () {
    setUp(() async {
      db = createTestDatabase();

      // Seed 1000 products with Arabic and English names, barcodes, and SKUs
      for (int i = 0; i < 1000; i++) {
        await db.productsDao.insertProduct(makeProduct(
          id: 'prod_$i',
          name: 'Product $i - منتج ${i % 50}',
          price: 10.0 + (i * 0.1),
          barcode: '69000${i.toString().padLeft(5, '0')}',
          sku: 'SKU-${i.toString().padLeft(5, '0')}',
          stockQty: 50 + (i % 200),
          minQty: (i % 10) + 1,
        ));
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('search 1000 products by name completes under 200ms', () async {
      final sw = Stopwatch()..start();
      final results = await db.productsDao.searchProducts('منتج', 'store-1');
      sw.stop();

      expect(results, isNotEmpty, reason: 'Search should return results');
      expect(sw.elapsedMilliseconds, lessThan(200),
          reason: 'Search across 1000 products should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('search 1000 products by partial English name completes under 200ms',
        () async {
      final sw = Stopwatch()..start();
      final results =
          await db.productsDao.searchProducts('Product 5', 'store-1');
      sw.stop();

      expect(results, isNotEmpty, reason: 'Search should return results');
      expect(sw.elapsedMilliseconds, lessThan(200),
          reason:
              'English name search across 1000 products should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('search by barcode pattern completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final results =
          await db.productsDao.searchProducts('69000005', 'store-1');
      sw.stop();

      expect(results, isNotEmpty,
          reason: 'Barcode pattern search should return results');
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Barcode pattern search should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });

  group('Barcode Lookup Performance', () {
    setUp(() async {
      db = createTestDatabase();

      for (int i = 0; i < 1000; i++) {
        await db.productsDao.insertProduct(makeProduct(
          id: 'prod_$i',
          name: 'Product $i',
          barcode: '69000${i.toString().padLeft(5, '0')}',
          stockQty: 100,
        ));
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('getProductByBarcode with 1000 products completes under 50ms',
        () async {
      // Lookup a barcode in the middle of the dataset
      final sw = Stopwatch()..start();
      final product =
          await db.productsDao.getProductByBarcode('6900000500', 'store-1');
      sw.stop();

      expect(product, isNotNull,
          reason: 'Barcode lookup should find the product');
      expect(product!.id, 'prod_500');
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Barcode lookup should complete under 50ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('quickFindByBarcode with 1000 products completes under 50ms',
        () async {
      final sw = Stopwatch()..start();
      final product =
          await db.productsDao.quickFindByBarcode('6900000750', 'store-1');
      sw.stop();

      expect(product, isNotNull,
          reason: 'Quick barcode lookup should find the product');
      expect(product!.id, 'prod_750');
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Quick barcode lookup should complete under 50ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('barcode lookup for non-existent barcode completes under 50ms',
        () async {
      final sw = Stopwatch()..start();
      final product =
          await db.productsDao.getProductByBarcode('9999999999', 'store-1');
      sw.stop();

      expect(product, isNull,
          reason: 'Non-existent barcode should return null');
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Miss lookup should also complete under 50ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });

  group('Products Count Query Performance', () {
    setUp(() async {
      db = createTestDatabase();

      for (int i = 0; i < 1000; i++) {
        await db.productsDao.insertProduct(makeProduct(
          id: 'prod_$i',
          name: 'Product $i',
          stockQty: 100,
        ));
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('getProductsCount with 1000 products completes under 100ms', () async {
      final sw = Stopwatch()..start();
      final count = await db.productsDao.getProductsCount('store-1');
      sw.stop();

      expect(count, 1000, reason: 'Should count all 1000 products');
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Count query should complete under 100ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getProductById for 100 random lookups completes under 200ms',
        () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        final product = await db.productsDao.getProductById('prod_${i * 10}');
        expect(product, isNotNull);
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(200),
          reason: '100 individual product lookups should complete under 200ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });

    test('getProductsByCategory with 1000 products completes under 50ms',
        () async {
      // No products have categoryId set, so this tests the empty result path performance
      final sw = Stopwatch()..start();
      final products =
          await db.productsDao.getProductsByCategory('cat-1', 'store-1');
      sw.stop();

      expect(products, isEmpty);
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Category filter query should complete under 50ms '
              '(actual: ${sw.elapsedMilliseconds}ms)');
    });
  });
}
