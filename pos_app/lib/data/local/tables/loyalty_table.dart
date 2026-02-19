import 'package:drift/drift.dart';

/// جدول نقاط الولاء
///
/// Indexes:
/// - idx_loyalty_customer_id: للاستعلامات حسب العميل
/// - idx_loyalty_store_id: للاستعلامات حسب المتجر
/// - idx_loyalty_synced_at: للمزامنة
@TableIndex(name: 'idx_loyalty_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_loyalty_store_id', columns: {#storeId})
@TableIndex(name: 'idx_loyalty_synced_at', columns: {#syncedAt})
class LoyaltyPointsTable extends Table {
  @override
  String get tableName => 'loyalty_points';

  /// معرف فريد
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();

  /// معرف العميل
  TextColumn get customerId => text().named('customer_id')();

  /// معرف المتجر
  TextColumn get storeId => text().named('store_id')();

  /// النقاط الحالية
  IntColumn get currentPoints => integer().named('current_points').withDefault(const Constant(0))();

  /// إجمالي النقاط المكتسبة
  IntColumn get totalEarned => integer().named('total_earned').withDefault(const Constant(0))();

  /// إجمالي النقاط المستبدلة
  IntColumn get totalRedeemed => integer().named('total_redeemed').withDefault(const Constant(0))();

  /// مستوى العميل: bronze, silver, gold, platinum
  TextColumn get tierLevel => text().named('tier_level').withDefault(const Constant('bronze'))();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  /// تاريخ التحديث
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

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
  TextColumn get loyaltyId => text().named('loyalty_id')();

  /// معرف العميل
  TextColumn get customerId => text().named('customer_id')();

  /// معرف المتجر
  TextColumn get storeId => text().named('store_id')();

  /// نوع المعاملة: earn, redeem, expire, adjust
  TextColumn get transactionType => text().named('transaction_type')();

  /// عدد النقاط (موجب للاكتساب، سالب للاستبدال)
  IntColumn get points => integer()();

  /// الرصيد بعد المعاملة
  IntColumn get balanceAfter => integer().named('balance_after')();

  /// معرف البيع المرتبط (اختياري)
  TextColumn get saleId => text().named('sale_id').nullable()();

  /// مبلغ البيع (للاكتساب)
  RealColumn get saleAmount => real().named('sale_amount').nullable()();

  /// الوصف
  TextColumn get description => text().nullable()();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  /// معرف الكاشير
  TextColumn get cashierId => text().named('cashier_id').nullable()();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

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
  TextColumn get storeId => text().named('store_id')();

  /// اسم المكافأة
  TextColumn get name => text()();

  /// الوصف
  TextColumn get description => text().nullable()();

  /// النقاط المطلوبة
  IntColumn get pointsRequired => integer().named('points_required')();

  /// نوع المكافأة: discount_percentage, discount_fixed, free_item
  TextColumn get rewardType => text().named('reward_type')();

  /// قيمة المكافأة (نسبة أو مبلغ)
  RealColumn get rewardValue => real().named('reward_value')();

  /// الحد الأدنى للشراء
  RealColumn get minPurchase => real().named('min_purchase').withDefault(const Constant(0))();

  /// المستوى المطلوب: all, bronze, silver, gold, platinum
  TextColumn get requiredTier => text().named('required_tier').withDefault(const Constant('all'))();

  /// هل نشطة
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();

  /// تاريخ الانتهاء (اختياري)
  DateTimeColumn get expiresAt => dateTime().named('expires_at').nullable()();

  /// تاريخ الإنشاء
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  /// تاريخ المزامنة
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
