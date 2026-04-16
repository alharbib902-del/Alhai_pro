import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'package:driver_app/features/deliveries/providers/location_tracking_provider.dart';

/// Stub Geolocator platform that emits a single position then stays open.
class _FakeGeolocator extends GeolocatorPlatform {
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    // Return a stream that emits one position. In tests we just verify
    // the notifier transitions state correctly.
    return Stream.value(
      Position(
        latitude: 24.7136,
        longitude: 46.6753,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GeolocatorPlatform.instance = _FakeGeolocator();
  });

  group('M1 — Location Tracking Provider', () {
    test('initial state is false (not tracking)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(locationTrackingProvider), isFalse);
    });

    test('startTracking sets state to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(locationTrackingProvider.notifier);
      notifier.startTracking('delivery-123');

      expect(container.read(locationTrackingProvider), isTrue);
    });

    test('stopTracking resets state to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(locationTrackingProvider.notifier);
      notifier.startTracking('delivery-123');
      notifier.stopTracking();

      expect(container.read(locationTrackingProvider), isFalse);
    });
  });
}
