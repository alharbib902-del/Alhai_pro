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

  // نوع الحركة
  TextColumn get type =>
      text()(); // sale, purchase, adjustment, return, transfer, waste

  // الكميات
  RealColumn get qty => real()(); // موجب أو سالب
  RealColumn get previousQty => real()();
  RealColumn get newQty => real()();

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
