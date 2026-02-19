/// اختبارات DAO المنتجات
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

Future<void> _insertTestProduct(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'منتج اختبار',
  String? categoryId,
  String? barcode,
  String? sku,
  double price = 25.0,
  int stockQty = 100,
  int minQty = 10,
  bool isActive = true,
}) async {
  await db.productsDao.insertProduct(ProductsTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    categoryId: Value(categoryId),
    barcode: Value(barcode),
    sku: Value(sku),
    price: price,
    stockQty: Value(stockQty),
    minQty: Value(minQty),
    isActive: Value(isActive),
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

  group('ProductsDao', () {
    group('insertProduct', () {
      test('يُضيف منتج جديد', () async {
        // Act
        final result = await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'prod-1',
            storeId: 'store-1',
            name: 'منتج اختبار',
            price: 50.0,
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getProductById', () {
      test('يجد المنتج بالمعرف', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1', name: 'تفاح');

        // Act
        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(product, isNotNull);
        expect(product!.name, 'تفاح');
      });

      test('يُرجع null إذا لم يُوجد المنتج', () async {
        // Act
        final product = await db.productsDao.getProductById('non-existent');

        // Assert
        expect(product, isNull);
      });
    });

    group('getProductByBarcode', () {
      test('يجد المنتج بالباركود', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          barcode: '1234567890',
        );

        // Act
        final product = await db.productsDao.getProductByBarcode(
          '1234567890',
          'store-1',
        );

        // Assert
        expect(product, isNotNull);
        expect(product!.id, 'prod-1');
      });

      test('يُرجع null إذا لم يُوجد الباركود', () async {
        // Act
        final product = await db.productsDao.getProductByBarcode(
          'non-existent',
          'store-1',
        );

        // Assert
        expect(product, isNull);
      });
    });

    group('getAllProducts', () {
      test('يُرجع جميع منتجات المتجر', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');
        await _insertTestProduct(db, id: 'prod-2', storeId: 'store-1');
        await _insertTestProduct(db, id: 'prod-3', storeId: 'store-2');

        // Act
        final products = await db.productsDao.getAllProducts('store-1');

        // Assert
        expect(products.length, 2);
      });

      test('يُرتب المنتجات حسب الاسم', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1', name: 'موز');
        await _insertTestProduct(db, id: 'prod-2', storeId: 'store-1', name: 'تفاح');

        // Act
        final products = await db.productsDao.getAllProducts('store-1');

        // Assert
        expect(products.first.name, 'تفاح');
        expect(products.last.name, 'موز');
      });
    });

    group('searchProducts', () {
      test('يبحث بالاسم', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1', name: 'تفاح أحمر');
        await _insertTestProduct(db, id: 'prod-2', storeId: 'store-1', name: 'تفاح أخضر');
        await _insertTestProduct(db, id: 'prod-3', storeId: 'store-1', name: 'موز');

        // Act
        final results = await db.productsDao.searchProducts('تفاح', 'store-1');

        // Assert
        expect(results.length, 2);
      });

      test('يبحث بالباركود', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          name: 'منتج 1',
          barcode: '123456',
        );
        await _insertTestProduct(
          db,
          id: 'prod-2',
          storeId: 'store-1',
          name: 'منتج 2',
          barcode: '789012',
        );

        // Act
        final results = await db.productsDao.searchProducts('1234', 'store-1');

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 'prod-1');
      });

      test('يبحث بـ SKU', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          name: 'منتج 1',
          sku: 'SKU-001',
        );

        // Act
        final results = await db.productsDao.searchProducts('SKU-001', 'store-1');

        // Assert
        expect(results.length, 1);
      });
    });

    group('getProductsByCategory', () {
      test('يُرجع منتجات التصنيف', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          categoryId: 'cat-1',
        );
        await _insertTestProduct(
          db,
          id: 'prod-2',
          storeId: 'store-1',
          categoryId: 'cat-1',
        );
        await _insertTestProduct(
          db,
          id: 'prod-3',
          storeId: 'store-1',
          categoryId: 'cat-2',
        );

        // Act
        final products = await db.productsDao.getProductsByCategory(
          'cat-1',
          'store-1',
        );

        // Assert
        expect(products.length, 2);
      });
    });

    group('getLowStockProducts', () {
      test('يُرجع المنتجات منخفضة المخزون', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          stockQty: 5,
          minQty: 10,
        );
        await _insertTestProduct(
          db,
          id: 'prod-2',
          storeId: 'store-1',
          stockQty: 100,
          minQty: 10,
        );
        await _insertTestProduct(
          db,
          id: 'prod-3',
          storeId: 'store-1',
          stockQty: 10,
          minQty: 10,
        );

        // Act
        final products = await db.productsDao.getLowStockProducts('store-1');

        // Assert
        expect(products.length, 2); // prod-1 و prod-3
      });

      test('يستثني المنتجات غير النشطة', () async {
        // Arrange
        await _insertTestProduct(
          db,
          id: 'prod-1',
          storeId: 'store-1',
          stockQty: 5,
          minQty: 10,
          isActive: false,
        );

        // Act
        final products = await db.productsDao.getLowStockProducts('store-1');

        // Assert
        expect(products.length, 0);
      });
    });

    group('updateStock', () {
      test('يُحدّث كمية المخزون', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1', stockQty: 100);

        // Act
        await db.productsDao.updateStock('prod-1', 80);
        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(product!.stockQty, 80);
      });

      test('يُحدّث تاريخ التعديل', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');
        final before = await db.productsDao.getProductById('prod-1');
        expect(before, isNotNull); // Verify product exists before update

        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        await db.productsDao.updateStock('prod-1', 50);
        final after = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(after!.updatedAt, isNotNull);
      });
    });

    group('upsertProduct', () {
      test('يُضيف منتج جديد إذا لم يكن موجوداً', () async {
        // Act
        await db.productsDao.upsertProduct(ProductsTableCompanion.insert(
          id: 'prod-1',
          storeId: 'store-1',
          name: 'منتج جديد',
          price: 50.0,
          createdAt: DateTime.now(),
        ));

        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(product, isNotNull);
        expect(product!.name, 'منتج جديد');
      });

      test('يُحدّث المنتج إذا كان موجوداً', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1', name: 'اسم قديم');

        // Act
        await db.productsDao.upsertProduct(ProductsTableCompanion.insert(
          id: 'prod-1',
          storeId: 'store-1',
          name: 'اسم جديد',
          price: 75.0,
          createdAt: DateTime.now(),
        ));

        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(product!.name, 'اسم جديد');
        expect(product.price, 75.0);
      });
    });

    group('deleteProduct', () {
      test('يحذف المنتج', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');

        // Act
        final deleted = await db.productsDao.deleteProduct('prod-1');
        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(deleted, 1);
        expect(product, isNull);
      });
    });

    group('markAsSynced', () {
      test('يُعيّن تاريخ المزامنة', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');

        // Act
        await db.productsDao.markAsSynced('prod-1');
        final product = await db.productsDao.getProductById('prod-1');

        // Assert
        expect(product!.syncedAt, isNotNull);
      });
    });

    group('getUnsyncedProducts', () {
      test('يُرجع المنتجات غير المزامنة', () async {
        // Arrange
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');
        await _insertTestProduct(db, id: 'prod-2', storeId: 'store-1');
        await db.productsDao.markAsSynced('prod-1');

        // Act
        final unsynced = await db.productsDao.getUnsyncedProducts();

        // Assert
        expect(unsynced.length, 1);
        expect(unsynced.first.id, 'prod-2');
      });
    });

    group('watchProducts', () {
      test('يُراقب المنتجات النشطة', () async {
        // Arrange
        final emissions = <List<ProductsTableData>>[];
        final subscription = db.productsDao.watchProducts('store-1').listen(emissions.add);

        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        await _insertTestProduct(db, id: 'prod-1', storeId: 'store-1');
        await Future.delayed(const Duration(milliseconds: 50));

        await _insertTestProduct(db, id: 'prod-2', storeId: 'store-1');
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        await subscription.cancel();
        expect(emissions.length, greaterThanOrEqualTo(2));
      });
    });
  });
}
