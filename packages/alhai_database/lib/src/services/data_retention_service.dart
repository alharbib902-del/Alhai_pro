import 'package:drift/drift.dart';

import '../app_database.dart';
import '../constants/retention_policy.dart';

/// Periodic cleanup of old data per Saudi VAT legal retention rules.
///
/// LEGAL WARNING: This service MUST respect Saudi VAT Law Article 66.
/// Sales, audit logs, and related records must be retained for minimum
/// 6 years.  DO NOT reduce retention without legal review.
class DataRetentionService {
  final AppDatabase _db;

  DataRetentionService(this._db);

  /// Run all retention cleanups.
  ///
  /// Should be called periodically (e.g. daily during off-hours).
  /// Returns a summary of what was cleaned.
  Future<RetentionCleanupResult> runCleanup() async {
    final result = RetentionCleanupResult();

    // 1. Old synced sales (>= 6 years AND synced)
    result.deletedSales = await _cleanupOldSales();

    // 2. Old completed sync queue items (>= 30 days)
    result.deletedSyncItems = await _cleanupOldSyncQueue();

    // 3. Old synced stock deltas (>= 7 days)
    result.deletedStockDeltas = await _cleanupOldStockDeltas();

    return result;
  }

  /// Delete sales older than [RetentionPolicy.salesRetention] that have
  /// already been synced to the server.
  ///
  /// CRITICAL: Never deletes unsynced sales regardless of age.
  Future<int> _cleanupOldSales() async {
    final cutoff = DateTime.now().subtract(RetentionPolicy.salesRetention);

    // Find candidates: old + synced + not soft-deleted
    final candidates =
        await (_db.select(_db.salesTable)..where(
              (s) =>
                  s.createdAt.isSmallerThanValue(cutoff) &
                  s.syncedAt.isNotNull() &
                  s.deletedAt.isNull(),
            ))
            .get();

    var count = 0;
    for (final sale in candidates) {
      // Delete the sale first — this removes the trigger condition that
      // prevents deleting sale_items of completed/paid/refunded sales.
      await (_db.delete(
        _db.salesTable,
      )..where((s) => s.id.equals(sale.id))).go();

      // Delete orphaned sale_items (parent sale already gone).
      await (_db.delete(
        _db.saleItemsTable,
      )..where((si) => si.saleId.equals(sale.id))).go();

      count++;
    }

    return count;
  }

  /// Delete completed sync queue items older than 30 days.
  Future<int> _cleanupOldSyncQueue() async {
    final cutoff = DateTime.now().subtract(RetentionPolicy.syncQueueRetention);

    return (_db.delete(_db.syncQueueTable)..where(
          (q) =>
              q.createdAt.isSmallerThanValue(cutoff) &
              q.status.equals('completed'),
        ))
        .go();
  }

  /// Delete synced stock deltas older than 7 days.
  Future<int> _cleanupOldStockDeltas() async {
    final cutoff = DateTime.now().subtract(
      RetentionPolicy.stockDeltasRetention,
    );

    return (_db.delete(_db.stockDeltasTable)..where(
          (d) =>
              d.createdAt.isSmallerThanValue(cutoff) &
              d.syncStatus.equals('synced'),
        ))
        .go();
  }
}

/// Summary of a retention cleanup run.
class RetentionCleanupResult {
  int deletedSales = 0;
  int deletedSyncItems = 0;
  int deletedStockDeltas = 0;

  @override
  String toString() =>
      'RetentionCleanup: sales=$deletedSales, '
      'syncQueue=$deletedSyncItems, stockDeltas=$deletedStockDeltas';
}
