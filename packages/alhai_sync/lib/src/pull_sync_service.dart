import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:alhai_database/alhai_database.dart';

import 'conflict_resolver.dart';
import 'sync_api_service.dart';
import 'sync_payload_utils.dart';
import 'sync_table_validator.dart';

/// نتيجة عملية السحب الدورية
class PullSyncResult {
  /// عدد السجلات المسحوبة لكل جدول
  final Map<String, int> tableCounts;

  /// إجمالي السجلات المسحوبة
  final int totalPulled;

  /// عدد السجلات المتخطاة بسبب تعارض محلي (unpushed changes)
  final int skippedConflicts;

  /// الأخطاء التي حدثت أثناء السحب
  final List<String> errors;

  /// هل نجحت العملية بالكامل (بدون أخطاء)؟
  bool get success => errors.isEmpty;

  /// هل توجد أخطاء؟
  bool get hasErrors => errors.isNotEmpty;

  PullSyncResult({
    required this.tableCounts,
    required this.totalPulled,
    this.skippedConflicts = 0,
    required this.errors,
  });

  @override
  String toString() =>
      'PullSyncResult(total=$totalPulled, tables=${tableCounts.length}, '
      'skippedConflicts=$skippedConflicts, errors=${errors.length})';
}

/// خدمة السحب الدوري من Supabase إلى القاعدة المحلية
///
/// تسحب البيانات المُحدّثة من جداول محددة يديرها المشرف/لوحة التحكم:
/// المنتجات، التصنيفات، الإعدادات، الخصومات، الكوبونات، العروض.
///
/// تعمل بشكل مستقل عن Push sync وبفاصل زمني مختلف (30 ثانية افتراضياً).
class PullSyncService {
  final SyncApiService _syncApi;
  final AppDatabase _db;
  final SyncMetadataDao _metadataDao;
  final SyncQueueDao _syncQueueDao;
  final ConflictResolver _conflictResolver;

  /// الجداول التي يتم سحبها دورياً من السيرفر
  /// هذه البيانات يديرها المشرف/لوحة التحكم ونقطة البيع تستهلكها فقط
  static const List<String> pullTables = [
    'products',
    'categories',
    'settings',
    'discounts',
    'coupons',
    'promotions',
  ];

  /// أعمدة التواريخ المعروفة التي يجب تحويلها من ISO 8601 إلى Unix seconds
  static const Set<String> _dateTimeColumns = {
    'created_at', 'updated_at', 'synced_at', 'deleted_at',
    'opened_at', 'closed_at', 'issued_at', 'due_at', 'paid_at',
    'expires_at', 'start_date', 'end_date', 'last_login',
    'completed_at', 'confirmed_at', 'cancelled_at', 'delivered_at',
    'shipped_at', 'refunded_at', 'voided_at', 'activated_at',
    'deactivated_at', 'last_sync_at', 'last_pull_at', 'last_push_at',
    // Additional datetime columns from database tables
    'order_date', 'preparing_at', 'ready_at', 'delivering_at',
    'received_at', 'approved_at', 'started_at', 'expiry_date',
    'expense_date', 'read_at', 'sent_at', 'last_attempt_at',
    'last_transaction_at', 'trial_ends_at', 'last_heartbeat_at',
    'current_period_start', 'current_period_end',
    'invited_at', 'joined_at', 'last_login_at',
  };

  PullSyncService({
    required SyncApiService syncApi,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
    required SyncQueueDao syncQueueDao,
    ConflictResolver conflictResolver = const ConflictResolver(),
  })  : _syncApi = syncApi,
        _db = db,
        _metadataDao = metadataDao,
        _syncQueueDao = syncQueueDao,
        _conflictResolver = conflictResolver;

  /// تنفيذ السحب الدوري لجميع الجداول المحددة
  ///
  /// يسحب فقط السجلات التي تم تحديثها بعد آخر عملية سحب ناجحة.
  /// يُحدّث `last_pull_at` في metadata بعد كل جدول ناجح.
  Future<PullSyncResult> pullUpdates({required String storeId}) async {
    final tableCounts = <String, int>{};
    final errors = <String>[];
    int totalPulled = 0;
    int totalSkippedConflicts = 0;

    for (final tableName in pullTables) {
      try {
        final result = await _pullTable(
          tableName: tableName,
          storeId: storeId,
        );

        tableCounts[tableName] = result.pulled;
        totalPulled += result.pulled;
        totalSkippedConflicts += result.skippedConflicts;

        if (result.pulled > 0 && kDebugMode) {
          debugPrint('[PullSync] Pulled ${result.pulled} records for $tableName');
        }
        if (result.skippedConflicts > 0 && kDebugMode) {
          debugPrint('[PullSync] Skipped ${result.skippedConflicts} conflicting records for $tableName');
        }
      } catch (e) {
        errors.add('$tableName: $e');
        if (kDebugMode) {
          debugPrint('[PullSync] Error pulling $tableName: $e');
        }
        // نستمر في بقية الجداول حتى لو فشل أحدها
      }
    }

    if (kDebugMode) {
      if (totalPulled > 0) {
        debugPrint('[PullSync] Done: $totalPulled total records pulled, $totalSkippedConflicts conflicts skipped');
      } else if (errors.isEmpty) {
        debugPrint('[PullSync] No updates found');
      }
    }

    return PullSyncResult(
      tableCounts: tableCounts,
      totalPulled: totalPulled,
      skippedConflicts: totalSkippedConflicts,
      errors: errors,
    );
  }

  /// سحب جدول واحد من السيرفر
  Future<_PullTableResult> _pullTable({
    required String tableName,
    required String storeId,
  }) async {
    // جلب آخر وقت سحب
    final lastPullAt = await _metadataDao.getLastPullAt(tableName);

    // جلب السجلات المحدثة من السيرفر
    final records = await _syncApi.fetchUpdates(
      tableName: tableName,
      storeId: storeId,
      since: lastPullAt,
    );

    if (records.isEmpty) return _PullTableResult(pulled: 0, skippedConflicts: 0);

    // تصفية السجلات التي لها عمليات معلقة في طابور الدفع
    // لمنع الكتابة فوق تغييرات محلية لم تُدفع بعد
    final pendingIds = await _getPendingRecordIds(tableName);
    final filteredRecords = pendingIds.isEmpty
        ? records
        : records.where((r) => !pendingIds.contains(r['id'])).toList();

    final skippedCount = records.length - filteredRecords.length;

    if (skippedCount > 0 && kDebugMode) {
      // Log each skipped record for debugging and visibility
      final skippedRecords = records.where((r) => pendingIds.contains(r['id']));
      final strategy = _conflictResolver.getStrategy(tableName, ConflictType.versionConflict);
      for (final skippedRecord in skippedRecords) {
        final recordId = skippedRecord['id'] as String? ?? 'unknown';
        debugPrint(
          '[PullSync] Conflict: skipped $tableName/$recordId '
          '(pending local push, server has update, strategy: ${strategy.name})',
        );
      }
    }

    if (filteredRecords.isEmpty) {
      // تحديث آخر وقت سحب حتى لو تم تصفية كل السجلات
      await _metadataDao.updateLastPullAt(
        tableName,
        DateTime.now().toUtc(),
        syncCount: 0,
      );
      return _PullTableResult(pulled: 0, skippedConflicts: skippedCount);
    }

    // تحويل أسماء الأعمدة من Supabase إلى Drift المحلي
    final localRecords = batchMapColumnsToLocal(tableName, filteredRecords);

    // إدراج/تحديث محلياً
    await _insertBatch(tableName, localRecords);

    // تحديث آخر وقت سحب
    await _metadataDao.updateLastPullAt(
      tableName,
      DateTime.now().toUtc(),
      syncCount: filteredRecords.length,
    );

    return _PullTableResult(
      pulled: filteredRecords.length,
      skippedConflicts: skippedCount,
    );
  }

  /// جلب معرّفات السجلات المعلقة أو الجاري مزامنتها لجدول معين
  Future<Set<String>> _getPendingRecordIds(String tableName) async {
    return _syncQueueDao.getPendingRecordIdsForTable(tableName);
  }

  /// تحويل ISO 8601 timestamps إلى Unix seconds (ما يتوقعه Drift)
  dynamic _convertValue(String column, dynamic value) {
    if (value == null) return null;
    if (!_dateTimeColumns.contains(column)) return value;
    if (value is int) return value; // بالفعل Unix seconds
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch ~/ 1000;
      } catch (_) {
        return null;
      }
    }
    return value;
  }

  /// إدراج مجموعة سجلات محلياً باستخدام batch INSERT OR REPLACE
  ///
  /// يتم تعطيل Foreign Keys مؤقتاً أثناء السحب لأن البيانات قادمة
  /// من السيرفر وسلامتها مضمونة.
  Future<void> _insertBatch(
      String tableName, List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    validateTableName(tableName);

    // تعطيل FK خارج الـ batch (PRAGMA لا يعمل داخل batch في WASM)
    await _db.customStatement('PRAGMA foreign_keys = OFF');

    try {
      await _db.batch((batch) {
        for (final record in records) {
          // التعامل مع الحذف الناعم
          final deletedAt = record['deleted_at'];
          if (deletedAt != null) {
            batch.customStatement(
              'DELETE FROM $tableName WHERE id = ?',
              [record['id']],
            );
          } else {
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
              columns.map((c) => _convertValue(c, record[c])).toList(),
            );
          }
        }
      });
    } finally {
      // إعادة تفعيل FK دائماً
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
  }
}

/// Internal result for a single table pull operation
class _PullTableResult {
  final int pulled;
  final int skippedConflicts;

  const _PullTableResult({
    required this.pulled,
    required this.skippedConflicts,
  });
}
