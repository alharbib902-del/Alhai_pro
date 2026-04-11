/// مزودات المنتجات المفضلة - Favorites Providers
///
/// توفر بيانات المنتجات المفضلة من قاعدة البيانات المحلية (Drift)
/// بدلاً من القائمة المضمنة في الكود
/// مع دعم المزامنة عبر SyncQueue
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

const _uuid = Uuid();

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات منتج مفضل مع تفاصيل المنتج
class FavoriteProductData {
  final FavoritesTableData favorite;
  final ProductsTableData product;

  const FavoriteProductData({required this.favorite, required this.product});

  /// معرّف المفضلة
  String get id => favorite.id;

  /// معرّف المنتج
  String get productId => favorite.productId;

  /// اسم المنتج
  String get name => product.name;

  /// سعر المنتج
  double get price => product.price;

  /// باركود المنتج
  String get barcode => product.barcode ?? '';

  /// المخزون
  double get stock => product.stockQty;

  /// صورة المنتج المصغرة
  String? get imageUrl => product.imageThumbnail;

  /// ترتيب الفرز
  int get sortOrder => favorite.sortOrder;
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// قائمة المنتجات المفضلة مع تفاصيل المنتج
final favoritesListProvider =
    FutureProvider.autoDispose<List<FavoriteProductData>>((ref) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return [];

      final db = GetIt.I<AppDatabase>();

      // جلب المفضلات من قاعدة البيانات
      final favorites =
          await (db.select(db.favoritesTable)
                ..where((f) => f.storeId.equals(storeId))
                ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
              .get();

      // لكل مفضلة، جلب بيانات المنتج
      final results = <FavoriteProductData>[];
      for (final fav in favorites) {
        final product = await db.productsDao.getProductById(fav.productId);
        if (product != null) {
          results.add(FavoriteProductData(favorite: fav, product: product));
        }
      }

      return results;
    });

// ============================================================================
// عمليات المفضلة (إضافة / إزالة / إعادة ترتيب)
// ============================================================================

/// إضافة منتج للمفضلة
Future<void> addToFavorites(WidgetRef ref, String productId) async {
  final storeId = ref.read(currentStoreIdProvider) ?? '';
  final db = GetIt.I<AppDatabase>();

  // التحقق من عدم وجود المنتج مسبقاً
  final existing =
      await (db.select(db.favoritesTable)..where(
            (f) => f.storeId.equals(storeId) & f.productId.equals(productId),
          ))
          .getSingleOrNull();

  if (existing != null) return; // موجود مسبقاً

  // حساب ترتيب الفرز (آخر +1)
  final maxOrderResult = await db
      .customSelect(
        'SELECT MAX(sort_order) as max_order FROM favorites WHERE store_id = ?',
        variables: [Variable.withString(storeId)],
      )
      .getSingleOrNull();
  final nextOrder = (maxOrderResult?.data['max_order'] as int? ?? 0) + 1;

  final id = _uuid.v4();
  final now = DateTime.now();

  // إدراج في قاعدة البيانات
  await db
      .into(db.favoritesTable)
      .insert(
        FavoritesTableCompanion.insert(
          id: id,
          storeId: storeId,
          productId: productId,
          sortOrder: Value(nextOrder),
          createdAt: now,
        ),
      );

  // إضافة للمزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'favorites',
      recordId: id,
      data: {
        'id': id,
        'store_id': storeId,
        'product_id': productId,
        'sort_order': nextOrder,
        'created_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[FavoritesDB] خطأ في إضافة المزامنة: $e');
  }

  // تحديث قائمة المفضلات
  ref.invalidate(favoritesListProvider);
}

/// إزالة منتج من المفضلة بمعرف المنتج
Future<void> removeFromFavorites(WidgetRef ref, String productId) async {
  final storeId = ref.read(currentStoreIdProvider) ?? '';
  final db = GetIt.I<AppDatabase>();

  // البحث عن المفضلة لمعرفة الـ id
  final existing =
      await (db.select(db.favoritesTable)..where(
            (f) => f.storeId.equals(storeId) & f.productId.equals(productId),
          ))
          .getSingleOrNull();

  if (existing == null) return; // غير موجود

  // حذف من قاعدة البيانات
  await (db.delete(
    db.favoritesTable,
  )..where((f) => f.id.equals(existing.id))).go();

  // إضافة للمزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(
      tableName: 'favorites',
      recordId: existing.id,
    );
  } catch (e) {
    debugPrint('[FavoritesDB] خطأ في إضافة المزامنة: $e');
  }

  // تحديث قائمة المفضلات
  ref.invalidate(favoritesListProvider);
}

/// إزالة مفضلة بمعرف المفضلة (للاستخدام من الشاشة)
Future<void> removeFavoriteById(WidgetRef ref, String favoriteId) async {
  final db = GetIt.I<AppDatabase>();

  // حذف من قاعدة البيانات
  await (db.delete(
    db.favoritesTable,
  )..where((f) => f.id.equals(favoriteId))).go();

  // إضافة للمزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueDelete(
      tableName: 'favorites',
      recordId: favoriteId,
    );
  } catch (e) {
    debugPrint('[FavoritesDB] خطأ في إضافة المزامنة: $e');
  }

  // تحديث قائمة المفضلات
  ref.invalidate(favoritesListProvider);
}

/// إعادة إضافة مفضلة (للتراجع عن الحذف)
Future<void> reAddFavorite(
  WidgetRef ref,
  FavoriteProductData favoriteData,
) async {
  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();

  // إعادة الإدراج في قاعدة البيانات
  await db
      .into(db.favoritesTable)
      .insert(
        FavoritesTableCompanion.insert(
          id: favoriteData.id,
          storeId: favoriteData.favorite.storeId,
          productId: favoriteData.productId,
          sortOrder: Value(favoriteData.sortOrder),
          createdAt: now,
        ),
      );

  // إضافة للمزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueCreate(
      tableName: 'favorites',
      recordId: favoriteData.id,
      data: {
        'id': favoriteData.id,
        'store_id': favoriteData.favorite.storeId,
        'product_id': favoriteData.productId,
        'sort_order': favoriteData.sortOrder,
        'created_at': now.toIso8601String(),
      },
    );
  } catch (e) {
    debugPrint('[FavoritesDB] خطأ في إضافة المزامنة: $e');
  }

  // تحديث قائمة المفضلات
  ref.invalidate(favoritesListProvider);
}
