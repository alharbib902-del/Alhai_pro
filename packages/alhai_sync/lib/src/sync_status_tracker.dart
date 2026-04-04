import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:alhai_database/alhai_database.dart';

/// صحة المزامنة العامة
enum SyncHealthStatus {
  /// كل شيء مزامن
  healthy,

  /// يوجد عناصر معلقة لكن لا مشاكل
  syncing,

  /// يوجد عناصر فاشلة تحتاج اهتمام
  warning,

  /// مشاكل خطيرة في المزامنة
  critical,
}

/// حالة مزامنة جدول واحد
class TableSyncStatus {
  final String tableName;
  final DateTime? lastPullAt;
  final DateTime? lastPushAt;
  final int pendingCount;
  final int failedCount;
  final bool isInitialSynced;
  final String? lastError;

  const TableSyncStatus({
    required this.tableName,
    this.lastPullAt,
    this.lastPushAt,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.isInitialSynced = false,
    this.lastError,
  });

  bool get hasErrors => failedCount > 0 || lastError != null;
  bool get hasPending => pendingCount > 0;
  bool get isSynced => isInitialSynced && pendingCount == 0 && failedCount == 0;
}

/// حالة المزامنة الشاملة
class SyncOverview {
  final SyncHealthStatus health;
  final int totalPending;
  final int totalFailed;
  final int totalDeltasPending;
  final List<TableSyncStatus> tables;
  final DateTime? lastFullSyncAt;

  const SyncOverview({
    this.health = SyncHealthStatus.healthy,
    this.totalPending = 0,
    this.totalFailed = 0,
    this.totalDeltasPending = 0,
    this.tables = const [],
    this.lastFullSyncAt,
  });
}

/// متتبع حالة المزامنة
/// يراقب ويعرض حالة المزامنة لكل جدول والحالة العامة
class SyncStatusTracker {
  final SyncMetadataDao _metadataDao;
  final SyncQueueDao _syncQueueDao;
  final StockDeltasDao _deltasDao;

  final _overviewController = StreamController<SyncOverview>.broadcast();
  SyncOverview _currentOverview = const SyncOverview();
  Timer? _refreshTimer;

  SyncStatusTracker({
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
    required StockDeltasDao deltasDao,
  })  : _metadataDao = metadataDao,
        _syncQueueDao = db.syncQueueDao,
        _deltasDao = deltasDao;

  /// Stream لحالة المزامنة الشاملة
  Stream<SyncOverview> get overviewStream => _overviewController.stream;

  /// حالة المزامنة الحالية
  SyncOverview get currentOverview => _currentOverview;

  /// بدء المراقبة (تحديث كل 10 ثوان)
  void startTracking() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refreshAll();
    });
    // تحديث أولي
    refreshAll();
  }

  /// إيقاف المراقبة
  void stopTracking() {
    _refreshTimer?.cancel();
  }

  /// تحديث جميع الحالات
  Future<void> refreshAll() async {
    try {
      // جلب بيانات المزامنة الوصفية
      final metadataList = await _metadataDao.getAll();

      // جلب العدد الإجمالي للمعلقات
      final pendingCount = await _syncQueueDao.getPendingCount();

      // جلب عدد الدلتا المعلقة
      final deltasPending = await _deltasDao.getPendingCount();

      // بناء حالة كل جدول
      final tableStatuses = metadataList
          .map((m) => TableSyncStatus(
                tableName: m.tableName_,
                lastPullAt: m.lastPullAt,
                lastPushAt: m.lastPushAt,
                pendingCount: m.pendingCount,
                failedCount: m.failedCount,
                isInitialSynced: m.isInitialSynced,
                lastError: m.lastError,
              ))
          .toList();

      // حساب الإجمالي
      final totalFailed =
          tableStatuses.fold(0, (sum, t) => sum + t.failedCount);

      // تحديد صحة المزامنة
      final health = _calculateHealth(
        pending: pendingCount + deltasPending,
        failed: totalFailed,
      );

      // آخر مزامنة كاملة
      DateTime? lastFullSync;
      if (tableStatuses.isNotEmpty) {
        final pullTimes = tableStatuses
            .where((t) => t.lastPullAt != null)
            .map((t) => t.lastPullAt!);
        if (pullTimes.isNotEmpty) {
          lastFullSync = pullTimes.reduce((a, b) => a.isBefore(b) ? a : b);
        }
      }

      _currentOverview = SyncOverview(
        health: health,
        totalPending: pendingCount,
        totalFailed: totalFailed,
        totalDeltasPending: deltasPending,
        tables: tableStatuses,
        lastFullSyncAt: lastFullSync,
      );

      if (!_overviewController.isClosed) {
        _overviewController.add(_currentOverview);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncStatusTracker refresh error: $e');
      }
    }
  }

  /// الحصول على عدد العناصر المعلقة
  Future<int> getPendingCount() async {
    final queuePending = await _syncQueueDao.getPendingCount();
    final deltasPending = await _deltasDao.getPendingCount();
    return queuePending + deltasPending;
  }

  /// الحصول على آخر وقت مزامنة لجدول
  Future<DateTime?> getLastSyncTime(String tableName) async {
    final metadata = await _metadataDao.getForTable(tableName);
    if (metadata == null) return null;
    // نرجع الأحدث بين السحب والدفع
    final pull = metadata.lastPullAt;
    final push = metadata.lastPushAt;
    if (pull == null) return push;
    if (push == null) return pull;
    return pull.isAfter(push) ? pull : push;
  }

  /// حساب صحة المزامنة
  SyncHealthStatus _calculateHealth({
    required int pending,
    required int failed,
  }) {
    if (failed > 10) return SyncHealthStatus.critical;
    if (failed > 0) return SyncHealthStatus.warning;
    if (pending > 0) return SyncHealthStatus.syncing;
    return SyncHealthStatus.healthy;
  }

  /// تنظيف الموارد
  void dispose() {
    _refreshTimer?.cancel();
    _overviewController.close();
  }
}
