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

  OrgProductsTableCompanion makeOrgProduct({
    String id = 'op-1',
    String orgId = 'org-1',
    String name = 'Test Product',
    String? nameEn,
    String? sku,
    String? barcode,
    double defaultPrice = 25.0,
    double? costPrice,
    String? categoryId,
    bool isActive = true,
    bool onlineAvailable = false,
    DateTime? createdAt,
  }) {
    return OrgProductsTableCompanion.insert(
      id: id,
      orgId: orgId,
      name: name,
      nameEn: Value(nameEn),
      sku: Value(sku),
      barcode: Value(barcode),
      defaultPrice: defaultPrice,
      costPrice: Value(costPrice),
      categoryId: Value(categoryId),
      isActive: Value(isActive),
      onlineAvailable: Value(onlineAvailable),
      createdAt: createdAt ?? DateTime(2026, 1, 15),
    );
  }

  group('OrgProductsDao', () {
    group('getById', () {
      test('returns org product when exists', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        final product = await db.orgProductsDao.getById('op-1');
        expect(product, isNotNull);
        expect(product!.name, 'Test Product');
        expect(product.defaultPrice, 25.0);
      });

      test('returns null for non-existent', () async {
        final product = await db.orgProductsDao.getById('non-existent');
        expect(product, isNull);
      });
    });

    group('getByOrgId', () {
      test('returns active products for org sorted by name', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-b', name: 'Banana'),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-a', name: 'Apple'),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-c', name: 'Cherry', isActive: false),
        );

        final products = await db.orgProductsDao.getByOrgId('org-1');
        expect(products, hasLength(2));
        expect(products.first.name, 'Apple');
        expect(products.last.name, 'Banana');
      });

      test('returns empty list for org with no products', () async {
        final products = await db.orgProductsDao.getByOrgId('org-2');
        expect(products, isEmpty);
      });
    });

    group('getBySku', () {
      test('finds product by SKU', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(sku: 'SKU-001'),
        );

        final product = await db.orgProductsDao.getBySku('org-1', 'SKU-001');
        expect(product, isNotNull);
        expect(product!.id, 'op-1');
      });

      test('returns null for wrong org', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(sku: 'SKU-001'),
        );

        final product = await db.orgProductsDao.getBySku('org-2', 'SKU-001');
        expect(product, isNull);
      });
    });

    group('getByBarcode', () {
      test('finds product by barcode', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(barcode: '1234567890'),
        );

        final product = await db.orgProductsDao.getByBarcode(
          'org-1',
          '1234567890',
        );
        expect(product, isNotNull);
        expect(product!.id, 'op-1');
      });
    });

    group('search', () {
      test('finds products by name', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', name: 'Apple Juice'),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-2', name: 'Orange Juice'),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-3', name: 'Milk'),
        );

        final results = await db.orgProductsDao.search('org-1', 'Juice');
        expect(results, hasLength(2));
      });

      test('finds products by barcode', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', name: 'Product', barcode: 'ABC123'),
        );

        final results = await db.orgProductsDao.search('org-1', 'ABC');
        expect(results, hasLength(1));
      });

      test('excludes inactive products', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', name: 'Active Product', isActive: true),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-2', name: 'Inactive Product', isActive: false),
        );

        final results = await db.orgProductsDao.search('org-1', 'Product');
        expect(results, hasLength(1));
        expect(results.first.id, 'op-1');
      });
    });

    group('getByCategory', () {
      test('returns products in a category', () async {
        // Need a category first
        await db.categoriesDao.insertCategory(
          CategoriesTableCompanion.insert(
            id: 'cat-1',
            storeId: 'store-1',
            name: 'Drinks',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', name: 'Cola', categoryId: 'cat-1'),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-2', name: 'Chips', categoryId: null),
        );

        final results = await db.orgProductsDao.getByCategory('org-1', 'cat-1');
        expect(results, hasLength(1));
        expect(results.first.name, 'Cola');
      });
    });

    group('getOnlineProducts', () {
      test('returns only online-available products', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', onlineAvailable: true),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(
            id: 'op-2',
            name: 'Offline Only',
            onlineAvailable: false,
          ),
        );

        final online = await db.orgProductsDao.getOnlineProducts('org-1');
        expect(online, hasLength(1));
        expect(online.first.id, 'op-1');
      });
    });

    group('upsertOrgProduct', () {
      test('inserts new product', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        final product = await db.orgProductsDao.getById('op-1');
        expect(product, isNotNull);
      });

      test('updates existing product on conflict', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(defaultPrice: 10.0),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(defaultPrice: 20.0),
        );

        final product = await db.orgProductsDao.getById('op-1');
        expect(product!.defaultPrice, 20.0);
      });
    });

    group('batchUpsert', () {
      test('inserts multiple products', () async {
        await db.orgProductsDao.batchUpsert([
          makeOrgProduct(id: 'op-1', name: 'Product 1'),
          makeOrgProduct(id: 'op-2', name: 'Product 2'),
          makeOrgProduct(id: 'op-3', name: 'Product 3'),
        ]);

        final products = await db.orgProductsDao.getByOrgId('org-1');
        expect(products, hasLength(3));
      });
    });

    group('softDelete', () {
      test('marks product as inactive', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        await db.orgProductsDao.softDelete('op-1');

        // Bypass the DAO's deletedAt.isNull() filter — post-v70 getById() hides
        // soft-deleted rows by design. To verify softDelete's effect on flags,
        // query the table directly.
        final product = await (db.select(db.orgProductsTable)
              ..where((p) => p.id.equals('op-1')))
            .getSingleOrNull();
        expect(product!.isActive, isFalse);
        expect(product.deletedAt, isNotNull);
      });

      test('soft-deleted products excluded from getByOrgId', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());
        await db.orgProductsDao.softDelete('op-1');

        final products = await db.orgProductsDao.getByOrgId('org-1');
        expect(products, isEmpty);
      });
    });

    group('deleteOrgProduct', () {
      test('hard deletes product', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        await db.orgProductsDao.deleteOrgProduct('op-1');

        final product = await db.orgProductsDao.getById('op-1');
        expect(product, isNull);
      });
    });

    group('markAsSynced', () {
      test('sets syncedAt timestamp', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        await db.orgProductsDao.markAsSynced('op-1');

        final product = await db.orgProductsDao.getById('op-1');
        expect(product!.syncedAt, isNotNull);
      });
    });

    group('getCount', () {
      test('returns count of active products for org', () async {
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-1', isActive: true),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-2', isActive: true),
        );
        await db.orgProductsDao.upsertOrgProduct(
          makeOrgProduct(id: 'op-3', isActive: false),
        );

        final count = await db.orgProductsDao.getCount('org-1');
        expect(count, 2);
      });
    });

    group('watchByOrgId', () {
      test('emits active products', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        final products = await db.orgProductsDao.watchByOrgId('org-1').first;
        expect(products, hasLength(1));
      });
    });

    group('updateOrgProduct images', () {
      test('updates image fields', () async {
        await db.orgProductsDao.upsertOrgProduct(makeOrgProduct());

        await db.orgProductsDao.updateOrgProduct(
          'op-1',
          orgImageThumbnail: 'https://example.com/thumb.webp',
          orgImageMedium: 'https://example.com/medium.webp',
          orgImageLarge: 'https://example.com/large.webp',
          orgImageHash: 'abc123',
        );

        final product = await db.orgProductsDao.getById('op-1');
        expect(product!.orgImageThumbnail, 'https://example.com/thumb.webp');
        expect(product.orgImageMedium, 'https://example.com/medium.webp');
        expect(product.orgImageLarge, 'https://example.com/large.webp');
        expect(product.orgImageHash, 'abc123');
      });
    });
  });
}
