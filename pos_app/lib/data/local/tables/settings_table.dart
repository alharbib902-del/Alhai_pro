import 'package:drift/drift.dart';

/// جدول الإعدادات
@TableIndex(name: 'idx_settings_store_key', columns: {#storeId, #key})
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
