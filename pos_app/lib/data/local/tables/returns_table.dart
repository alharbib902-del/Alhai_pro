import 'package:drift/drift.dart';

/// جدول المرتجعات
@TableIndex(name: 'idx_returns_store_id', columns: {#storeId})
@TableIndex(name: 'idx_returns_sale_id', columns: {#saleId})
@TableIndex(name: 'idx_returns_status', columns: {#status})
@TableIndex(name: 'idx_returns_created_at', columns: {#createdAt})
class ReturnsTable extends Table {
  @override
  String get tableName => 'returns';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get returnNumber => text()();
  TextColumn get saleId => text()();
  TextColumn get storeId => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('full'))(); // full, partial
  TextColumn get refundMethod => text().withDefault(const Constant('cash'))();
  RealColumn get totalRefund => real()();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get createdBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول عناصر المرتجعات
@TableIndex(name: 'idx_return_items_return_id', columns: {#returnId})
@TableIndex(name: 'idx_return_items_product_id', columns: {#productId})
class ReturnItemsTable extends Table {
  @override
  String get tableName => 'return_items';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get returnId => text()();
  TextColumn get saleItemId => text().nullable()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get qty => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get refundAmount => real()();

  @override
  Set<Column> get primaryKey => {id};
}
