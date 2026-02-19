import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stores_table.dart';

part 'stores_dao.g.dart';

/// DAO for stores
@DriftAccessor(tables: [StoresTable])
class StoresDao extends DatabaseAccessor<AppDatabase> with _$StoresDaoMixin {
  StoresDao(super.db);

  Future<List<StoresTableData>> getAllStores() {
    return (select(storesTable)..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
  }

  Future<List<StoresTableData>> getActiveStores() {
    return (select(storesTable)..where((s) => s.isActive.equals(true))..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
  }

  Future<StoresTableData?> getStoreById(String id) {
    return (select(storesTable)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertStore(StoresTableCompanion store) => into(storesTable).insert(store);
  Future<bool> updateStore(StoresTableData store) => update(storesTable).replace(store);
  Future<int> deleteStore(String id) => (delete(storesTable)..where((s) => s.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(storesTable)..where((s) => s.id.equals(id))).write(StoresTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Stream<List<StoresTableData>> watchStores() {
    return (select(storesTable)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();
  }
}
