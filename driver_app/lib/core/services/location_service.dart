import 'package:geolocator/geolocator.dart';

import 'sentry_service.dart';

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
          throw const LocationServiceException(
            'تم رفض إذن الموقع. يرجى السماح للتطبيق بالوصول إلى موقعك.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // On iOS/Android, once the user denies permanently, the OS will not
        // show the permission dialog again. The only recourse is to open the
        // app-level settings screen so the user can toggle the permission
        // manually.
        await Geolocator.openAppSettings();
        throw const LocationServiceException(
          'إذن الموقع مرفوض بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
          isDeniedForever: true,
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
    } catch (e, st) {
      // Handle unexpected initialization errors
      _isInitialized = false;
      reportError(e, stackTrace: st, hint: 'LocationService.initialize');
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
    } catch (e, st) {
      reportError(
        e,
        stackTrace: st,
        hint: 'LocationService.getCurrentPosition',
      );
      return null;
    }
  }

  /// Gets the current position and validates it is not from a mock provider.
  ///
  /// On Android, [Position.isMocked] reliably detects mock location apps.
  /// On iOS, isMocked is always false — a separate detection strategy
  /// (e.g., velocity/altitude anomaly detection) would be needed (deferred).
  ///
  /// Throws [MockGpsDetectedException] if a mocked position is detected.
  Future<Position> getVerifiedPosition() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = position;

    // Position.isMocked is only reliable on Android.
    // iOS always returns false — needs a different approach (deferred).
    if (position.isMocked) {
      throw MockGpsDetectedException(position: position);
    }

    return position;
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

/// Exception thrown when a mock/fake GPS provider is detected.
///
/// Carries the offending [position] so callers can log coordinates for audit.
class MockGpsDetectedException implements Exception {
  final Position position;

  const MockGpsDetectedException({required this.position});

  String get message => 'تم اكتشاف تطبيق محاكاة موقع. يرجى تعطيله للاستمرار.';

  @override
  String toString() => message;
}

/// Exception thrown by [LocationService] when location is unavailable
/// due to disabled services or denied permissions.
///
/// The [message] is a user-readable Arabic string that callers can display
/// directly in a SnackBar or dialog.
///
/// [isDeniedForever] is `true` when the user has permanently denied the
/// location permission. In that case, `Geolocator.openAppSettings()` has
/// already been called, but the caller may want to show a dialog explaining
/// the situation.
class LocationServiceException implements Exception {
  final String message;
  final bool isDeniedForever;

  const LocationServiceException(this.message, {this.isDeniedForever = false});

  @override
  String toString() => message;
}
