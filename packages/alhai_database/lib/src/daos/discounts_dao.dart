import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/discounts_table.dart';

part 'discounts_dao.g.dart';

/// DAO for discounts, coupons and promotions
@DriftAccessor(tables: [DiscountsTable, CouponsTable, PromotionsTable])
class DiscountsDao extends DatabaseAccessor<AppDatabase>
    with _$DiscountsDaoMixin {
  DiscountsDao(super.db);

  Future<List<DiscountsTableData>> getAllDiscounts(String storeId) {
    return (select(discountsTable)
          ..where((d) => d.storeId.equals(storeId) & d.deletedAt.isNull())
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)])
          ..limit(200))
        .get();
  }

  Future<List<DiscountsTableData>> getActiveDiscounts(String storeId) {
    return (select(discountsTable)
          ..where((d) =>
              d.storeId.equals(storeId) &
              d.isActive.equals(true) &
              d.deletedAt.isNull())
          ..limit(200))
        .get();
  }

  Future<int> insertDiscount(DiscountsTableCompanion discount) =>
      into(discountsTable).insert(discount);
  Future<bool> updateDiscount(DiscountsTableData discount) =>
      update(discountsTable).replace(discount);
  Future<int> deleteDiscount(String id) =>
      (delete(discountsTable)..where((d) => d.id.equals(id))).go();

  // Coupons
  Future<List<CouponsTableData>> getAllCoupons(String storeId) {
    return (select(couponsTable)
          ..where((c) => c.storeId.equals(storeId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(200))
        .get();
  }

  Future<CouponsTableData?> getCouponByCode(String code, String storeId) {
    return (select(couponsTable)..where(
          (c) =>
              c.storeId.equals(storeId) &
              c.code.equals(code) &
              c.isActive.equals(true) &
              c.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Most-recently-touched coupons for a store, capped at [limit].
  /// Backs the "recent coupons" rail on the coupon screen. Ordered by
  /// `createdAt` descending — enough to feel fresh without needing a
  /// dedicated audit table for coupon activity.
  Future<List<CouponsTableData>> getRecentCoupons(
    String storeId, {
    int limit = 5,
  }) {
    return (select(couponsTable)
          ..where(
            (c) =>
                c.storeId.equals(storeId) &
                c.isActive.equals(true) &
                c.deletedAt.isNull(),
          )
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Atomically increment a coupon's `currentUses`, but only if the
  /// coupon is still redeemable (active, not deleted, not expired, and
  /// `currentUses < maxUses` — a `maxUses` of 0 means "unlimited").
  ///
  /// Returns the number of rows affected: `1` on success, `0` if the
  /// coupon is exhausted, expired, or no longer active. This is the
  /// canonical guard against double-spend race conditions; never branch
  /// on an in-memory `currentUses` snapshot.
  Future<int> tryRedeemCoupon(String couponId) {
    final now = DateTime.now();
    return customUpdate(
      '''UPDATE coupons
         SET current_uses = current_uses + 1
         WHERE id = ?
           AND is_active = 1
           AND deleted_at IS NULL
           AND (max_uses = 0 OR current_uses < max_uses)
           AND (expires_at IS NULL OR expires_at > ?)''',
      variables: [
        Variable.withString(couponId),
        Variable.withDateTime(now),
      ],
      updates: {couponsTable},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> insertCoupon(CouponsTableCompanion coupon) =>
      into(couponsTable).insert(coupon);
  Future<bool> updateCoupon(CouponsTableData coupon) =>
      update(couponsTable).replace(coupon);
  Future<int> deleteCoupon(String id) =>
      (delete(couponsTable)..where((c) => c.id.equals(id))).go();

  // Promotions
  Future<List<PromotionsTableData>> getAllPromotions(String storeId) {
    return (select(promotionsTable)
          ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(200))
        .get();
  }

  Future<List<PromotionsTableData>> getActivePromotions(String storeId) {
    final now = DateTime.now();
    return (select(promotionsTable)..where(
          (p) =>
              p.storeId.equals(storeId) &
              p.isActive.equals(true) &
              p.deletedAt.isNull() &
              p.startDate.isSmallerOrEqualValue(now) &
              p.endDate.isBiggerOrEqualValue(now),
        ))
        .get();
  }

  Future<int> insertPromotion(PromotionsTableCompanion promotion) =>
      into(promotionsTable).insert(promotion);
  Future<bool> updatePromotion(PromotionsTableData promotion) =>
      update(promotionsTable).replace(promotion);
  Future<int> deletePromotion(String id) =>
      (delete(promotionsTable)..where((p) => p.id.equals(id))).go();
}
