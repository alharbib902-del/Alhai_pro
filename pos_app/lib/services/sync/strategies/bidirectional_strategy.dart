import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/local/app_database.dart';
import '../../../data/local/daos/sync_metadata_dao.dart';
import '../../../data/local/daos/sync_queue_dao.dart';
import '../json_converter.dart';

/// سياسة حل التعارضات
enum ConflictResolution {
  /// الكتابة الأخيرة تفوز (بناءً على updated_at)
  lastWriteWins,

  /// المحلي يفوز (البيانات المحلية لها الأولوية)
  localWins,

  /// دمج الدلتا (للمخزون - يُعالج بـ StockDeltaSync)
  deltaMerge,
}

/// تكوين المزامنة ثنائية الاتجاه لجدول
class BidirectionalTableConfig {
  final String tableName;
  final ConflictResolution conflictResolution;

  const BidirectionalTableConfig({
    required this.tableName,
    required this.conflictResolution,
  });
}

/// استراتيجية المزامنة ثنائية الاتجاه
/// تُستخدم للبيانات التي تُعدل محلياً وعلى السيرفر:
/// حركات المخزون، العملاء، المصروفات، المرتجعات، المشتريات
///
/// آلية العمل:
/// 1. دفع التغييرات المحلية المعلقة أولاً
/// 2. سحب التغييرات من السيرفر
/// 3. كشف التعارضات ومقارنة synced_at مع server updated_at
/// 4. حل التعارضات حسب سياسة كل جدول
class BidirectionalStrategy {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncQueueDao _syncQueueDao;
  final SyncMetadataDao _metadataDao;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// تكوين الجداول ثنائية الاتجاه
  static const List<BidirectionalTableConfig> tableConfigs = [
    BidirectionalTableConfig(
      tableName: 'customers',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'expenses',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'returns',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'return_items',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'purchases',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'purchase_items',
      conflictResolution: ConflictResolution.localWins,
    ),
  ];

  /// حجم الصفحة
  static const int pageSize = 500;

  BidirectionalStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _syncQueueDao = db.syncQueueDao,
        _metadataDao = metadataDao;

  /// تنفيذ المزامنة ثنائية الاتجاه لجميع الجداول
  Future<List<BidirectionalResult>> syncAll({
    required String orgId,
    required String storeId,
  }) async {
    final results = <BidirectionalResult>[];
    for (final config in tableConfigs) {
      final result = await syncTable(
        config: config,
        orgId: orgId,
        storeId: storeId,
      );
      results.add(result);
    }
    return results;
  }

  /// تنفيذ المزامنة ثنائية الاتجاه لجدول واحد
  Future<BidirectionalResult> syncTable({
    required BidirectionalTableConfig config,
    required String orgId,
    required String storeId,
  }) async {
    int pushed = 0;
    int pulled = 0;
    int conflicts = 0;
    final errors = <String>[];

    try {
      // المرحلة 1: دفع التغييرات المحلية المعلقة
      pushed = await _pushLocalChanges(config.tableName);

      // المرحلة 2: سحب التغييرات من السيرفر
      final pullResult = await _pullServerChanges(
        tableName: config.tableName,
        orgId: orgId,
        storeId: storeId,
        conflictResolution: config.conflictResolution,
      );
      pulled = pullResult.pulled;
      conflicts = pullResult.conflicts;
      errors.addAll(pullResult.errors);

      // تحديث بيانات المزامنة الوصفية
      final now = DateTime.now().toUtc();
      await _metadataDao.updateLastPushAt(config.tableName, now,
          syncCount: pushed);
      await _metadataDao.updateLastPullAt(config.tableName, now,
          syncCount: pulled);
      await _metadataDao.clearError(config.tableName);
    } catch (e) {
      errors.add('Bidirectional ${config.tableName}: $e');
      await _metadataDao.setError(config.tableName, e.toString());
      if (kDebugMode) {
        debugPrint('BidirectionalStrategy error for ${config.tableName}: $e');
      }
    }

    return BidirectionalResult(
      tableName: config.tableName,
      pushed: pushed,
      pulled: pulled,
      conflicts: conflicts,
      errors: errors,
    );
  }

  /// دفع التغييرات المحلية المعلقة
  Future<int> _pushLocalChanges(String tableName) async {
    int count = 0;
    final pendingItems = await _syncQueueDao.getPendingItems();
    final tableItems =
        pendingItems.where((i) => i.tableName_ == tableName).toList();

    for (final item in tableItems) {
      try {
        await _syncQueueDao.markAsSyncing(item.id);
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        final remotePayload = _jsonConverter.toRemote(tableName, payload);
        final cleanPayload = _cleanPayload(remotePayload);

        switch (item.operation.toUpperCase()) {
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

        await _syncQueueDao.markAsSynced(item.id);
        count++;
      } catch (e) {
        await _syncQueueDao.markAsFailed(item.id, e.toString());
        if (kDebugMode) {
          debugPrint('Bidirectional push failed for $tableName/${item.recordId}: $e');
        }
      }
    }

    return count;
  }

  /// سحب التغييرات من السيرفر مع كشف التعارضات
  Future<_PullWithConflictsResult> _pullServerChanges({
    required String tableName,
    required String orgId,
    required String storeId,
    required ConflictResolution conflictResolution,
  }) async {
    int pulled = 0;
    int conflicts = 0;
    final errors = <String>[];

    // جلب آخر وقت سحب
    final lastPullAt = await _metadataDao.getLastPullAt(tableName);

    // جلب التغييرات من السيرفر
    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final records = await _fetchServerRecords(
        tableName: tableName,
        orgId: orgId,
        storeId: storeId,
        since: lastPullAt,
        offset: offset,
      );

      if (records.isEmpty) {
        hasMore = false;
        break;
      }

      for (final serverRecord in records) {
        try {
          final result = await _applyServerRecord(
            tableName: tableName,
            serverRecord: serverRecord,
            conflictResolution: conflictResolution,
          );
          if (result == _ApplyResult.pulled) {
            pulled++;
          } else if (result == _ApplyResult.conflict) {
            conflicts++;
          }
        } catch (e) {
          errors.add('Apply $tableName/${serverRecord['id']}: $e');
        }
      }

      if (records.length < pageSize) {
        hasMore = false;
      } else {
        offset += pageSize;
      }
    }

    return _PullWithConflictsResult(
      pulled: pulled,
      conflicts: conflicts,
      errors: errors,
    );
  }

  /// تطبيق سجل من السيرفر مع كشف التعارض
  Future<_ApplyResult> _applyServerRecord({
    required String tableName,
    required Map<String, dynamic> serverRecord,
    required ConflictResolution conflictResolution,
  }) async {
    final recordId = serverRecord['id'] as String;

    // التعامل مع الحذف الناعم
    if (serverRecord['deleted_at'] != null) {
      await _db.customStatement(
        'DELETE FROM $tableName WHERE id = ?',
        [recordId],
      );
      return _ApplyResult.pulled;
    }

    // تحديد عمود الوقت المتاح
    final timeCol = _getOrderColumn(tableName);

    // التحقق من وجود سجل محلي
    final List<QueryRow> localRows;
    if (timeCol != null) {
      localRows = await _db.customSelect(
        'SELECT synced_at, $timeCol as time_col FROM $tableName WHERE id = ?',
        variables: [Variable.withString(recordId)],
      ).get();
    } else {
      // جداول بدون أعمدة زمنية: نتحقق فقط من الوجود
      localRows = await _db.customSelect(
        'SELECT id FROM $tableName WHERE id = ?',
        variables: [Variable.withString(recordId)],
      ).get();
    }

    if (localRows.isEmpty) {
      // سجل جديد: إدراج مباشر
      await _upsertRecord(tableName, serverRecord);
      return _ApplyResult.pulled;
    }

    // جداول بدون أعمدة زمنية: تحديث مباشر (لا يمكن كشف التعارض)
    if (timeCol == null) {
      if (conflictResolution == ConflictResolution.localWins) {
        return _ApplyResult.conflict;
      }
      await _upsertRecord(tableName, serverRecord);
      return _ApplyResult.pulled;
    }

    // كشف التعارض: مقارنة الأوقات
    final localRow = localRows.first;
    final localSyncedAt = localRow.data['synced_at'] as String?;
    final localTimeCol = localRow.data['time_col'] as String?;
    final serverTimeCol = serverRecord[timeCol] as String?;

    // إذا لم يُعدل محلياً منذ آخر مزامنة، لا تعارض
    if (localSyncedAt != null && localTimeCol != null) {
      final syncTime = DateTime.parse(localSyncedAt);
      final updateTime = DateTime.parse(localTimeCol);
      if (!updateTime.isAfter(syncTime)) {
        // لم يُعدل محلياً، تحديث مباشر
        await _upsertRecord(tableName, serverRecord);
        return _ApplyResult.pulled;
      }
    }

    // يوجد تعارض: حل حسب السياسة
    switch (conflictResolution) {
      case ConflictResolution.lastWriteWins:
        // مقارنة الأوقات
        if (serverTimeCol != null && localTimeCol != null) {
          final serverTime = DateTime.parse(serverTimeCol);
          final localTime = DateTime.parse(localTimeCol);
          if (serverTime.isAfter(localTime)) {
            await _upsertRecord(tableName, serverRecord);
            return _ApplyResult.pulled;
          }
        }
        return _ApplyResult.conflict;

      case ConflictResolution.localWins:
        // المحلي يفوز: نتجاهل تغيير السيرفر
        return _ApplyResult.conflict;

      case ConflictResolution.deltaMerge:
        // يُعالج بـ StockDeltaSync، لا نفعل شيئاً هنا
        return _ApplyResult.conflict;
    }
  }

  /// جلب سجلات من السيرفر
  Future<List<Map<String, dynamic>>> _fetchServerRecords({
    required String tableName,
    required String orgId,
    required String storeId,
    DateTime? since,
    int offset = 0,
  }) async {
    var query = _client.from(tableName).select();

    // فلترة حسب الأعمدة المتاحة لكل جدول
    if (_hasOrgId(tableName)) {
      query = query.eq('org_id', orgId);
    }
    if (_hasStoreId(tableName)) {
      query = query.eq('store_id', storeId);
    }

    final orderCol = _getOrderColumn(tableName);

    if (since != null && orderCol != null) {
      query = query.gte(orderCol, since.toUtc().toIso8601String());
    }

    if (orderCol != null) {
      final response = await query
          .order(orderCol, ascending: true)
          .range(offset, offset + pageSize - 1);
      final records = List<Map<String, dynamic>>.from(response);
      return _jsonConverter.batchToLocal(tableName, records);
    } else {
      // جداول بدون أعمدة زمنية (return_items, purchase_items)
      final response = await query.range(offset, offset + pageSize - 1);
      final records = List<Map<String, dynamic>>.from(response);
      return _jsonConverter.batchToLocal(tableName, records);
    }
  }

  /// هل يحتوي الجدول على عمود org_id في Supabase؟
  bool _hasOrgId(String tableName) {
    // فقط هذه الجداول لديها org_id فعلياً في Supabase
    const tablesWithOrgId = {
      'customers', 'expenses', 'returns', 'purchases',
    };
    return tablesWithOrgId.contains(tableName);
  }

  /// هل يحتوي الجدول على عمود store_id في Supabase؟
  bool _hasStoreId(String tableName) {
    // return_items و purchase_items ليس لديهم store_id
    const tablesWithStoreId = {
      'customers', 'expenses', 'returns', 'purchases',
    };
    return tablesWithStoreId.contains(tableName);
  }

  /// عمود الترتيب الزمني المتاح لكل جدول
  String? _getOrderColumn(String tableName) {
    const tablesWithUpdatedAt = {
      'customers', 'expenses', 'purchases',
    };
    const tablesWithCreatedAtOnly = {'returns'};
    if (tablesWithUpdatedAt.contains(tableName)) return 'updated_at';
    if (tablesWithCreatedAtOnly.contains(tableName)) return 'created_at';
    // return_items و purchase_items ليس لديهم أعمدة زمنية
    return null;
  }

  /// إدراج/تحديث سجل محلياً
  Future<void> _upsertRecord(
      String tableName, Map<String, dynamic> record) async {
    final columns = record.keys.toList();
    final placeholders = columns.map((_) => '?').join(', ');
    final updates = columns
        .where((c) => c != 'id')
        .map((c) => '$c = excluded.$c')
        .join(', ');

    await _db.customStatement(
      'INSERT INTO $tableName (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $updates',
      columns.map((c) => record[c]).toList(),
    );
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    final clean = Map<String, dynamic>.from(payload);
    clean.remove('syncedAt');
    clean.remove('synced_at');
    clean.remove('items');
    return clean;
  }
}

enum _ApplyResult { pulled, conflict }

class _PullWithConflictsResult {
  final int pulled;
  final int conflicts;
  final List<String> errors;

  _PullWithConflictsResult({
    required this.pulled,
    required this.conflicts,
    required this.errors,
  });
}

/// نتيجة المزامنة ثنائية الاتجاه
class BidirectionalResult {
  final String tableName;
  final int pushed;
  final int pulled;
  final int conflicts;
  final List<String> errors;

  BidirectionalResult({
    required this.tableName,
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}
