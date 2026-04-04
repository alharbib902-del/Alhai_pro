import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/deliveries/data/delivery_datasource.dart';
import 'location_service.dart';

/// Broadcasts driver GPS location to server at regular intervals.
/// Updates are throttled to [_updateInterval] to reduce server load.
class LocationBroadcastService {
  LocationBroadcastService._();

  static final LocationBroadcastService instance = LocationBroadcastService._();

  StreamSubscription? _subscription;
  String? _activeDeliveryId;
  bool _isTracking = false;

  Timer? _debounceTimer;
  Position? _lastPosition;
  double? _lastSentLat;
  double? _lastSentLng;

  /// Minimum time between location updates sent to the server.
  static const _updateInterval = Duration(seconds: 30);

  /// Minimum distance (metres) that must be covered before sending an update.
  static const _minDistanceMetres = 50.0;

  bool get isTracking => _isTracking;

  /// Start broadcasting location for an active delivery.
  void startTracking(String deliveryId) {
    if (_isTracking && _activeDeliveryId == deliveryId) return;

    stopTracking();
    _activeDeliveryId = deliveryId;
    _isTracking = true;

    _subscription = LocationService.instance
        .getPositionStream()
        .listen(_onPositionUpdate);

    if (kDebugMode) debugPrint('Location tracking started for $deliveryId');
  }

  /// Handles incoming position events with debouncing and distance filtering.
  void _onPositionUpdate(Position position) {
    _lastPosition = position;

    // If we haven't sent anything yet, or the driver has moved enough, schedule
    // a send.  The timer is always reset so we send at most once per interval.
    final movedEnough = _lastSentLat == null ||
        _lastSentLng == null ||
        Geolocator.distanceBetween(
              _lastSentLat!,
              _lastSentLng!,
              position.latitude,
              position.longitude,
            ) >=
            _minDistanceMetres;

    if (!movedEnough) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_updateInterval, _sendPendingLocation);
  }

  /// Sends the most recently captured position to the server.
  Future<void> _sendPendingLocation() async {
    final deliveryId = _activeDeliveryId;
    final pos = _lastPosition;
    if (deliveryId == null || pos == null) return;

    try {
      final ds = GetIt.instance<DeliveryDatasource>();
      await ds.updateDriverLocation(
        deliveryId,
        pos.latitude,
        pos.longitude,
      );
      _lastSentLat = pos.latitude;
      _lastSentLng = pos.longitude;
    } catch (e) {
      if (kDebugMode) debugPrint('Location broadcast error: $e');
    }
  }

  /// Stop broadcasting location.
  Future<void> stopTracking() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    _lastPosition = null;
    _lastSentLat = null;
    _lastSentLng = null;
    _activeDeliveryId = null;
    _isTracking = false;
  }
}
