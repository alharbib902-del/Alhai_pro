import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/daos/stock_deltas_dao.dart';
import '../../../data/local/daos/sync_metadata_dao.dart';

/// مزامنة تغييرات المخزون بنظام الدلتا (Delta Sync)
///
/// المشكلة: عند وجود أجهزة POS متعددة في نفس المتجر:
/// - جهاز 1: المخزون 100، يبيع 3 → يسجل 97
/// - جهاز 2: المخزون 100، يبيع 2 → يسجل 98
/// - التعارض: أيهما صحيح؟ 97 أم 98؟
/// - الحل: نرسل الدلتا فقط: [-3, -2] والسيرفر يحسب: 100 - 3 - 2 = 95
///
/// آلية العمل:
/// 1. كل عملية بيع/مرتجع/تعديل تسجل دلتا في stock_deltas
/// 2. عند المزامنة: نجمع كل الدلتا غير المزامنة ونرسلها للسيرفر
/// 3. السيرفر يطبق الدلتا ويرجع المخزون النهائي
/// 4. نحدث المخزون المحلي بالقيمة النهائية من السيرفر
class StockDeltaSync {
  final SupabaseClient _client;
  final AppDatabase _db;
  final StockDeltasDao _deltasDao;
  final SyncMetadataDao _metadataDao;

  /// حجم الدفعة
  static const int batchSize = 100;

  StockDeltaSync({
    required SupabaseClient client,
    required AppDatabase db,
    required StockDeltasDao deltasDao,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _deltasDao = deltasDao,
        _metadataDao = metadataDao;

  /// تنفيذ مزامنة دلتا المخزون
  Future<StockDeltaResult> sync({
    required String orgId,
    required String storeId,
    required String deviceId,
  }) async {
    int deltasSent = 0;
    int productsUpdated = 0;
    final errors = <String>[];
    final oversoldProducts = <String>[];

    try {
      // جلب التغييرات غير المزامنة
      final pendingDeltas =
          await _deltasDao.getPendingDeltasForStore(storeId, limit: batchSize);

      if (pendingDeltas.isEmpty) {
        return StockDeltaResult(
          deltasSent: 0,
          productsUpdated: 0,
          errors: [],
          oversoldProducts: [],
        );
      }

      // تحويل الدلتا لصيغة JSON للإرسال
      final deltasPayload = pendingDeltas
          .map((d) => {
                'id': d.id,
                'product_id': d.productId,
                'quantity_change': d.quantityChange,
                'device_id': d.deviceId,
                'operation_type': d.operationType,
                'reference_id': d.referenceId,
                'created_at': d.createdAt.toUtc().toIso8601String(),
              })
          .toList();

      // إرسال الدلتا للسيرفر عبر RPC
      final response = await _client.rpc(
        'apply_stock_deltas',
        params: {
          'p_org_id': orgId,
          'p_store_id': storeId,
          'p_deltas': deltasPayload,
        },
      );

      // معالجة النتيجة
      if (response is List) {
        final results = List<Map<String, dynamic>>.from(response);

        for (final result in results) {
          final productId = result['product_id'] as String;
          final newStock = result['new_stock'] as int;
          final isOversold = (result['is_oversold'] as bool?) ?? false;

          // تحديث المخزون المحلي بالقيمة النهائية من السيرفر
          await _updateLocalStock(productId, newStock);
          productsUpdated++;

          // تسجيل حالات نقص المخزون
          if (isOversold) {
            oversoldProducts.add(productId);
          }
        }
      }

      // تعيين الدلتا كـ "تمت المزامنة"
      final deltaIds = pendingDeltas.map((d) => d.id).toList();
      await _deltasDao.markSynced(deltaIds);
      deltasSent = deltaIds.length;

      // تحديث بيانات المزامنة الوصفية
      await _metadataDao.updateLastPushAt(
        'stock_deltas',
        DateTime.now().toUtc(),
        syncCount: deltasSent,
      );
      await _metadataDao.clearError('stock_deltas');
    } catch (e) {
      errors.add('StockDeltaSync: $e');
      await _metadataDao.setError('stock_deltas', e.toString());

      if (kDebugMode) {
        debugPrint('StockDeltaSync error: $e');
      }

      // في حالة فشل RPC، نحاول الطريقة البديلة
      if (e.toString().contains('function') ||
          e.toString().contains('rpc')) {
        try {
          final fallbackResult = await _fallbackSync(
            orgId: orgId,
            storeId: storeId,
          );
          deltasSent = fallbackResult.deltasSent;
          productsUpdated = fallbackResult.productsUpdated;
          errors.clear();
        } catch (fallbackError) {
          errors.add('Fallback sync failed: $fallbackError');
        }
      }
    }

    return StockDeltaResult(
      deltasSent: deltasSent,
      productsUpdated: productsUpdated,
      errors: errors,
      oversoldProducts: oversoldProducts,
    );
  }

  /// الطريقة البديلة: إذا لم تتوفر دالة RPC
  /// نرسل الدلتا كسجلات عادية ونسحب المخزون الحالي
  Future<StockDeltaResult> _fallbackSync({
    required String orgId,
    required String storeId,
  }) async {
    int deltasSent = 0;
    int productsUpdated = 0;

    final pendingDeltas =
        await _deltasDao.getPendingDeltasForStore(storeId, limit: batchSize);

    if (pendingDeltas.isEmpty) {
      return StockDeltaResult(
        deltasSent: 0,
        productsUpdated: 0,
        errors: [],
        oversoldProducts: [],
      );
    }

    // إرسال كل دلتا كـ inventory_movement
    for (final delta in pendingDeltas) {
      try {
        await _client.from('inventory_movements').upsert({
          'id': delta.id,
          'org_id': orgId,
          'product_id': delta.productId,
          'store_id': storeId,
          'type': delta.operationType,
          'qty': delta.quantityChange,
          'previous_qty': 0,
          'new_qty': 0,
          'reference_id': delta.referenceId,
          'created_at': delta.createdAt.toUtc().toIso8601String(),
        }, onConflict: 'id');
        deltasSent++;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Fallback delta push failed: $e');
        }
      }
    }

    // سحب المخزون الحالي من السيرفر
    final productIds = pendingDeltas.map((d) => d.productId).toSet().toList();
    for (final productId in productIds) {
      try {
        final response = await _client
            .from('products')
            .select('id, stock_qty')
            .eq('id', productId)
            .maybeSingle();

        if (response != null) {
          final serverStock = response['stock_qty'] as int;
          await _updateLocalStock(productId, serverStock);
          productsUpdated++;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Fallback stock pull failed for $productId: $e');
        }
      }
    }

    // تعيين كـ تمت المزامنة
    await _deltasDao.markSynced(pendingDeltas.map((d) => d.id).toList());

    return StockDeltaResult(
      deltasSent: deltasSent,
      productsUpdated: productsUpdated,
      errors: [],
      oversoldProducts: [],
    );
  }

  /// تحديث المخزون المحلي
  Future<void> _updateLocalStock(String productId, int newStock) async {
    await _db.customStatement(
      'UPDATE products SET stock_qty = ?, synced_at = ? WHERE id = ?',
      [
        newStock,
        DateTime.now().toUtc().toIso8601String(),
        productId,
      ],
    );
  }
}

/// نتيجة مزامنة دلتا المخزون
class StockDeltaResult {
  final int deltasSent;
  final int productsUpdated;
  final List<String> errors;
  final List<String> oversoldProducts;

  StockDeltaResult({
    required this.deltasSent,
    required this.productsUpdated,
    required this.errors,
    required this.oversoldProducts,
  });

  bool get hasErrors => errors.isNotEmpty;

  /// هل يوجد منتجات تم بيعها أكثر من المتوفر؟
  bool get hasOversoldProducts => oversoldProducts.isNotEmpty;
}
