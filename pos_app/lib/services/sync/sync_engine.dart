import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connectivity_service.dart';
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

  double get progress =>
      totalTables > 0 ? completedTables / totalTables : 0.0;

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
  })  : _pullStrategy = pullStrategy,
        _pushStrategy = pushStrategy,
        _bidirectionalStrategy = bidirectionalStrategy,
        _stockDeltaSync = stockDeltaSync,
        _connectivity = connectivity,
        _statusTracker = statusTracker;

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
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((isOnline) {
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
      return SyncEngineResult(
        success: false,
        errors: ['Device is offline'],
      );
    }

    if (_orgId == null || _storeId == null || _deviceId == null) {
      return SyncEngineResult(
        success: false,
        errors: ['Sync engine not initialized (missing org/store/device ID)'],
      );
    }

    _isLocked = true;
    final allErrors = <String>[];

    // حساب إجمالي الجداول
    final totalTables = PullStrategy.pullTables.length +
        1 + // push (1 عملية)
        BidirectionalStrategy.tableConfigs.length +
        1; // stock delta

    _updateProgress(SyncProgress(
      state: SyncEngineState.syncing,
      phase: SyncPhase.pulling,
      totalTables: totalTables,
      completedTables: 0,
    ));

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
        _updateProgress(_currentProgress.copyWith(
          completedTables: completed,
          currentTable: result.tableName,
        ));
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
          _currentProgress.copyWith(phase: SyncPhase.bidirectional));
      final biResults = await _bidirectionalStrategy.syncAll(
        orgId: _orgId!,
        storeId: _storeId!,
      );
      for (final result in biResults) {
        completed++;
        _updateProgress(_currentProgress.copyWith(
          completedTables: completed,
          currentTable: result.tableName,
        ));
        if (result.hasErrors) allErrors.addAll(result.errors);
      }

      // المرحلة 4: دلتا المخزون (Stock Delta)
      _updateProgress(
          _currentProgress.copyWith(phase: SyncPhase.stockDelta));
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

      _updateProgress(SyncProgress(
        state: finalState,
        phase: SyncPhase.none,
        totalTables: totalTables,
        completedTables: totalTables,
        errors: allErrors,
        lastSyncAt: now,
      ));

      // تحديث متتبع الحالة
      await _statusTracker.refreshAll();

      // إعادة تعيين الحالة لـ idle بعد ثانيتين
      Future.delayed(const Duration(seconds: 2), () {
        if (!_progressController.isClosed) {
          _updateProgress(_currentProgress.copyWith(
            state: SyncEngineState.idle,
          ));
        }
      });

      return SyncEngineResult(
        success: allErrors.isEmpty,
        errors: allErrors,
        pullResults: pullResults,
        pushResult: pushResult,
        bidirectionalResults: biResults,
        stockDeltaResult: deltaResult,
      );
    } catch (e) {
      allErrors.add('SyncEngine: $e');
      _updateProgress(SyncProgress(
        state: SyncEngineState.error,
        phase: SyncPhase.none,
        errors: allErrors,
      ));

      if (kDebugMode) {
        debugPrint('SyncEngine critical error: $e');
      }

      return SyncEngineResult(success: false, errors: allErrors);
    } finally {
      _isLocked = false;
    }
  }

  /// بدء المزامنة الدورية
  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(syncInterval, (_) {
      if (_connectivity.isOnline && !_isLocked) {
        syncNow();
      }
    });
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
      total += bidirectionalResults!
          .fold(0, (sum, r) => sum + r.pushed + r.pulled);
    }
    if (stockDeltaResult != null) {
      total += stockDeltaResult!.deltasSent;
    }
    return total;
  }
}
