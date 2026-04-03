import 'package:drift/drift.dart';

/// جدول المستخدمين والكاشير
@TableIndex(name: 'idx_users_store_id', columns: {#storeId})
@TableIndex(name: 'idx_users_phone', columns: {#phone})
@TableIndex(name: 'idx_users_is_active', columns: {#isActive})
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get pin => text().nullable()();
  TextColumn get authUid => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('cashier'))();
  TextColumn get roleId => text().nullable()();
  TextColumn get avatar => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول الأدوار والصلاحيات
@TableIndex(name: 'idx_roles_store_id', columns: {#storeId})
class RolesTable extends Table {
  @override
  String get tableName => 'roles';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get permissions => text().withDefault(const Constant('{}'))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
