import 'package:alhai_core/alhai_core.dart' show AppendOnlyViolationException;
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to create a product for FK constraints.
  // C-4 Stage B: SAR × 100 = cents
  Future<void> _seedProduct(String id) async {
    await db.productsDao.insertProduct(
      ProductsTableCompanion.insert(
        id: id,
        storeId: 'store-1',
        name: 'Product $id',
        price: 5000,
        createdAt: DateTime(2025, 1, 1),
      ),
    );
  }

  /// Helper to insert a sale with given status.
  Future<SalesTableData> _insertSale({
    required String id,
    required String status,
  }) async {
    await db.salesDao.insertSale(
      SalesTableCompanion.insert(
        id: id,
        storeId: 'store-1',
        receiptNo: 'REC-$id',
        cashierId: 'cashier-1',
        // C-4 Session 3: sales money columns are int cents.
        subtotal: 10000, // 100.00 SAR
        total: 10000, // 100.00 SAR
        paymentMethod: 'cash',
        status: Value(status),
        createdAt: DateTime(2025, 6, 1),
      ),
    );
    return (await db.salesDao.getSaleById(id))!;
  }

  group('Append-Only Sales (ZATCA Compliance)', () {
    test('draft sale can be updated', () async {
      await _seedProduct('prod-1');
      final sale = await _insertSale(id: 'sale-draft', status: 'draft');

      // Modifying total on a draft sale should succeed
      // C-4 Session 3: total is int cents.
      final modified = sale.copyWith(total: 20000); // 200.00 SAR
      final ok = await db.salesDao.updateSale(modified);
      expect(ok, isTrue);

      final refreshed = await db.salesDao.getSaleById('sale-draft');
      expect(refreshed!.total, 20000); // 200.00 SAR in cents
    });

    test(
      'completed sale financial update throws AppendOnlyViolationException',
      () async {
        await _seedProduct('prod-2');
        final sale = await _insertSale(id: 'sale-done', status: 'completed');

        // Attempt to change the total on a completed sale
        // C-4 Session 3: total is int cents.
        final modified = sale.copyWith(total: 99900); // 999.00 SAR
        expect(
          () => db.salesDao.updateSale(modified),
          throwsA(isA<AppendOnlyViolationException>()),
        );
      },
    );

    test('completed sale technical field (syncedAt) update succeeds', () async {
      await _seedProduct('prod-3');
      await _insertSale(id: 'sale-sync', status: 'completed');

      // Updating only syncedAt (technical field) must succeed
      final result = await db.salesDao.markAsSynced('sale-sync');
      expect(result, 1);

      final refreshed = await db.salesDao.getSaleById('sale-sync');
      expect(refreshed!.syncedAt, isNotNull);
    });

    test('cannot delete sale_items of a completed sale (DB trigger)', () async {
      await _seedProduct('prod-4');
      await _insertSale(id: 'sale-items-test', status: 'completed');

      // Insert a sale item
      await db
          .into(db.saleItemsTable)
          .insert(
            SaleItemsTableCompanion.insert(
              id: 'si-1',
              saleId: 'sale-items-test',
              productId: 'prod-4',
              productName: 'Product 4',
              qty: 2.0,
              // C-4 Session 2: SAR × 100 = cents (int)
              unitPrice: 5000,
              subtotal: 10000,
              total: 10000,
            ),
          );

      // The DB trigger should prevent deleting this item
      expect(
        () => (db.delete(
          db.saleItemsTable,
        )..where((t) => t.id.equals('si-1'))).go(),
        throwsA(anything),
      );

      // Verify the item still exists
      final items = await (db.select(
        db.saleItemsTable,
      )..where((t) => t.saleId.equals('sale-items-test'))).get();
      expect(items, hasLength(1));
    });
  });
}
