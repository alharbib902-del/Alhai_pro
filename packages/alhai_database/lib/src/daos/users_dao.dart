import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

/// DAO for users and roles
@DriftAccessor(tables: [UsersTable, RolesTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<UsersTableData>> getAllUsers(String storeId) {
    return (select(usersTable)
          ..where((u) => u.storeId.equals(storeId) & u.deletedAt.isNull())
          ..orderBy([(u) => OrderingTerm.asc(u.name)]))
        .get();
  }

  Future<List<UsersTableData>> getActiveUsers(String storeId) {
    return (select(usersTable)
          ..where((u) =>
              u.storeId.equals(storeId) &
              u.isActive.equals(true) &
              u.deletedAt.isNull())
          ..orderBy([(u) => OrderingTerm.asc(u.name)]))
        .get();
  }

  Future<UsersTableData?> getUserById(String id) =>
      (select(usersTable)
            ..where((u) => u.id.equals(id) & u.deletedAt.isNull()))
          .getSingleOrNull();
  Future<UsersTableData?> getUserByPhone(String phone) => (select(usersTable)
        ..where((u) => u.phone.equals(phone) & u.deletedAt.isNull()))
      .getSingleOrNull();

  /// ⚠️ SECURITY NOTE (P0-1, P1-7): this method does a **plaintext** PIN
  /// compare against the stored `users.pin` column. It MUST NOT be used
  /// as the primary security gate for any approval flow — call
  /// [PinService.verifyPin] (PBKDF2 + lockout) FIRST, and use this DAO
  /// method only as a SECONDARY identification step ("which user record
  /// matches this verified PIN?") for audit attribution.
  ///
  /// The legacy plaintext PIN column is scheduled for replacement in a
  /// future wave (per-user hashed PIN with per-user lockout counters,
  /// migration TBD). Until then, treat any new caller of this method
  /// with high suspicion in code review.
  Future<UsersTableData?> verifyPin(String storeId, String pin) {
    return (select(usersTable)..where(
          (u) =>
              u.storeId.equals(storeId) &
              u.pin.equals(pin) &
              u.isActive.equals(true) &
              u.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// P1-7 (Wave 9b plan, 2026-04-26): non-admin readers of the user
  /// list must not pull `email` / `phone` over the wire. Today every
  /// caller uses [getAllUsers] which returns the full row including
  /// PII; the UI masks display, but the data still rides in memory.
  ///
  /// Defense-in-depth target:
  ///   1. **Server-side**: REVOKE column-level SELECT on
  ///      `users.email` / `users.phone` from `authenticated`, force
  ///      reads through `get_user_pii(p_user_id)` RPC (already added
  ///      in Wave 9 migration v81 for the single-user fetch path).
  ///      For list views, add `get_users_safe(p_store_id)` RPC that
  ///      strips PII server-side based on the caller's role.
  ///   2. **Client-side**: replace `getAllUsers` calls in non-admin
  ///      surfaces with a `getUsersListSafe(storeId)` method that
  ///      doesn't project the PII columns. Existing admin surfaces
  ///      keep [getAllUsers].
  ///
  /// Until v9b ships, the client-side UI mask in
  /// `users_permissions_screen._showUserDetail` is the only barrier —
  /// safe under normal use, but a curious cashier with debug tooling
  /// could read the in-memory `_UserInfo` objects.
  // TODO(wave-9b): implement getUsersListSafe + run migration v82
  // (REVOKE columns) once admin surfaces are migrated to the new RPC.

  Future<int> insertUser(UsersTableCompanion user) =>
      into(usersTable).insert(user);

  /// إدراج أو تحديث مستخدم (UPSERT) - يمنع FOREIGN KEY errors
  Future<int> ensureUser(UsersTableCompanion user) =>
      into(usersTable).insertOnConflictUpdate(user);
  Future<bool> updateUser(UsersTableData user) =>
      update(usersTable).replace(user);
  Future<int> deleteUser(String id) =>
      (delete(usersTable)..where((u) => u.id.equals(id))).go();

  Future<int> updateLastLogin(String id) {
    return (update(usersTable)..where((u) => u.id.equals(id))).write(
      UsersTableCompanion(
        lastLoginAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<UsersTableData>> watchUsers(String storeId) {
    return (select(usersTable)
          ..where((u) => u.storeId.equals(storeId) & u.deletedAt.isNull())
          ..orderBy([(u) => OrderingTerm.asc(u.name)]))
        .watch();
  }

  Future<int> markUserAsSynced(String id) {
    return (update(usersTable)..where((u) => u.id.equals(id))).write(
      UsersTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  // Roles
  Future<List<RolesTableData>> getAllRoles(String storeId) {
    return (select(rolesTable)
          ..where((r) => r.storeId.equals(storeId))
          ..orderBy([(r) => OrderingTerm.asc(r.name)]))
        .get();
  }

  Future<RolesTableData?> getRoleById(String id) =>
      (select(rolesTable)..where((r) => r.id.equals(id))).getSingleOrNull();
  Future<int> insertRole(RolesTableCompanion role) =>
      into(rolesTable).insert(role);
  Future<bool> updateRole(RolesTableData role) =>
      update(rolesTable).replace(role);
  Future<int> deleteRole(String id) =>
      (delete(rolesTable)..where((r) => r.id.equals(id))).go();
}
