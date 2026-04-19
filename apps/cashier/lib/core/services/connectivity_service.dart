import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/timing.dart';

/// Monitors network connectivity.
///
/// Uses `connectivity_plus` to detect Wi-Fi, mobile, ethernet, etc.
/// Exposes a [Stream] of connectivity changes and a synchronous
/// [isOnline] getter for quick checks.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Broadcast controller so multiple listeners can subscribe.
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  StreamSubscription<ConnectivityResult>? _subscription;

  /// Current connectivity state. Defaults to `true` (optimistic).
  bool _isOnline = true;

  /// Whether the service has been initialized.
  bool _initialized = false;

  // -- Public API ------------------------------------------------------------

  /// Whether the device currently has network connectivity.
  bool get isOnline => _isOnline;

  /// Stream that emits `true` when online and `false` when offline.
  /// Only emits on actual state changes (debounced).
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Initialize the service and start listening for connectivity changes.
  ///
  /// Safe to call multiple times -- subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Check initial state (with timeout to avoid blocking app startup)
    try {
      final result = await _connectivity.checkConnectivity().timeout(
        Timeouts.connectivityCheck,
      );
      _isOnline = result != ConnectivityResult.none;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('ConnectivityService: فحص الاتصال الأولي تجاوز المهلة');
      }
      _isOnline = true; // optimistic default on timeout
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ConnectivityService: فشل فحص الاتصال الأولي: $e');
      }
      _isOnline = true; // optimistic default
    }

    if (kDebugMode) {
      debugPrint(
        'ConnectivityService: الحالة الأولية: ${_isOnline ? "متصل" : "غير متصل"}',
      );
    }

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) => _handleConnectivityChange(result),
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('ConnectivityService: خطأ في مراقبة الاتصال: $error');
        }
      },
    );
  }

  /// Check connectivity on demand (useful for pull-to-refresh).
  Future<bool> checkNow() async {
    try {
      final result = await _connectivity.checkConnectivity().timeout(
        Timeouts.connectivityCheck,
      );
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline != wasOnline) {
        _controller.add(_isOnline);
      }

      return _isOnline;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('ConnectivityService: فحص الاتصال تجاوز المهلة');
      }
      return _isOnline;
    } catch (e) {
      if (kDebugMode) debugPrint('ConnectivityService: خطأ في الفحص: $e');
      return _isOnline;
    }
  }

  /// Stop listening and release resources.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller.close();
    _initialized = false;
  }

  // -- Internal --------------------------------------------------------------

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    // Only emit on actual state changes
    if (_isOnline != wasOnline) {
      _controller.add(_isOnline);

      if (kDebugMode) {
        debugPrint('ConnectivityService: ${_isOnline ? "متصل" : "غير متصل"}');
      }
    }
  }
}
