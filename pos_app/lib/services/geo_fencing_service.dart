// TODO: Add geolocator package to pubspec.yaml
// import 'package:geolocator/geolocator.dart';

/// خدمة الإشعارات الجغرافية (Geo-Fencing)
class GeoFencingService {
  /// موقع المتجر الافتراضي (الرياض)
  static const double defaultLatitude = 24.7136;
  static const double defaultLongitude = 46.6753;
  
  /// نصف قطر الإشعارات الافتراضي (كم)
  static const double defaultRadius = 2.0;
  
  double _storeLatitude = defaultLatitude;
  double _storeLongitude = defaultLongitude;
  double _notificationRadius = defaultRadius;
  
  /// تحديث موقع المتجر
  void setStoreLocation(double latitude, double longitude) {
    _storeLatitude = latitude;
    _storeLongitude = longitude;
  }
  
  /// تحديث نصف قطر الإشعارات
  void setNotificationRadius(double radiusKm) {
    _notificationRadius = radiusKm;
  }
  
  /// حساب المسافة بين نقطتين (Haversine formula)
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // كم
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// التحقق من وجود العميل في نطاق الإشعارات
  bool isCustomerNearby(double customerLat, double customerLon) {
    final distance = calculateDistance(
      _storeLatitude, _storeLongitude,
      customerLat, customerLon,
    );
    return distance <= _notificationRadius;
  }
  
  /// الحصول على قائمة العملاء القريبين
  List<Map<String, dynamic>> getNearbyCustomers(
    List<Map<String, dynamic>> customers,
  ) {
    return customers.where((customer) {
      final lat = customer['latitude'] as double?;
      final lon = customer['longitude'] as double?;
      if (lat == null || lon == null) return false;
      return isCustomerNearby(lat, lon);
    }).toList();
  }
  
  /// إرسال إشعار ترويجي للعملاء القريبين
  Future<int> sendPromotionToNearbyCustomers({
    required String promotionTitle,
    required String promotionMessage,
    required List<Map<String, dynamic>> customers,
  }) async {
    final nearbyCustomers = getNearbyCustomers(customers);
    
    // TODO: Implement actual push notification or WhatsApp integration
    for (final customer in nearbyCustomers) {
      // ignore: avoid_print
      print('Sending promotion to ${customer['name']}: $promotionTitle');
    }
    
    return nearbyCustomers.length;
  }
  
  // Math helpers (simplified, in production use dart:math)
  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorSin(x + 1.5707963268);
  double _sqrt(double x) => _newtonSqrt(x);
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 1.5707963268;
    if (x == 0 && y < 0) return -1.5707963268;
    return 0;
  }
  
  double _taylorSin(double x) {
    // Normalize to [-π, π]
    while (x > 3.14159265359) {
      x -= 6.28318530718;
    }
    while (x < -3.14159265359) {
      x += 6.28318530718;
    }
    
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
  
  double _atan(double x) {
    if (x.abs() <= 1) {
      double result = x;
      double term = x;
      for (int i = 1; i <= 15; i++) {
        term *= -x * x;
        result += term / (2 * i + 1);
      }
      return result;
    }
    return (x > 0 ? 1 : -1) * 1.5707963268 - _atan(1 / x);
  }
  
  double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  
  /// Getters
  double get storeLatitude => _storeLatitude;
  double get storeLongitude => _storeLongitude;
  double get notificationRadius => _notificationRadius;
}
