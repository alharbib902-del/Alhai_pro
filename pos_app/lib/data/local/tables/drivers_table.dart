import 'package:drift/drift.dart';

/// جدول السائقين
@TableIndex(name: 'idx_drivers_store_id', columns: {#storeId})
@TableIndex(name: 'idx_drivers_is_active', columns: {#isActive})
class DriversTable extends Table {
  @override
  String get tableName => 'drivers';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get vehicleType => text().nullable()();
  TextColumn get vehiclePlate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('available'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
