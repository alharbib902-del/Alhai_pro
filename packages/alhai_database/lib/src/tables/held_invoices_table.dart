import 'package:drift/drift.dart';

/// جدول الفواتير المعلقة
@TableIndex(name: 'idx_held_invoices_store_id', columns: {#storeId})
@TableIndex(name: 'idx_held_invoices_cashier_id', columns: {#cashierId})
class HeldInvoicesTable extends Table {
  @override
  String get tableName => 'held_invoices';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get cashierId => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get items => text()(); // JSON array of cart items
  // C-4 Session 2: money columns are int cents (ROUND_HALF_UP).
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get total => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get orgId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
