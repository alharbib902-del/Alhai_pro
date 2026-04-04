import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Location Service for Driver App
/// 
/// Handles GPS tracking, permissions, and background location updates.
class LocationService {
  LocationService._();
  
  static final LocationService instance = LocationService._();
  
  bool _isInitialized = false;
  Position? _currentPosition;
  
  Position? get currentPosition => _currentPosition;
  bool get isInitialized => _isInitialized;
  
  /// Initialize location service and request permissions.
  ///
  /// Throws a [LocationServiceException] if location services are disabled
  /// or if permission is denied, so the caller can surface a message to the user.
  Future<void> initialize() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException(
          'خدمة الموقع معطلة. يرجى تفعيلها من إعدادات الجهاز.',
        );
      }

      // Check and request permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationServiceException(
            'تم رفض إذن الموقع. يرجى السماح للتطبيق بالوصول إلى موقعك.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationServiceException(
          'إذن الموقع مرفوض بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
        );
      }

      // Get initial position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _isInitialized = true;
    } on LocationServiceException {
      _isInitialized = false;
      rethrow;
    } catch (e) {
      // Handle unexpected initialization errors
      _isInitialized = false;
      debugPrint('LocationService initialization error: $e');
    }
  }
  
  /// Start listening to location updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
  
  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      return null;
    }
  }
  
  /// Calculate distance between two points (in meters)
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

/// Exception thrown by [LocationService] when location is unavailable
/// due to disabled services or denied permissions.
///
/// The [message] is a user-readable Arabic string that callers can display
/// directly in a SnackBar or dialog.
class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
