/// Independent verification for Fix #7: Sales Retention Policy (6-year).
///
/// Tests retention rules, sync-queue cleanup, and edge cases.
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_database/src/constants/retention_policy.dart';
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

  /// Helper to insert a sale
  Future<void> _insertSale({
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
            subtotal: 100.0,
            total: 115.0,
            paymentMethod: 'cash',
            createdAt: createdAt,
            syncedAt: Value(syncedAt),
          ),
        );
  }

  group('VERIFICATION — Fix #7: Sales Retention (6-year)', () {
    // -----------------------------------------------------------------------
    // 7.1 Age-based rules
    // -----------------------------------------------------------------------
    test('5-year-old synced sale → NOT deleted', () async {
      final age = DateTime.now().subtract(const Duration(days: 1825));
      await _insertSale(id: 'sale-5yr', createdAt: age, syncedAt: age);

      await service.runCleanup();

      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-5yr'))).get();
      expect(remaining.length, 1);
    });

    test('7-year-old synced sale → deleted', () async {
      final age = DateTime.now().subtract(const Duration(days: 2555));
      await _insertSale(id: 'sale-7yr', createdAt: age, syncedAt: age);

      final result = await service.runCleanup();

      expect(result.deletedSales, 1);
      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-7yr'))).get();
      expect(remaining, isEmpty);
    });

    // -----------------------------------------------------------------------
    // 7.2 Sync-safety: unsynced sales are NEVER deleted
    // -----------------------------------------------------------------------
    test('7-year-old UNsynced sale → NOT deleted', () async {
      final age = DateTime.now().subtract(const Duration(days: 2555));
      await _insertSale(id: 'sale-unsync', createdAt: age, syncedAt: null);

      await service.runCleanup();

      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-unsync'))).get();
      expect(
        remaining.length,
        1,
        reason: 'Unsynced sales must NEVER be deleted regardless of age',
      );
    });

    // -----------------------------------------------------------------------
    // 7.3 Retention constant verification
    // -----------------------------------------------------------------------
    test('salesRetention is 2190 days (6 years)', () {
      expect(RetentionPolicy.salesRetention.inDays, equals(2190));
    });

    test('canDeleteSale — 5 years → false', () {
      final date = DateTime.now().subtract(const Duration(days: 1825));
      expect(RetentionPolicy.canDeleteSale(date), isFalse);
    });

    test('canDeleteSale — 7 years → true', () {
      final date = DateTime.now().subtract(const Duration(days: 2555));
      expect(RetentionPolicy.canDeleteSale(date), isTrue);
    });

    // -----------------------------------------------------------------------
    // 7.4 Sale items are cleaned with parent sale
    // -----------------------------------------------------------------------
    test('sale_items deleted after parent sale is cleaned', () async {
      final age = DateTime.now().subtract(const Duration(days: 2555));

      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-ret-7',
          name: 'Retention Product',
          storeId: 'store-1',
          price: 50.0,
          createdAt: DateTime.now(),
        ),
      );

      await _insertSale(id: 'sale-items-7yr', createdAt: age, syncedAt: age);
      await db
          .into(db.saleItemsTable)
          .insert(
            SaleItemsTableCompanion.insert(
              id: 'si-ret-7',
              saleId: 'sale-items-7yr',
              productId: 'prod-ret-7',
              productName: 'Test',
              qty: 3.0,
              unitPrice: 50.0,
              subtotal: 150.0,
              total: 150.0,
            ),
          );

      await service.runCleanup();

      final remainingItems = await (db.select(
        db.saleItemsTable,
      )..where((si) => si.saleId.equals('sale-items-7yr'))).get();
      expect(
        remainingItems,
        isEmpty,
        reason: 'Sale items must be deleted with their parent sale',
      );
    });

    // -----------------------------------------------------------------------
    // 7.5 Sync queue cleanup
    // -----------------------------------------------------------------------
    test('sync queue: only completed items > 30 days are deleted', () async {
      final cutoff35d = DateTime.now().subtract(const Duration(days: 35));
      final cutoff10d = DateTime.now().subtract(const Duration(days: 10));

      // 35-day-old completed → should be deleted
      await db.syncQueueDao.enqueue(
        id: 'sq-old-completed',
        tableName: 'sales',
        recordId: 'rec-1',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'sq1',
      );
      // Manually set created_at and status using integer timestamp (drift format)
      final cutoff35dEpoch = cutoff35d.millisecondsSinceEpoch ~/ 1000;
      await db.customStatement(
        "UPDATE sync_queue SET created_at = $cutoff35dEpoch, status = 'completed' WHERE id = 'sq-old-completed'",
        [],
      );

      // 35-day-old pending → must NOT be deleted
      await db.syncQueueDao.enqueue(
        id: 'sq-old-pending',
        tableName: 'sales',
        recordId: 'rec-2',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'sq2',
      );
      await db.customStatement(
        "UPDATE sync_queue SET created_at = $cutoff35dEpoch, status = 'pending' WHERE id = 'sq-old-pending'",
        [],
      );

      // 10-day-old completed → must NOT be deleted (too recent)
      await db.syncQueueDao.enqueue(
        id: 'sq-recent-completed',
        tableName: 'sales',
        recordId: 'rec-3',
        operation: 'CREATE',
        payload: '{}',
        idempotencyKey: 'sq3',
      );
      final cutoff10dEpoch = cutoff10d.millisecondsSinceEpoch ~/ 1000;
      await db.customStatement(
        "UPDATE sync_queue SET created_at = $cutoff10dEpoch, status = 'completed' WHERE id = 'sq-recent-completed'",
        [],
      );

      final result = await service.runCleanup();

      expect(
        result.deletedSyncItems,
        equals(1),
        reason: 'Only old+completed sync items should be deleted',
      );
    });

    // -----------------------------------------------------------------------
    // 7.6 Boundary: exact cutoff (2190 days)
    // -----------------------------------------------------------------------
    test('exact 2190-day boundary: sale is NOT deleted (strict <)', () async {
      final age = DateTime.now().subtract(const Duration(days: 2190));
      await _insertSale(id: 'sale-boundary', createdAt: age, syncedAt: age);

      await service.runCleanup();

      final remaining = await (db.select(
        db.salesTable,
      )..where((s) => s.id.equals('sale-boundary'))).get();
      expect(
        remaining.length,
        1,
        reason: 'Exact boundary record should NOT be deleted (strict <)',
      );
    });
  });
}
