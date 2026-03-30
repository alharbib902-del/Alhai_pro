import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_transfers_table.dart';

part 'stock_transfers_dao.g.dart';

/// DAO for stock_transfers (inter-branch inventory transfers)
@DriftAccessor(tables: [StockTransfersTable])
class StockTransfersDao extends DatabaseAccessor<AppDatabase>
    with _$StockTransfersDaoMixin {
  StockTransfersDao(super.db);

  /// Get all transfers for a store (as sender or receiver)
  Future<List<StockTransfersTableData>> getByStore(String storeId) {
    return (select(stockTransfersTable)
          ..where((t) =>
              t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get outgoing transfers
  Future<List<StockTransfersTableData>> getOutgoing(String storeId) {
    return (select(stockTransfersTable)
          ..where((t) => t.fromStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get incoming transfers
  Future<List<StockTransfersTableData>> getIncoming(String storeId) {
    return (select(stockTransfersTable)
          ..where((t) => t.toStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get pending incoming transfers (awaiting approval)
  Future<List<StockTransfersTableData>> getPendingIncoming(String storeId) {
    return (select(stockTransfersTable)
          ..where((t) =>
              t.toStoreId.equals(storeId) &
              t.approvalStatus.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get transfer by ID
  Future<StockTransfersTableData?> getById(String id) {
    return (select(stockTransfersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update transfer
  Future<int> upsertTransfer(StockTransfersTableCompanion transfer) =>
      into(stockTransfersTable).insertOnConflictUpdate(transfer);

  /// Update approval status
  Future<int> updateApprovalStatus(
    String id, {
    required String approvalStatus,
    String? approvedBy,
  }) {
    return (update(stockTransfersTable)..where((t) => t.id.equals(id))).write(
      StockTransfersTableCompanion(
        approvalStatus: Value(approvalStatus),
        approvedBy: approvedBy != null ? Value(approvedBy) : const Value.absent(),
        approvedAt: approvalStatus == 'approved'
            ? Value(DateTime.now())
            : const Value.absent(),
      ),
    );
  }

  /// Mark transfer as in transit
  Future<int> markInTransit(String id) {
    return (update(stockTransfersTable)..where((t) => t.id.equals(id))).write(
      const StockTransfersTableCompanion(
        status: Value('in_transit'),
        approvalStatus: Value('in_transit'),
      ),
    );
  }

  /// Mark transfer as received
  Future<int> markReceived(String id, String receivedBy) {
    final now = DateTime.now();
    return (update(stockTransfersTable)..where((t) => t.id.equals(id))).write(
      StockTransfersTableCompanion(
        status: Value('completed'),
        approvalStatus: Value('received'),
        receivedBy: Value(receivedBy),
        receivedAt: Value(now),
        completedAt: Value(now),
      ),
    );
  }

  /// Cancel transfer
  Future<int> cancelTransfer(String id) {
    return (update(stockTransfersTable)..where((t) => t.id.equals(id))).write(
      const StockTransfersTableCompanion(
        status: Value('cancelled'),
        approvalStatus: Value('cancelled'),
      ),
    );
  }

  /// Mark as synced
  Future<int> markAsSynced(String id) {
    return (update(stockTransfersTable)..where((t) => t.id.equals(id))).write(
      StockTransfersTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// Get unsynced transfers
  Future<List<StockTransfersTableData>> getUnsynced() {
    return (select(stockTransfersTable)
          ..where((t) => t.syncedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Watch transfers for a store
  Stream<List<StockTransfersTableData>> watchByStore(String storeId) {
    return (select(stockTransfersTable)
          ..where((t) =>
              t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Watch pending incoming count
  Stream<int> watchPendingIncomingCount(String storeId) {
    final count = stockTransfersTable.id.count();
    final query = selectOnly(stockTransfersTable)
      ..addColumns([count])
      ..where(stockTransfersTable.toStoreId.equals(storeId) &
          stockTransfersTable.approvalStatus.equals('pending'));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
