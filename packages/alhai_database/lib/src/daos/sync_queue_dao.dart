import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// DAO لطابور المزامنة
@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);
  
  /// الحصول على العناصر المعلقة
  Future<List<SyncQueueTableData>> getPendingItems() {
    return (select(syncQueueTable)
      ..where((q) => q.status.equals('pending') | q.status.equals('failed'))
      ..where((q) => q.retryCount.isSmallerThan(q.maxRetries))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .get();
  }
  
  /// الحصول على عدد العناصر المعلقة
  Future<int> getPendingCount() async {
    final result = await customSelect(
      '''SELECT COUNT(*) as count FROM sync_queue 
         WHERE (status = 'pending' OR status = 'failed') 
         AND retry_count < max_retries''',
    ).getSingle();
    
    return result.data['count'] as int? ?? 0;
  }
  
  /// Check if a pending/failed item with the same idempotency key exists
  Future<bool> hasExistingPendingItem(String idempotencyKey) async {
    final result = await customSelect(
      "SELECT COUNT(*) as cnt FROM sync_queue WHERE idempotency_key = ? AND status IN ('pending', 'failed')",
      variables: [Variable.withString(idempotencyKey)],
      readsFrom: {syncQueueTable},
    ).getSingle();
    return (result.data['cnt'] as int? ?? 0) > 0;
  }

  /// إضافة للطابور مع حماية من التكرار (idempotency guard)
  Future<int> enqueue({
    required String id,
    required String tableName,
    required String recordId,
    required String operation,
    required String payload,
    required String idempotencyKey,
    int priority = 2,
  }) async {
    // Guard: skip insert if a pending/failed item with the same key exists
    if (await hasExistingPendingItem(idempotencyKey)) {
      debugPrint('[SyncQueue] Skipping duplicate enqueue '
          '(key=$idempotencyKey, table=$tableName, op=$operation)');
      return 0;
    }

    return into(syncQueueTable).insert(SyncQueueTableCompanion.insert(
      id: id,
      tableName_: tableName,
      recordId: recordId,
      operation: operation,
      payload: payload,
      idempotencyKey: idempotencyKey,
      priority: Value(priority),
      createdAt: DateTime.now(),
    ));
  }
  
  /// تحديث الحالة إلى "جاري المزامنة"
  Future<int> markAsSyncing(String id) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('syncing'),
        lastAttemptAt: Value(DateTime.now()),
      ));
  }
  
  /// تحديث الحالة إلى "تمت المزامنة"
  Future<int> markAsSynced(String id) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('synced'),
        syncedAt: Value(DateTime.now()),
      ));
  }
  
  /// تحديث الحالة إلى "فشل" مع كشف التعارضات تلقائياً
  Future<int> markAsFailed(String id, String error) {
    final errorLower = error.toLowerCase();
    final isConflict = errorLower.contains('409') ||
        errorLower.contains('conflict') ||
        errorLower.contains('constraint');

    if (isConflict) {
      // Conflict detected: mark as 'conflict' and set retry_count = max_retries
      // to prevent infinite retries
      return customUpdate(
        'UPDATE sync_queue SET status = ?, last_error = ?, retry_count = max_retries, last_attempt_at = ? WHERE id = ?',
        variables: [
          const Variable('conflict'),
          Variable.withString(error),
          Variable.withDateTime(DateTime.now()),
          Variable.withString(id),
        ],
        updates: {syncQueueTable},
        updateKind: UpdateKind.update,
      );
    }

    return customUpdate(
      'UPDATE sync_queue SET status = ?, last_error = ?, retry_count = retry_count + 1, last_attempt_at = ? WHERE id = ?',
      variables: [
        const Variable('failed'),
        Variable.withString(error),
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
      updates: {syncQueueTable},
      updateKind: UpdateKind.update,
    );
  }
  
  /// حذف العناصر المزامنة القديمة
  Future<int> cleanupSyncedItems({Duration olderThan = const Duration(days: 7)}) {
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(syncQueueTable)
      ..where((q) => q.status.equals('synced') & q.syncedAt.isSmallerThanValue(cutoff)))
      .go();
  }
  
  /// حذف عنصر بالمعرف
  Future<int> removeItem(String id) {
    return (delete(syncQueueTable)..where((q) => q.id.equals(id))).go();
  }

  /// تحديث البيانات (payload) لعنصر معلق
  Future<int> updatePayload(String id, String newPayload) {
    return (update(syncQueueTable)..where((t) => t.id.equals(id)))
      .write(SyncQueueTableCompanion(
        payload: Value(newPayload),
      ));
  }
  
  /// البحث عن عنصر بمفتاح idempotency
  Future<SyncQueueTableData?> findByIdempotencyKey(String key) {
    return (select(syncQueueTable)..where((q) => q.idempotencyKey.equals(key)))
      .getSingleOrNull();
  }
  
  /// مراقبة عدد العناصر المعلقة
  Stream<int> watchPendingCount() {
    return customSelect(
      '''SELECT COUNT(*) as count FROM sync_queue
         WHERE (status = 'pending' OR status = 'failed')
         AND retry_count < max_retries''',
      readsFrom: {syncQueueTable},
    ).map((row) => row.data['count'] as int? ?? 0).watchSingle();
  }

  /// مراقبة قائمة العناصر المعلقة
  Stream<List<SyncQueueTableData>> watchPendingItems() {
    return (select(syncQueueTable)
      ..where((q) => q.status.equals('pending') | q.status.equals('failed'))
      ..where((q) => q.retryCount.isSmallerThan(q.maxRetries))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .watch();
  }

  /// Reset items stuck in 'syncing' status (from app crash) back to 'pending'
  Future<int> resetStuckItems() async {
    return (update(syncQueueTable)
      ..where((t) => t.status.equals('syncing'))
    ).write(SyncQueueTableCompanion(
      status: const Value('pending'),
      lastAttemptAt: Value(DateTime.now()),
    ));
  }

  /// الحصول على العناصر العالقة في حالة 'syncing' (بسبب إغلاق مفاجئ أو خطأ)
  Future<List<SyncQueueTableData>> getStuckSyncingItems() {
    return (select(syncQueueTable)
      ..where((q) => q.status.equals('syncing'))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .get();
  }

  /// الحصول على العناصر المتعارضة (فشلت بعد استنفاد المحاولات)
  Future<List<SyncQueueTableData>> getConflictItems() {
    return (select(syncQueueTable)
      ..where((q) =>
          q.status.equals('conflict') |
          (q.status.equals('failed') &
              q.retryCount.isBiggerOrEqual(q.maxRetries)))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .get();
  }

  /// مراقبة العناصر المتعارضة
  Stream<List<SyncQueueTableData>> watchConflictItems() {
    return (select(syncQueueTable)
      ..where((q) =>
          q.status.equals('conflict') |
          (q.status.equals('failed') &
              q.retryCount.isBiggerOrEqual(q.maxRetries)))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .watch();
  }

  /// عدد العناصر المتعارضة
  Stream<int> watchConflictCount() {
    return customSelect(
      '''SELECT COUNT(*) as count FROM sync_queue
         WHERE status = 'conflict'
         OR (status = 'failed' AND retry_count >= max_retries)''',
      readsFrom: {syncQueueTable},
    ).map((row) => row.data['count'] as int? ?? 0).watchSingle();
  }

  /// تحديث الحالة إلى "تم الحل"
  Future<int> markResolved(String id) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('resolved'),
        syncedAt: Value(DateTime.now()),
      ));
  }

  /// إعادة تعيين عنصر للمحاولة مرة أخرى
  Future<int> retryItem(String id) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(const SyncQueueTableCompanion(
        status: Value('pending'),
        retryCount: Value(0),
        lastError: Value(null),
      ));
  }

  /// تحديث الحالة إلى "تعارض"
  Future<int> markAsConflict(String id, String error) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('conflict'),
        lastError: Value(error),
        lastAttemptAt: Value(DateTime.now()),
      ));
  }

  /// الحصول على جميع العناصر (لعرض شامل)
  Future<List<SyncQueueTableData>> getAllItems() {
    return (select(syncQueueTable)
      ..orderBy([
        (q) => OrderingTerm.desc(q.createdAt),
      ]))
      .get();
  }

  /// الحصول على معرّفات السجلات المعلقة لجدول معين
  /// يُستخدم لمنع السحب (Pull) من الكتابة فوق تغييرات محلية لم تُدفع بعد
  Future<Set<String>> getPendingRecordIdsForTable(String tableName) async {
    final items = await (select(syncQueueTable)
      ..where((q) =>
          (q.status.equals('pending') | q.status.equals('syncing')) &
          q.tableName_.equals(tableName)))
      .get();
    return items.map((item) => item.recordId).toSet();
  }

  /// حذف العناصر المزامنة القديمة (أكثر من 30 يوم)
  /// يُستخدم للصيانة الدورية لمنع تراكم البيانات القديمة في طابور المزامنة
  Future<int> cleanOldSyncedItems() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return (delete(syncQueueTable)
      ..where((q) =>
          q.status.equals('synced') &
          q.syncedAt.isSmallerThanValue(thirtyDaysAgo)))
        .go();
  }

  // ==================== Conflict Tracking ====================

  /// Insert a conflict record into the sync queue for tracking
  /// instead of silently skipping records during pull sync
  Future<void> insertConflict({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> serverData,
    required String reason,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await into(syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        id: id,
        tableName_: tableName,
        recordId: recordId,
        operation: 'CONFLICT',
        payload: jsonEncode(serverData),
        idempotencyKey: 'conflict_${tableName}_${recordId}_${now.millisecondsSinceEpoch}',
        status: const Value('conflict'),
        priority: const Value(1),
        createdAt: now,
        lastError: Value(reason),
      ),
    );
  }

  /// Get a single sync queue item by its ID
  Future<SyncQueueTableData?> getById(String id) {
    return (select(syncQueueTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Mark a conflict as resolved
  Future<int> markAsResolved(String id) {
    return (update(syncQueueTable)..where((t) => t.id.equals(id)))
        .write(SyncQueueTableCompanion(
          status: const Value('resolved'),
          syncedAt: Value(DateTime.now()),
        ));
  }

  // ==================== Sync Audit Log Queries ====================

  /// Get recent sync activity for display in sync status screen
  Future<List<SyncQueueTableData>> getRecentActivity({int limit = 50}) async {
    return (select(syncQueueTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit)
    ).get();
  }

  /// Get conflict count for badge display
  Future<int> getConflictCount() async {
    final result = await customSelect(
      "SELECT COUNT(*) as count FROM sync_queue WHERE status = 'conflict'",
      readsFrom: {syncQueueTable},
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  /// Get count of pending items (not yet synced)
  Future<int> getPendingQueueCount() async {
    final result = await customSelect(
      "SELECT COUNT(*) as count FROM sync_queue WHERE status = 'pending'",
      readsFrom: {syncQueueTable},
    ).getSingle();
    return result.data['count'] as int? ?? 0;
  }

  // ==================== تعارضات متقدمة (Advanced Conflicts) ====================

  /// الحصول على العناصر المتعارضة لجدول معين
  Future<List<SyncQueueTableData>> getConflictItemsForTable(String tableName) {
    return (select(syncQueueTable)
      ..where((q) =>
          q.status.equals('conflict') &
          q.tableName_.equals(tableName))
      ..orderBy([
        (q) => OrderingTerm.desc(q.priority),
        (q) => OrderingTerm.asc(q.createdAt),
      ]))
      .get();
  }

  /// الحصول على عدد التعارضات لكل جدول
  Future<Map<String, int>> getConflictCountsByTable() async {
    final rows = await customSelect(
      '''SELECT table_name, COUNT(*) as count FROM sync_queue
         WHERE status = 'conflict'
         GROUP BY table_name ORDER BY count DESC''',
      readsFrom: {syncQueueTable},
    ).get();

    final result = <String, int>{};
    for (final row in rows) {
      final table = row.data['table_name'] as String? ?? 'unknown';
      final count = row.data['count'] as int? ?? 0;
      result[table] = count;
    }
    return result;
  }

  /// حل تعارض مع تحديث البيانات المحلولة
  /// يحدث الـ payload بالبيانات الناتجة عن الحل ويعيد الحالة إلى pending
  Future<int> resolveConflictWithData(String id, String resolvedPayload) {
    return (update(syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('pending'),
        payload: Value(resolvedPayload),
        retryCount: const Value(0),
        lastError: const Value(null),
        lastAttemptAt: Value(DateTime.now()),
      ));
  }

  /// تنظيف جميع التعارضات المحلولة
  Future<int> cleanupResolvedConflicts({Duration olderThan = const Duration(days: 3)}) {
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(syncQueueTable)
      ..where((q) =>
          q.status.equals('resolved') &
          q.syncedAt.isSmallerThanValue(cutoff)))
      .go();
  }

  // ==================== دمج العمليات (Dedup) ====================

  /// البحث عن عنصر معلق بالجدول والسجل والعملية
  Future<SyncQueueTableData?> findPendingByTableRecordOperation(
    String tableName,
    String recordId,
    String operation,
  ) {
    return (select(syncQueueTable)
      ..where((q) =>
          q.tableName_.equals(tableName) &
          q.recordId.equals(recordId) &
          q.operation.equals(operation) &
          q.status.equals('pending'))
      ..limit(1))
      .getSingleOrNull();
  }

  /// البحث عن جميع العناصر المعلقة لسجل معين في جدول معين
  Future<List<SyncQueueTableData>> findPendingByTableRecord(
    String tableName,
    String recordId,
  ) {
    return (select(syncQueueTable)
      ..where((q) =>
          q.tableName_.equals(tableName) &
          q.recordId.equals(recordId) &
          q.status.equals('pending'))
      ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
      .get();
  }

  // ==================== صحة الطابور (Queue Health) ====================

  /// الحصول على إحصائيات صحة الطابور
  Future<SyncQueueHealth> getQueueHealth() async {
    // إجمالي العناصر
    final totalResult = await customSelect(
      'SELECT COUNT(*) as count FROM sync_queue',
    ).getSingle();
    final totalItems = totalResult.data['count'] as int? ?? 0;

    // العناصر حسب الحالة
    final statusRows = await customSelect(
      'SELECT status, COUNT(*) as count FROM sync_queue GROUP BY status',
    ).get();
    final statusCounts = <String, int>{};
    for (final row in statusRows) {
      final status = row.data['status'] as String? ?? 'unknown';
      final count = row.data['count'] as int? ?? 0;
      statusCounts[status] = count;
    }

    // أقدم عنصر معلق
    final oldestResult = await customSelect(
      '''SELECT MIN(created_at) as oldest FROM sync_queue
         WHERE status = 'pending' OR status = 'failed' ''',
    ).getSingleOrNull();
    DateTime? oldestPendingAt;
    if (oldestResult != null && oldestResult.data['oldest'] != null) {
      final oldestMs = oldestResult.data['oldest'] as int;
      oldestPendingAt = DateTime.fromMillisecondsSinceEpoch(oldestMs);
    }

    // متوسط عدد المحاولات
    final retryResult = await customSelect(
      '''SELECT AVG(retry_count) as avg_retry FROM sync_queue
         WHERE status = 'pending' OR status = 'failed' ''',
    ).getSingleOrNull();
    final avgRetryCount = (retryResult?.data['avg_retry'] as num?)?.toDouble() ?? 0.0;

    // العناصر حسب الجدول
    final tableRows = await customSelect(
      '''SELECT table_name, COUNT(*) as count FROM sync_queue
         WHERE status != 'synced' AND status != 'resolved'
         GROUP BY table_name ORDER BY count DESC''',
    ).get();
    final itemsPerTable = <String, int>{};
    for (final row in tableRows) {
      final table = row.data['table_name'] as String? ?? 'unknown';
      final count = row.data['count'] as int? ?? 0;
      itemsPerTable[table] = count;
    }

    return SyncQueueHealth(
      totalItems: totalItems,
      pendingCount: statusCounts['pending'] ?? 0,
      syncingCount: statusCounts['syncing'] ?? 0,
      failedCount: statusCounts['failed'] ?? 0,
      conflictCount: statusCounts['conflict'] ?? 0,
      syncedCount: statusCounts['synced'] ?? 0,
      oldestPendingAt: oldestPendingAt,
      avgRetryCount: avgRetryCount,
      itemsPerTable: itemsPerTable,
    );
  }

  // ==================== استعادة العناصر العالقة (Stuck Recovery) ====================

  /// استعادة العناصر العالقة في حالة 'syncing' لأكثر من المدة المحددة
  Future<int> recoverStuckSyncingItems({
    Duration stuckThreshold = const Duration(minutes: 5),
  }) async {
    final cutoff = DateTime.now().subtract(stuckThreshold);
    return customUpdate(
      '''UPDATE sync_queue SET status = 'pending', retry_count = retry_count
         WHERE status = 'syncing' AND last_attempt_at < ?''',
      variables: [Variable.withDateTime(cutoff)],
      updates: {syncQueueTable},
      updateKind: UpdateKind.update,
    );
  }

  // ==================== تسجيل عمليات المزامنة (Sync Audit) ====================

  /// تسجيل نتيجة عملية مزامنة في جدول audit_log
  /// يُستخدم لتتبع وتشخيص مشاكل المزامنة
  /// ملاحظة: يكتب مباشرة في جدول audit_log لتجنب إنشاء جدول جديد
  Future<void> logSyncOperation({
    required String tableName,
    required String operation,
    required String recordId,
    required String result,
    int? durationMs,
    String? error,
  }) async {
    final now = DateTime.now();
    final id = 'sync_${now.millisecondsSinceEpoch}_${recordId.hashCode.abs()}';
    final description = 'Sync $operation $tableName/$recordId: $result'
        '${durationMs != null ? ' (${durationMs}ms)' : ''}'
        '${error != null ? ' - $error' : ''}';

    await customInsert(
      '''INSERT OR IGNORE INTO audit_log
         (id, store_id, user_id, user_name, action, entity_type, entity_id, description, created_at)
         VALUES (?, 'system', 'sync_engine', 'SyncEngine', 'sync_operation', ?, ?, ?, ?)''',
      variables: [
        Variable.withString(id),
        Variable.withString(tableName),
        Variable.withString(recordId),
        Variable.withString(description),
        Variable.withDateTime(now),
      ],
    );
  }

  /// تنظيف سجلات المزامنة القديمة (أقدم من المدة المحددة)
  Future<int> cleanupSyncAuditLogs({Duration olderThan = const Duration(days: 7)}) {
    final cutoff = DateTime.now().subtract(olderThan);
    return customUpdate(
      '''DELETE FROM audit_log
         WHERE action = 'sync_operation' AND created_at < ?''',
      variables: [Variable.withDateTime(cutoff)],
      updates: {},
      updateKind: UpdateKind.delete,
    );
  }
}

/// حالة صحة طابور المزامنة
class SyncQueueHealth {
  final int totalItems;
  final int pendingCount;
  final int syncingCount;
  final int failedCount;
  final int conflictCount;
  final int syncedCount;
  final DateTime? oldestPendingAt;
  final double avgRetryCount;
  final Map<String, int> itemsPerTable;

  const SyncQueueHealth({
    required this.totalItems,
    required this.pendingCount,
    required this.syncingCount,
    required this.failedCount,
    required this.conflictCount,
    required this.syncedCount,
    this.oldestPendingAt,
    this.avgRetryCount = 0.0,
    this.itemsPerTable = const {},
  });

  /// عدد العناصر النشطة (غير المكتملة)
  int get activeCount => pendingCount + syncingCount + failedCount + conflictCount;

  /// هل الطابور ممتلئ؟ (أكثر من 10,000 عنصر نشط)
  bool get isOverloaded => activeCount > 10000;

  /// هل الطابور في حالة تحذير؟ (أكثر من 5,000 عنصر نشط)
  bool get isWarning => activeCount > 5000;

  /// عمر أقدم عنصر معلق
  Duration? get oldestPendingAge {
    if (oldestPendingAt == null) return null;
    return DateTime.now().difference(oldestPendingAt!);
  }

  @override
  String toString() => 'SyncQueueHealth('
      'total=$totalItems, pending=$pendingCount, syncing=$syncingCount, '
      'failed=$failedCount, conflict=$conflictCount, '
      'oldestAge=${oldestPendingAge?.inMinutes}min, '
      'avgRetry=${avgRetryCount.toStringAsFixed(1)})';
}
