import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

/// DAO for suppliers
@DriftAccessor(tables: [SuppliersTable])
class SuppliersDao extends DatabaseAccessor<AppDatabase> with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  Future<List<SuppliersTableData>> getAllSuppliers(String storeId) {
    return (select(suppliersTable)..where((s) => s.storeId.equals(storeId))..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
  }

  Future<List<SuppliersTableData>> getActiveSuppliers(String storeId) {
    return (select(suppliersTable)..where((s) => s.storeId.equals(storeId) & s.isActive.equals(true))..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
  }

  Future<SuppliersTableData?> getSupplierById(String id) => (select(suppliersTable)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<SuppliersTableData>> searchSuppliers(String query, String storeId) {
    return (select(suppliersTable)..where((s) => s.storeId.equals(storeId) & (s.name.contains(query) | s.phone.contains(query)))..limit(20)).get();
  }

  Future<int> insertSupplier(SuppliersTableCompanion supplier) => into(suppliersTable).insert(supplier);
  Future<bool> updateSupplier(SuppliersTableData supplier) => update(suppliersTable).replace(supplier);

  Future<int> updateBalance(String id, double newBalance) {
    return (update(suppliersTable)..where((s) => s.id.equals(id))).write(SuppliersTableCompanion(balance: Value(newBalance), updatedAt: Value(DateTime.now())));
  }

  Future<int> deleteSupplier(String id) => (delete(suppliersTable)..where((s) => s.id.equals(id))).go();

  Future<int> markAsSynced(String id) {
    return (update(suppliersTable)..where((s) => s.id.equals(id))).write(SuppliersTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Stream<List<SuppliersTableData>> watchSuppliers(String storeId) {
    return (select(suppliersTable)..where((s) => s.storeId.equals(storeId))..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();
  }
}
