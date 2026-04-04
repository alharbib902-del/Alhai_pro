import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'accounts_table.dart';

/// جدول حركات الحسابات (المدفوعات والفوائد والفواتير)
///
/// Indexes:
/// - idx_transactions_store_id: للاستعلامات حسب المتجر
/// - idx_transactions_account_id: للاستعلامات حسب الحساب
/// - idx_transactions_type: لفلترة حسب النوع
/// - idx_transactions_created_at: للاستعلامات حسب التاريخ
/// - idx_transactions_synced_at: للمزامنة
@TableIndex(name: 'idx_transactions_store_id', columns: {#storeId})
@TableIndex(name: 'idx_transactions_account_id', columns: {#accountId})
@TableIndex(name: 'idx_transactions_type', columns: {#type})
@TableIndex(name: 'idx_transactions_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_transactions_synced_at', columns: {#syncedAt})
class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get storeId => text().references(StoresTable, #id)();
  TextColumn get accountId => text().references(AccountsTable, #id)();

  // نوع الحركة
  TextColumn get type => text()(); // invoice, payment, interest, adjustment

  // المبلغ والوصف
  RealColumn get amount => real()();
  RealColumn get balanceAfter => real()(); // الرصيد بعد الحركة
  TextColumn get description => text().nullable()();

  // مرجع خارجي
  TextColumn get referenceId => text().nullable()(); // saleId, purchaseId, etc
  TextColumn get referenceType => text().nullable()(); // sale, purchase

  // فترة الفائدة (للفوائد الشهرية)
  TextColumn get periodKey => text().nullable()(); // YYYY-MM format

  // طريقة الدفع (للمدفوعات)
  TextColumn get paymentMethod => text().nullable()(); // cash, card, transfer

  // المستخدم
  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
