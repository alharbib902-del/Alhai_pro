/// Smoke test for createReturnTransaction after ghost bug fix (F1).
///
/// Verifies that createReturnTransaction() no longer throws ArgumentError
/// from Variable.withReal / Variable.withString in customStatement().
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

  group('createReturnTransaction — ghost bug fix smoke test', () {
    test('completes without ArgumentError', () async {
      // Setup: product with stock
      // C-4 Stage B: SAR × 100 = cents
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-smoke',
          name: 'Smoke Test Widget',
          storeId: 'store-1',
          price: 5000,
          createdAt: DateTime.now(),
        ),
      );
      await db.productsDao.updateStock('prod-smoke', 100.0);

      // Setup: sale (FK target for returns)
      await db
          .into(db.salesTable)
          .insert(
            SalesTableCompanion.insert(
              id: 'sale-smoke',
              receiptNo: 'REC-SMOKE',
              storeId: 'store-1',
              cashierId: 'user-1',
              // C-4 Session 3: sales money columns are int cents.
              subtotal: 5000, // 50.00 SAR
              total: 5750, // 57.50 SAR
              paymentMethod: 'cash',
              createdAt: DateTime.now(),
            ),
          );

      // This previously threw ArgumentError due to Variable.withReal()
      await db.createReturnTransaction(
        returnData: ReturnsTableCompanion.insert(
          id: 'ret-smoke',
          returnNumber: 'RET-SMOKE-001',
          saleId: 'sale-smoke',
          storeId: 'store-1',
          totalRefund: 5000, // 50.00 in cents
          reason: const Value('defective'),
          createdAt: DateTime.now(),
        ),
        items: const [],
        stockAdditions: [const MapEntry('prod-smoke', 3.0)],
      );

      // Verify stock increased atomically
      final product = await db.productsDao.getProductById('prod-smoke');
      expect(product!.stockQty, equals(103.0));
    });

    test('also works for createSaleTransaction (same fix)', () async {
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-sale-smoke',
          name: 'Sale Smoke Widget',
          storeId: 'store-1',
          price: 2500,
          createdAt: DateTime.now(),
        ),
      );
      await db.productsDao.updateStock('prod-sale-smoke', 100.0);

      await db.createSaleTransaction(
        sale: SalesTableCompanion.insert(
          id: 'sale-txn-smoke',
          receiptNo: 'REC-TXN-SMOKE',
          storeId: 'store-1',
          cashierId: 'user-1',
          // C-4 Session 3: sales money columns are int cents.
          subtotal: 5000, // 50.00 SAR
          total: 5750, // 57.50 SAR
          paymentMethod: 'cash',
          createdAt: DateTime.now(),
        ),
        items: [],
        stockDeductions: [const MapEntry('prod-sale-smoke', 5.0)],
      );

      // Verify stock decreased atomically
      final product = await db.productsDao.getProductById('prod-sale-smoke');
      expect(product!.stockQty, equals(95.0));
    });
  });
}
