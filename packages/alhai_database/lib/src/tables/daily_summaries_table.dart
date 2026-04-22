import 'package:drift/drift.dart';

/// جدول الملخصات اليومية (للتقارير السريعة)
@TableIndex(name: 'idx_daily_summaries_store_id', columns: {#storeId})
@TableIndex(name: 'idx_daily_summaries_date', columns: {#date})
@TableIndex(name: 'idx_daily_summaries_store_date', columns: {#storeId, #date})
class DailySummariesTable extends Table {
  @override
  String get tableName => 'daily_summaries';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  DateTimeColumn get date => dateTime()();
  // C-4 Session 4: daily_summaries money columns are int cents (ROUND_HALF_UP).
  // Count columns (totalSales, totalOrders, totalRefunds) already int.
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  IntColumn get totalSalesAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalOrders => integer().withDefault(const Constant(0))();
  IntColumn get totalOrdersAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  IntColumn get totalRefundsAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalExpenses => integer().withDefault(const Constant(0))();
  IntColumn get cashTotal => integer().withDefault(const Constant(0))();
  IntColumn get cardTotal => integer().withDefault(const Constant(0))();
  IntColumn get creditTotal => integer().withDefault(const Constant(0))();
  IntColumn get netProfit => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
