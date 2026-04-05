/// Marketing Providers - مزودات التسويق
///
/// توفر بيانات الخصومات والكوبونات والعروض الترويجية
/// تشمل: قراءة، إضافة، تعديل، حذف مع مزامنة SyncQueue
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';

const _uuid = Uuid();

// ============================================================================
// DISCOUNTS - الخصومات
// ============================================================================

/// جميع الخصومات
final discountsListProvider =
    FutureProvider.autoDispose<List<DiscountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.discountsDao.getAllDiscounts(storeId);
});

/// الخصومات النشطة فقط
final activeDiscountsProvider =
    FutureProvider.autoDispose<List<DiscountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.discountsDao.getActiveDiscounts(storeId);
});

/// إضافة خصم جديد مع مزامنة
Future<void> addDiscount(
  WidgetRef ref, {
  required String name,
  String? nameEn,
  required String type,
  required double value,
  double minPurchase = 0,
  double? maxDiscount,
  String appliesTo = 'all',
  String? productIds,
  String? categoryIds,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final now = DateTime.now();

  await db.discountsDao.insertDiscount(DiscountsTableCompanion(
    id: Value(id),
    storeId: Value(storeId),
    name: Value(name),
    nameEn: Value(nameEn ?? name),
    type: Value(type),
    value: Value(value),
    minPurchase: Value(minPurchase),
    maxDiscount: Value(maxDiscount),
    appliesTo: Value(appliesTo),
    productIds: Value(productIds),
    categoryIds: Value(categoryIds),
    startDate: Value(startDate ?? now),
    endDate: Value(endDate ?? now.add(const Duration(days: 30))),
    isActive: const Value(true),
    createdAt: Value(now),
    updatedAt: Value(now),
  ));

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'discounts',
      recordId: id,
      data: {
        'id': id,
        'store_id': storeId,
        'name': name,
        'name_en': nameEn ?? name,
        'type': type,
        'value': value,
        'min_purchase': minPurchase,
        'max_discount': maxDiscount,
        'applies_to': appliesTo,
        'product_ids': productIds,
        'category_ids': categoryIds,
        'start_date': (startDate ?? now).toIso8601String(),
        'end_date':
            (endDate ?? now.add(const Duration(days: 30))).toIso8601String(),
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Add discount sync failed: $e');
  }

  ref.invalidate(discountsListProvider);
  ref.invalidate(activeDiscountsProvider);
}

/// تحديث خصم مع مزامنة
Future<void> updateDiscount(WidgetRef ref, DiscountsTableData discount) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.updateDiscount(discount);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueUpdate(
      tableName: 'discounts',
      recordId: discount.id,
      changes: {
        'id': discount.id,
        'store_id': discount.storeId,
        'name': discount.name,
        'name_en': discount.nameEn,
        'type': discount.type,
        'value': discount.value,
        'is_active': discount.isActive,
        'updated_at': discount.updatedAt?.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Update discount sync failed: $e');
  }

  ref.invalidate(discountsListProvider);
  ref.invalidate(activeDiscountsProvider);
}

/// حذف خصم مع مزامنة
Future<void> deleteDiscount(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.deleteDiscount(id);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(tableName: 'discounts', recordId: id);
  } catch (e) {
    debugPrint('[MarketingProviders] Delete discount sync failed: $e');
  }

  ref.invalidate(discountsListProvider);
  ref.invalidate(activeDiscountsProvider);
}

// ============================================================================
// COUPONS - الكوبونات
// ============================================================================

/// جميع الكوبونات
final couponsListProvider =
    FutureProvider.autoDispose<List<CouponsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.discountsDao.getAllCoupons(storeId);
});

/// إضافة كوبون جديد مع مزامنة
Future<void> addCoupon(
  WidgetRef ref, {
  required String code,
  String? discountId,
  required String type,
  required double value,
  int maxUses = 100,
  double minPurchase = 0,
  DateTime? expiresAt,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final now = DateTime.now();
  final expires = expiresAt ?? now.add(const Duration(days: 30));

  await db.discountsDao.insertCoupon(CouponsTableCompanion(
    id: Value(id),
    storeId: Value(storeId),
    code: Value(code),
    discountId: Value(discountId),
    type: Value(type),
    value: Value(value),
    maxUses: Value(maxUses),
    currentUses: const Value(0),
    minPurchase: Value(minPurchase),
    isActive: const Value(true),
    expiresAt: Value(expires),
    createdAt: Value(now),
  ));

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'coupons',
      recordId: id,
      data: {
        'id': id,
        'store_id': storeId,
        'code': code,
        'discount_id': discountId,
        'type': type,
        'value': value,
        'max_uses': maxUses,
        'current_uses': 0,
        'min_purchase': minPurchase,
        'is_active': true,
        'expires_at': expires.toIso8601String(),
        'created_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Add coupon sync failed: $e');
  }

  ref.invalidate(couponsListProvider);
}

/// تحديث كوبون مع مزامنة
Future<void> updateCoupon(WidgetRef ref, CouponsTableData coupon) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.updateCoupon(coupon);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueUpdate(
      tableName: 'coupons',
      recordId: coupon.id,
      changes: {
        'id': coupon.id,
        'store_id': coupon.storeId,
        'code': coupon.code,
        'type': coupon.type,
        'value': coupon.value,
        'is_active': coupon.isActive,
        'max_uses': coupon.maxUses,
        'current_uses': coupon.currentUses,
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Update coupon sync failed: $e');
  }

  ref.invalidate(couponsListProvider);
}

/// حذف كوبون مع مزامنة
Future<void> deleteCoupon(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.deleteCoupon(id);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(tableName: 'coupons', recordId: id);
  } catch (e) {
    debugPrint('[MarketingProviders] Delete coupon sync failed: $e');
  }

  ref.invalidate(couponsListProvider);
}

// ============================================================================
// PROMOTIONS - العروض الترويجية
// ============================================================================

/// جميع العروض الترويجية
final promotionsListProvider =
    FutureProvider.autoDispose<List<PromotionsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.discountsDao.getAllPromotions(storeId);
});

/// العروض النشطة فقط
final activePromotionsProvider =
    FutureProvider.autoDispose<List<PromotionsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.discountsDao.getActivePromotions(storeId);
});

/// إضافة عرض ترويجي جديد مع مزامنة
Future<void> addPromotion(
  WidgetRef ref, {
  required String name,
  String? nameEn,
  String? description,
  required String type,
  String rules = '{}',
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) return;
  final db = GetIt.I<AppDatabase>();
  final id = _uuid.v4();
  final now = DateTime.now();
  final start = startDate ?? now;
  final end = endDate ?? now.add(const Duration(days: 30));

  await db.discountsDao.insertPromotion(PromotionsTableCompanion(
    id: Value(id),
    storeId: Value(storeId),
    name: Value(name),
    nameEn: Value(nameEn ?? name),
    description: Value(description),
    type: Value(type),
    rules: Value(rules),
    startDate: Value(start),
    endDate: Value(end),
    isActive: const Value(true),
    createdAt: Value(now),
    updatedAt: Value(now),
  ));

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'promotions',
      recordId: id,
      data: {
        'id': id,
        'store_id': storeId,
        'name': name,
        'name_en': nameEn ?? name,
        'description': description,
        'type': type,
        'rules': rules,
        'start_date': start.toIso8601String(),
        'end_date': end.toIso8601String(),
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Add promotion sync failed: $e');
  }

  ref.invalidate(promotionsListProvider);
  ref.invalidate(activePromotionsProvider);
}

/// تحديث عرض ترويجي مع مزامنة
Future<void> updatePromotion(WidgetRef ref, PromotionsTableData promo) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.updatePromotion(promo);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueUpdate(
      tableName: 'promotions',
      recordId: promo.id,
      changes: {
        'id': promo.id,
        'store_id': promo.storeId,
        'name': promo.name,
        'name_en': promo.nameEn,
        'type': promo.type,
        'is_active': promo.isActive,
        'updated_at': promo.updatedAt?.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[MarketingProviders] Update promotion sync failed: $e');
  }

  ref.invalidate(promotionsListProvider);
  ref.invalidate(activePromotionsProvider);
}

/// حذف عرض ترويجي مع مزامنة
Future<void> deletePromotion(WidgetRef ref, String id) async {
  final db = GetIt.I<AppDatabase>();
  await db.discountsDao.deletePromotion(id);

  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(tableName: 'promotions', recordId: id);
  } catch (e) {
    debugPrint('[MarketingProviders] Delete promotion sync failed: $e');
  }

  ref.invalidate(promotionsListProvider);
  ref.invalidate(activePromotionsProvider);
}
