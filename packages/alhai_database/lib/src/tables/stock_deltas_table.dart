import 'package:drift/drift.dart';

import 'products_table.dart';
import 'stores_table.dart';

/// جدول تتبع تغييرات المخزون لكل جهاز (Delta Sync)
/// بدلاً من إرسال القيمة المطلقة للمخزون، نسجل التغييرات (الدلتا)
/// هذا يحل مشكلة التعارض عند وجود أجهزة متعددة
///
/// مثال: جهاز 1 يبيع 3 قطع، جهاز 2 يبيع 2 قطع
/// الدلتا: [{qty: -3, device: 1}, {qty: -2, device: 2}]
/// السيرفر يطبق كل التغييرات ويرجع المخزون النهائي
///
/// Foreign Keys:
/// - productId -> ProductsTable.id (SET NULL on delete, so deltas survive product deletion)
/// - storeId -> StoresTable.id (RESTRICT on delete, store must not be deleted with deltas)
///
/// Indexes:
/// - idx_stock_deltas_product: للاستعلام حسب المنتج
/// - idx_stock_deltas_sync_status: للحصول على التغييرات غير المزامنة
/// - idx_stock_deltas_device: للاستعلام حسب الجهاز
@TableIndex(name: 'idx_stock_deltas_product', columns: {#productId})
@TableIndex(name: 'idx_stock_deltas_sync_status', columns: {#syncStatus})
@TableIndex(name: 'idx_stock_deltas_device', columns: {#deviceId})
@TableIndex(
    name: 'idx_stock_deltas_product_sync',
    columns: {#productId, #syncStatus})
class StockDeltasTable extends Table {
  @override
  String get tableName => 'stock_deltas';

  /// معرف فريد للتغيير
  TextColumn get id => text()();

  /// معرف المنتج (FK -> products.id, SET NULL on delete)
  TextColumn get productId => text()
      .nullable()
      .references(ProductsTable, #id, onDelete: KeyAction.setNull)();

  /// معرف المتجر (FK -> stores.id, RESTRICT on delete)
  TextColumn get storeId => text()
      .references(StoresTable, #id, onDelete: KeyAction.restrict)();

  /// معرف المؤسسة
  TextColumn get orgId => text().nullable()();

  /// التغيير في الكمية (موجب للإضافة، سالب للنقصان)
  RealColumn get quantityChange => real()();

  /// معرف الجهاز (POS terminal) الذي أجرى التغيير
  TextColumn get deviceId => text()();

  /// نوع العملية التي سببت التغيير
  TextColumn get operationType => text()(); // sale, return, adjustment, purchase

  /// معرف العملية المرجعية (sale_id, return_id, etc.)
  TextColumn get referenceId => text().nullable()();

  /// حالة المزامنة
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))(); // pending, synced, failed

  /// وقت إنشاء التغيير
  DateTimeColumn get createdAt => dateTime()();

  /// وقت المزامنة
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
