import 'dart:async';

import 'package:alhai_database/alhai_database.dart' show SyncQueueDao;
import 'package:flutter/foundation.dart';

import 'connectivity_service.dart';
import 'strategies/pull_strategy.dart';
import 'strategies/push_strategy.dart';
import 'strategies/bidirectional_strategy.dart';
import 'strategies/stock_delta_sync.dart';
import 'sync_status_tracker.dart';

/// حالة محرك المزامنة
enum SyncEngineState {
  /// خامل - لا توجد عملية مزامنة جارية
  idle,

  /// جاري المزامنة
  syncing,

  /// مكتمل بنجاح
  completed,

  /// مكتمل مع أخطاء
  error,
}

/// مرحلة المزامنة الحالية
enum SyncPhase {
  /// لم تبدأ بعد
  none,

  /// المرحلة 1: سحب البيانات من السيرفر
  pulling,

  /// المرحلة 2: دفع البيانات للسيرفر
  pushing,

  /// المرحلة 3: مزامنة ثنائية الاتجاه
  bidirectional,

  /// المرحلة 4: مزامنة دلتا المخزون
  stockDelta,
}

/// حالة تقدم المزامنة
class SyncProgress {
  final SyncEngineState state;
  final SyncPhase phase;
  final int totalTables;
  final int completedTables;
  final String? currentTable;
  final List<String> errors;
  final DateTime? lastSyncAt;

  const SyncProgress({
    this.state = SyncEngineState.idle,
    this.phase = SyncPhase.none,
    this.totalTables = 0,
    this.completedTables = 0,
    this.currentTable,
    this.errors = const [],
    this.lastSyncAt,
  });

  double get progress => totalTables > 0 ? completedTables / totalTables : 0.0;

  bool get isSyncing => state == SyncEngineState.syncing;

  SyncProgress copyWith({
    SyncEngineState? state,
    SyncPhase? phase,
    int? totalTables,
    int? completedTables,
    String? currentTable,
    List<String>? errors,
    DateTime? lastSyncAt,
  }) {
    return SyncProgress(
      state: state ?? this.state,
      phase: phase ?? this.phase,
      totalTables: totalTables ?? this.totalTables,
      completedTables: completedTables ?? this.completedTables,
      currentTable: currentTable ?? this.currentTable,
      errors: errors ?? this.errors,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

/// محرك المزامنة المركزي
/// ينسق جميع عمليات المزامنة بين القاعدة المحلية وSupabase
///
/// ترتيب المزامنة (3 مراحل + دلتا المخزون):
/// 1. Pull: سحب البيانات من السيرفر (منتجات، تصنيفات، إعدادات)
/// 2. Push: دفع البيانات المحلية (مبيعات، طلبات، حركات نقد)
/// 3. Bidirectional: مزامنة ثنائية (عملاء، مصروفات، مرتجعات)
/// 4. StockDelta: مزامنة دلتا المخزون (للأجهزة المتعددة)
class SyncEngine {
  final PullStrategy _pullStrategy;
  final PushStrategy _pushStrategy;
  final BidirectionalStrategy _bidirectionalStrategy;
  final StockDeltaSync _stockDeltaSync;
  final ConnectivityService _connectivity;
  final SyncStatusTracker _statusTracker;
  final SyncQueueDao _syncQueueDao;

  /// قفل لمنع المزامنة المتزامنة
  bool _isLocked = false;

  /// مؤقت المزامنة الدورية
  Timer? _periodicTimer;

  /// اشتراك مراقبة الاتصال
  StreamSubscription<bool>? _connectivitySubscription;

  /// تحكم بحالة التقدم
  final _progressController = StreamController<SyncProgress>.broadcast();

  /// آخر حالة تقدم
  SyncProgress _currentProgress = const SyncProgress();

  /// الفترة بين المزامنات الدورية (30 ثانية)
  static const Duration syncInterval = Duration(seconds: 30);

  /// عداد الفشل المتتالي (M148 fix - exponential backoff)
  int _consecutiveFailures = 0;

  /// الحد الأقصى للفشل المتتالي قبل التوقف المؤقت
  /// max = 30s × 2^4 = 480s ≈ 5 دقائق (بدلاً من 16 دقيقة)
  static const int _maxBackoffExponent = 4;

  /// الحد الأقصى المطلق للفترة بين المزامنات (5 دقائق)
  static const Duration _maxSyncInterval = Duration(minutes: 5);

  /// معرف المؤسسة الحالية
  String? _orgId;

  /// معرف المتجر الحالي
  String? _storeId;

  /// معرف الجهاز الحالي
  String? _deviceId;

  SyncEngine({
    required PullStrategy pullStrategy,
    required PushStrategy pushStrategy,
    required BidirectionalStrategy bidirectionalStrategy,
    required StockDeltaSync stockDeltaSync,
    required ConnectivityService connectivity,
    required SyncStatusTracker statusTracker,
    required SyncQueueDao syncQueueDao,
  }) : _pullStrategy = pullStrategy,
       _pushStrategy = pushStrategy,
       _bidirectionalStrategy = bidirectionalStrategy,
       _stockDeltaSync = stockDeltaSync,
       _connectivity = connectivity,
       _statusTracker = statusTracker,
       _syncQueueDao = syncQueueDao;

  /// تهيئة المحرك
  Future<void> initialize({
    required String orgId,
    required String storeId,
    required String deviceId,
  }) async {
    _orgId = orgId;
    _storeId = storeId;
    _deviceId = deviceId;

    // الاستماع لتغييرات الاتصال
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      isOnline,
    ) {
      if (isOnline) {
        // عند استعادة الاتصال: مزامنة فورية
        syncNow();
      } else {
        // عند فقدان الاتصال: إيقاف المؤقت
        _periodicTimer?.cancel();
      }
    });

    // بدء المزامنة الدورية إذا كان متصلاً
    if (_connectivity.isOnline) {
      _startPeriodicSync();
      // مزامنة أولية
      await syncNow();
    }
  }

  /// Stream لحالة التقدم
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// حالة التقدم الحالية
  SyncProgress get currentProgress => _currentProgress;

  /// Performs a lightweight health check before starting a sync cycle.
  ///
  /// Returns a [SyncHealthReport] with:
  /// - [isServerReachable]: whether the network is available
  /// - [lastSyncTime]: timestamp of the last successful sync
  /// - [pendingItemCount]: number of items waiting to be pushed
  /// - [consecutiveFailures]: how many sync cycles have failed in a row
  /// - [errors]: list of error messages from the last sync
  Future<SyncHealthReport> healthCheck() async {
    bool isReachable = false;

    if (_connectivity.isOnline) {
      try {
        // Lightweight connectivity check
        isReachable = await _connectivity.checkConnectivity();
      } catch (_) {
        isReachable = false;
      }
    }

    // Get pending count from status tracker overview
    final overview = _statusTracker.currentOverview;
    final pendingCount = overview.totalPending;

    // Get dead letter count
    int deadLetterCount = 0;
    try {
      deadLetterCount = await _syncQueueDao.getDeadLetterCount();
    } catch (_) {}

    return SyncHealthReport(
      isServerReachable: isReachable,
      lastSyncTime: _currentProgress.lastSyncAt,
      pendingItemCount: pendingCount,
      consecutiveFailures: _consecutiveFailures,
      currentState: _currentProgress.state,
      errors: _currentProgress.errors,
      deadLetterCount: deadLetterCount,
    );
  }

  /// هل المحرك مقفل (مزامنة جارية)؟
  bool get isLocked => _isLocked;

  /// تنفيذ مزامنة فورية
  Future<SyncEngineResult> syncNow() async {
    // منع المزامنة المتزامنة
    if (_isLocked) {
      return SyncEngineResult(
        success: false,
        errors: ['Sync already in progress'],
      );
    }

    if (_connectivity.isOffline) {
      return SyncEngineResult(success: false, errors: ['Device is offline']);
    }

    if (_orgId == null || _storeId == null || _deviceId == null) {
      return SyncEngineResult(
        success: false,
        errors: ['Sync engine not initialized (missing org/store/device ID)'],
      );
    }

    _isLocked = true;
    final allErrors = <String>[];

    // استعادة العناصر العالقة من تعطل سابق (>60 ثانية في حالة syncing)
    try {
      final recovered = await _syncQueueDao.recoverStuckItems();
      if (recovered > 0 && kDebugMode) {
        debugPrint('SyncEngine: recovered $recovered stuck items before sync');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncEngine: failed to recover stuck items: $e');
      }
    }

    // حساب إجمالي الجداول
    final totalTables =
        PullStrategy.pullTables.length +
        1 + // push (1 عملية)
        BidirectionalStrategy.tableConfigs.length +
        1; // stock delta

    _updateProgress(
      SyncProgress(
        state: SyncEngineState.syncing,
        phase: SyncPhase.pulling,
        totalTables: totalTables,
        completedTables: 0,
      ),
    );

    try {
      int completed = 0;

      // المرحلة 1: سحب (Pull)
      _updateProgress(_currentProgress.copyWith(phase: SyncPhase.pulling));
      final pullResults = await _pullStrategy.pullAll(
        orgId: _orgId!,
        storeId: _storeId!,
      );
      for (final result in pullResults) {
        completed++;
        _updateProgress(
          _currentProgress.copyWith(
            completedTables: completed,
            currentTable: result.tableName,
          ),
        );
        if (result.hasErrors) allErrors.addAll(result.errors);
      }

      // المرحلة 2: دفع (Push)
      _updateProgress(_currentProgress.copyWith(phase: SyncPhase.pushing));
      final pushResult = await _pushStrategy.pushPending();
      completed++;
      _updateProgress(_currentProgress.copyWith(completedTables: completed));
      if (pushResult.hasErrors) allErrors.addAll(pushResult.errors);

      // المرحلة 3: ثنائي الاتجاه (Bidirectional)
      _updateProgress(
        _currentProgress.copyWith(phase: SyncPhase.bidirectional),
      );
      final biResults = await _bidirectionalStrategy.syncAll(
        orgId: _orgId!,
        storeId: _storeId!,
      );
      for (final result in biResults) {
        completed++;
        _updateProgress(
          _currentProgress.copyWith(
            completedTables: completed,
            currentTable: result.tableName,
          ),
        );
        if (result.hasErrors) allErrors.addAll(result.errors);
      }

      // المرحلة 4: دلتا المخزون (Stock Delta)
      _updateProgress(_currentProgress.copyWith(phase: SyncPhase.stockDelta));
      final deltaResult = await _stockDeltaSync.sync(
        orgId: _orgId!,
        storeId: _storeId!,
        deviceId: _deviceId!,
      );
      completed++;
      _updateProgress(_currentProgress.copyWith(completedTables: completed));
      if (deltaResult.hasErrors) allErrors.addAll(deltaResult.errors);

      // تحديث حالة المزامنة
      final now = DateTime.now().toUtc();
      final finalState = allErrors.isEmpty
          ? SyncEngineState.completed
          : SyncEngineState.error;

      _updateProgress(
        SyncProgress(
          state: finalState,
          phase: SyncPhase.none,
          totalTables: totalTables,
          completedTables: totalTables,
          errors: allErrors,
          lastSyncAt: now,
        ),
      );

      // تحديث متتبع الحالة
      await _statusTracker.refreshAll();

      // إعادة تعيين الحالة لـ idle بعد ثانيتين
      Future.delayed(const Duration(seconds: 2), () {
        if (!_progressController.isClosed) {
          _updateProgress(
            _currentProgress.copyWith(state: SyncEngineState.idle),
          );
        }
      });

      final success = allErrors.isEmpty;
      if (success) {
        _resetBackoff();
      } else {
        _incrementBackoff();
      }

      return SyncEngineResult(
        success: success,
        errors: allErrors,
        pullResults: pullResults,
        pushResult: pushResult,
        bidirectionalResults: biResults,
        stockDeltaResult: deltaResult,
      );
    } catch (e) {
      allErrors.add('SyncEngine: $e');
      _updateProgress(
        SyncProgress(
          state: SyncEngineState.error,
          phase: SyncPhase.none,
          errors: allErrors,
        ),
      );

      _incrementBackoff();

      if (kDebugMode) {
        debugPrint('SyncEngine critical error: $e');
      }

      return SyncEngineResult(success: false, errors: allErrors);
    } finally {
      _isLocked = false;
    }
  }

  /// بدء المزامنة الدورية مع exponential backoff (M148 fix)
  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    final backoffMultiplier = _consecutiveFailures > 0
        ? (1 << _consecutiveFailures.clamp(0, _maxBackoffExponent))
        : 1;
    var interval = syncInterval * backoffMultiplier;
    // حد أقصى 5 دقائق بين المزامنات
    if (interval > _maxSyncInterval) interval = _maxSyncInterval;
    _periodicTimer = Timer.periodic(interval, (_) {
      if (_connectivity.isOnline && !_isLocked) {
        syncNow();
      }
    });

    if (kDebugMode && _consecutiveFailures > 0) {
      debugPrint(
        'SyncEngine: backoff interval = ${interval.inSeconds}s '
        '(failures: $_consecutiveFailures)',
      );
    }
  }

  /// إعادة تعيين backoff عند نجاح المزامنة
  void _resetBackoff() {
    if (_consecutiveFailures > 0) {
      _consecutiveFailures = 0;
      _startPeriodicSync();
    }
  }

  /// زيادة backoff عند فشل المزامنة
  void _incrementBackoff() {
    _consecutiveFailures++;
    _startPeriodicSync();
  }

  /// تحديث حالة التقدم
  void _updateProgress(SyncProgress progress) {
    _currentProgress = progress;
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  /// إيقاف المحرك وتنظيف الموارد
  void dispose() {
    _periodicTimer?.cancel();
    _connectivitySubscription?.cancel();
    _progressController.close();
  }
}

/// نتيجة عملية المزامنة الكاملة
class SyncEngineResult {
  final bool success;
  final List<String> errors;
  final List<PullResult>? pullResults;
  final PushResult? pushResult;
  final List<BidirectionalResult>? bidirectionalResults;
  final StockDeltaResult? stockDeltaResult;

  SyncEngineResult({
    required this.success,
    required this.errors,
    this.pullResults,
    this.pushResult,
    this.bidirectionalResults,
    this.stockDeltaResult,
  });

  /// إجمالي السجلات التي تمت مزامنتها
  int get totalSynced {
    int total = 0;
    if (pullResults != null) {
      total += pullResults!.fold(0, (sum, r) => sum + r.recordsPulled);
    }
    if (pushResult != null) {
      total += pushResult!.successCount;
    }
    if (bidirectionalResults != null) {
      total += bidirectionalResults!.fold(
        0,
        (sum, r) => sum + r.pushed + r.pulled,
      );
    }
    if (stockDeltaResult != null) {
      total += stockDeltaResult!.deltasSent;
    }
    return total;
  }
}

/// تقرير صحة محرك المزامنة
///
/// يُستخدم لمراقبة حالة المزامنة وتشخيص المشاكل.
class SyncHealthReport {
  /// هل الخادم قابل للوصول؟
  final bool isServerReachable;

  /// آخر وقت مزامنة ناجحة
  final DateTime? lastSyncTime;

  /// عدد العناصر المعلقة للدفع
  final int pendingItemCount;

  /// عدد حالات الفشل المتتالية
  final int consecutiveFailures;

  /// حالة المحرك الحالية
  final SyncEngineState currentState;

  /// قائمة الأخطاء من آخر محاولة مزامنة
  final List<String> errors;

  /// عدد العناصر الميتة (فشلت نهائياً بعد استنفاد المحاولات)
  final int deadLetterCount;

  const SyncHealthReport({
    required this.isServerReachable,
    this.lastSyncTime,
    this.pendingItemCount = 0,
    this.consecutiveFailures = 0,
    this.currentState = SyncEngineState.idle,
    this.errors = const [],
    this.deadLetterCount = 0,
  });

  /// هل المزامنة في حالة صحية؟
  bool get isHealthy =>
      isServerReachable && consecutiveFailures == 0 && errors.isEmpty;

  /// هل المزامنة في حالة تحذير (أخطاء قليلة)؟
  bool get isWarning => consecutiveFailures > 0 && consecutiveFailures < 3;

  /// هل المزامنة في حالة حرجة (أخطاء كثيرة)؟
  bool get isCritical => !isServerReachable || consecutiveFailures >= 3;

  /// مدة منذ آخر مزامنة
  Duration? get timeSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().toUtc().difference(lastSyncTime!);
  }

  /// ملخص نصي للحالة
  String get summary {
    if (isCritical) {
      return 'Critical: ${!isServerReachable ? "Server unreachable" : "$consecutiveFailures consecutive failures"}';
    }
    if (isWarning) {
      return 'Warning: $consecutiveFailures failures, $pendingItemCount pending';
    }
    final dlSuffix = deadLetterCount > 0
        ? ', $deadLetterCount dead letter'
        : '';
    return 'Healthy: $pendingItemCount pending items$dlSuffix';
  }

  @override
  String toString() =>
      'SyncHealthReport(reachable=$isServerReachable, pending=$pendingItemCount, '
      'failures=$consecutiveFailures, deadLetter=$deadLetterCount, '
      'lastSync=$lastSyncTime, errors=${errors.length})';
}
