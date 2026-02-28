import 'package:drift/drift.dart';

/// جدول عمليات الجرد
@TableIndex(name: 'idx_stock_takes_store_id', columns: {#storeId})
@TableIndex(name: 'idx_stock_takes_status', columns: {#status})
class StockTakesTable extends Table {
  @override
  String get tableName => 'stock_takes';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  TextColumn get items => text().withDefault(const Constant('[]'))();
  IntColumn get totalItems => integer().withDefault(const Constant(0))();
  IntColumn get countedItems => integer().withDefault(const Constant(0))();
  IntColumn get varianceItems => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
