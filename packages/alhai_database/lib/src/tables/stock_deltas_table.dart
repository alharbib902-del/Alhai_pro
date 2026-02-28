import 'package:drift/drift.dart';

/// جدول تتبع تغييرات المخزون لكل جهاز (Delta Sync)
/// بدلاً من إرسال القيمة المطلقة للمخزون، نسجل التغييرات (الدلتا)
/// هذا يحل مشكلة التعارض عند وجود أجهزة متعددة
///
/// مثال: جهاز 1 يبيع 3 قطع، جهاز 2 يبيع 2 قطع
/// الدلتا: [{qty: -3, device: 1}, {qty: -2, device: 2}]
/// السيرفر يطبق كل التغييرات ويرجع المخزون النهائي
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

  /// معرف المنتج
  TextColumn get productId => text()();

  /// معرف المتجر
  TextColumn get storeId => text()();

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
