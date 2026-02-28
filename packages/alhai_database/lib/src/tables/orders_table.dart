import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'customers_table.dart';

/// جدول الطلبات من تطبيق العملاء
///
/// Local-only delivery columns (not synced to Supabase orders table):
/// - [deliveryLat], [deliveryLng]: GPS coordinates stored locally for map display
/// - [driverId]: local driver assignment, managed separately in Supabase
/// - [deliveringAt], [deliveredAt]: local delivery timestamp tracking
/// - [cancelReason]: local-only; Supabase tracks cancellation in a separate audit log
/// - [syncedAt], [deletedAt]: local sync bookkeeping columns
///
/// Indexes:
/// - idx_orders_store_id: للاستعلامات حسب المتجر
/// - idx_orders_customer_id: للاستعلامات حسب العميل
/// - idx_orders_status: لفلترة حسب الحالة
/// - idx_orders_order_date: للاستعلامات حسب التاريخ
/// - idx_orders_store_status: استعلام مركب للمتجر والحالة
/// - idx_orders_synced_at: للمزامنة
@TableIndex(name: 'idx_orders_store_id', columns: {#storeId})
@TableIndex(name: 'idx_orders_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_orders_status', columns: {#status})
@TableIndex(name: 'idx_orders_order_date', columns: {#orderDate})
@TableIndex(name: 'idx_orders_store_status', columns: {#storeId, #status})
@TableIndex(name: 'idx_orders_synced_at', columns: {#syncedAt})
@TableIndex(name: 'idx_orders_store_number_unique', columns: {#storeId, #orderNumber}, unique: true)
class OrdersTable extends Table {
  @override
  String get tableName => 'orders';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().references(StoresTable, #id)();
  TextColumn get customerId => text().nullable().references(CustomersTable, #id)();
  
  // معلومات الطلب
  TextColumn get orderNumber => text()(); // ORD-YYYYMMDD-XXX
  TextColumn get channel => text().withDefault(const Constant('app'))(); // app, pos
  TextColumn get status => text().withDefault(const Constant('created'))();
  // created, confirmed, preparing, ready, out_for_delivery, delivered, picked_up, completed, cancelled, refunded
  
  // المبالغ
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get deliveryFee => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  
  // الدفع
  TextColumn get paymentMethod => text().nullable()(); // cash, card, online
  TextColumn get paymentStatus => text().withDefault(const Constant('pending'))();
  // pending, paid, refunded
  
  // التوصيل
  TextColumn get deliveryType => text().withDefault(const Constant('delivery'))();
  // delivery, pickup
  TextColumn get deliveryAddress => text().nullable()();
  RealColumn get deliveryLat => real().nullable()();
  RealColumn get deliveryLng => real().nullable()();
  TextColumn get driverId => text().nullable()();
  
  // الملاحظات
  TextColumn get notes => text().nullable()();
  TextColumn get cancelReason => text().nullable()();
  
  // التواريخ
  DateTimeColumn get orderDate => dateTime()();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  DateTimeColumn get preparingAt => dateTime().nullable()();
  DateTimeColumn get readyAt => dateTime().nullable()();
  DateTimeColumn get deliveringAt => dateTime().nullable()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  
  // المزامنة
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
