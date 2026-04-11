import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/purchases_table.dart';

part 'purchases_dao.g.dart';

/// DAO for purchases
@DriftAccessor(tables: [PurchasesTable, PurchaseItemsTable])
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  Future<List<PurchasesTableData>> getAllPurchases(String storeId) {
    return (select(purchasesTable)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(500))
        .get();
  }

  Future<List<PurchasesTableData>> getPurchasesByStatus(
    String storeId,
    String status,
  ) {
    return (select(purchasesTable)
          ..where((p) => p.storeId.equals(storeId) & p.status.equals(status))
          ..limit(500))
        .get();
  }

  Future<PurchasesTableData?> getPurchaseById(String id) =>
      (select(purchasesTable)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertPurchase(PurchasesTableCompanion purchase) =>
      into(purchasesTable).insert(purchase);
  Future<bool> updatePurchase(PurchasesTableData purchase) =>
      update(purchasesTable).replace(purchase);

  Future<int> updateStatus(String id, String status) {
    return (update(purchasesTable)..where((p) => p.id.equals(id))).write(
      PurchasesTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> receivePurchase(String id) {
    return (update(purchasesTable)..where((p) => p.id.equals(id))).write(
      PurchasesTableCompanion(
        status: const Value('received'),
        receivedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deletePurchase(String id) =>
      (delete(purchasesTable)..where((p) => p.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(purchasesTable)..where((p) => p.id.equals(id))).write(
      PurchasesTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  // Purchase items
  Future<List<PurchaseItemsTableData>> getPurchaseItems(String purchaseId) {
    return (select(
      purchaseItemsTable,
    )..where((i) => i.purchaseId.equals(purchaseId))).get();
  }

  Future<void> insertPurchaseItems(
    List<PurchaseItemsTableCompanion> items,
  ) async {
    await batch((b) {
      b.insertAll(purchaseItemsTable, items);
    });
  }

  Future<int> deletePurchaseItems(String purchaseId) {
    return (delete(
      purchaseItemsTable,
    )..where((i) => i.purchaseId.equals(purchaseId))).go();
  }

  // ── Pagination ─────────────────────────────────────────────────

  /// Paginated purchases (all statuses)
  Future<List<PurchasesTableData>> getPurchasesPaginated(
    String storeId, {
    int offset = 0,
    int limit = 20,
  }) {
    return (select(purchasesTable)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Paginated purchases filtered by status
  Future<List<PurchasesTableData>> getPurchasesByStatusPaginated(
    String storeId,
    String status, {
    int offset = 0,
    int limit = 20,
  }) {
    return (select(purchasesTable)
          ..where((p) => p.storeId.equals(storeId) & p.status.equals(status))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Total count of purchases (for pagination controls)
  Future<int> getPurchasesCount(String storeId, {String? status}) async {
    final countExpr = purchasesTable.id.count();
    var query = selectOnly(purchasesTable)
      ..addColumns([countExpr])
      ..where(purchasesTable.storeId.equals(storeId));
    if (status != null) {
      query.where(purchasesTable.status.equals(status));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }
}
