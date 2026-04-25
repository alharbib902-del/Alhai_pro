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
          ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(500))
        .get();
  }

  Future<List<PurchasesTableData>> getPurchasesByStatus(
    String storeId,
    String status,
  ) {
    return (select(purchasesTable)
          ..where((p) =>
              p.storeId.equals(storeId) &
              p.status.equals(status) &
              p.deletedAt.isNull())
          ..limit(500))
        .get();
  }

  Future<PurchasesTableData?> getPurchaseById(String id) =>
      (select(purchasesTable)
            ..where((p) => p.id.equals(id) & p.deletedAt.isNull()))
          .getSingleOrNull();

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

  /// Optimistically flip a purchase from `approved` → `received`. The
  /// `status = approved` guard prevents double-receive races where two
  /// cashiers tap "استلام" almost simultaneously — the second
  /// UPDATE touches zero rows and the caller must bail out instead of
  /// silently re-adjusting stock a second time.
  ///
  /// Returns the number of rows affected: `1` on success, `0` if the
  /// purchase was already received (or never approved).
  Future<int> receivePurchase(String id) {
    return (update(purchasesTable)..where(
          (p) => p.id.equals(id) & p.status.equals('approved'),
        ))
        .write(
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

  /// P0-27: mark a purchase line as fully received. Sprint 1 fix —
  /// previously `purchase_items.received_qty` stayed at its `0` default
  /// even after the cashier confirmed receipt, so the column was
  /// effectively dead and partial-receive reports would always read as
  /// "nothing received".
  ///
  /// Called from inside the cashier_receiving transaction (one row per
  /// PO line), after `recordReceiveMovement` + `applyReceiveAndRecomputeCost`
  /// have updated stock + cost. Atomic together with those writes via
  /// the surrounding `_db.transaction(...)`.
  Future<int> markItemReceived({
    required String itemId,
    required double receivedQty,
  }) {
    return (update(purchaseItemsTable)..where((i) => i.id.equals(itemId)))
        .write(
      PurchaseItemsTableCompanion(receivedQty: Value(receivedQty)),
    );
  }

  // ── Pagination ─────────────────────────────────────────────────

  /// Paginated purchases (all statuses)
  Future<List<PurchasesTableData>> getPurchasesPaginated(
    String storeId, {
    int offset = 0,
    int limit = 20,
  }) {
    return (select(purchasesTable)
          ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
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
          ..where((p) =>
              p.storeId.equals(storeId) &
              p.status.equals(status) &
              p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Total count of purchases (for pagination controls)
  Future<int> getPurchasesCount(String storeId, {String? status}) async {
    final countExpr = purchasesTable.id.count();
    var query = selectOnly(purchasesTable)
      ..addColumns([countExpr])
      ..where(purchasesTable.storeId.equals(storeId) &
          purchasesTable.deletedAt.isNull());
    if (status != null) {
      query.where(purchasesTable.status.equals(status));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }
}
