import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'suppliers_table.dart';
import 'products_table.dart';

/// جدول أوامر الشراء
@TableIndex(name: 'idx_purchases_store_id', columns: {#storeId})
@TableIndex(name: 'idx_purchases_supplier_id', columns: {#supplierId})
@TableIndex(name: 'idx_purchases_status', columns: {#status})
@TableIndex(name: 'idx_purchases_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_purchases_store_number_unique', columns: {#storeId, #purchaseNumber}, unique: true)
class PurchasesTable extends Table {
  @override
  String get tableName => 'purchases';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().references(StoresTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get supplierId => text().nullable().references(SuppliersTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get supplierName => text().nullable()();
  TextColumn get purchaseNumber => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get paymentStatus => text().withDefault(const Constant('pending'))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول عناصر الشراء
@TableIndex(name: 'idx_purchase_items_purchase_id', columns: {#purchaseId})
@TableIndex(name: 'idx_purchase_items_product_id', columns: {#productId})
class PurchaseItemsTable extends Table {
  @override
  String get tableName => 'purchase_items';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get purchaseId => text().references(PurchasesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(ProductsTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get productName => text()();
  TextColumn get productBarcode => text().nullable()();
  RealColumn get qty => real()();
  RealColumn get receivedQty => real().withDefault(const Constant(0))();
  RealColumn get unitCost => real()();
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}
