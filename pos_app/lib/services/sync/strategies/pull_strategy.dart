import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/daos/sync_metadata_dao.dart';
import '../json_converter.dart';

/// استراتيجية السحب (Pull): السيرفر ← المحلي
/// تُستخدم للبيانات التي يديرها السيرفر: المنتجات، التصنيفات، المتاجر، الأدوار، الإعدادات
///
/// آلية العمل:
/// 1. جلب آخر وقت سحب من sync_metadata
/// 2. جلب السجلات المحدثة من السيرفر (updated_at > last_pull_at)
/// 3. إدراج أو تحديث محلياً (upsert)
/// 4. تحديث last_pull_at في sync_metadata
class PullStrategy {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncMetadataDao _metadataDao;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// الجداول التي يتم سحبها من السيرفر
  static const List<String> pullTables = [
    'categories',
    'products',
    'stores',
    'roles',
    'settings',
  ];

  /// حجم الصفحة لجلب البيانات
  static const int pageSize = 500;

  PullStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _metadataDao = metadataDao;

  /// تنفيذ السحب لجدول معين
  Future<PullResult> pullTable({
    required String tableName,
    required String orgId,
    required String storeId,
  }) async {
    int totalPulled = 0;
    final errors = <String>[];

    try {
      // جلب آخر وقت سحب
      final lastPullAt = await _metadataDao.getLastPullAt(tableName);

      // جلب البيانات من السيرفر بالصفحات
      int page = 0;
      bool hasMore = true;

      while (hasMore) {
        final records = await _fetchPage(
          tableName: tableName,
          orgId: orgId,
          storeId: storeId,
          since: lastPullAt,
          offset: page * pageSize,
        );

        if (records.isEmpty) {
          hasMore = false;
          break;
        }

        // إدراج/تحديث محلياً
        await _upsertLocally(tableName, records);
        totalPulled += records.length;

        if (records.length < pageSize) {
          hasMore = false;
        } else {
          page++;
        }
      }

      // تحديث آخر وقت سحب
      await _metadataDao.updateLastPullAt(
        tableName,
        DateTime.now().toUtc(),
        syncCount: totalPulled,
      );
      await _metadataDao.clearError(tableName);
    } catch (e) {
      errors.add('Pull $tableName: $e');
      await _metadataDao.setError(tableName, e.toString());
      if (kDebugMode) {
        debugPrint('PullStrategy error for $tableName: $e');
      }
    }

    return PullResult(
      tableName: tableName,
      recordsPulled: totalPulled,
      errors: errors,
    );
  }

  /// تنفيذ السحب لجميع الجداول
  Future<List<PullResult>> pullAll({
    required String orgId,
    required String storeId,
  }) async {
    final results = <PullResult>[];
    for (final tableName in pullTables) {
      final result = await pullTable(
        tableName: tableName,
        orgId: orgId,
        storeId: storeId,
      );
      results.add(result);
    }
    return results;
  }

  /// جلب صفحة من البيانات من السيرفر
  Future<List<Map<String, dynamic>>> _fetchPage({
    required String tableName,
    required String orgId,
    required String storeId,
    DateTime? since,
    int offset = 0,
  }) async {
    var query = _client
        .from(tableName)
        .select()
        .eq('org_id', orgId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final response = await query
        .order('updated_at', ascending: true)
        .range(offset, offset + pageSize - 1);

    final records = List<Map<String, dynamic>>.from(response);
    return _jsonConverter.batchToLocal(tableName, records);
  }

  /// إدراج/تحديث السجلات محلياً باستخدام SQL مباشر
  Future<void> _upsertLocally(
      String tableName, List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;

    await _db.batch((batch) {
      for (final record in records) {
        // التعامل مع الحذف الناعم
        final deletedAt = record['deleted_at'];
        if (deletedAt != null) {
          // حذف ناعم: حذف السجل محلياً
          batch.customStatement(
            'DELETE FROM $tableName WHERE id = ?',
            [record['id']],
          );
        } else {
          // إدراج أو تحديث
          final columns = record.keys.toList();
          final placeholders = columns.map((_) => '?').join(', ');
          final updates = columns
              .where((c) => c != 'id')
              .map((c) => '$c = excluded.$c')
              .join(', ');

          batch.customStatement(
            'INSERT INTO $tableName (${columns.join(', ')}) '
            'VALUES ($placeholders) '
            'ON CONFLICT(id) DO UPDATE SET $updates',
            columns.map((c) => record[c]).toList(),
          );
        }
      }
    });
  }
}

/// نتيجة عملية السحب
class PullResult {
  final String tableName;
  final int recordsPulled;
  final List<String> errors;

  PullResult({
    required this.tableName,
    required this.recordsPulled,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}
