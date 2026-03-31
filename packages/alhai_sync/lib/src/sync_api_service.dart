import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'json_converter.dart';
import 'sync_payload_utils.dart';

/// خدمة المزامنة مع Supabase REST API
/// تنفذ المزامنة الفعلية مع قاعدة بيانات Supabase
class SyncApiService {
  final SupabaseClient _client;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  SyncApiService({required SupabaseClient client}) : _client = client;

  /// Check if record was already synced (for timeout recovery).
  ///
  /// When a push times out, the server may have already processed the request.
  /// Call this before retrying to avoid creating duplicates.
  Future<bool> isRecordSynced(String tableName, String recordId, String storeId) async {
    try {
      final response = await _client
          .from(tableName)
          .select('id, updated_at')
          .eq('id', recordId)
          .eq('store_id', storeId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
      return response != null;
    } catch (_) {
      return false; // Can't verify, will retry
    }
  }

  /// Calculate adaptive timeout based on payload size in bytes.
  ///
  /// Large payloads (e.g. sales with many items) need more time.
  static Duration getAdaptiveTimeout(int payloadSizeBytes) {
    if (payloadSizeBytes > 500000) return const Duration(seconds: 60);
    if (payloadSizeBytes > 100000) return const Duration(seconds: 45);
    return const Duration(seconds: 30);
  }

  /// تنفيذ المزامنة لعملية واحدة
  Future<void> syncOperation({
    required String tableName,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    // Convert JSONB text fields to proper objects before sending
    final remotePayload = _jsonConverter.toRemote(tableName, payload);

    switch (operation.toUpperCase()) {
      case 'CREATE':
      case 'UPDATE':
        await _upsert(tableName, remotePayload);
        break;
      case 'DELETE':
        await _delete(tableName, remotePayload);
        break;
      default:
        throw UnsupportedError('Unsupported operation: $operation');
    }
  }

  /// إدراج أو تحديث سجل (upsert)
  Future<void> _upsert(String tableName, Map<String, dynamic> payload) async {
    // Clean payload: remove local-only fields
    final cleanPayload = _cleanPayload(tableName, payload);

    try {
      await _client.from(tableName).upsert(
        cleanPayload,
        onConflict: 'id',
      ).timeout(const Duration(seconds: 30));
    } on PostgrestException catch (e) {
      // FK violation على customer_id → إعادة المحاولة بدون العميل
      if (_isForeignKeyError(e) && cleanPayload.containsKey('customer_id')) {
        if (kDebugMode) {
          debugPrint('Sync: FK error on $tableName customer_id, retrying without it');
        }
        final retryPayload = Map<String, dynamic>.from(cleanPayload)
          ..remove('customer_id');
        try {
          await _client.from(tableName).upsert(
            retryPayload,
            onConflict: 'id',
          ).timeout(const Duration(seconds: 30));
          return; // نجحت بدون customer_id
        } catch (_) {
          // الخطأ الثاني — نرمي الخطأ الأصلي
        }
      }
      if (kDebugMode) {
        debugPrint('Sync upsert DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Sync upsert timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync upsert error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// هل الخطأ من نوع FK violation؟
  bool _isForeignKeyError(PostgrestException e) {
    // PostgreSQL error code 23503 = foreign_key_violation
    return e.code == '23503' ||
        (e.message?.contains('foreign key') ?? false) ||
        (e.message?.contains('violates foreign key') ?? false);
  }

  /// حذف سجل
  Future<void> _delete(String tableName, Map<String, dynamic> payload) async {
    final id = payload['id'] as String?;
    if (id == null) {
      throw ArgumentError('Delete operation requires an "id" field');
    }

    try {
      await _client.from(tableName).delete().eq('id', id).timeout(const Duration(seconds: 30));
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('Sync delete DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Sync delete timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync delete error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// تنظيف الحمولة من الحقول المحلية فقط
  Map<String, dynamic> _cleanPayload(
      String tableName, Map<String, dynamic> payload) {
    // Remove local-only fields (including embedded items), then convert to snake_case for Supabase
    return toSnakeCase(cleanSyncPayload(payload, removeItems: true));
  }

  /// مزامنة مجموعة عمليات (batch)
  Future<SyncBatchResult> syncBatch(
      List<SyncOperationItem> operations) async {
    int successCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    for (final op in operations) {
      try {
        await syncOperation(
          tableName: op.tableName,
          operation: op.operation,
          payload: op.payload,
        );
        successCount++;
      } catch (e) {
        failedCount++;
        errors.add('${op.tableName}/${op.recordId}: $e');
      }
    }

    return SyncBatchResult(
      successCount: successCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  /// جلب التحديثات من السيرفر لجدول معين (مع تقسيم الصفحات)
  ///
  /// يجلب السجلات على دفعات بحجم [pageSize] لتجنب timeout/OOM
  /// عند وجود آلاف السجلات (مثل 9,742 منتج).
  Future<List<Map<String, dynamic>>> fetchUpdates({
    required String tableName,
    required String storeId,
    DateTime? since,
    int pageSize = 500,
  }) async {
    try {
      final allRecords = await _fetchPaginated(
        tableName,
        storeId,
        since,
        pageSize: pageSize,
      );
      // Convert JSONB fields from remote to local text format
      return _jsonConverter.batchToLocal(tableName, allRecords);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch updates DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Fetch updates timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch updates error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// جلب السجلات بشكل مُقسّم على صفحات لتجنب timeout/OOM
  Future<List<Map<String, dynamic>>> _fetchPaginated(
    String tableName,
    String storeId,
    DateTime? since, {
    int pageSize = 500,
  }) async {
    final allRecords = <Map<String, dynamic>>[];
    int offset = 0;

    while (true) {
      var query = _client
          .from(tableName)
          .select()
          .eq('store_id', storeId);

      if (since != null) {
        query = query.gte('updated_at', since.toIso8601String());
      }

      final response = await query
          .order('updated_at', ascending: true)
          .range(offset, offset + pageSize - 1)
          .timeout(const Duration(seconds: 30));

      final records = List<Map<String, dynamic>>.from(response);
      allRecords.addAll(records);

      if (kDebugMode && records.isNotEmpty) {
        debugPrint('[SyncApi] Fetched page: $tableName offset=$offset count=${records.length}');
      }

      if (records.length < pageSize) break; // Last page
      offset += pageSize;
    }

    return allRecords;
  }

  /// جلب سجل واحد بالـ ID
  Future<Map<String, dynamic>?> fetchById({
    required String tableName,
    required String id,
  }) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(const Duration(seconds: 30));
      if (response == null) return null;
      // Convert JSONB fields from remote to local text format
      return _jsonConverter.toLocal(tableName, response);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch by ID DB error for $tableName/$id: ${e.code} ${e.message}');
      }
      return null;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Fetch by ID timeout for $tableName/$id');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch by ID error for $tableName/$id: $e');
      }
      return null;
    }
  }
}

/// عنصر عملية مزامنة
class SyncOperationItem {
  final String tableName;
  final String operation;
  final String recordId;
  final Map<String, dynamic> payload;

  SyncOperationItem({
    required this.tableName,
    required this.operation,
    required this.recordId,
    required this.payload,
  });
}

/// نتيجة مزامنة مجموعة عمليات
class SyncBatchResult {
  final int successCount;
  final int failedCount;
  final List<String> errors;

  SyncBatchResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });

  bool get hasErrors => failedCount > 0;
  int get totalCount => successCount + failedCount;
}
