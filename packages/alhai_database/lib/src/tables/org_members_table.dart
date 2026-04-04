import 'package:drift/drift.dart';

@TableIndex(name: 'idx_org_members_org_id', columns: {#orgId})
@TableIndex(name: 'idx_org_members_user_id', columns: {#userId})
@TableIndex(
    name: 'idx_org_members_org_user_unique',
    columns: {#orgId, #userId},
    unique: true)
class OrgMembersTable extends Table {
  @override
  String get tableName => 'org_members';

  TextColumn get id => text()();
  TextColumn get orgId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('staff'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get invitedBy => text().nullable()();
  DateTimeColumn get invitedAt => dateTime().nullable()();
  DateTimeColumn get joinedAt => dateTime().nullable()();
  TextColumn get storeId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_user_stores_user_id', columns: {#userId})
@TableIndex(name: 'idx_user_stores_store_id', columns: {#storeId})
@TableIndex(
    name: 'idx_user_stores_user_store_unique',
    columns: {#userId, #storeId},
    unique: true)
class UserStoresTable extends Table {
  @override
  String get tableName => 'user_stores';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get storeId => text()();
  TextColumn get role => text().withDefault(const Constant('cashier'))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
