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
  
  /// Initialize location service and request permissions
  Future<void> initialize() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled
        return;
      }
      
      // Check and request permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return;
      }
      
      // Get initial position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _isInitialized = true;
    } catch (e) {
      // Handle initialization error
      _isInitialized = false;
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
