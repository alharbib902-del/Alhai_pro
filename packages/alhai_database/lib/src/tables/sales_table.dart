import 'package:drift/drift.dart';

import 'shifts_table.dart';
import 'stores_table.dart';
import 'users_table.dart';
import 'customers_table.dart';

/// جدول المبيعات/الفواتير المحلي (POS Sales)
///
/// Indexes:
/// - idx_sales_store_id: للاستعلامات حسب المتجر
/// - idx_sales_cashier_id: للاستعلامات حسب الكاشير
/// - idx_sales_created_at: للاستعلامات حسب التاريخ
/// - idx_sales_status: لفلترة حسب الحالة
/// - idx_sales_synced_at: للمزامنة
/// - idx_sales_store_status_created: للفلترة المركبة حسب المتجر والحالة والتاريخ
@TableIndex(name: 'idx_sales_store_id', columns: {#storeId})
@TableIndex(name: 'idx_sales_cashier_id', columns: {#cashierId})
@TableIndex(name: 'idx_sales_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_sales_status', columns: {#status})
@TableIndex(name: 'idx_sales_synced_at', columns: {#syncedAt})
@TableIndex(name: 'idx_sales_store_created', columns: {#storeId, #createdAt})
@TableIndex(name: 'idx_sales_store_status_created', columns: {#storeId, #status, #createdAt})
@TableIndex(name: 'idx_sales_store_receipt_unique', columns: {#storeId, #receiptNo}, unique: true)
class SalesTable extends Table {
  @override
  String get tableName => 'sales';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get receiptNo => text()();
  TextColumn get storeId => text().references(StoresTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get cashierId => text().references(UsersTable, #id, onDelete: KeyAction.restrict)();
  TextColumn get terminalId => text().nullable()();
  TextColumn get shiftId => text().nullable().references(ShiftsTable, #id, onDelete: KeyAction.setNull)();

  // العميل (اختياري)
  TextColumn get customerId => text().nullable().references(CustomersTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  
  // المبالغ
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  
  // الدفع
  TextColumn get paymentMethod => text()(); // cash, card, mixed, credit
  BoolColumn get isPaid => boolean().withDefault(const Constant(true))();
  RealColumn get amountReceived => real().nullable()();
  RealColumn get changeAmount => real().nullable()();

  // تفصيل مبالغ الدفع (للدفع المختلط والتقارير)
  RealColumn get cashAmount => real().nullable()();   // المبلغ النقدي
  RealColumn get cardAmount => real().nullable()();   // مبلغ البطاقة
  RealColumn get creditAmount => real().nullable()();  // المبلغ الآجل
  
  // معلومات إضافية
  TextColumn get notes => text().nullable()();
  TextColumn get channel => text().withDefault(const Constant('POS'))(); // POS, ONLINE
  
  // الحالة
  TextColumn get status => text().withDefault(const Constant('completed'))(); // completed, voided, refunded
  
  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
