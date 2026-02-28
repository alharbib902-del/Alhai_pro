import 'package:drift/drift.dart';

/// جدول تحويلات المخزون بين الفروع
@TableIndex(name: 'idx_stock_transfers_from_store', columns: {#fromStoreId})
@TableIndex(name: 'idx_stock_transfers_to_store', columns: {#toStoreId})
@TableIndex(name: 'idx_stock_transfers_status', columns: {#status})
class StockTransfersTable extends Table {
  @override
  String get tableName => 'stock_transfers';

  TextColumn get id => text()();
  TextColumn get transferNumber => text()();
  TextColumn get fromStoreId => text()();
  TextColumn get toStoreId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, approved, in_transit, completed, cancelled
  TextColumn get items => text()(); // JSON array
  TextColumn get notes => text().nullable()();
  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();
  TextColumn get approvedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
