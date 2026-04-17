import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/sentry_service.dart';
import '../data/delivery_datasource.dart';
import 'delivery_providers.dart';

/// Tracks driver location during active deliveries and pushes updates to
/// Supabase so the customer can see real-time driver position.
///
/// Usage: call `ref.listen(locationTrackingProvider, ...)` from a long-lived
/// widget (e.g. [DriverApp]) so the provider stays alive while the app is in
/// the foreground.
final locationTrackingProvider =
    StateNotifierProvider<LocationTrackingNotifier, bool>((ref) {
      return LocationTrackingNotifier(ref);
    });

class LocationTrackingNotifier extends StateNotifier<bool> {
  StreamSubscription<dynamic>? _locationSub;
  String? _activeDeliveryId;

  LocationTrackingNotifier(Ref ref) : super(false);

  /// Start streaming GPS updates for the given delivery.
  void startTracking(String deliveryId) {
    if (_locationSub != null && _activeDeliveryId == deliveryId) return;
    stopTracking();

    _activeDeliveryId = deliveryId;
    state = true;

    _locationSub = LocationService.instance.getPositionStream().listen(
      (position) async {
        try {
          final ds = GetIt.instance<DeliveryDatasource>();
          await ds.updateDriverLocation(
            deliveryId,
            position.latitude,
            position.longitude,
          );
        } catch (e, st) {
          reportError(e, stackTrace: st, hint: 'LocationTracking.update');
        }
      },
      onError: (Object e, StackTrace st) {
        reportError(e, stackTrace: st, hint: 'LocationTracking.stream');
      },
    );
  }

  /// Stop location tracking and clean up the stream subscription.
  void stopTracking() {
    _locationSub?.cancel();
    _locationSub = null;
    _activeDeliveryId = null;
    state = false;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

/// Wires location tracking to the active deliveries stream.
///
/// Call `ref.listen(locationTrackingWiringProvider, ...)` from a long-lived
/// widget so tracking starts/stops automatically.
final locationTrackingWiringProvider = Provider<void>((ref) {
  final activeDeliveries = ref.watch(activeDeliveriesStreamProvider);
  final tracker = ref.read(locationTrackingProvider.notifier);

  activeDeliveries.whenData((deliveries) {
    if (deliveries.isNotEmpty) {
      final firstId = deliveries.first['id'] as String;
      tracker.startTracking(firstId);
    } else {
      tracker.stopTracking();
    }
  });
});
