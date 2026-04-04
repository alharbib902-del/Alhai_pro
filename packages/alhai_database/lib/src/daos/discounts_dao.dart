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
          ..where((d) => d.storeId.equals(storeId))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)])
          ..limit(200))
        .get();
  }

  Future<List<DiscountsTableData>> getActiveDiscounts(String storeId) {
    return (select(discountsTable)
          ..where((d) => d.storeId.equals(storeId) & d.isActive.equals(true))
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
          ..where((c) => c.storeId.equals(storeId))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(200))
        .get();
  }

  Future<CouponsTableData?> getCouponByCode(String code, String storeId) {
    return (select(couponsTable)
          ..where((c) =>
              c.storeId.equals(storeId) &
              c.code.equals(code) &
              c.isActive.equals(true)))
        .getSingleOrNull();
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
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(200))
        .get();
  }

  Future<List<PromotionsTableData>> getActivePromotions(String storeId) {
    final now = DateTime.now();
    return (select(promotionsTable)
          ..where((p) =>
              p.storeId.equals(storeId) &
              p.isActive.equals(true) &
              p.startDate.isSmallerOrEqualValue(now) &
              p.endDate.isBiggerOrEqualValue(now)))
        .get();
  }

  Future<int> insertPromotion(PromotionsTableCompanion promotion) =>
      into(promotionsTable).insert(promotion);
  Future<bool> updatePromotion(PromotionsTableData promotion) =>
      update(promotionsTable).replace(promotion);
  Future<int> deletePromotion(String id) =>
      (delete(promotionsTable)..where((p) => p.id.equals(id))).go();
}
