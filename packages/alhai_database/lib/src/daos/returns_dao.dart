import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/returns_table.dart';

part 'returns_dao.g.dart';

/// DAO for returns
@DriftAccessor(tables: [ReturnsTable, ReturnItemsTable])
class ReturnsDao extends DatabaseAccessor<AppDatabase> with _$ReturnsDaoMixin {
  ReturnsDao(super.db);

  Future<List<ReturnsTableData>> getAllReturns(String storeId, {int limit = 1000}) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])..limit(limit)).get();
  }

  Future<List<ReturnsTableData>> getReturnsByStatus(String storeId, String status, {int limit = 1000}) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId) & r.status.equals(status))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])..limit(limit)).get();
  }

  Future<List<ReturnsTableData>> getReturnsByStatuses(String storeId, List<String> statuses, {int limit = 1000}) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId) & r.status.isIn(statuses))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])..limit(limit)).get();
  }

  Future<List<ReturnsTableData>> getReturnsByDateRange(String storeId, DateTime startDate, DateTime endDate, {int limit = 5000}) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId) & r.createdAt.isBiggerOrEqualValue(startDate) & r.createdAt.isSmallerThanValue(endDate))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])..limit(limit)).get();
  }

  Future<ReturnsTableData?> getReturnById(String id) => (select(returnsTable)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<ReturnsTableData>> getReturnsBySaleId(String saleId, String storeId) {
    return (select(returnsTable)..where((r) => r.saleId.equals(saleId) & r.storeId.equals(storeId))).get();
  }

  Future<int> insertReturn(ReturnsTableCompanion returnData) => into(returnsTable).insert(returnData);

  Future<int> markAsSynced(String id) {
    return (update(returnsTable)..where((r) => r.id.equals(id))).write(ReturnsTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<List<ReturnItemsTableData>> getReturnItems(String returnId) {
    return (select(returnItemsTable)..where((i) => i.returnId.equals(returnId))).get();
  }

  Future<void> insertReturnItems(List<ReturnItemsTableCompanion> items) async {
    await batch((b) { b.insertAll(returnItemsTable, items); });
  }

  /// مجموع المرتجعات النقدية فقط خلال فترة الوردية
  /// يُستخدم لحساب النقد المتوقع في الدرج
  Future<double> getCashRefundsTotalForPeriod(
    String storeId, {
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    var whereClause = "store_id = ? AND refund_method = 'cash' AND status = 'completed' AND created_at >= ?";
    final variables = <Variable>[
      Variable.withString(storeId),
      Variable.withDateTime(startDate),
    ];

    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect(
      'SELECT COALESCE(SUM(total_refund), 0) as total FROM returns WHERE $whereClause',
      variables: variables,
    ).getSingle();

    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total.toDouble();
    return total as double;
  }
}
