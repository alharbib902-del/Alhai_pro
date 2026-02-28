import 'package:drift/drift.dart';

/// جدول بيانات المتاجر/الفروع
@TableIndex(name: 'idx_stores_is_active', columns: {#isActive})
class StoresTable extends Table {
  @override
  String get tableName => 'stores';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialReg => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Riyadh'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
