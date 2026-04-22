import 'package:drift/drift.dart';

/// جدول الورديات
@TableIndex(name: 'idx_shifts_store_id', columns: {#storeId})
@TableIndex(name: 'idx_shifts_cashier_id', columns: {#cashierId})
@TableIndex(name: 'idx_shifts_status', columns: {#status})
@TableIndex(name: 'idx_shifts_opened_at', columns: {#openedAt})
@TableIndex(
  name: 'idx_shifts_store_cashier_status',
  columns: {#storeId, #cashierId, #status},
)
class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get terminalId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get cashierName => text()();
  // C-4 Session 3: shifts money columns are int cents (ROUND_HALF_UP).
  // totalSales and totalRefunds are count columns — already int.
  IntColumn get openingCash => integer().withDefault(const Constant(0))();
  IntColumn get closingCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  IntColumn get difference => integer().nullable()();
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  IntColumn get totalSalesAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  IntColumn get totalRefundsAmount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول حركات الصندوق
@TableIndex(name: 'idx_cash_movements_shift_id', columns: {#shiftId})
@TableIndex(name: 'idx_cash_movements_store_id', columns: {#storeId})
@TableIndex(name: 'idx_cash_movements_created_at', columns: {#createdAt})
class CashMovementsTable extends Table {
  @override
  String get tableName => 'cash_movements';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get shiftId => text()();
  TextColumn get storeId => text()();
  TextColumn get type => text()(); // in, out
  // C-4 Session 3: amount is int cents (ROUND_HALF_UP).
  IntColumn get amount => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();

  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
