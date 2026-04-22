import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    // sale_items reference products and sales via FK
    // C-4 Stage B: SAR × 100 = cents
    final now = DateTime(2025, 1, 1);
    for (var i = 1; i <= 3; i++) {
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-$i',
          storeId: 'store-1',
          name: 'P$i',
          price: 1000,
          createdAt: now,
        ),
      );
    }
    for (final id in ['sale-1', 'sale-2']) {
      await db.salesDao.insertSale(
        SalesTableCompanion.insert(
          id: id,
          storeId: 'store-1',
          receiptNo: 'R-$id',
          cashierId: 'cashier-1',
          // C-4 Session 3: sales money columns are int cents.
          subtotal: 10000, // 100.00 SAR
          total: 10000, // 100.00 SAR
          paymentMethod: 'cash',
          status: const Value('draft'),
          createdAt: now,
        ),
      );
    }
  });

  tearDown(() async {
    await db.close();
  });

  SaleItemsTableCompanion makeItem({
    String id = 'item-1',
    String saleId = 'sale-1',
    String productId = 'prod-1',
    String productName = 'حليب طازج',
    double qty = 2,
    double unitPrice = 5.5,
    double subtotal = 11.0,
    double total = 11.0,
  }) {
    return SaleItemsTableCompanion.insert(
      id: id,
      saleId: saleId,
      productId: productId,
      productName: productName,
      qty: qty,
      // C-4 Session 2: fixture inputs are SAR doubles for readability;
      // convert to int cents at the Drift boundary.
      unitPrice: (unitPrice * 100).round(),
      subtotal: (subtotal * 100).round(),
      total: (total * 100).round(),
    );
  }

  group('SaleItemsDao', () {
    test('insertItem and getItemsBySaleId', () async {
      await db.saleItemsDao.insertItem(makeItem());
      await db.saleItemsDao.insertItem(
        makeItem(
          id: 'item-2',
          productId: 'prod-2',
          productName: 'عصير برتقال',
          qty: 1,
          unitPrice: 3.0,
          subtotal: 3.0,
          total: 3.0,
        ),
      );

      final items = await db.saleItemsDao.getItemsBySaleId('sale-1');
      expect(items, hasLength(2));
    });

    test('getItemsBySaleId returns empty for unknown sale', () async {
      await db.saleItemsDao.insertItem(makeItem());

      final items = await db.saleItemsDao.getItemsBySaleId('unknown-sale');
      expect(items, isEmpty);
    });

    test('insertItems batch inserts multiple items', () async {
      final items = [
        makeItem(id: 'item-1'),
        makeItem(id: 'item-2', productName: 'خبز', productId: 'prod-2'),
        makeItem(id: 'item-3', productName: 'جبنة', productId: 'prod-3'),
      ];

      await db.saleItemsDao.insertItems(items);

      final result = await db.saleItemsDao.getItemsBySaleId('sale-1');
      expect(result, hasLength(3));
    });

    test('deleteItemsBySaleId removes all items for a sale', () async {
      await db.saleItemsDao.insertItem(makeItem(id: 'item-1'));
      await db.saleItemsDao.insertItem(
        makeItem(id: 'item-2', productId: 'prod-2'),
      );
      await db.saleItemsDao.insertItem(
        makeItem(id: 'item-3', saleId: 'sale-2', productId: 'prod-3'),
      );

      final deleted = await db.saleItemsDao.deleteItemsBySaleId('sale-1');
      expect(deleted, 2);

      // sale-2 items should remain
      final remaining = await db.saleItemsDao.getItemsBySaleId('sale-2');
      expect(remaining, hasLength(1));
    });

    test('getProductSalesCount sums quantities', () async {
      // sale-1 and sale-2 are created in setUp

      await db.saleItemsDao.insertItem(
        makeItem(id: 'item-1', qty: 3, productId: 'prod-1'),
      );
      await db.saleItemsDao.insertItem(
        makeItem(id: 'item-2', saleId: 'sale-2', qty: 5, productId: 'prod-1'),
      );

      final count = await db.saleItemsDao.getProductSalesCount(
        'prod-1',
        'store-1',
      );
      expect(count, 8);
    });

    test('getProductSalesCount returns 0 for no sales', () async {
      final count = await db.saleItemsDao.getProductSalesCount(
        'prod-unknown',
        'store-1',
      );
      expect(count, 0);
    });
  });
}
