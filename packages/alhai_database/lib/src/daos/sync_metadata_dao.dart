import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_metadata_table.dart';

part 'sync_metadata_dao.g.dart';

/// DAO لبيانات المزامنة الوصفية
/// يدير حالة المزامنة لكل جدول
@DriftAccessor(tables: [SyncMetadataTable])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  /// الحصول على بيانات المزامنة لجدول معين
  Future<SyncMetadataTableData?> getForTable(String tableName) {
    return (select(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .getSingleOrNull();
  }

  /// الحصول على بيانات المزامنة لجميع الجداول
  Future<List<SyncMetadataTableData>> getAll() {
    return select(syncMetadataTable).get();
  }

  /// مراقبة بيانات المزامنة لجميع الجداول
  Stream<List<SyncMetadataTableData>> watchAll() {
    return select(syncMetadataTable).watch();
  }

  /// مراقبة بيانات المزامنة لجدول معين
  Stream<SyncMetadataTableData?> watchForTable(String tableName) {
    return (select(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .watchSingleOrNull();
  }

  /// تحديث آخر وقت سحب لجدول
  Future<void> updateLastPullAt(String tableName, DateTime time,
      {int syncCount = 0}) async {
    final companion = SyncMetadataTableCompanion(
      lastPullAt: Value(time),
      lastSyncCount: Value(syncCount),
      isInitialSynced: const Value(true),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          lastPullAt: Value(time),
          lastSyncCount: Value(syncCount),
          isInitialSynced: const Value(true),
        ),
      );
    }
  }

  /// تحديث آخر وقت دفع لجدول
  Future<void> updateLastPushAt(String tableName, DateTime time,
      {int syncCount = 0}) async {
    final companion = SyncMetadataTableCompanion(
      lastPushAt: Value(time),
      lastSyncCount: Value(syncCount),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          lastPushAt: Value(time),
          lastSyncCount: Value(syncCount),
        ),
      );
    }
  }

  /// تحديث عدد العناصر المعلقة والفاشلة
  Future<void> updateCounts(String tableName, int pending, int failed) async {
    final companion = SyncMetadataTableCompanion(
      pendingCount: Value(pending),
      failedCount: Value(failed),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          pendingCount: Value(pending),
          failedCount: Value(failed),
        ),
      );
    }
  }

  /// تعيين أن المزامنة الأولية تمت
  Future<void> markInitialSynced(String tableName) async {
    const companion = SyncMetadataTableCompanion(
      isInitialSynced: Value(true),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          isInitialSynced: const Value(true),
        ),
      );
    }
  }

  /// تسجيل خطأ مزامنة
  Future<void> setError(String tableName, String error) async {
    final companion = SyncMetadataTableCompanion(
      lastError: Value(error),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          lastError: Value(error),
        ),
      );
    }
  }

  /// مسح خطأ المزامنة
  Future<void> clearError(String tableName) async {
    const companion = SyncMetadataTableCompanion(
      lastError: Value(null),
    );
    final rows = await (update(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .write(companion);
    if (rows == 0) {
      await into(syncMetadataTable).insert(
        SyncMetadataTableCompanion.insert(
          tableName_: tableName,
          lastError: const Value(null),
        ),
      );
    }
  }

  /// هل تمت المزامنة الأولية لجدول معين؟
  Future<bool> isInitialSynced(String tableName) async {
    final data = await getForTable(tableName);
    return data?.isInitialSynced ?? false;
  }

  /// الحصول على آخر وقت سحب لجدول
  Future<DateTime?> getLastPullAt(String tableName) async {
    final data = await getForTable(tableName);
    return data?.lastPullAt;
  }

  /// الحصول على آخر وقت دفع لجدول
  Future<DateTime?> getLastPushAt(String tableName) async {
    final data = await getForTable(tableName);
    return data?.lastPushAt;
  }

  /// الحصول على إجمالي العناصر المعلقة لجميع الجداول
  Future<int> getTotalPendingCount() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(pending_count), 0) as total FROM sync_metadata',
      readsFrom: {syncMetadataTable},
    ).getSingle();
    return result.data['total'] as int? ?? 0;
  }

  /// الحصول على إجمالي العناصر الفاشلة لجميع الجداول
  Future<int> getTotalFailedCount() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(failed_count), 0) as total FROM sync_metadata',
      readsFrom: {syncMetadataTable},
    ).getSingle();
    return result.data['total'] as int? ?? 0;
  }

  /// إعادة تعيين بيانات المزامنة لجدول (للمزامنة الكاملة)
  Future<void> resetTable(String tableName) async {
    await (delete(syncMetadataTable)
          ..where((t) => t.tableName_.equals(tableName)))
        .go();
  }

  /// إعادة تعيين جميع بيانات المزامنة
  Future<void> resetAll() async {
    await delete(syncMetadataTable).go();
  }
}
