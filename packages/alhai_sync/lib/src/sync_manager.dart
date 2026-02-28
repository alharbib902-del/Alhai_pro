import 'dart:async';
import 'dart:convert';

import 'connectivity_service.dart';
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

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncManager({
    required SyncService syncService,
    required ConnectivityService connectivityService,
    this.onSync,
    this.orgSyncService,
  }) : _syncService = syncService,
       _connectivityService = connectivityService;
  
  /// تهيئة المدير وبدء المراقبة
  Future<void> initialize() async {
    // الاستماع لتغييرات الاتصال
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // محاولة المزامنة عند استعادة الاتصال
        syncPending();
      }
    });
    
    // مزامنة أولية إذا كان متصل
    if (_connectivityService.isOnline) {
      await syncPending();
    }
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
      
      for (final item in pendingItems) {
        try {
          await _syncService.markAsSyncing(item.id);
          
          final payload = jsonDecode(item.payload) as Map<String, dynamic>;

          // توجيه جداول المؤسسة لخدمة مزامنة المؤسسة
          if (OrgTables.all.contains(item.tableName_) && orgSyncService != null) {
            await orgSyncService!.syncOperation(
              tableName: item.tableName_,
              operation: item.operation,
              payload: payload,
            );
          } else if (onSync != null) {
            await onSync!(item.tableName_, item.operation, payload);
          }
          
          await _syncService.markAsSynced(item.id);
          successCount++;
        } catch (e) {
          await _syncService.markAsFailed(item.id, e.toString());
          failedCount++;
          errors.add('${item.tableName_}/${item.recordId}: $e');
          
          // جدولة إعادة المحاولة
          _scheduleRetry(item.retryCount);
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
  
  /// جدولة إعادة المحاولة مع exponential backoff
  void _scheduleRetry(int retryCount) {
    if (retryCount >= RetryStrategy.maxRetries) return;
    
    final delay = RetryStrategy.getDelay(retryCount);
    _syncTimer?.cancel();
    _syncTimer = Timer(delay, () {
      if (_connectivityService.isOnline) {
        syncPending();
      }
    });
  }
  
  /// تنظيف العناصر القديمة
  Future<int> cleanup() {
    return _syncService.cleanup();
  }
  
  /// إيقاف المدير
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _statusController.close();
  }
}
