// ---------------------------------------------------------------------------
// DUAL-QUEUE ARCHITECTURE -- DB-LEVEL QUEUE (Queue 2 of 2)
// ---------------------------------------------------------------------------
//
// This is the GENERAL-PURPOSE sync queue used by ALL apps in the monorepo.
// It pushes locally-created rows from the Drift/SQLite `sync_queue` table
// to Supabase.
//
// Tables pushed: sales, sale_items, orders, order_items, cash_movements,
//   audit_log, inventory_movements, order_status_history, daily_summaries,
//   whatsapp_messages.
//
// Retry: 5 attempts max, exponential backoff with random jitter, batch
//   size 100. Conflict types detected: duplicate key (23505), version
//   conflict (409), delete-update, schema mismatch, network timeout.
//
// IMPORTANT -- Separate from OfflineQueueService in the cashier app.
//   The cashier app has a SECOND queue:
//     apps/cashier/lib/core/services/offline_queue_service.dart
//   That queue uses FlutterSecureStorage (encrypted) for cashier-specific
//   operations (sale creates/updates, refunds, inventory, customer sync)
//   that contain sensitive PII / financial data.
//
// On reconnect both queues flush independently:
//   - OfflineQueueService.flush()  (cashier encrypted queue)
//   - SyncEngine.syncNow()         (this DB-level queue via PushStrategy)
//   Idempotency keys on both sides prevent duplicate server-side processing.
//
// See the doc block at the top of offline_queue_service.dart for the full
// architectural overview of both queues.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import '../conflict_resolver.dart';
import '../json_converter.dart';
import '../org_sync_service.dart';
import '../sync_api_service.dart';
import '../sync_payload_utils.dart';

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
  final ConflictResolver _conflictResolver;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// Lazy-initialized API service for idempotency checks on timeout recovery.
  late final SyncApiService _apiService = SyncApiService(client: _client);

  /// الجداول التي يتم دفعها للسيرفر
  /// هذه البيانات تُنشأ محلياً على نقطة البيع وتُرسل للسيرفر
  ///
  /// NOTE: 'customers' is NOT here — it is in BidirectionalStrategy only,
  /// because customers can be modified both locally and from the admin panel.
  ///
  /// All tables below exist in both Drift (local) and Supabase (remote).
  /// 'cash_movements' and 'audit_log' were previously skipped via an
  /// exclusion list because Supabase lacked the tables — the migration has
  /// since been applied so they now push normally.
  static const List<String> pushTables = [
    'sales',
    'sale_items',
    'orders',
    'order_items',
    'cash_movements',
    'audit_log',
    // جداول جديدة
    'inventory_movements',
    'order_status_history',
    'daily_summaries',
    'whatsapp_messages',
    // فواتير - تُنشأ محلياً وتُدفع للسيرفر
    'invoices',
  ];

  // _tablesNotInSupabase removed — both cash_movements and audit_log now
  // exist in Supabase (confirmed in schema_summary.json).

  /// الحد الأقصى لعدد المحاولات
  static const int maxRetries = 5;

  /// حجم الدفعة
  static const int batchSize = 100;

  PushStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
    ConflictResolver conflictResolver = const ConflictResolver(),
  }) : _client = client,
       _syncQueueDao = db.syncQueueDao,
       _metadataDao = metadataDao,
       _conflictResolver = conflictResolver;

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
          .where(
            (item) =>
                pushTables.contains(item.tableName_) &&
                item.retryCount < maxRetries,
          )
          .take(batchSize)
          .toList();

      for (final item in itemsToPush) {
        try {
          // تعيين كـ "جاري المزامنة"
          await _syncQueueDao.markAsSyncing(item.id);

          // تحليل البيانات
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;

          // ZATCA append-only guard: reject UPDATE pushes on completed sales
          if (_isAppendOnlyViolation(item.tableName_, item.operation, payload)) {
            await _syncQueueDao.markAsFailed(
              item.id,
              'append_only_violation: cannot push UPDATE for '
              '${item.tableName_} with status ${payload['status']}',
            );
            failedCount++;
            errors.add(
              '${item.tableName_}/${item.recordId}: append_only_violation',
            );
            if (kDebugMode) {
              debugPrint(
                'PushStrategy: append_only_violation — '
                'blocked UPDATE on ${item.tableName_}/${item.recordId}',
              );
            }
            continue;
          }

          // تنفيذ العملية على السيرفر (with idempotency key & adaptive timeout)
          await _executeRemoteOperation(
            tableName: item.tableName_,
            operation: item.operation,
            payload: payload,
            idempotencyKey: item.idempotencyKey,
          );

          // حماية المبيعات: لا نحذف من الطابور حتى نتأكد من وجود البيع محلياً
          if (_isSacredTable(item.tableName_) &&
              item.operation.toUpperCase() != 'DELETE') {
            final localId = payload['id'] as String?;
            if (localId != null) {
              // فحص بسيط: تأكد أن الـ ID موجود وصالح
              if (localId.isEmpty) {
                // إعادة إضافة للطابور بدلاً من فقدان البيانات
                await _syncQueueDao.markAsFailed(
                  item.id,
                  'Sacred data protection: empty ID after push',
                );
                failedCount++;
                errors.add(
                  '${item.tableName_}/${item.recordId}: Sacred data verification failed',
                );
                if (kDebugMode) {
                  debugPrint(
                    'PushStrategy: Sacred data (${item.tableName_}) verification failed - re-queued',
                  );
                }
                continue;
              }
            }
          }

          // نجاح: تعيين كـ "تمت المزامنة"
          await _syncQueueDao.markAsSynced(item.id);
          successCount++;
        } on PostgrestException catch (e) {
          failedCount++;
          final errorMsg = 'DB ${e.code}: ${e.message}';
          errors.add('${item.tableName_}/${item.recordId}: $errorMsg');
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;

          if (kDebugMode) {
            debugPrint(
              'Push DB error for ${item.tableName_}/${item.recordId}: ${e.code} ${e.message}',
            );
          }

          // --- Conflict Type Detection ---

          // A. Schema mismatch: table/column does not exist (42P01)
          final isTableMissing =
              e.code == '42P01' ||
              (e.message.contains('relation') &&
                  e.message.contains('does not exist'));
          if (isTableMissing) {
            final conflict = SyncConflict(
              syncQueueId: item.id,
              tableName: item.tableName_,
              recordId: item.recordId,
              type: ConflictType.schemaMismatch,
              operation: item.operation,
              localData: payload,
              errorMessage: errorMsg,
            );
            await _syncQueueDao.markAsConflict(
              item.id,
              conflict.toJsonString(),
            );
            if (kDebugMode) {
              debugPrint(
                'PushStrategy: Table "${item.tableName_}" missing from Supabase - '
                'marked as schemaMismatch conflict (no retry).',
              );
            }
            continue;
          }

          // B. Duplicate key conflict (PostgreSQL 23505 unique_violation)
          if (e.code == '23505') {
            if (kDebugMode) {
              debugPrint(
                'PushStrategy: Duplicate key for ${item.tableName_}/${item.recordId} - '
                'auto-resolving by converting to UPSERT',
              );
            }
            // Auto-resolve: retry as upsert instead of insert
            try {
              await _executeUpsert(
                tableName: item.tableName_,
                payload: payload,
              );
              await _syncQueueDao.markAsSynced(item.id);
              successCount++;
              failedCount--; // undo the increment above
              errors.removeLast(); // undo the error added above
              if (kDebugMode) {
                debugPrint(
                  'PushStrategy: Duplicate key auto-resolved via UPSERT for '
                  '${item.tableName_}/${item.recordId}',
                );
              }
            } catch (upsertError) {
              final conflict = SyncConflict(
                syncQueueId: item.id,
                tableName: item.tableName_,
                recordId: item.recordId,
                type: ConflictType.duplicateKey,
                operation: item.operation,
                localData: payload,
                errorMessage: 'UPSERT fallback failed: $upsertError',
              );
              await _syncQueueDao.markAsConflict(
                item.id,
                conflict.toJsonString(),
              );
            }
            continue;
          }

          // C. Version conflict (HTTP 409 Conflict or updated_at mismatch)
          final isVersionConflict =
              e.code == '409' ||
              (e.message.contains('conflict') || e.message.contains('409'));
          if (isVersionConflict) {
            // Fetch server version to store both sides
            Map<String, dynamic>? serverData;
            try {
              final response = await _client
                  .from(item.tableName_)
                  .select()
                  .eq('id', item.recordId)
                  .maybeSingle()
                  .timeout(const Duration(seconds: 10));
              serverData = response;
            } catch (_) {
              // Best effort - may not get server data
            }

            final conflict = SyncConflict(
              syncQueueId: item.id,
              tableName: item.tableName_,
              recordId: item.recordId,
              type: ConflictType.versionConflict,
              operation: item.operation,
              localData: payload,
              serverData: serverData,
              errorMessage: errorMsg,
            );

            // Try auto-resolution
            final resolution = await _conflictResolver.resolve(conflict);
            if (resolution.resolved && resolution.resolvedData != null) {
              try {
                await _executeUpsert(
                  tableName: item.tableName_,
                  payload: resolution.resolvedData!,
                );
                await _syncQueueDao.markAsSynced(item.id);
                successCount++;
                failedCount--;
                errors.removeLast();
                if (kDebugMode) {
                  debugPrint(
                    'PushStrategy: Version conflict auto-resolved (${resolution.strategy.name}) '
                    'for ${item.tableName_}/${item.recordId}: ${resolution.description}',
                  );
                }
              } catch (resolveError) {
                await _syncQueueDao.markAsConflict(
                  item.id,
                  conflict.toJsonString(),
                );
              }
            } else {
              await _syncQueueDao.markAsConflict(
                item.id,
                conflict.toJsonString(),
              );
            }
            continue;
          }

          // D. Delete-Update conflict: local UPDATE but server record deleted (404 on row)
          final isRecordNotFound =
              e.code == 'PGRST116' ||
              (e.message.contains('not found') || e.message.contains('0 rows'));
          if (isRecordNotFound && item.operation.toUpperCase() == 'UPDATE') {
            final conflict = SyncConflict(
              syncQueueId: item.id,
              tableName: item.tableName_,
              recordId: item.recordId,
              type: ConflictType.deleteUpdate,
              operation: item.operation,
              localData: payload,
              serverData: null, // record was deleted on server
              errorMessage:
                  'Record deleted on server, local has update: $errorMsg',
            );

            final resolution = await _conflictResolver.resolve(conflict);
            if (resolution.resolved && resolution.resolvedData != null) {
              try {
                // Re-create the record on server using the resolved data
                await _executeUpsert(
                  tableName: item.tableName_,
                  payload: resolution.resolvedData!,
                );
                await _syncQueueDao.markAsSynced(item.id);
                successCount++;
                failedCount--;
                errors.removeLast();
                if (kDebugMode) {
                  debugPrint(
                    'PushStrategy: Delete-update conflict auto-resolved (${resolution.strategy.name}) '
                    'for ${item.tableName_}/${item.recordId}',
                  );
                }
              } catch (resolveError) {
                await _syncQueueDao.markAsConflict(
                  item.id,
                  conflict.toJsonString(),
                );
              }
            } else {
              await _syncQueueDao.markAsConflict(
                item.id,
                conflict.toJsonString(),
              );
            }
            continue;
          }

          // E. Other DB errors: standard retry with backoff
          await _syncQueueDao.markAsFailed(item.id, errorMsg);
          if (item.retryCount + 1 >= maxRetries) {
            final conflict = SyncConflict(
              syncQueueId: item.id,
              tableName: item.tableName_,
              recordId: item.recordId,
              type: ConflictType.versionConflict,
              operation: item.operation,
              localData: payload,
              errorMessage: 'Max retries reached (DB error): ${e.message}',
            );
            await _syncQueueDao.markAsConflict(
              item.id,
              conflict.toJsonString(),
            );
          }
        } on TimeoutException {
          if (kDebugMode) {
            debugPrint('Push timeout for ${item.tableName_}/${item.recordId}');
          }

          // Idempotency check: the server may have already processed the
          // request before the timeout fired. Verify before retrying to
          // avoid creating duplicates.
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;
          final recordId = payload['id'] as String? ?? item.recordId;
          final storeId =
              payload['storeId'] as String? ??
              payload['store_id'] as String? ??
              '';

          if (storeId.isNotEmpty && item.operation.toUpperCase() != 'DELETE') {
            final alreadySynced = await _apiService.isRecordSynced(
              item.tableName_,
              recordId,
              storeId,
            );
            if (alreadySynced) {
              // Server already has the record -- treat as success
              await _syncQueueDao.markAsSynced(item.id);
              successCount++;
              if (kDebugMode) {
                debugPrint(
                  'PushStrategy: Timeout recovered - record already on server '
                  '${item.tableName_}/$recordId',
                );
              }
              continue;
            }
          }

          // Record not found on server (or couldn't verify) -- mark as failed for retry
          failedCount++;
          errors.add('${item.tableName_}/${item.recordId}: Timeout');

          final conflict = SyncConflict(
            syncQueueId: item.id,
            tableName: item.tableName_,
            recordId: item.recordId,
            type: ConflictType.networkTimeout,
            operation: item.operation,
            errorMessage: 'Network timeout',
          );
          await _syncQueueDao.markAsFailed(item.id, conflict.toJsonString());

          if (item.retryCount + 1 >= maxRetries) {
            await _syncQueueDao.markAsConflict(
              item.id,
              conflict.toJsonString(),
            );
          }
        } catch (e) {
          failedCount++;
          errors.add('${item.tableName_}/${item.recordId}: $e');

          await _syncQueueDao.markAsFailed(item.id, e.toString());

          if (kDebugMode) {
            debugPrint(
              'Push failed for ${item.tableName_}/${item.recordId}: $e',
            );
          }

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
    String? idempotencyKey,
  }) async {
    // تحويل JSONB fields من نص إلى كائنات
    final remotePayload = _jsonConverter.toRemote(tableName, payload);

    // تنظيف الحقول المحلية (including per-table local-only columns)
    final cleanPayload = _cleanPayload(remotePayload, tableName: tableName);

    // M36: إعادة تسمية الأعمدة المحلية لتتوافق مع مخطط Supabase
    final mappedPayload = mapColumnsToRemote(tableName, cleanPayload);

    // Include idempotency_key so the server can detect duplicate pushes
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      mappedPayload['idempotency_key'] = idempotencyKey;
    }

    // تجاهل جداول المؤسسة (تُعالج بخدمة مزامنة المؤسسة)
    if (OrgTables.all.contains(tableName)) return;

    // Adaptive timeout based on payload size
    final payloadBytes = utf8.encode(jsonEncode(mappedPayload)).length;
    final timeout = SyncApiService.getAdaptiveTimeout(payloadBytes);

    switch (operation.toUpperCase()) {
      case 'CREATE':
      case 'UPDATE':
        await _client
            .from(tableName)
            .upsert(mappedPayload, onConflict: 'id')
            .timeout(timeout);
        break;
      case 'DELETE':
        final id = mappedPayload['id'] as String?;
        if (id != null) {
          await _client.from(tableName).delete().eq('id', id).timeout(timeout);
        }
        break;
    }
  }

  /// Execute an upsert (INSERT ... ON CONFLICT UPDATE) on the server
  ///
  /// Used for:
  /// - Auto-resolving duplicate key conflicts (23505)
  /// - Re-creating records after delete-update conflict resolution
  /// - Applying resolved version conflict data
  Future<void> _executeUpsert({
    required String tableName,
    required Map<String, dynamic> payload,
  }) async {
    final remotePayload = _jsonConverter.toRemote(tableName, payload);
    final cleanPayload = _cleanPayload(remotePayload, tableName: tableName);
    final mappedPayload = mapColumnsToRemote(tableName, cleanPayload);

    if (OrgTables.all.contains(tableName)) return;

    // Adaptive timeout based on payload size
    final payloadBytes = utf8.encode(jsonEncode(mappedPayload)).length;
    final timeout = SyncApiService.getAdaptiveTimeout(payloadBytes);

    await _client
        .from(tableName)
        .upsert(mappedPayload, onConflict: 'id')
        .timeout(timeout);
  }

  /// الجداول المقدسة التي لا يجوز فقدان بياناتها
  /// Sales are sacred - never lose sale data
  static const Set<String> _sacredTables = {'sales', 'sale_items'};

  /// هل هذا جدول مقدس (لا يمكن فقدان بياناته)؟
  bool _isSacredTable(String tableName) => _sacredTables.contains(tableName);

  /// ZATCA append-only: block UPDATE pushes on completed/paid/refunded sales.
  static const _immutableStatuses = {'completed', 'paid', 'refunded'};

  bool _isAppendOnlyViolation(
    String tableName,
    String operation,
    Map<String, dynamic> payload,
  ) {
    if (operation.toUpperCase() != 'UPDATE') return false;
    if (tableName != 'sales' && tableName != 'sale_items') return false;
    final status = payload['status'] as String?;
    // For sale_items, the status comes from the parent sale.  In the push
    // queue payload, sale_items don't carry status themselves, so we only
    // guard the sales table directly.
    if (tableName == 'sales' && _immutableStatuses.contains(status)) {
      return true;
    }
    return false;
  }

  /// تنظيف الحقول المحلية قبل الإرسال
  Map<String, dynamic> _cleanPayload(
    Map<String, dynamic> payload, {
    String? tableName,
  }) {
    return cleanSyncPayload(payload, removeItems: true, tableName: tableName);
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
