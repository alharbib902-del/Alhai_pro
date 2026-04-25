import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'products_table.dart';

/// جدول حركات المخزون
///
/// Indexes:
/// - idx_inventory_product_id: للاستعلامات حسب المنتج
/// - idx_inventory_store_id: للاستعلامات حسب المتجر
/// - idx_inventory_created_at: للتقارير حسب التاريخ
/// - idx_inventory_type: للفلترة حسب نوع الحركة
/// - idx_inventory_reference: للربط بالمستندات المرجعية
@TableIndex(name: 'idx_inventory_product_id', columns: {#productId})
@TableIndex(name: 'idx_inventory_store_id', columns: {#storeId})
@TableIndex(name: 'idx_inventory_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_inventory_type', columns: {#type})
@TableIndex(
  name: 'idx_inventory_reference',
  columns: {#referenceType, #referenceId},
)
@TableIndex(name: 'idx_inventory_synced_at', columns: {#syncedAt})
class InventoryMovementsTable extends Table {
  @override
  String get tableName => 'inventory_movements';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get productId => text().references(ProductsTable, #id)();
  TextColumn get storeId => text().references(StoresTable, #id)();

  // نوع الحركة. Wave 7 (P0-19): the canonical enum is
  // {receive, adjust, transfer_in, transfer_out, wastage, stock_take,
  //  return, sale, void}. Old rows ('purchase', 'addition',
  // 'subtraction', 'adjustment') are remapped at migration v48.
  // Application-level validation lives in `kInventoryMovementTypes`
  // (alhai_database) — SQLite ALTER TABLE can't add a CHECK constraint
  // in place, and the table-copy pattern is heavier than the safety
  // we'd buy with it given we own every write path.
  TextColumn get type => text()();

  // الكميات
  RealColumn get qty => real()(); // موجب أو سالب
  RealColumn get previousQty => real()();
  RealColumn get newQty => real()();

  // Wave 7 (P0-21): unit cost in int cents at the time of the
  // movement. Null on legacy rows (pre-v48) and on movements where
  // a cost makes no sense (sale / void / transfer_out — these draw
  // down stock at whatever cost was already on the product). The
  // `receive` flow uses this to compute weighted-average product cost
  // via `productsDao.applyReceiveAndRecomputeCost`.
  IntColumn get unitCostCents => integer().nullable()();

  // المرجع
  TextColumn get referenceType =>
      text().nullable()(); // sale, purchase_order, adjustment
  TextColumn get referenceId => text().nullable()();

  // السبب والملاحظات
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();

  // المستخدم
  TextColumn get userId => text().nullable()();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
