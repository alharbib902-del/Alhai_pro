/// خدمة الإشعارات الجغرافية
/// تستخدم من: customer_app
///
/// تحتاج: Firebase Cloud Messaging + Geofencing
class GeoNotificationService {
  final Set<GeoFence> _activeGeofences = {};
  final List<Function(GeoFenceEvent)> _listeners = [];

  /// إضافة سياج جغرافي
  Future<bool> addGeoFence(GeoFence geofence) async {
    try {
      // TODO: Implement actual geofencing with platform-specific code
      _activeGeofences.add(geofence);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إزالة سياج جغرافي
  Future<bool> removeGeoFence(String geofenceId) async {
    try {
      _activeGeofences.removeWhere((g) => g.id == geofenceId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إزالة جميع الأسياج الجغرافية
  Future<void> removeAllGeoFences() async {
    _activeGeofences.clear();
  }

  /// الحصول على الأسياج الجغرافية النشطة
  List<GeoFence> get activeGeofences => _activeGeofences.toList();

  /// الاستماع لأحداث السياج الجغرافي
  void addListener(Function(GeoFenceEvent) listener) {
    _listeners.add(listener);
  }

  /// إزالة مستمع
  void removeListener(Function(GeoFenceEvent) listener) {
    _listeners.remove(listener);
  }

  // ==================== إرسال الإشعارات ====================

  /// إرسال إشعار للمستخدمين في منطقة معينة
  Future<GeoNotificationResult> sendNotificationToArea({
    required double lat,
    required double lng,
    required double radiusKm,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: Implement with Firebase Cloud Messaging + Firestore GeoQuery
      // 1. Query users in the area using geohash
      // 2. Send FCM to those users

      await Future.delayed(const Duration(milliseconds: 500));

      return GeoNotificationResult(
        success: true,
        sentCount: 0, // Would be actual count
      );
    } catch (e) {
      return GeoNotificationResult(success: false, error: e.toString());
    }
  }

  /// إرسال إشعار للمستخدمين في حي معين
  Future<GeoNotificationResult> sendNotificationToDistrict({
    required String districtId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: Implement district-based notification
      await Future.delayed(const Duration(milliseconds: 500));

      return GeoNotificationResult(success: true, sentCount: 0);
    } catch (e) {
      return GeoNotificationResult(success: false, error: e.toString());
    }
  }

  // ==================== التحقق من الموقع ====================

  /// التحقق إذا كان الموقع داخل نطاق التوصيل
  bool isWithinDeliveryRadius({
    required double userLat,
    required double userLng,
    required double storeLat,
    required double storeLng,
    required double radiusKm,
  }) {
    final distance = _calculateDistance(userLat, userLng, storeLat, storeLng);
    return distance <= radiusKm;
  }

  /// حساب المسافة بين نقطتين (بالكيلومتر)
  double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return _calculateDistance(lat1, lng1, lat2, lng2);
  }

  // ==================== Helpers ====================

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Haversine formula
    const earthRadius = 6371.0; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;
  double _sin(double x) => _taylor(x, true);
  double _cos(double x) => _taylor(x, false);
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x == 0) return y > 0 ? 1.5707963 : -1.5707963;
    return y / x; // Simplified
  }

  double _taylor(double x, bool isSin) {
    x = x % (2 * 3.14159265359);
    double result = isSin ? x : 1;
    double term = isSin ? x : 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + (isSin ? 1 : -1)));
      result += term;
    }
    return result;
  }
}

/// سياج جغرافي
class GeoFence {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double radiusMeters;
  final GeoFenceTransition transitions;
  final Map<String, dynamic>? data;

  const GeoFence({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    this.transitions = GeoFenceTransition.both,
    this.data,
  });
}

/// نوع انتقال السياج الجغرافي
enum GeoFenceTransition { enter, exit, both }

/// حدث السياج الجغرافي
class GeoFenceEvent {
  final String geofenceId;
  final GeoFenceTransition transition;
  final DateTime timestamp;

  const GeoFenceEvent({
    required this.geofenceId,
    required this.transition,
    required this.timestamp,
  });
}

/// نتيجة إرسال إشعار جغرافي
class GeoNotificationResult {
  final bool success;
  final int? sentCount;
  final String? error;

  const GeoNotificationResult({
    required this.success,
    this.sentCount,
    this.error,
  });
}
