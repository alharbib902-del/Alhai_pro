import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/deliveries/data/delivery_datasource.dart';
import 'location_service.dart';

/// Broadcasts driver GPS location to server at regular intervals.
class LocationBroadcastService {
  LocationBroadcastService._();

  static final LocationBroadcastService instance = LocationBroadcastService._();

  StreamSubscription? _subscription;
  String? _activeDeliveryId;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  /// Start broadcasting location for an active delivery.
  void startTracking(String deliveryId) {
    if (_isTracking && _activeDeliveryId == deliveryId) return;

    stopTracking();
    _activeDeliveryId = deliveryId;
    _isTracking = true;

    _subscription = LocationService.instance
        .getPositionStream()
        .listen((position) async {
      try {
        final ds = GetIt.instance<DeliveryDatasource>();
        await ds.updateDriverLocation(
          deliveryId,
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Location broadcast error: $e');
      }
    });

    if (kDebugMode) debugPrint('Location tracking started for $deliveryId');
  }

  /// Stop broadcasting location.
  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    _activeDeliveryId = null;
    _isTracking = false;
  }
}
