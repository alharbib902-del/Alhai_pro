/// Offline Manager - إدارة العمل بدون إنترنت
///
/// يوفر:
/// - مراقبة حالة الاتصال
/// - إشعارات تغير الاتصال
/// - عرض العمليات المعلقة
/// - مزامنة تلقائية عند عودة الاتصال
library offline_manager;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ============================================================================
// CONNECTION STATUS
// ============================================================================

/// حالة الاتصال
enum ConnectionStatus {
  /// متصل بالإنترنت
  online,

  /// غير متصل
  offline,

  /// جاري التحقق
  checking,
}

/// نوع الاتصال
enum NetworkConnectionType {
  /// WiFi
  wifi,

  /// بيانات الجوال
  mobile,

  /// Ethernet
  ethernet,

  /// غير معروف
  unknown,

  /// لا يوجد اتصال
  none,
}

// ============================================================================
// CONNECTION STATE
// ============================================================================

/// حالة الاتصال الكاملة
class NetworkConnectionState {
  final ConnectionStatus status;
  final NetworkConnectionType type;
  final DateTime lastChecked;
  final DateTime? lastOnline;
  final int pendingSyncCount;

  const NetworkConnectionState({
    required this.status,
    required this.type,
    required this.lastChecked,
    this.lastOnline,
    this.pendingSyncCount = 0,
  });

  bool get isOnline => status == ConnectionStatus.online;
  bool get isOffline => status == ConnectionStatus.offline;

  /// مدة عدم الاتصال
  Duration? get offlineDuration {
    if (isOnline || lastOnline == null) return null;
    return DateTime.now().difference(lastOnline!);
  }

  NetworkConnectionState copyWith({
    ConnectionStatus? status,
    NetworkConnectionType? type,
    DateTime? lastChecked,
    DateTime? lastOnline,
    int? pendingSyncCount,
  }) {
    return NetworkConnectionState(
      status: status ?? this.status,
      type: type ?? this.type,
      lastChecked: lastChecked ?? this.lastChecked,
      lastOnline: lastOnline ?? this.lastOnline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}

// ============================================================================
// OFFLINE MANAGER
// ============================================================================

/// مدير العمل بدون إنترنت
class OfflineManager {
  OfflineManager._();

  static OfflineManager? _instance;
  static OfflineManager get instance => _instance ??= OfflineManager._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  /// حالة الاتصال الحالية
  NetworkConnectionState _state = NetworkConnectionState(
    status: ConnectionStatus.checking,
    type: NetworkConnectionType.unknown,
    lastChecked: DateTime.now(),
  );

  NetworkConnectionState get state => _state;

  /// Stream لمراقبة تغيرات الاتصال
  final _stateController = StreamController<NetworkConnectionState>.broadcast();
  Stream<NetworkConnectionState> get stateStream => _stateController.stream;

  /// Callbacks عند تغير الاتصال
  final List<void Function(NetworkConnectionState)> _listeners = [];

  /// Callback للمزامنة عند عودة الاتصال
  Future<void> Function()? onReconnect;

  /// بدء المراقبة
  Future<void> startMonitoring() async {
    // فحص أولي
    await checkConnection();

    // الاستماع لتغيرات الاتصال
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) => _handleConnectivityChange(result),
    );

    debugPrint('[OfflineManager] Started monitoring');
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('[OfflineManager] Stopped monitoring');
  }

  /// فحص الاتصال يدوياً
  Future<NetworkConnectionState> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(result);
    return _state;
  }

  /// معالجة تغير الاتصال
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    final wasOnline = _state.isOnline;
    final type = _mapConnectivityType(result);
    final isNowOnline = type != NetworkConnectionType.none;

    _state = _state.copyWith(
      status: isNowOnline ? ConnectionStatus.online : ConnectionStatus.offline,
      type: type,
      lastChecked: DateTime.now(),
      lastOnline: isNowOnline ? DateTime.now() : _state.lastOnline,
    );

    _stateController.add(_state);

    // إشعار المستمعين
    for (final listener in _listeners) {
      listener(_state);
    }

    // إذا عاد الاتصال، نبدأ المزامنة
    if (!wasOnline && isNowOnline) {
      debugPrint('[OfflineManager] 📶 Connection restored!');
      _onConnectionRestored();
    } else if (wasOnline && !isNowOnline) {
      debugPrint('[OfflineManager] 📴 Connection lost!');
    }
  }

  NetworkConnectionType _mapConnectivityType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkConnectionType.wifi;
      case ConnectivityResult.mobile:
        return NetworkConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkConnectionType.ethernet;
      case ConnectivityResult.none:
        return NetworkConnectionType.none;
      default:
        return NetworkConnectionType.unknown;
    }
  }

  /// عند عودة الاتصال
  Future<void> _onConnectionRestored() async {
    if (onReconnect != null) {
      try {
        await onReconnect!();
        debugPrint('[OfflineManager] ✅ Sync completed after reconnection');
      } catch (e) {
        debugPrint('[OfflineManager] ❌ Sync failed: $e');
      }
    }
  }

  /// تسجيل مستمع
  void addListener(void Function(NetworkConnectionState) listener) {
    _listeners.add(listener);
  }

  /// إلغاء تسجيل مستمع
  void removeListener(void Function(NetworkConnectionState) listener) {
    _listeners.remove(listener);
  }

  /// تحديث عدد العمليات المعلقة
  void updatePendingCount(int count) {
    _state = _state.copyWith(pendingSyncCount: count);
    _stateController.add(_state);
  }

  /// التنظيف
  void dispose() {
    stopMonitoring();
    _stateController.close();
    _listeners.clear();
  }
}

// ============================================================================
// OFFLINE AWARE MIXIN
// ============================================================================

/// Mixin لإضافة وعي بحالة الاتصال للـ widgets
mixin OfflineAwareMixin {
  StreamSubscription<NetworkConnectionState>? _offlineSubscription;

  /// الاشتراك في تغيرات الاتصال
  void subscribeToConnectivity(void Function(NetworkConnectionState) onChanged) {
    _offlineSubscription = OfflineManager.instance.stateStream.listen(onChanged);
  }

  /// إلغاء الاشتراك
  void unsubscribeFromConnectivity() {
    _offlineSubscription?.cancel();
    _offlineSubscription = null;
  }

  /// الحالة الحالية
  NetworkConnectionState get connectionState => OfflineManager.instance.state;

  /// هل متصل
  bool get isOnline => connectionState.isOnline;

  /// هل غير متصل
  bool get isOffline => connectionState.isOffline;
}

// ============================================================================
// OFFLINE OPERATION
// ============================================================================

/// عملية يمكن تنفيذها offline
class OfflineOperation<T> {
  final String id;
  final String type;
  final Future<T> Function() execute;
  final DateTime createdAt;
  int retryCount;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.execute,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// مدير العمليات المعلقة
class PendingOperationsManager {
  final List<OfflineOperation> _operations = [];

  List<OfflineOperation> get operations => List.unmodifiable(_operations);

  int get count => _operations.length;

  bool get hasOperations => _operations.isNotEmpty;

  /// إضافة عملية
  void add<T>(OfflineOperation<T> operation) {
    _operations.add(operation);
    OfflineManager.instance.updatePendingCount(_operations.length);
  }

  /// إزالة عملية
  void remove(String id) {
    _operations.removeWhere((op) => op.id == id);
    OfflineManager.instance.updatePendingCount(_operations.length);
  }

  /// تنفيذ جميع العمليات المعلقة
  Future<void> executeAll() async {
    final toExecute = List<OfflineOperation>.from(_operations);

    for (final operation in toExecute) {
      try {
        await operation.execute();
        remove(operation.id);
        debugPrint('[PendingOps] ✅ Executed: ${operation.type}');
      } catch (e) {
        operation.retryCount++;
        debugPrint('[PendingOps] ❌ Failed: ${operation.type} - $e');

        // إزالة بعد 3 محاولات
        if (operation.retryCount >= 3) {
          remove(operation.id);
          debugPrint('[PendingOps] 🗑️ Removed after 3 retries: ${operation.type}');
        }
      }
    }
  }

  /// مسح جميع العمليات
  void clear() {
    _operations.clear();
    OfflineManager.instance.updatePendingCount(0);
  }
}
