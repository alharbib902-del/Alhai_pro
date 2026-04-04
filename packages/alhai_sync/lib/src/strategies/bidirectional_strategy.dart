import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import '../conflict_resolver.dart';
import '../json_converter.dart';
import '../sync_payload_utils.dart';
import '../sync_table_validator.dart';

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
  final ConflictResolver _conflictResolver;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// تكوين الجداول ثنائية الاتجاه
  /// كل جدول له سياسة حل تعارض تناسب طبيعة البيانات
  static const List<BidirectionalTableConfig> tableConfigs = [
    // --- جداول موجودة ---
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
    // --- جداول جديدة ---
    BidirectionalTableConfig(
      tableName: 'shifts',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'suppliers',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'notifications',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'loyalty_points',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'loyalty_transactions',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'customer_addresses',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'accounts',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'transactions',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'product_expiry',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'stock_takes',
      conflictResolution: ConflictResolution.localWins,
    ),
    BidirectionalTableConfig(
      tableName: 'stock_transfers',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
    BidirectionalTableConfig(
      tableName: 'whatsapp_templates',
      conflictResolution: ConflictResolution.lastWriteWins,
    ),
  ];

  /// حجم الصفحة
  static const int pageSize = 500;

  BidirectionalStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
    ConflictResolver conflictResolver = const ConflictResolver(),
  })  : _client = client,
        _db = db,
        _syncQueueDao = db.syncQueueDao,
        _metadataDao = metadataDao,
        _conflictResolver = conflictResolver;

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
      final pushResult = await _pushLocalChanges(config.tableName);
      pushed = pushResult.count;

      // المرحلة 2: سحب التغييرات من السيرفر
      // Skip records that were just pushed in this cycle to avoid overwriting
      final pullResult = await _pullServerChanges(
        tableName: config.tableName,
        orgId: orgId,
        storeId: storeId,
        conflictResolution: config.conflictResolution,
        justPushedIds: pushResult.pushedIds,
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
  Future<_PushResult> _pushLocalChanges(String tableName) async {
    int count = 0;
    final pushedIds = <String>{};
    final pendingItems = await _syncQueueDao.getPendingItems();
    final tableItems =
        pendingItems.where((i) => i.tableName_ == tableName).toList();

    for (final item in tableItems) {
      try {
        await _syncQueueDao.markAsSyncing(item.id);
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        final remotePayload = _jsonConverter.toRemote(tableName, payload);
        final cleanPayload = _cleanPayload(remotePayload, tableName: tableName);
        // M36: إعادة تسمية الأعمدة المحلية لتتوافق مع مخطط Supabase
        final mappedPayload = mapColumnsToRemote(tableName, cleanPayload);

        switch (item.operation.toUpperCase()) {
          case 'CREATE':
          case 'UPDATE':
            await _client
                .from(tableName)
                .upsert(
                  mappedPayload,
                  onConflict: 'id',
                )
                .timeout(const Duration(seconds: 30));
            break;
          case 'DELETE':
            final id = mappedPayload['id'] as String?;
            if (id != null) {
              await _client
                  .from(tableName)
                  .delete()
                  .eq('id', id)
                  .timeout(const Duration(seconds: 30));
            }
            break;
        }

        await _syncQueueDao.markAsSynced(item.id);
        count++;
        pushedIds.add(item.recordId);
      } on PostgrestException catch (e) {
        final errorMsg = 'DB ${e.code}: ${e.message}';
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        if (kDebugMode) {
          debugPrint(
              'Bidirectional push DB error for $tableName/${item.recordId}: ${e.code} ${e.message}');
        }

        // Duplicate key (23505): auto-resolve by converting to upsert
        if (e.code == '23505') {
          try {
            await _client
                .from(tableName)
                .upsert(
                  _cleanPayload(_jsonConverter.toRemote(tableName, payload),
                      tableName: tableName),
                  onConflict: 'id',
                )
                .timeout(const Duration(seconds: 30));
            await _syncQueueDao.markAsSynced(item.id);
            count++;
            pushedIds.add(item.recordId);
            if (kDebugMode) {
              debugPrint(
                  'Bidirectional: duplicate key auto-resolved via UPSERT for $tableName/${item.recordId}');
            }
            continue;
          } catch (_) {
            // UPSERT fallback failed, fall through to mark as conflict
          }
        }

        // Version conflict (409) or delete-update (record not found)
        final isVersionConflict = e.code == '409' ||
            (e.message.contains('conflict') || e.message.contains('409'));
        final isDeleteUpdate = e.code == 'PGRST116' ||
            (e.message.contains('not found') || e.message.contains('0 rows'));

        if (isVersionConflict || isDeleteUpdate) {
          // Fetch server data for conflict record
          Map<String, dynamic>? serverData;
          try {
            serverData = await _client
                .from(tableName)
                .select()
                .eq('id', item.recordId)
                .maybeSingle()
                .timeout(const Duration(seconds: 10));
          } catch (_) {}

          final conflict = SyncConflict(
            syncQueueId: item.id,
            tableName: tableName,
            recordId: item.recordId,
            type: isDeleteUpdate
                ? ConflictType.deleteUpdate
                : ConflictType.versionConflict,
            operation: item.operation,
            localData: payload,
            serverData: serverData,
            errorMessage: errorMsg,
          );

          final resolution = await _conflictResolver.resolve(conflict);
          if (resolution.resolved && resolution.resolvedData != null) {
            try {
              final mappedPayload = mapColumnsToRemote(
                tableName,
                _cleanPayload(
                    _jsonConverter.toRemote(
                        tableName, resolution.resolvedData!),
                    tableName: tableName),
              );
              await _client
                  .from(tableName)
                  .upsert(
                    mappedPayload,
                    onConflict: 'id',
                  )
                  .timeout(const Duration(seconds: 30));
              await _syncQueueDao.markAsSynced(item.id);
              count++;
              pushedIds.add(item.recordId);
              if (kDebugMode) {
                debugPrint(
                    'Bidirectional: conflict auto-resolved (${resolution.strategy.name}) '
                    'for $tableName/${item.recordId}');
              }
              continue;
            } catch (_) {
              // Resolution failed, mark as conflict
            }
          }

          await _syncQueueDao.markAsConflict(item.id, conflict.toJsonString());
        } else {
          await _syncQueueDao.markAsFailed(item.id, errorMsg);
        }
      } on TimeoutException {
        final conflict = SyncConflict(
          syncQueueId: item.id,
          tableName: tableName,
          recordId: item.recordId,
          type: ConflictType.networkTimeout,
          operation: item.operation,
          errorMessage: 'Network timeout',
        );
        await _syncQueueDao.markAsFailed(item.id, conflict.toJsonString());
        if (kDebugMode) {
          debugPrint(
              'Bidirectional push timeout for $tableName/${item.recordId}');
        }
      } catch (e) {
        await _syncQueueDao.markAsFailed(item.id, e.toString());
        if (kDebugMode) {
          debugPrint(
              'Bidirectional push failed for $tableName/${item.recordId}: $e');
        }
      }
    }

    return _PushResult(count: count, pushedIds: pushedIds);
  }

  /// سحب التغييرات من السيرفر مع كشف التعارضات
  Future<_PullWithConflictsResult> _pullServerChanges({
    required String tableName,
    required String orgId,
    required String storeId,
    required ConflictResolution conflictResolution,
    Set<String> justPushedIds = const {},
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
        // Skip records that were just pushed in this same sync cycle
        // to prevent overwriting local data with stale server response
        final recordId = serverRecord['id'] as String?;
        if (recordId != null && justPushedIds.contains(recordId)) {
          if (kDebugMode) {
            debugPrint(
                'BidirectionalStrategy: skipping just-pushed record $tableName/$recordId');
          }
          continue;
        }

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
    validateTableName(tableName);
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

    // إذا لم يُعدل محلياً منذ آخر مزامنة، لا تعارض
    if (localSyncedAt != null && localTimeCol != null) {
      final syncTime = DateTime.tryParse(localSyncedAt) ?? DateTime.now();
      final updateTime = DateTime.tryParse(localTimeCol) ?? DateTime.now();
      if (!updateTime.isAfter(syncTime)) {
        // لم يُعدل محلياً، تحديث مباشر
        await _upsertRecord(tableName, serverRecord);
        return _ApplyResult.pulled;
      }
    }

    // يوجد تعارض: حل باستخدام ConflictResolver
    // Fetch the full local record for merge/comparison
    Map<String, dynamic>? localData;
    try {
      final fullLocalRows = await _db.customSelect(
        'SELECT * FROM $tableName WHERE id = ?',
        variables: [Variable.withString(recordId)],
      ).get();
      if (fullLocalRows.isNotEmpty) {
        localData = fullLocalRows.first.data;
      }
    } catch (_) {
      // Best effort to get local data
    }

    final conflict = SyncConflict(
      syncQueueId: '', // No sync queue item for pull conflicts
      tableName: tableName,
      recordId: recordId,
      type: ConflictType.versionConflict,
      operation: 'PULL',
      localData: localData,
      serverData: serverRecord,
      errorMessage: 'Pull conflict: local has unpushed changes',
    );

    final resolution = await _conflictResolver.resolve(conflict);
    if (resolution.resolved && resolution.resolvedData != null) {
      await _upsertRecord(tableName, resolution.resolvedData!);
      if (kDebugMode) {
        debugPrint('BidirectionalStrategy: pull conflict auto-resolved '
            '(${resolution.strategy.name}) for $tableName/$recordId');
      }
      return _ApplyResult.pulled;
    }

    if (kDebugMode) {
      debugPrint('BidirectionalStrategy: pull conflict unresolved for '
          '$tableName/$recordId (${resolution.description})');
    }
    return _ApplyResult.conflict;
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
    if (tableName == 'stock_transfers') {
      // stock_transfers لديها from_store_id و to_store_id بدلاً من store_id
      // نجلب التحويلات التي تخص المتجر كمصدر أو وجهة
      query = query.or('from_store_id.eq.$storeId,to_store_id.eq.$storeId');
    } else if (_hasStoreId(tableName)) {
      query = query.eq('store_id', storeId);
    }

    final orderCol = _getOrderColumn(tableName);

    if (since != null && orderCol != null) {
      query = query.gte(orderCol, since.toUtc().toIso8601String());
    }

    if (orderCol != null) {
      final response = await query
          .order(orderCol, ascending: true)
          .range(offset, offset + pageSize - 1)
          .timeout(const Duration(seconds: 30));
      final records = List<Map<String, dynamic>>.from(response);
      final jsonConverted = _jsonConverter.batchToLocal(tableName, records);
      // M36: إعادة تسمية أعمدة Supabase لتتوافق مع مخطط Drift المحلي
      return batchMapColumnsToLocal(tableName, jsonConverted);
    } else {
      // جداول بدون أعمدة زمنية (return_items, purchase_items)
      final response = await query
          .range(offset, offset + pageSize - 1)
          .timeout(const Duration(seconds: 30));
      final records = List<Map<String, dynamic>>.from(response);
      final jsonConverted = _jsonConverter.batchToLocal(tableName, records);
      // M36: إعادة تسمية أعمدة Supabase لتتوافق مع مخطط Drift المحلي
      return batchMapColumnsToLocal(tableName, jsonConverted);
    }
  }

  /// هل يحتوي الجدول على عمود org_id في Supabase؟
  bool _hasOrgId(String tableName) {
    const tablesWithOrgId = {
      'customers', 'expenses', 'returns', 'purchases',
      // جداول جديدة
      'shifts', 'suppliers', 'notifications', 'loyalty_points',
      'loyalty_transactions', 'customer_addresses', 'accounts',
      'transactions', 'product_expiry', 'stock_takes', 'stock_transfers',
    };
    return tablesWithOrgId.contains(tableName);
  }

  /// هل يحتوي الجدول على عمود store_id في Supabase؟
  bool _hasStoreId(String tableName) {
    // customer_addresses: ليس لديها store_id (مرتبطة بالعميل مباشرة)
    // stock_transfers: تستخدم from_store_id/to_store_id (تُعالج في _fetchServerRecords)
    const tablesWithStoreId = {
      'customers', 'expenses', 'returns', 'purchases',
      // جداول جديدة
      'shifts', 'suppliers', 'notifications', 'loyalty_points',
      'loyalty_transactions', 'accounts',
      'transactions', 'product_expiry', 'stock_takes',
      'whatsapp_templates',
    };
    return tablesWithStoreId.contains(tableName);
  }

  /// عمود الترتيب الزمني المتاح لكل جدول
  String? _getOrderColumn(String tableName) {
    const tablesWithUpdatedAt = {
      'customers', 'expenses', 'purchases',
      // جداول جديدة
      'shifts', 'suppliers', 'notifications', 'loyalty_points',
      'customer_addresses', 'accounts', 'product_expiry',
      'stock_takes', 'stock_transfers', 'whatsapp_templates',
    };
    const tablesWithCreatedAtOnly = {
      'returns',
      // جداول جديدة
      'loyalty_transactions', 'transactions',
    };
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

  Map<String, dynamic> _cleanPayload(
    Map<String, dynamic> payload, {
    String? tableName,
  }) {
    return cleanSyncPayload(payload, removeItems: true, tableName: tableName);
  }
}

enum _ApplyResult { pulled, conflict }

class _PushResult {
  final int count;
  final Set<String> pushedIds;

  _PushResult({required this.count, required this.pushedIds});
}

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
