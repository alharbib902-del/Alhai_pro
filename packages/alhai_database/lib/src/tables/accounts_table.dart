import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'customers_table.dart';
import 'suppliers_table.dart';

/// جدول حسابات العملاء والموردين
///
/// Indexes:
/// - idx_accounts_store_id: للاستعلامات حسب المتجر
/// - idx_accounts_type: لفلترة حسب النوع
/// - idx_accounts_customer_id: للاستعلامات حسب العميل
/// - idx_accounts_supplier_id: للاستعلامات حسب المورد
/// - idx_accounts_synced_at: للمزامنة
@TableIndex(name: 'idx_accounts_store_id', columns: {#storeId})
@TableIndex(name: 'idx_accounts_type', columns: {#type})
@TableIndex(name: 'idx_accounts_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_accounts_supplier_id', columns: {#supplierId})
@TableIndex(name: 'idx_accounts_synced_at', columns: {#syncedAt})
class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().references(StoresTable, #id)();

  // نوع الحساب
  TextColumn get type => text()(); // receivable (عميل), payable (مورد)

  // صاحب الحساب
  TextColumn get customerId =>
      text().nullable().references(CustomersTable, #id)();
  TextColumn get supplierId =>
      text().nullable().references(SuppliersTable, #id)();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();

  // الرصيد
  // C-4 Session 4: money columns are int cents (ROUND_HALF_UP).
  IntColumn get balance => integer().withDefault(const Constant(0))();
  IntColumn get creditLimit => integer().withDefault(const Constant(0))();

  // حالة الحساب
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // آخر حركة
  DateTimeColumn get lastTransactionAt => dateTime().nullable()();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
