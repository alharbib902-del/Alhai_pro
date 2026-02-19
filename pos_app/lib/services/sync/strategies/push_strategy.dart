import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/daos/sync_metadata_dao.dart';
import '../../../data/local/daos/sync_queue_dao.dart';
import '../json_converter.dart';
import '../org_sync_service.dart';

/// استراتيجية الدفع (Push): المحلي ← السيرفر
/// تُستخدم للبيانات التي تُنشأ محلياً: المبيعات، عناصر المبيعات، الطلبات، حركات النقد، سجل المراجعة
///
/// آلية العمل:
/// 1. جلب السجلات من sync_queue حيث status = 'pending' أو 'failed'
/// 2. دفع كل سجل للسيرفر باستخدام upsert (idempotent)
/// 3. تعيين synced عند النجاح
/// 4. زيادة retry_count عند الفشل مع exponential backoff
/// 5. الحد الأقصى 5 محاولات
class PushStrategy {
  final SupabaseClient _client;
  final SyncQueueDao _syncQueueDao;
  final SyncMetadataDao _metadataDao;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// الجداول التي يتم دفعها للسيرفر
  static const List<String> pushTables = [
    'sales',
    'sale_items',
    'orders',
    'order_items',
    'cash_movements',
    'audit_log',
  ];

  /// الحد الأقصى لعدد المحاولات
  static const int maxRetries = 5;

  /// حجم الدفعة
  static const int batchSize = 100;

  PushStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _syncQueueDao = db.syncQueueDao,
        _metadataDao = metadataDao;

  /// تنفيذ الدفع لجميع العناصر المعلقة
  Future<PushResult> pushPending() async {
    int successCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    try {
      // جلب العناصر المعلقة (مرتبة حسب الأولوية ثم التاريخ)
      final pendingItems = await _syncQueueDao.getPendingItems();

      // فلترة فقط جداول الدفع + التحقق من عدد المحاولات
      final itemsToPush = pendingItems
          .where((item) =>
              pushTables.contains(item.tableName_) &&
              item.retryCount < maxRetries)
          .take(batchSize)
          .toList();

      for (final item in itemsToPush) {
        try {
          // تعيين كـ "جاري المزامنة"
          await _syncQueueDao.markAsSyncing(item.id);

          // تحليل البيانات
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;

          // تنفيذ العملية على السيرفر
          await _executeRemoteOperation(
            tableName: item.tableName_,
            operation: item.operation,
            payload: payload,
          );

          // نجاح: تعيين كـ "تمت المزامنة"
          await _syncQueueDao.markAsSynced(item.id);
          successCount++;
        } catch (e) {
          failedCount++;
          errors.add('${item.tableName_}/${item.recordId}: $e');

          // فشل: زيادة عداد المحاولات
          await _syncQueueDao.markAsFailed(item.id, e.toString());

          if (kDebugMode) {
            debugPrint(
                'Push failed for ${item.tableName_}/${item.recordId}: $e');
          }

          // إذا وصلنا للحد الأقصى، نعلم كتعارض
          if (item.retryCount + 1 >= maxRetries) {
            await _syncQueueDao.markAsConflict(
              item.id,
              'Max retries reached: $e',
            );
          }
        }
      }

      // تحديث بيانات المزامنة الوصفية لكل جدول
      for (final tableName in pushTables) {
        final pushed = itemsToPush
            .where((i) => i.tableName_ == tableName)
            .length;
        if (pushed > 0) {
          await _metadataDao.updateLastPushAt(
            tableName,
            DateTime.now().toUtc(),
            syncCount: pushed,
          );
        }
      }
    } catch (e) {
      errors.add('Push strategy error: $e');
      if (kDebugMode) {
        debugPrint('PushStrategy error: $e');
      }
    }

    return PushResult(
      successCount: successCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  /// تنفيذ عملية على السيرفر
  Future<void> _executeRemoteOperation({
    required String tableName,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    // تحويل JSONB fields من نص إلى كائنات
    final remotePayload = _jsonConverter.toRemote(tableName, payload);

    // تنظيف الحقول المحلية
    final cleanPayload = _cleanPayload(remotePayload);

    // تجاهل جداول المؤسسة (تُعالج بخدمة مزامنة المؤسسة)
    if (OrgTables.all.contains(tableName)) return;

    switch (operation.toUpperCase()) {
      case 'CREATE':
      case 'UPDATE':
        await _client.from(tableName).upsert(
              cleanPayload,
              onConflict: 'id',
            );
        break;
      case 'DELETE':
        final id = cleanPayload['id'] as String?;
        if (id != null) {
          await _client.from(tableName).delete().eq('id', id);
        }
        break;
    }
  }

  /// تنظيف الحقول المحلية قبل الإرسال
  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    final clean = Map<String, dynamic>.from(payload);
    // إزالة الحقول المحلية
    clean.remove('syncedAt');
    clean.remove('synced_at');
    // إزالة حقل items المضمّن في sales (عناصر البيع تُزامن عبر sale_items)
    clean.remove('items');
    return clean;
  }

  /// حساب تأخير إعادة المحاولة (Exponential Backoff)
  static Duration getRetryDelay(int retryCount) {
    // 2s, 4s, 8s, 16s, 32s + jitter عشوائي
    final baseDelay = Duration(seconds: 2 * pow(2, retryCount).toInt());
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    return baseDelay + jitter;
  }
}

/// نتيجة عملية الدفع
class PushResult {
  final int successCount;
  final int failedCount;
  final List<String> errors;

  PushResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });

  bool get hasErrors => failedCount > 0;
  int get totalCount => successCount + failedCount;
}
