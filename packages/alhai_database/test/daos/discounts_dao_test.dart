import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('DiscountsDao', () {
    // Discounts
    test('insertDiscount and getAllDiscounts', () async {
      await db.discountsDao.insertDiscount(
        DiscountsTableCompanion.insert(
          id: 'disc-1',
          storeId: 'store-1',
          name: 'خصم رمضان',
          type: 'percentage',
          // C-4 Stage A: value stored as cents (× 100). 10.0% → 1000.
          value: 1000,
          isActive: const Value(true),
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final discounts = await db.discountsDao.getAllDiscounts('store-1');
      expect(discounts, hasLength(1));
      expect(discounts.first.name, 'خصم رمضان');
      expect(discounts.first.value, 1000);
    });

    test('getActiveDiscounts returns only active', () async {
      await db.discountsDao.insertDiscount(
        DiscountsTableCompanion.insert(
          id: 'disc-1',
          storeId: 'store-1',
          name: 'خصم نشط',
          type: 'percentage',
          value: 1000,
          isActive: const Value(true),
          createdAt: DateTime(2025, 3, 1),
        ),
      );
      await db.discountsDao.insertDiscount(
        DiscountsTableCompanion.insert(
          id: 'disc-2',
          storeId: 'store-1',
          name: 'خصم منتهي',
          type: 'fixed',
          value: 500,
          isActive: const Value(false),
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final active = await db.discountsDao.getActiveDiscounts('store-1');
      expect(active, hasLength(1));
      expect(active.first.name, 'خصم نشط');
    });

    test('deleteDiscount removes discount', () async {
      await db.discountsDao.insertDiscount(
        DiscountsTableCompanion.insert(
          id: 'disc-1',
          storeId: 'store-1',
          name: 'خصم',
          type: 'fixed',
          value: 500,
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final deleted = await db.discountsDao.deleteDiscount('disc-1');
      expect(deleted, 1);
    });

    // Coupons — C-4 Session 4: value stored as int cents (ROUND_HALF_UP).
    // For 'percentage' type: 20% = 2000 cents (caller interprets).
    test('insertCoupon and getCouponByCode', () async {
      await db.discountsDao.insertCoupon(
        CouponsTableCompanion.insert(
          id: 'coupon-1',
          storeId: 'store-1',
          code: 'SAVE20',
          type: 'percentage',
          value: 2000, // 20% as cents
          isActive: const Value(true),
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final coupon = await db.discountsDao.getCouponByCode('SAVE20', 'store-1');
      expect(coupon, isNotNull);
      expect(coupon!.value, 2000);
    });

    test('getCouponByCode returns null for inactive coupon', () async {
      await db.discountsDao.insertCoupon(
        CouponsTableCompanion.insert(
          id: 'coupon-1',
          storeId: 'store-1',
          code: 'EXPIRED',
          type: 'fixed',
          value: 1000, // 10.00 SAR as cents
          isActive: const Value(false),
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final coupon = await db.discountsDao.getCouponByCode(
        'EXPIRED',
        'store-1',
      );
      expect(coupon, isNull);
    });

    test('getAllCoupons returns all for store', () async {
      await db.discountsDao.insertCoupon(
        CouponsTableCompanion.insert(
          id: 'c-1',
          storeId: 'store-1',
          code: 'C1',
          type: 'fixed',
          value: 500, // 5.00 SAR as cents
          createdAt: DateTime(2025, 3, 1),
        ),
      );
      await db.discountsDao.insertCoupon(
        CouponsTableCompanion.insert(
          id: 'c-2',
          storeId: 'store-1',
          code: 'C2',
          type: 'percentage',
          value: 1500, // 15% as cents
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final coupons = await db.discountsDao.getAllCoupons('store-1');
      expect(coupons, hasLength(2));
    });

    test('deleteCoupon removes coupon', () async {
      await db.discountsDao.insertCoupon(
        CouponsTableCompanion.insert(
          id: 'c-1',
          storeId: 'store-1',
          code: 'C1',
          type: 'fixed',
          value: 500, // 5.00 SAR as cents
          createdAt: DateTime(2025, 3, 1),
        ),
      );

      final deleted = await db.discountsDao.deleteCoupon('c-1');
      expect(deleted, 1);
    });

    // Promotions
    test('insertPromotion and getAllPromotions', () async {
      await db.discountsDao.insertPromotion(
        PromotionsTableCompanion.insert(
          id: 'promo-1',
          storeId: 'store-1',
          name: 'عرض الصيف',
          type: 'flash_sale',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 8, 31),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final promotions = await db.discountsDao.getAllPromotions('store-1');
      expect(promotions, hasLength(1));
      expect(promotions.first.name, 'عرض الصيف');
    });

    test('deletePromotion removes promotion', () async {
      await db.discountsDao.insertPromotion(
        PromotionsTableCompanion.insert(
          id: 'promo-1',
          storeId: 'store-1',
          name: 'عرض',
          type: 'bundle',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 30),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final deleted = await db.discountsDao.deletePromotion('promo-1');
      expect(deleted, 1);
    });
  });
}
