import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'conflict_resolver.dart';
import 'connectivity_service.dart';
import 'pull_sync_service.dart';
import 'sync_service.dart';
import 'org_sync_service.dart';

/// استراتيجية Exponential Backoff للمحاولات
class RetryStrategy {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);
  
  /// حساب التأخير بناءً على عدد المحاولات
  static Duration getDelay(int retryCount) {
    // 2s, 4s, 8s, 16s, ...
    return baseDelay * (1 << retryCount);
  }
}

/// حالة المزامنة
enum SyncStatus { idle, syncing, error }

/// نتيجة المزامنة
class SyncResult {
  final int successCount;
  final int failedCount;
  final List<String> errors;
  
  SyncResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });
  
  bool get hasErrors => failedCount > 0;
  int get totalCount => successCount + failedCount;
}

/// مدير المزامنة
/// يدير عملية المزامنة التلقائية ويراقب الاتصال
class SyncManager {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final Future<void> Function(String tableName, String operation, Map<String, dynamic> payload)? onSync;
  final OrgSyncService? orgSyncService;

  /// خدمة السحب الدوري (اختيارية - تحتاج SupabaseClient)
  final PullSyncService? pullSyncService;

  /// معرف المتجر الحالي (مطلوب لعمليات السحب)
  final String? storeId;

  /// فاصل المزامنة الدورية للدفع (كل 15 ثانية)
  static const _periodicSyncInterval = Duration(seconds: 15);

  /// فاصل السحب الدوري (قابل للتخصيص، افتراضي 30 ثانية)
  final Duration pullSyncInterval;

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  Timer? _periodicTimer;
  Timer? _pullTimer;
  Timer? _dailyCleanupTimer;
  bool _isSyncing = false;
  bool _isPulling = false;
  DateTime? _lastCleanupTime;

  SyncManager({
    required SyncService syncService,
    required ConnectivityService connectivityService,
    this.onSync,
    this.orgSyncService,
    this.pullSyncService,
    this.storeId,
    this.pullSyncInterval = const Duration(seconds: 30),
  }) : _syncService = syncService,
       _connectivityService = connectivityService;
  
  /// تهيئة المدير وبدء المراقبة
  Future<void> initialize() async {
    // استعادة العناصر العالقة في حالة 'syncing' لأكثر من 5 دقائق
    // (بسبب إغلاق مفاجئ أو crash أثناء المزامنة)
    try {
      final recovered = await _syncService.recoverStuckSyncingItems(
        stuckThreshold: const Duration(minutes: 5),
      );
      if (recovered > 0 && kDebugMode) {
        debugPrint('[SyncManager] 🔧 Recovered $recovered items stuck in syncing state (>5min)');
      }
      // أيضاً استعادة العناصر بدون timeout (للتوافق مع الكود القديم)
      await _recoverStuckSyncingItems();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncManager] ⚠️ Failed to recover stuck syncing items: $e');
      }
    }

    // إعادة تعيين العناصر المتعارضة عند بدء التشغيل
    // فقط العناصر التي يمكن إعادة محاولتها (network timeouts) وليست تعارضات حقيقية
    try {
      if (_connectivityService.isOnline) {
        final conflictItems = await _syncService.getConflictItems();
        if (conflictItems.isNotEmpty) {
          int retried = 0;
          int preserved = 0;
          for (final item in conflictItems) {
            // Parse conflict details from error field
            final errorJson = item.lastError;
            if (errorJson != null) {
              final conflict = SyncConflict.fromJsonString(
                errorJson,
                syncQueueId: item.id,
              );
              if (conflict != null) {
                // Only retry network timeouts - they are transient
                if (conflict.type == ConflictType.networkTimeout) {
                  await _syncService.retryItem(item.id);
                  retried++;
                } else {
                  // Real conflicts (version, delete-update, schema) are preserved
                  preserved++;
                }
                continue;
              }
            }
            // Items without structured conflict data (legacy) - retry them
            await _syncService.retryItem(item.id);
            retried++;
          }
          if (kDebugMode) {
            if (retried > 0) {
              debugPrint('[SyncManager] Retrying $retried transient conflict items (online)');
            }
            if (preserved > 0) {
              debugPrint('[SyncManager] Preserved $preserved real conflict items for review');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncManager] Failed to process conflict items: $e');
      }
    }

    // الاستماع لتغييرات الاتصال
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // محاولة المزامنة عند استعادة الاتصال
        syncPending();
        // سحب التحديثات أيضاً عند استعادة الاتصال
        pullUpdates();
      }
    });

    // مزامنة أولية إذا كان متصل
    if (_connectivityService.isOnline) {
      await syncPending();
    }

    // مؤقت دوري لالتقاط العناصر الجديدة التي تُضاف بعد التشغيل
    _periodicTimer = Timer.periodic(_periodicSyncInterval, (_) {
      if (_connectivityService.isOnline && !_isSyncing) {
        syncPending();
      }
    });

    // مؤقت دوري للسحب من السيرفر (Pull sync)
    if (pullSyncService != null && storeId != null) {
      if (kDebugMode) {
        debugPrint('[SyncManager] Starting pull sync timer (interval: ${pullSyncInterval.inSeconds}s)');
      }
      _pullTimer = Timer.periodic(pullSyncInterval, (_) {
        if (_connectivityService.isOnline && !_isPulling) {
          pullUpdates();
        }
      });
    }

    // مؤقت يومي لتنظيف العناصر القديمة المتزامنة (أقدم من 3 أيام)
    _dailyCleanupTimer = Timer.periodic(const Duration(hours: 24), (_) async {
      try {
        final deleted = await _syncService.cleanup(olderThan: const Duration(days: 3));
        if (kDebugMode && deleted > 0) {
          debugPrint('[SyncManager] 🧹 Daily cleanup: removed $deleted old synced items');
        }
        // تنظيف سجلات المزامنة القديمة (أقدم من 7 أيام)
        final auditDeleted = await _syncService.cleanupSyncAuditLogs();
        if (kDebugMode && auditDeleted > 0) {
          debugPrint('[SyncManager] 🧹 Daily cleanup: removed $auditDeleted old sync audit logs');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SyncManager] ⚠️ Daily cleanup failed: $e');
        }
      }
    });
  }
  
  /// حالة المزامنة
  Stream<SyncStatus> get statusStream => _statusController.stream;
  
  /// هل جاري المزامنة؟
  bool get isSyncing => _isSyncing;
  
  /// مزامنة العناصر المعلقة
  Future<SyncResult> syncPending() async {
    if (_isSyncing || _connectivityService.isOffline) {
      return SyncResult(successCount: 0, failedCount: 0, errors: []);
    }
    
    _isSyncing = true;
    _statusController.add(SyncStatus.syncing);
    
    int successCount = 0;
    int failedCount = 0;
    final errors = <String>[];
    
    try {
      final pendingItems = await _syncService.getPendingItems();

      if (kDebugMode) {
        debugPrint('[SyncManager] 📤 Push: ${pendingItems.length} pending items');
        for (final item in pendingItems) {
          debugPrint('[SyncManager]   → ${item.tableName_}/${item.recordId} (${item.operation}, retry: ${item.retryCount})');
        }
      }

      // فحص صحة الطابور وتسجيل تحذير إذا كان ممتلئاً
      try {
        final health = await _syncService.getQueueHealth();
        if (health.isOverloaded && kDebugMode) {
          debugPrint('[SyncManager] ⚠️ Queue overloaded: ${health.activeCount} active items');
        } else if (health.isWarning && kDebugMode) {
          debugPrint('[SyncManager] ⚠️ Queue warning: ${health.activeCount} active items');
        }
      } catch (_) {
        // تجاهل أخطاء فحص الصحة
      }

      for (final item in pendingItems) {
        // فحص الاتصال قبل كل عنصر (network-aware retry)
        if (_connectivityService.isOffline) {
          if (kDebugMode) {
            debugPrint('[SyncManager] ⚠️ Connection lost, stopping push (${pendingItems.length - successCount - failedCount} items remaining)');
          }
          break;
        }

        final stopwatch = Stopwatch()..start();
        try {
          await _syncService.markAsSyncing(item.id);

          final payload = jsonDecode(item.payload) as Map<String, dynamic>;

          // توجيه جداول المؤسسة لخدمة مزامنة المؤسسة
          bool didSync = false;
          if (OrgTables.all.contains(item.tableName_) && orgSyncService != null) {
            await orgSyncService!.syncOperation(
              tableName: item.tableName_,
              operation: item.operation,
              payload: payload,
            );
            didSync = true;
          } else if (onSync != null) {
            await onSync!(item.tableName_, item.operation, payload);
            didSync = true;
          } else {
            if (kDebugMode) {
              debugPrint('[SyncManager] ❌ No sync handler for ${item.tableName_} (onSync=null, orgSync=${orgSyncService != null})');
              debugPrint('[SyncManager] ❌ SupabaseClient may not be registered in GetIt!');
            }
          }

          stopwatch.stop();

          if (didSync) {
            await _syncService.markAsSynced(item.id);
            successCount++;
            if (kDebugMode) {
              debugPrint('[SyncManager] ✅ Synced: ${item.tableName_}/${item.recordId} (${stopwatch.elapsedMilliseconds}ms)');
            }
            // تسجيل عملية ناجحة
            try {
              await _syncService.logSyncOperation(
                tableName: item.tableName_,
                operation: item.operation,
                recordId: item.recordId,
                result: 'success',
                durationMs: stopwatch.elapsedMilliseconds,
              );
            } catch (_) {
              // تجاهل أخطاء التسجيل - لا تمنع المزامنة
            }
          } else {
            // إعادة الحالة إلى pending (كانت تتغير إلى syncing أعلاه ولا ترجع)
            await _syncService.retryItem(item.id);
            failedCount++;
            errors.add('${item.tableName_}/${item.recordId}: No sync handler available');
            if (kDebugMode) {
              debugPrint('[SyncManager] ⏳ Reverted to pending (no handler): ${item.tableName_}/${item.recordId}');
            }
          }
        } catch (e) {
          stopwatch.stop();

          // تحديد ما إذا كان يجب وضع العنصر كتعارض (conflict) بدلاً من مجرد فشل
          final isMaxRetries = item.retryCount + 1 >= item.maxRetries;
          if (isMaxRetries) {
            await _syncService.markAsConflict(
              item.id,
              'Max retries (${item.maxRetries}) reached: $e',
            );
            if (kDebugMode) {
              debugPrint('[SyncManager] 🚫 Conflict (max retries): ${item.tableName_}/${item.recordId}: $e');
            }
          } else {
            await _syncService.markAsFailed(item.id, e.toString());
          }

          failedCount++;
          errors.add('${item.tableName_}/${item.recordId}: $e');
          if (kDebugMode) {
            debugPrint('[SyncManager] ❌ Failed: ${item.tableName_}/${item.recordId}: $e');
          }

          // تسجيل عملية فاشلة
          try {
            await _syncService.logSyncOperation(
              tableName: item.tableName_,
              operation: item.operation,
              recordId: item.recordId,
              result: isMaxRetries ? 'conflict' : 'failed',
              durationMs: stopwatch.elapsedMilliseconds,
              error: e.toString(),
            );
          } catch (_) {
            // تجاهل أخطاء التسجيل
          }

          // جدولة إعادة المحاولة فقط إذا كنا متصلين (network-aware)
          if (_connectivityService.isOnline && !isMaxRetries) {
            _scheduleRetry(item.retryCount);
          }
        }
      }

      // تنظيف تلقائي بعد مزامنة ناجحة (مرة واحدة في الساعة كحد أقصى)
      if (successCount > 0) {
        final now = DateTime.now();
        final shouldCleanup = _lastCleanupTime == null ||
            now.difference(_lastCleanupTime!).inHours >= 1;
        if (shouldCleanup) {
          try {
            final deleted = await _syncService.cleanup(
              olderThan: const Duration(hours: 6),
            );
            _lastCleanupTime = now;
            if (kDebugMode && deleted > 0) {
              debugPrint('[SyncManager] 🧹 Auto-cleanup: removed $deleted synced items older than 6h');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[SyncManager] ⚠️ Auto-cleanup failed: $e');
            }
          }
        }
      }
    } finally {
      _isSyncing = false;
      _statusController.add(
        errors.isNotEmpty ? SyncStatus.error : SyncStatus.idle,
      );
    }
    
    return SyncResult(
      successCount: successCount,
      failedCount: failedCount,
      errors: errors,
    );
  }
  
  /// سحب التحديثات من السيرفر (Pull)
  ///
  /// يسحب البيانات المحدثة من الجداول التي يديرها المشرف/لوحة التحكم.
  /// يعمل بشكل مستقل عن Push sync (مؤقت منفصل وعلامة منفصلة).
  Future<PullSyncResult?> pullUpdates() async {
    if (_isPulling || _connectivityService.isOffline) {
      return null;
    }

    if (pullSyncService == null || storeId == null) {
      if (kDebugMode) {
        debugPrint('[PullSync] Skipped: pullSyncService or storeId is null');
      }
      return null;
    }

    _isPulling = true;

    try {
      final result = await pullSyncService!.pullUpdates(storeId: storeId!);

      if (kDebugMode && result.totalPulled > 0) {
        debugPrint('[SyncManager] Pull complete: ${result.totalPulled} records pulled'
            '${result.skippedConflicts > 0 ? ', ${result.skippedConflicts} conflicts skipped' : ''}');
      }

      if (result.hasErrors && kDebugMode) {
        debugPrint('[SyncManager] Pull errors: ${result.errors.join('; ')}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncManager] Pull failed: $e');
      }
      return null;
    } finally {
      _isPulling = false;
    }
  }

  /// جدولة إعادة المحاولة مع exponential backoff
  /// لا تبدأ المؤقت إذا كنا أوفلاين (network-aware)
  void _scheduleRetry(int retryCount) {
    if (retryCount >= RetryStrategy.maxRetries) return;

    // لا فائدة من جدولة retry إذا كنا أوفلاين
    if (_connectivityService.isOffline) return;

    final delay = RetryStrategy.getDelay(retryCount);
    _syncTimer?.cancel();
    _syncTimer = Timer(delay, () {
      // فحص مزدوج: تأكد أننا لا زلنا متصلين عند انتهاء المؤقت
      if (_connectivityService.isOnline) {
        syncPending();
      }
    });
  }
  
  /// استعادة العناصر العالقة في حالة 'syncing'
  /// يحدث عند إغلاق التطبيق أثناء المزامنة أو عند خطأ غير معالج
  Future<void> _recoverStuckSyncingItems() async {
    final stuckItems = await _syncService.getStuckSyncingItems();
    if (stuckItems.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[SyncManager] 🔧 Recovering ${stuckItems.length} items stuck in syncing state');
      }
      for (final item in stuckItems) {
        await _syncService.retryItem(item.id);
        if (kDebugMode) {
          debugPrint('[SyncManager]   → Recovered: ${item.tableName_}/${item.recordId}');
        }
      }
    }
  }

  /// تنظيف العناصر القديمة
  Future<int> cleanup() {
    return _syncService.cleanup();
  }
  
  /// إيقاف المدير
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _periodicTimer?.cancel();
    _pullTimer?.cancel();
    _dailyCleanupTimer?.cancel();
    _statusController.close();
  }
}
