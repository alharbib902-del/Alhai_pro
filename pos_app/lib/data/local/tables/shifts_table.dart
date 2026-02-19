import 'package:drift/drift.dart';

/// جدول الورديات
@TableIndex(name: 'idx_shifts_store_id', columns: {#storeId})
@TableIndex(name: 'idx_shifts_cashier_id', columns: {#cashierId})
@TableIndex(name: 'idx_shifts_status', columns: {#status})
@TableIndex(name: 'idx_shifts_opened_at', columns: {#openedAt})
class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get terminalId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get cashierName => text()();
  RealColumn get openingCash => real().withDefault(const Constant(0))();
  RealColumn get closingCash => real().nullable()();
  RealColumn get expectedCash => real().nullable()();
  RealColumn get difference => real().nullable()();
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  RealColumn get totalSalesAmount => real().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  RealColumn get totalRefundsAmount => real().withDefault(const Constant(0))();
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
  RealColumn get amount => real()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
