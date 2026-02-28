import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/org_members_table.dart';

part 'org_members_dao.g.dart';

@DriftAccessor(tables: [OrgMembersTable, UserStoresTable])
class OrgMembersDao extends DatabaseAccessor<AppDatabase>
    with _$OrgMembersDaoMixin {
  OrgMembersDao(super.db);

  // === Org Members ===

  Future<List<OrgMembersTableData>> getOrgMembers(String orgId) {
    return (select(orgMembersTable)
          ..where((m) => m.orgId.equals(orgId)))
        .get();
  }

  Stream<List<OrgMembersTableData>> watchOrgMembers(String orgId) {
    return (select(orgMembersTable)
          ..where((m) => m.orgId.equals(orgId)))
        .watch();
  }

  Future<OrgMembersTableData?> getMemberByUserId(
      String orgId, String userId) {
    return (select(orgMembersTable)
          ..where((m) =>
              m.orgId.equals(orgId) & m.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<int> upsertOrgMember(OrgMembersTableCompanion member) =>
      into(orgMembersTable)
          .insert(member, mode: InsertMode.insertOrReplace);

  Future<int> deleteOrgMember(String id) =>
      (delete(orgMembersTable)..where((m) => m.id.equals(id))).go();

  // === User Stores ===

  Future<List<UserStoresTableData>> getUserStores(String userId) {
    return (select(userStoresTable)
          ..where((us) => us.userId.equals(userId)))
        .get();
  }

  Stream<List<UserStoresTableData>> watchUserStores(String userId) {
    return (select(userStoresTable)
          ..where((us) => us.userId.equals(userId)))
        .watch();
  }

  Future<List<UserStoresTableData>> getStoreUsers(String storeId) {
    return (select(userStoresTable)
          ..where((us) => us.storeId.equals(storeId)))
        .get();
  }

  Future<int> upsertUserStore(UserStoresTableCompanion userStore) =>
      into(userStoresTable)
          .insert(userStore, mode: InsertMode.insertOrReplace);

  Future<int> deleteUserStore(String id) =>
      (delete(userStoresTable)..where((us) => us.id.equals(id))).go();
}
