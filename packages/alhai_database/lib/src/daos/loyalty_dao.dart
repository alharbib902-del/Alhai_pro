import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/loyalty_table.dart';

part 'loyalty_dao.g.dart';

/// DAO لنظام الولاء
@DriftAccessor(
  tables: [LoyaltyPointsTable, LoyaltyTransactionsTable, LoyaltyRewardsTable],
)
class LoyaltyDao extends DatabaseAccessor<AppDatabase> with _$LoyaltyDaoMixin {
  LoyaltyDao(super.db);

  // ============================================================================
  // LOYALTY POINTS CRUD
  // ============================================================================

  /// الحصول على نقاط عميل
  Future<LoyaltyPointsTableData?> getCustomerLoyalty(
    String customerId,
    String storeId,
  ) {
    return (select(loyaltyPointsTable)..where(
          (l) => l.customerId.equals(customerId) & l.storeId.equals(storeId),
        ))
        .getSingleOrNull();
  }

  /// الحصول على نقاط بالمعرف
  Future<LoyaltyPointsTableData?> getLoyaltyById(String id) {
    return (select(
      loyaltyPointsTable,
    )..where((l) => l.id.equals(id))).getSingleOrNull();
  }

  /// إنشاء سجل نقاط جديد
  Future<int> createLoyalty(LoyaltyPointsTableCompanion loyalty) {
    return into(loyaltyPointsTable).insert(loyalty);
  }

  /// تحديث نقاط العميل
  Future<bool> updateLoyalty(LoyaltyPointsTableData loyalty) {
    return update(loyaltyPointsTable).replace(loyalty);
  }

  /// إضافة نقاط للعميل - atomic SQL to prevent race conditions
  Future<void> addPoints(String customerId, String storeId, int points) async {
    await customStatement(
      '''UPDATE loyalty_points
         SET current_points = current_points + ?,
             total_earned = total_earned + ?,
             tier_level = CASE
               WHEN total_earned + ? >= 10000 THEN 'platinum'
               WHEN total_earned + ? >= 5000 THEN 'gold'
               WHEN total_earned + ? >= 1000 THEN 'silver'
               ELSE 'bronze'
             END,
             updated_at = ?
         WHERE customer_id = ? AND store_id = ?''',
      [
        points,
        points,
        points,
        points,
        points,
        DateTime.now().millisecondsSinceEpoch,
        customerId,
        storeId,
      ],
    );
  }

  /// خصم نقاط من العميل - atomic with balance check
  Future<bool> redeemPoints(
    String customerId,
    String storeId,
    int points,
  ) async {
    final result = await customUpdate(
      '''UPDATE loyalty_points
         SET current_points = current_points - ?,
             total_redeemed = total_redeemed + ?,
             updated_at = ?
         WHERE customer_id = ? AND store_id = ? AND current_points >= ?''',
      variables: [
        Variable.withInt(points),
        Variable.withInt(points),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(customerId),
        Variable.withString(storeId),
        Variable.withInt(points),
      ],
      updates: {loyaltyPointsTable},
    );
    return result > 0;
  }

  /// حساب مستوى العميل بناءً على النقاط
  /// يستخدم لتحديد المستوى عند تحديث النقاط
  String calculateTier(int totalPoints) {
    if (totalPoints >= 10000) return 'platinum';
    if (totalPoints >= 5000) return 'gold';
    if (totalPoints >= 1000) return 'silver';
    return 'bronze';
  }

  /// الحصول على جميع العملاء مع نقاطهم
  Future<List<LoyaltyPointsTableData>> getAllLoyaltyAccounts(String storeId) {
    return (select(loyaltyPointsTable)
          ..where((l) => l.storeId.equals(storeId))
          ..orderBy([(l) => OrderingTerm.desc(l.currentPoints)]))
        .get();
  }

  /// الحصول على أفضل العملاء
  Future<List<LoyaltyPointsTableData>> getTopCustomers(
    String storeId, {
    int limit = 10,
  }) {
    return (select(loyaltyPointsTable)
          ..where((l) => l.storeId.equals(storeId))
          ..orderBy([(l) => OrderingTerm.desc(l.totalEarned)])
          ..limit(limit))
        .get();
  }

  /// العملاء حسب المستوى
  Future<List<LoyaltyPointsTableData>> getCustomersByTier(
    String storeId,
    String tier,
  ) {
    return (select(loyaltyPointsTable)
          ..where((l) => l.storeId.equals(storeId) & l.tierLevel.equals(tier))
          ..orderBy([(l) => OrderingTerm.desc(l.currentPoints)]))
        .get();
  }

  // ============================================================================
  // TRANSACTIONS
  // ============================================================================

  /// تسجيل معاملة نقاط
  Future<int> logTransaction(LoyaltyTransactionsTableCompanion transaction) {
    return into(loyaltyTransactionsTable).insert(transaction);
  }

  /// الحصول على معاملات عميل
  Future<List<LoyaltyTransactionsTableData>> getCustomerTransactions(
    String customerId,
    String storeId, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(loyaltyTransactionsTable)
          ..where(
            (t) => t.customerId.equals(customerId) & t.storeId.equals(storeId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// معاملات اليوم
  Future<List<LoyaltyTransactionsTableData>> getTodayTransactions(
    String storeId,
  ) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(loyaltyTransactionsTable)
          ..where(
            (t) =>
                t.storeId.equals(storeId) &
                t.createdAt.isBiggerOrEqualValue(startOfDay) &
                t.createdAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// إحصائيات النقاط لفترة
  Future<LoyaltyStats> getStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause = 'store_id = ?';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect('''SELECT
           SUM(CASE WHEN transaction_type = 'earn' THEN points ELSE 0 END) as total_earned,
           SUM(CASE WHEN transaction_type = 'redeem' THEN ABS(points) ELSE 0 END) as total_redeemed,
           COUNT(DISTINCT customer_id) as active_customers,
           COUNT(*) as total_transactions
         FROM loyalty_transactions
         WHERE $whereClause''', variables: variables).getSingle();

    return LoyaltyStats(
      totalEarned: result.data['total_earned'] as int? ?? 0,
      totalRedeemed: result.data['total_redeemed'] as int? ?? 0,
      activeCustomers: result.data['active_customers'] as int? ?? 0,
      totalTransactions: result.data['total_transactions'] as int? ?? 0,
    );
  }

  // ============================================================================
  // REWARDS
  // ============================================================================

  /// الحصول على المكافآت المتاحة
  Future<List<LoyaltyRewardsTableData>> getAvailableRewards(
    String storeId, {
    int? customerPoints,
    String? customerTier,
  }) {
    var query = select(loyaltyRewardsTable)
      ..where((r) {
        var condition = r.storeId.equals(storeId) & r.isActive.equals(true);

        // تصفية المنتهية الصلاحية
        condition =
            condition &
            (r.expiresAt.isNull() |
                r.expiresAt.isBiggerThanValue(DateTime.now()));

        // تصفية حسب النقاط
        if (customerPoints != null) {
          condition =
              condition &
              r.pointsRequired.isSmallerOrEqualValue(customerPoints);
        }

        return condition;
      })
      ..orderBy([(r) => OrderingTerm.asc(r.pointsRequired)]);

    return query.get();
  }

  /// الحصول على مكافأة بالمعرف
  Future<LoyaltyRewardsTableData?> getRewardById(String id) {
    return (select(
      loyaltyRewardsTable,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// إنشاء مكافأة
  Future<int> createReward(LoyaltyRewardsTableCompanion reward) {
    return into(loyaltyRewardsTable).insert(reward);
  }

  /// تحديث مكافأة
  Future<bool> updateReward(LoyaltyRewardsTableData reward) {
    return update(loyaltyRewardsTable).replace(reward);
  }

  /// تعطيل مكافأة
  Future<int> deactivateReward(String id) {
    return (update(loyaltyRewardsTable)..where((r) => r.id.equals(id))).write(
      const LoyaltyRewardsTableCompanion(isActive: Value(false)),
    );
  }

  // ============================================================================
  // SYNC
  // ============================================================================

  /// الحصول على السجلات غير المزامنة
  Future<List<LoyaltyPointsTableData>> getUnsyncedLoyalty() {
    return (select(
      loyaltyPointsTable,
    )..where((l) => l.syncedAt.isNull())).get();
  }

  /// الحصول على المعاملات غير المزامنة
  Future<List<LoyaltyTransactionsTableData>> getUnsyncedTransactions() {
    return (select(
      loyaltyTransactionsTable,
    )..where((t) => t.syncedAt.isNull())).get();
  }

  /// تعيين تاريخ المزامنة
  Future<void> markLoyaltySynced(String id) {
    return (update(loyaltyPointsTable)..where((l) => l.id.equals(id))).write(
      LoyaltyPointsTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  Future<void> markTransactionSynced(String id) {
    return (update(
      loyaltyTransactionsTable,
    )..where((t) => t.id.equals(id))).write(
      LoyaltyTransactionsTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }
}

/// نموذج إحصائيات الولاء
class LoyaltyStats {
  final int totalEarned;
  final int totalRedeemed;
  final int activeCustomers;
  final int totalTransactions;

  const LoyaltyStats({
    required this.totalEarned,
    required this.totalRedeemed,
    required this.activeCustomers,
    required this.totalTransactions,
  });

  /// صافي النقاط
  int get netPoints => totalEarned - totalRedeemed;
}
