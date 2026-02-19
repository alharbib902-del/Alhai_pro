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
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  RealColumn get totalSalesAmount => real().withDefault(const Constant(0))();
  IntColumn get totalOrders => integer().withDefault(const Constant(0))();
  RealColumn get totalOrdersAmount => real().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  RealColumn get totalRefundsAmount => real().withDefault(const Constant(0))();
  RealColumn get totalExpenses => real().withDefault(const Constant(0))();
  RealColumn get cashTotal => real().withDefault(const Constant(0))();
  RealColumn get cardTotal => real().withDefault(const Constant(0))();
  RealColumn get creditTotal => real().withDefault(const Constant(0))();
  RealColumn get netProfit => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
