import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';

/// خدمة كتالوج المنظمة المركزي
///
/// تتعامل مع:
/// 1. نسخ منتجات المنظمة لفرع جديد
/// 2. مزامنة صور المنظمة لكل الفروع
class OrgCatalogService {
  final SupabaseClient _client;
  final AppDatabase _db;
  static const _uuid = Uuid();

  OrgCatalogService({
    required SupabaseClient client,
    required AppDatabase db,
  })  : _client = client,
        _db = db;

  /// نسخ كتالوج المنظمة لفرع جديد
  ///
  /// ينشئ نسخة من كل منتجات المنظمة النشطة مع:
  /// - سعر المنظمة الافتراضي
  /// - صور المنظمة
  /// - مخزون صفر (الفرع الجديد يحتاج تعبئة)
  Future<int> cloneOrgProductsToStore({
    required String orgId,
    required String storeId,
  }) async {
    final orgProducts = await _db.orgProductsDao.getByOrgId(orgId);
    int cloned = 0;

    for (final op in orgProducts) {
      final productId = _uuid.v4();

      await _db.productsDao.upsertProduct(
        ProductsTableCompanion.insert(
          id: productId,
          name: op.name,
          price: op.defaultPrice,
          createdAt: DateTime.now(),
          orgId: Value(orgId),
          storeId: storeId,
          orgProductId: Value(op.id),
          barcode: Value(op.barcode),
          sku: Value(op.sku),
          costPrice: Value(op.costPrice),
          categoryId: Value(op.categoryId),
          unit: Value(op.unit),
          description: Value(op.description),
          // صور المنظمة (الافتراضية)
          orgImageThumbnail: Value(op.orgImageThumbnail),
          orgImageMedium: Value(op.orgImageMedium),
          orgImageLarge: Value(op.orgImageLarge),
          orgImageHash: Value(op.orgImageHash),
          // إعدادات أونلاين
          onlineAvailable: Value(op.onlineAvailable),
          onlineMaxQty: Value(op.onlineMaxQty),
          minAlertQty: Value(op.minAlertQty),
          autoReorder: Value(op.autoReorder),
          reorderQty: Value(op.reorderQty),
        ),
      );
      cloned++;
    }

    if (kDebugMode) {
      debugPrint(
          'OrgCatalogService: cloned $cloned products to store $storeId');
    }

    return cloned;
  }

  /// مزامنة صور المنظمة لكل الفروع (عبر RPC)
  Future<int> syncOrgProductToStores(String orgProductId) async {
    try {
      final result = await _client.rpc('sync_org_product_to_stores', params: {
        'p_org_product_id': orgProductId,
      });
      return result as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrgCatalogService: sync failed: $e');
      }
      return 0;
    }
  }

  /// الحصول على الكمية المتاحة للطلب الأونلاين
  static double getOnlineAvailableQty(ProductsTableData product) {
    if (!product.onlineAvailable) return 0;

    final physicalStock = product.stockQty.toDouble();
    final reserved = product.onlineReservedQty;
    final maxOnline = product.onlineMaxQty;

    // المتاح = المخزون الفعلي - المحجوز
    final available = physicalStock - reserved;

    // لا يتجاوز الحد الأقصى (إن وُضع)
    if (maxOnline != null) {
      return available < maxOnline ? available : maxOnline;
    }
    return available > 0 ? available : 0;
  }

  /// الحصول على رابط صورة المنتج (فرع → منظمة → placeholder)
  static String? getProductImageUrl(ProductsTableData product,
      {String size = 'thumbnail'}) {
    switch (size) {
      case 'thumbnail':
        return product.imageThumbnail ?? product.orgImageThumbnail;
      case 'medium':
        return product.imageMedium ?? product.orgImageMedium;
      case 'large':
        return product.imageLarge ?? product.orgImageLarge;
      default:
        return product.imageThumbnail ?? product.orgImageThumbnail;
    }
  }
}
