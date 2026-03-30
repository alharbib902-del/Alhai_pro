import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

/// DAO for users and roles
@DriftAccessor(tables: [UsersTable, RolesTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<UsersTableData>> getAllUsers(String storeId) {
    return (select(usersTable)..where((u) => u.storeId.equals(storeId))..orderBy([(u) => OrderingTerm.asc(u.name)])).get();
  }

  Future<List<UsersTableData>> getActiveUsers(String storeId) {
    return (select(usersTable)..where((u) => u.storeId.equals(storeId) & u.isActive.equals(true))..orderBy([(u) => OrderingTerm.asc(u.name)])).get();
  }

  Future<UsersTableData?> getUserById(String id) => (select(usersTable)..where((u) => u.id.equals(id))).getSingleOrNull();
  Future<UsersTableData?> getUserByPhone(String phone) => (select(usersTable)..where((u) => u.phone.equals(phone))).getSingleOrNull();

  Future<UsersTableData?> verifyPin(String storeId, String pin) {
    return (select(usersTable)..where((u) => u.storeId.equals(storeId) & u.pin.equals(pin) & u.isActive.equals(true))).getSingleOrNull();
  }

  Future<int> insertUser(UsersTableCompanion user) => into(usersTable).insert(user);

  /// إدراج أو تحديث مستخدم (UPSERT) - يمنع FOREIGN KEY errors
  Future<int> ensureUser(UsersTableCompanion user) =>
      into(usersTable).insertOnConflictUpdate(user);
  Future<bool> updateUser(UsersTableData user) => update(usersTable).replace(user);
  Future<int> deleteUser(String id) => (delete(usersTable)..where((u) => u.id.equals(id))).go();

  Future<int> updateLastLogin(String id) {
    return (update(usersTable)..where((u) => u.id.equals(id))).write(UsersTableCompanion(lastLoginAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())));
  }

  Stream<List<UsersTableData>> watchUsers(String storeId) {
    return (select(usersTable)..where((u) => u.storeId.equals(storeId))..orderBy([(u) => OrderingTerm.asc(u.name)])).watch();
  }

  Future<int> markUserAsSynced(String id) {
    return (update(usersTable)..where((u) => u.id.equals(id))).write(UsersTableCompanion(syncedAt: Value(DateTime.now())));
  }

  // Roles
  Future<List<RolesTableData>> getAllRoles(String storeId) {
    return (select(rolesTable)..where((r) => r.storeId.equals(storeId))..orderBy([(r) => OrderingTerm.asc(r.name)])).get();
  }

  Future<RolesTableData?> getRoleById(String id) => (select(rolesTable)..where((r) => r.id.equals(id))).getSingleOrNull();
  Future<int> insertRole(RolesTableCompanion role) => into(rolesTable).insert(role);
  Future<bool> updateRole(RolesTableData role) => update(rolesTable).replace(role);
  Future<int> deleteRole(String id) => (delete(rolesTable)..where((r) => r.id.equals(id))).go();
}
