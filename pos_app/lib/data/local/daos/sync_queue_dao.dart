import 'package:drift/drift.dart';

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
  
  /// إضافة للطابور
  Future<int> enqueue({
    required String id,
    required String tableName,
    required String recordId,
    required String operation,
    required String payload,
    required String idempotencyKey,
    int priority = 2,
  }) {
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
  
  /// تحديث الحالة إلى "فشل"
  Future<int> markAsFailed(String id, String error) {
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
}
