import 'package:drift/drift.dart';

import 'customers_table.dart';
import 'stores_table.dart';
import 'sales_table.dart';
import 'users_table.dart';

/// جدول نقاط الولاء
///
/// Indexes:
/// - idx_loyalty_customer_id: للاستعلامات حسب العميل
/// - idx_loyalty_store_id: للاستعلامات حسب المتجر
/// - idx_loyalty_synced_at: للمزامنة
@TableIndex(name: 'idx_loyalty_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_loyalty_store_id', columns: {#storeId})
@TableIndex(name: 'idx_loyalty_synced_at', columns: {#syncedAt})
@TableIndex(
  name: 'idx_loyalty_customer_store_unique',
  columns: {#customerId, #storeId},
  unique: true,
)
class LoyaltyPointsTable extends Table {
  @override
  String get tableName => 'loyalty_points';

  /// معرف فريد
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();

  /// معرف العميل
  TextColumn get customerId => text().references(CustomersTable, #id)();

  /// معرف المتجر
  TextColumn get storeId => text().references(StoresTable, #id)();

  /// النقاط الحالية
  IntColumn get currentPoints => integer().withDefault(const Constant(0))();

  /// إجمالي النقاط المكتسبة
  IntColumn get totalEarned => integer().withDefault(const Constant(0))();

  /// إجمالي النقاط المستبدلة
  IntColumn get totalRedeemed => integer().withDefault(const Constant(0))();

  /// مستوى العميل: bronze, silver, gold, platinum
  TextColumn get tierLevel => text().withDefault(const Constant('bronze'))();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime()();

  /// تاريخ التحديث
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول سجل معاملات النقاط
///
/// Indexes:
/// - idx_loyalty_tx_loyalty_id: للاستعلامات حسب سجل الولاء
/// - idx_loyalty_tx_customer_id: للاستعلامات حسب العميل
/// - idx_loyalty_tx_store_id: للاستعلامات حسب المتجر
/// - idx_loyalty_tx_created_at: للاستعلامات حسب التاريخ
/// - idx_loyalty_tx_synced_at: للمزامنة
@TableIndex(name: 'idx_loyalty_tx_loyalty_id', columns: {#loyaltyId})
@TableIndex(name: 'idx_loyalty_tx_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_loyalty_tx_store_id', columns: {#storeId})
@TableIndex(name: 'idx_loyalty_tx_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_loyalty_tx_synced_at', columns: {#syncedAt})
class LoyaltyTransactionsTable extends Table {
  @override
  String get tableName => 'loyalty_transactions';

  /// معرف فريد
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();

  /// معرف سجل الولاء
  TextColumn get loyaltyId => text().references(LoyaltyPointsTable, #id)();

  /// معرف العميل
  TextColumn get customerId => text().references(CustomersTable, #id)();

  /// معرف المتجر
  TextColumn get storeId => text().references(StoresTable, #id)();

  /// نوع المعاملة: earn, redeem, expire, adjust
  TextColumn get transactionType => text()();

  /// عدد النقاط (موجب للاكتساب، سالب للاستبدال)
  IntColumn get points => integer()();

  /// الرصيد بعد المعاملة
  IntColumn get balanceAfter => integer()();

  /// معرف البيع المرتبط (اختياري)
  TextColumn get saleId => text().nullable().references(SalesTable, #id)();

  /// Sale amount that triggered the loyalty transaction. Optional — a
  /// manual points adjustment won't populate it.
  ///
  /// **C-4 convention deviation (deliberate, documented 2026-04-23).**
  /// This column is `REAL` (double SAR) while every other money column
  /// in the schema is `INTEGER` cents after the C-4 migration. The
  /// reason it wasn't migrated: no Dart code anywhere in the repo
  /// currently reads or writes `saleAmount`. It's a dormant reserved
  /// field. Migrating a never-written column to int cents would have
  /// risked breaking the Supabase schema on live tenants for zero
  /// behavioural benefit.
  ///
  /// **If you start writing this column**, write it as INTEGER cents
  /// (`(sar * 100).round()`) and simultaneously migrate both the Drift
  /// schema (bump `schemaVersion`, add a cast step) and the Supabase
  /// column (`ALTER TABLE ... TYPE BIGINT USING (sale_amount * 100)::bigint`).
  /// Until then, leave the column alone — formatter code that reads
  /// from here (none today) must divide by 100.
  RealColumn get saleAmount => real().nullable()();

  /// الوصف
  TextColumn get description => text().nullable()();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime()();

  /// معرف الكاشير
  TextColumn get cashierId => text().nullable().references(UsersTable, #id)();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول المكافآت المتاحة
///
/// Indexes:
/// - idx_loyalty_rewards_store_id: للاستعلامات حسب المتجر
/// - idx_loyalty_rewards_synced_at: للمزامنة
@TableIndex(name: 'idx_loyalty_rewards_store_id', columns: {#storeId})
@TableIndex(name: 'idx_loyalty_rewards_synced_at', columns: {#syncedAt})
class LoyaltyRewardsTable extends Table {
  @override
  String get tableName => 'loyalty_rewards';

  /// معرف فريد
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();

  /// معرف المتجر
  TextColumn get storeId => text().references(StoresTable, #id)();

  /// اسم المكافأة
  TextColumn get name => text()();

  /// الوصف
  TextColumn get description => text().nullable()();

  /// النقاط المطلوبة
  IntColumn get pointsRequired => integer()();

  /// نوع المكافأة: discount_percentage, discount_fixed, free_item
  TextColumn get rewardType => text()();

  // C-4 Session 4: loyalty_rewards money cols are int cents (ROUND_HALF_UP).
  /// قيمة المكافأة (نسبة أو مبلغ)
  IntColumn get rewardValue => integer()();

  /// الحد الأدنى للشراء
  IntColumn get minPurchase => integer().withDefault(const Constant(0))();

  /// المستوى المطلوب: all, bronze, silver, gold, platinum
  TextColumn get requiredTier => text().withDefault(const Constant('all'))();

  /// هل نشطة
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// تاريخ الانتهاء (اختياري)
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime()();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
