import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'sales_table.dart';
import 'customers_table.dart';
import 'products_table.dart';

/// جدول المرتجعات
@TableIndex(name: 'idx_returns_store_id', columns: {#storeId})
@TableIndex(name: 'idx_returns_sale_id', columns: {#saleId})
@TableIndex(name: 'idx_returns_status', columns: {#status})
@TableIndex(name: 'idx_returns_created_at', columns: {#createdAt})
@TableIndex(
  name: 'idx_returns_store_number_unique',
  columns: {#storeId, #returnNumber},
  unique: true,
)
class ReturnsTable extends Table {
  @override
  String get tableName => 'returns';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get returnNumber => text()();
  TextColumn get saleId =>
      text().references(SalesTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get storeId =>
      text().references(StoresTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get customerId => text().nullable().references(
    CustomersTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get customerName => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get type =>
      text().withDefault(const Constant('full'))(); // full, partial
  TextColumn get refundMethod => text().withDefault(const Constant('cash'))();
  // C-4 Session 4: totalRefund is int cents (ROUND_HALF_UP).
  IntColumn get totalRefund => integer()();
  TextColumn get status => text().withDefault(const Constant('completed'))();

  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

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
  TextColumn get returnId =>
      text().references(ReturnsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get saleItemId => text().nullable()();
  TextColumn get productId =>
      text().references(ProductsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get productName => text()();
  // C-4 Session 4: return_items money cols are int cents; qty stays Real.
  RealColumn get qty => real()();
  IntColumn get unitPrice => integer()();
  IntColumn get refundAmount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
