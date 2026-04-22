import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_database/src/services/data_retention_service.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;
  late DataRetentionService service;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
    service = DataRetentionService(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to insert a sale with the given age and sync status.
  Future<String> _insertSale({
    required String id,
    required DateTime createdAt,
    DateTime? syncedAt,
  }) async {
    await db
        .into(db.salesTable)
        .insert(
          SalesTableCompanion.insert(
            id: id,
            receiptNo: 'REC-$id',
            storeId: 'store-1',
            cashierId: 'user-1',
            // C-4 Session 3: sales money columns are int cents.
            subtotal: 10000, // 100.00 SAR
            total: 11500, // 115.00 SAR
            paymentMethod: 'cash',
            createdAt: createdAt,
            syncedAt: Value(syncedAt),
          ),
        );
    return id;
  }

  group('DataRetentionService — sales cleanup', () {
    test('does NOT delete sales younger than 6 years', () async {
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      await _insertSale(
        id: 'sale-young',
        createdAt: fiveYearsAgo,
        syncedAt: fiveYearsAgo,
      );

      await service.runCleanup();

      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-young'))).get();
      expect(
        remaining.length,
        equals(1),
        reason: '5-year-old sale must NOT be deleted',
      );
    });

    test('deletes synced sales older than 6 years', () async {
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      await _insertSale(
        id: 'sale-old',
        createdAt: sevenYearsAgo,
        syncedAt: sevenYearsAgo,
      );

      final result = await service.runCleanup();

      expect(result.deletedSales, equals(1));
      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-old'))).get();
      expect(remaining, isEmpty);
    });

    test('never deletes unsynced sales regardless of age', () async {
      final eightYearsAgo = DateTime.now().subtract(const Duration(days: 2920));
      await _insertSale(
        id: 'sale-unsynced',
        createdAt: eightYearsAgo,
        syncedAt: null, // NOT synced
      );

      await service.runCleanup();

      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-unsynced'))).get();
      expect(
        remaining.length,
        equals(1),
        reason: 'Unsynced sale must NEVER be deleted',
      );
    });

    test('mixed scenario: only old+synced sales are deleted', () async {
      // Recent synced — keep
      await _insertSale(
        id: 'sale-recent',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        syncedAt: DateTime.now().subtract(const Duration(days: 29)),
      );
      // 5-year-old synced — keep
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      await _insertSale(
        id: 'sale-5yr',
        createdAt: fiveYearsAgo,
        syncedAt: fiveYearsAgo,
      );
      // 7-year-old synced — delete
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      await _insertSale(
        id: 'sale-7yr',
        createdAt: sevenYearsAgo,
        syncedAt: sevenYearsAgo,
      );
      // 8-year-old unsynced — keep
      await _insertSale(
        id: 'sale-8yr-unsynced',
        createdAt: DateTime.now().subtract(const Duration(days: 2920)),
        syncedAt: null,
      );

      final result = await service.runCleanup();

      expect(result.deletedSales, equals(1));
      final remaining = await db.select(db.salesTable).get();
      final ids = remaining.map((s) => s.id).toSet();
      expect(
        ids,
        containsAll(['sale-recent', 'sale-5yr', 'sale-8yr-unsynced']),
      );
      expect(ids, isNot(contains('sale-7yr')));
    });

    test('deletes related sale_items when sale is cleaned', () async {
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));

      // Insert product for FK
      // C-4 Stage B: SAR × 100 = cents
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-ret-sale',
          name: 'Retention Test',
          storeId: 'store-1',
          price: 5000,
          createdAt: DateTime.now(),
        ),
      );

      // Insert sale
      await _insertSale(
        id: 'sale-with-items',
        createdAt: sevenYearsAgo,
        syncedAt: sevenYearsAgo,
      );
      // Insert sale items
      await db
          .into(db.saleItemsTable)
          .insert(
            SaleItemsTableCompanion.insert(
              id: 'si-1',
              saleId: 'sale-with-items',
              productId: 'prod-ret-sale',
              productName: 'Test',
              qty: 2.0,
              // C-4 Session 2: SAR × 100 = cents (int)
              unitPrice: 5000,
              subtotal: 10000,
              total: 10000,
            ),
          );

      await service.runCleanup();

      final remainingSaleItems = await (db.select(
        db.saleItemsTable,
      )..where((si) => si.saleId.equals('sale-with-items'))).get();
      expect(
        remainingSaleItems,
        isEmpty,
        reason: 'Sale items must be deleted with their parent sale',
      );
    });
  });

  group('RetentionCleanupResult', () {
    test('toString provides readable summary', () {
      final result = RetentionCleanupResult()
        ..deletedSales = 5
        ..deletedSyncItems = 10
        ..deletedStockDeltas = 3;

      expect(result.toString(), contains('sales=5'));
      expect(result.toString(), contains('syncQueue=10'));
    });
  });
}
