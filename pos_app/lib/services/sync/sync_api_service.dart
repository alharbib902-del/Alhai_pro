import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'json_converter.dart';

/// خدمة المزامنة مع Supabase REST API
/// تنفذ المزامنة الفعلية مع قاعدة بيانات Supabase
class SyncApiService {
  final SupabaseClient _client;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  SyncApiService({required SupabaseClient client}) : _client = client;

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
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync upsert error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// حذف سجل
  Future<void> _delete(String tableName, Map<String, dynamic> payload) async {
    final id = payload['id'] as String?;
    if (id == null) {
      throw ArgumentError('Delete operation requires an "id" field');
    }

    try {
      await _client.from(tableName).delete().eq('id', id);
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
    final clean = Map<String, dynamic>.from(payload);

    // Remove drift/local-only fields
    clean.remove('syncedAt');
    clean.remove('synced_at');

    // Convert camelCase to snake_case for Supabase
    return _toSnakeCase(clean);
  }

  /// تحويل مفاتيح الـ Map من camelCase إلى snake_case
  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> map) {
    return map.map((key, value) {
      final snakeKey = _camelToSnake(key);
      // Handle nested maps recursively
      if (value is Map<String, dynamic>) {
        return MapEntry(snakeKey, _toSnakeCase(value));
      }
      return MapEntry(snakeKey, value);
    });
  }

  /// تحويل نص من camelCase إلى snake_case
  String _camelToSnake(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
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

  /// جلب التحديثات من السيرفر لجدول معين
  Future<List<Map<String, dynamic>>> fetchUpdates({
    required String tableName,
    required String storeId,
    DateTime? since,
  }) async {
    try {
      var query = _client
          .from(tableName)
          .select()
          .eq('store_id', storeId);

      if (since != null) {
        query = query.gte('updated_at', since.toIso8601String());
      }

      final response = await query;
      final records = List<Map<String, dynamic>>.from(response);
      // Convert JSONB fields from remote to local text format
      return _jsonConverter.batchToLocal(tableName, records);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Fetch updates error for $tableName: $e');
      }
      rethrow;
    }
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
          .maybeSingle();
      if (response == null) return null;
      // Convert JSONB fields from remote to local text format
      return _jsonConverter.toLocal(tableName, response);
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
