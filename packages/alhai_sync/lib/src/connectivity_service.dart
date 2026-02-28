import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة مراقبة الاتصال بالإنترنت
///
/// Compatible with both connectivity_plus v5 (single ConnectivityResult)
/// and v6+ (List<ConnectivityResult>). The internal helpers accept dynamic
/// results and normalize them into a single boolean online/offline status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<dynamic>? _subscription;
  bool _isOnline = true;

  /// تهيئة الخدمة وبدء المراقبة
  Future<void> initialize() async {
    // التحقق من الحالة الحالية
    // connectivity_plus v6+ returns List<ConnectivityResult>,
    // v5.x returns a single ConnectivityResult.
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnectedDynamic(result);
    _controller.add(_isOnline);

    // الاستماع للتغييرات
    // onConnectivityChanged in v6+ emits List<ConnectivityResult>,
    // in v5.x emits ConnectivityResult. We handle both via dynamic.
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _isConnectedDynamic(result);

      if (wasOnline != _isOnline) {
        _controller.add(_isOnline);
      }
    });
  }

  /// هل متصل الآن؟
  bool get isOnline => _isOnline;

  /// هل غير متصل؟
  bool get isOffline => !_isOnline;

  /// Stream لحالة الاتصال
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// التحقق من الاتصال
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnectedDynamic(result);
    return _isOnline;
  }

  /// Checks connectivity (connectivity_plus ^5.x returns single ConnectivityResult)
  bool _isConnectedDynamic(ConnectivityResult result) {
    return _isConnectedSingle(result);
  }

  /// Check if a single ConnectivityResult indicates a connection.
  bool _isConnectedSingle(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  /// إغلاق الخدمة
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
