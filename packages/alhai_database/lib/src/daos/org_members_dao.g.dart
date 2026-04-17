// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_members_dao.dart';

// ignore_for_file: type=lint
mixin _$OrgMembersDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrgMembersTableTable get orgMembersTable => attachedDatabase.orgMembersTable;
  $UserStoresTableTable get userStoresTable => attachedDatabase.userStoresTable;
  OrgMembersDaoManager get managers => OrgMembersDaoManager(this);
}

class OrgMembersDaoManager {
  final _$OrgMembersDaoMixin _db;
  OrgMembersDaoManager(this._db);
  $$OrgMembersTableTableTableManager get orgMembersTable =>
      $$OrgMembersTableTableTableManager(
        _db.attachedDatabase,
        _db.orgMembersTable,
      );
  $$UserStoresTableTableTableManager get userStoresTable =>
      $$UserStoresTableTableTableManager(
        _db.attachedDatabase,
        _db.userStoresTable,
      );
}
