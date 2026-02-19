/// Marketing Providers - مزودات التسويق
///
/// توفر بيانات الخصومات والكوبونات والعروض الترويجية
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

// ============================================================================
// DISCOUNTS
// ============================================================================

/// جميع الخصومات
final discountsListProvider =
    FutureProvider.autoDispose<List<DiscountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.discountsDao.getAllDiscounts(storeId);
});

/// الخصومات النشطة فقط
final activeDiscountsProvider =
    FutureProvider.autoDispose<List<DiscountsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.discountsDao.getActiveDiscounts(storeId);
});

// ============================================================================
// COUPONS
// ============================================================================

/// جميع الكوبونات
final couponsListProvider =
    FutureProvider.autoDispose<List<CouponsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.discountsDao.getAllCoupons(storeId);
});

// ============================================================================
// PROMOTIONS
// ============================================================================

/// جميع العروض الترويجية
final promotionsListProvider =
    FutureProvider.autoDispose<List<PromotionsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.discountsDao.getAllPromotions(storeId);
});

/// العروض النشطة فقط
final activePromotionsProvider =
    FutureProvider.autoDispose<List<PromotionsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.discountsDao.getActivePromotions(storeId);
});
