// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizations_dao.dart';

// ignore_for_file: type=lint
mixin _$OrganizationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTableTable get organizationsTable =>
      attachedDatabase.organizationsTable;
  $SubscriptionsTableTable get subscriptionsTable =>
      attachedDatabase.subscriptionsTable;
  $OrgMembersTableTable get orgMembersTable => attachedDatabase.orgMembersTable;
  OrganizationsDaoManager get managers => OrganizationsDaoManager(this);
}

class OrganizationsDaoManager {
  final _$OrganizationsDaoMixin _db;
  OrganizationsDaoManager(this._db);
  $$OrganizationsTableTableTableManager get organizationsTable =>
      $$OrganizationsTableTableTableManager(
          _db.attachedDatabase, _db.organizationsTable);
  $$SubscriptionsTableTableTableManager get subscriptionsTable =>
      $$SubscriptionsTableTableTableManager(
          _db.attachedDatabase, _db.subscriptionsTable);
  $$OrgMembersTableTableTableManager get orgMembersTable =>
      $$OrgMembersTableTableTableManager(
          _db.attachedDatabase, _db.orgMembersTable);
}
