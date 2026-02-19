import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة مراقبة الاتصال بالإنترنت
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOnline = true;
  
  /// تهيئة الخدمة وبدء المراقبة
  Future<void> initialize() async {
    // التحقق من الحالة الحالية
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result);
    _controller.add(_isOnline);
    
    // الاستماع للتغييرات
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(result);
      
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
    _isOnline = _isConnected(result);
    return _isOnline;
  }
  
  bool _isConnected(ConnectivityResult result) {
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
