import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_deltas_table.dart';

part 'stock_deltas_dao.g.dart';

/// DAO لتتبع تغييرات المخزون (Delta Sync)
/// يسجل كل تغيير في المخزون كدلتا بدلاً من القيمة المطلقة
@DriftAccessor(tables: [StockDeltasTable])
class StockDeltasDao extends DatabaseAccessor<AppDatabase>
    with _$StockDeltasDaoMixin {
  StockDeltasDao(super.db);

  /// إضافة تغيير مخزون جديد
  ///
  /// [productId] is nullable because the FK uses SET NULL on product delete,
  /// but callers should always pass a non-null value for new deltas.
  Future<int> addDelta({
    required String id,
    required String productId,
    required String storeId,
    String? orgId,
    required double quantityChange,
    required String deviceId,
    required String operationType,
    String? referenceId,
  }) {
    return into(stockDeltasTable).insert(
      StockDeltasTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        orgId: Value(orgId),
        quantityChange: quantityChange,
        deviceId: deviceId,
        operationType: operationType,
        referenceId: Value(referenceId),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// الحصول على التغييرات غير المزامنة
  Future<List<StockDeltasTableData>> getPendingDeltas({int limit = 100}) {
    return (select(stockDeltasTable)
          ..where((t) => t.syncStatus.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// الحصول على التغييرات غير المزامنة لمتجر معين
  Future<List<StockDeltasTableData>> getPendingDeltasForStore(
    String storeId, {
    int limit = 100,
  }) {
    return (select(stockDeltasTable)
          ..where(
            (t) => t.syncStatus.equals('pending') & t.storeId.equals(storeId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// عدد التغييرات غير المزامنة
  Future<int> getPendingCount() async {
    final result = await customSelect(
      "SELECT COUNT(*) as count FROM stock_deltas WHERE sync_status = 'pending'",
      readsFrom: {stockDeltasTable},
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  /// تعيين مجموعة تغييرات كـ "تمت المزامنة"
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = ids.map((_) => '?').join(',');
    await customUpdate(
      'UPDATE stock_deltas SET sync_status = ?, synced_at = ? WHERE id IN ($placeholders)',
      variables: [
        const Variable('synced'),
        Variable.withDateTime(DateTime.now().toUtc()),
        ...ids.map(Variable.withString),
      ],
      updates: {stockDeltasTable},
      updateKind: UpdateKind.update,
    );
  }

  /// تعيين مجموعة تغييرات كـ "فشل"
  Future<void> markFailed(List<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = ids.map((_) => '?').join(',');
    await customUpdate(
      'UPDATE stock_deltas SET sync_status = ? WHERE id IN ($placeholders)',
      variables: [const Variable('failed'), ...ids.map(Variable.withString)],
      updates: {stockDeltasTable},
      updateKind: UpdateKind.update,
    );
  }

  /// إعادة محاولة التغييرات الفاشلة
  Future<void> retryFailed() async {
    await customUpdate(
      "UPDATE stock_deltas SET sync_status = 'pending' WHERE sync_status = 'failed'",
      updates: {stockDeltasTable},
      updateKind: UpdateKind.update,
    );
  }

  /// حذف التغييرات المزامنة القديمة
  Future<int> cleanupSynced({Duration olderThan = const Duration(days: 7)}) {
    final cutoff = DateTime.now().toUtc().subtract(olderThan);
    return (delete(stockDeltasTable)..where(
          (t) =>
              t.syncStatus.equals('synced') &
              t.syncedAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  /// الحصول على ملخص التغييرات لكل منتج (للعرض في الواجهة)
  Future<List<Map<String, dynamic>>> getDeltaSummaryByProduct(
    String storeId,
  ) async {
    final results = await customSelect(
      '''SELECT product_id,
              SUM(quantity_change) as total_change,
              COUNT(*) as delta_count,
              MAX(created_at) as last_change
         FROM stock_deltas
         WHERE store_id = ? AND sync_status = 'pending'
         GROUP BY product_id''',
      variables: [Variable.withString(storeId)],
      readsFrom: {stockDeltasTable},
    ).get();
    return results.map((r) => r.data).toList();
  }

  /// مراقبة عدد التغييرات غير المزامنة
  Stream<int> watchPendingCount() {
    return customSelect(
      "SELECT COUNT(*) as count FROM stock_deltas WHERE sync_status = 'pending'",
      readsFrom: {stockDeltasTable},
    ).map((row) => row.data['count'] as int? ?? 0).watchSingle();
  }
}
