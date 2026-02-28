import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/returns_table.dart';

part 'returns_dao.g.dart';

/// DAO for returns
@DriftAccessor(tables: [ReturnsTable, ReturnItemsTable])
class ReturnsDao extends DatabaseAccessor<AppDatabase> with _$ReturnsDaoMixin {
  ReturnsDao(super.db);

  Future<List<ReturnsTableData>> getAllReturns(String storeId) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();
  }

  Future<List<ReturnsTableData>> getReturnsByDateRange(String storeId, DateTime startDate, DateTime endDate) {
    return (select(returnsTable)..where((r) => r.storeId.equals(storeId) & r.createdAt.isBiggerOrEqualValue(startDate) & r.createdAt.isSmallerThanValue(endDate))..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();
  }

  Future<ReturnsTableData?> getReturnById(String id) => (select(returnsTable)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<ReturnsTableData>> getReturnsBySaleId(String saleId) {
    return (select(returnsTable)..where((r) => r.saleId.equals(saleId))).get();
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
}
