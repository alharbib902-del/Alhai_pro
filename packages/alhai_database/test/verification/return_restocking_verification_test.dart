/// Independent verification for Fix #5: Inventory Restocking on Returns.
///
/// Tests return movement recording, stock changes, and edge cases.
/// NOTE: The provider-level createReturn() is tested separately because
/// it requires Riverpod setup.  These tests target the database layer.
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

  /// Helper: insert a product with given stock
  Future<void> _insertProduct(String id, double stock) async {
    await db.productsDao.insertProduct(
      ProductsTableCompanion.insert(
        id: id,
        name: 'Product $id',
        storeId: 'store-1',
        price: 50.0,
        createdAt: DateTime.now(),
      ),
    );
    await db.productsDao.updateStock(id, stock);
  }

  group('VERIFICATION — Fix #5: Return Restocking', () {
    // -----------------------------------------------------------------------
    // 5.1 Full return (10 bought, 10 returned)
    // -----------------------------------------------------------------------
    test('full return: stock increases by full amount', () async {
      await _insertProduct('prod-full-ret', 90.0); // was 100, sold 10 → 90

      // Record return of all 10
      await db.inventoryDao.recordReturnMovement(
        id: 'mov-full-1',
        productId: 'prod-full-ret',
        storeId: 'store-1',
        qty: 10.0,
        previousQty: 90.0,
        returnId: 'ret-full-1',
      );
      await db.productsDao.updateStock('prod-full-ret', 100.0);

      final product = await db.productsDao.getProductById('prod-full-ret');
      expect(product!.stockQty, equals(100.0));

      final movements = await db.inventoryDao.getMovementsByProduct(
        'prod-full-ret',
      );
      expect(movements.length, equals(1));
      expect(movements.first.type, equals('return'));
      expect(movements.first.qty, equals(10.0));
      expect(movements.first.newQty, equals(100.0));
    });

    // -----------------------------------------------------------------------
    // 5.2 Multiple partial returns on same invoice
    // -----------------------------------------------------------------------
    test('multiple partial returns: cumulative stock increase', () async {
      await _insertProduct('prod-partial', 90.0); // sold 10 → 90

      // First return: 3 items
      await db.inventoryDao.recordReturnMovement(
        id: 'mov-part-1',
        productId: 'prod-partial',
        storeId: 'store-1',
        qty: 3.0,
        previousQty: 90.0,
        returnId: 'ret-part-1',
      );
      await db.productsDao.updateStock('prod-partial', 93.0);

      // Second return: 4 items
      await db.inventoryDao.recordReturnMovement(
        id: 'mov-part-2',
        productId: 'prod-partial',
        storeId: 'store-1',
        qty: 4.0,
        previousQty: 93.0,
        returnId: 'ret-part-2',
      );
      await db.productsDao.updateStock('prod-partial', 97.0);

      final product = await db.productsDao.getProductById('prod-partial');
      expect(product!.stockQty, equals(97.0));

      final movements = await db.inventoryDao.getMovementsByProduct(
        'prod-partial',
      );
      expect(movements.length, equals(2));

      // Verify movement trail
      final returnMovements = movements
          .where((m) => m.type == 'return')
          .toList();
      expect(returnMovements.length, equals(2));
      final totalReturned = returnMovements.fold<double>(
        0,
        (sum, m) => sum + m.qty,
      );
      expect(totalReturned, equals(7.0));
    });

    // -----------------------------------------------------------------------
    // 5.3 Return movement records positive qty
    // -----------------------------------------------------------------------
    test('return movement qty is always positive (restock)', () async {
      await _insertProduct('prod-pos', 50.0);

      await db.inventoryDao.recordReturnMovement(
        id: 'mov-pos-1',
        productId: 'prod-pos',
        storeId: 'store-1',
        qty: 5.0,
        previousQty: 50.0,
        returnId: 'ret-pos-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-pos');
      expect(
        movements.first.qty,
        greaterThan(0),
        reason: 'Return qty must be positive (restock)',
      );
      expect(
        movements.first.newQty,
        equals(55.0),
        reason: 'New qty should be previous + return qty',
      );
    });

    // -----------------------------------------------------------------------
    // 5.4 createReturnTransaction uses transaction (atomic)
    // -----------------------------------------------------------------------
    // GHOST BUG (FIXED): Variable.withReal/withString in customStatement
    // was replaced with raw Dart values.  See return_transaction_smoke_test.dart.
    test(
      'createReturnTransaction completes without error (ghost bug fixed)',
      () async {
        await _insertProduct('prod-txn', 100.0);

        await db
            .into(db.salesTable)
            .insert(
              SalesTableCompanion.insert(
                id: 'sale-txn-1',
                receiptNo: 'REC-TXN',
                storeId: 'store-1',
                cashierId: 'user-1',
                subtotal: 50.0,
                total: 57.5,
                paymentMethod: 'cash',
                createdAt: DateTime.now(),
              ),
            );

        await db.createReturnTransaction(
          returnData: ReturnsTableCompanion.insert(
            id: 'ret-txn-1',
            returnNumber: 'RET-TXN-001',
            saleId: 'sale-txn-1',
            storeId: 'store-1',
            totalRefund: 50.0,
            reason: const Value('defective'),
            createdAt: DateTime.now(),
          ),
          items: const [],
          stockAdditions: [const MapEntry('prod-txn', 3.0)],
        );

        final product = await db.productsDao.getProductById('prod-txn');
        expect(
          product!.stockQty,
          equals(103.0),
          reason: 'Atomic stock update via SQL: stock_qty = stock_qty + 3',
        );
      },
    );

    // -----------------------------------------------------------------------
    // 5.5 Movement records reference the return
    // -----------------------------------------------------------------------
    test('movement tracks referenceType and referenceId', () async {
      await _insertProduct('prod-ref', 40.0);

      await db.inventoryDao.recordReturnMovement(
        id: 'mov-ref-1',
        productId: 'prod-ref',
        storeId: 'store-1',
        qty: 2.0,
        previousQty: 40.0,
        returnId: 'ret-ref-001',
        userId: 'user-1',
      );

      final movements = await db.inventoryDao.getMovementsByProduct('prod-ref');
      expect(movements.first.referenceType, equals('return'));
      expect(movements.first.referenceId, equals('ret-ref-001'));
      expect(movements.first.userId, equals('user-1'));
    });
  });
}
