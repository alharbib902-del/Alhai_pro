import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:driver_app/core/services/location_service.dart';

// ---------------------------------------------------------------------------
// Mock GeolocatorPlatform so we control Position.isMocked in tests.
// ---------------------------------------------------------------------------

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

Position _makePosition({required bool isMocked}) {
  return Position(
    latitude: 24.7136,
    longitude: 46.6753,
    timestamp: DateTime(2026, 4, 15),
    accuracy: 10.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    isMocked: isMocked,
  );
}

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late LocationService service;

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    service = LocationService.instance;
  });

  // -------------------------------------------------------------------------
  // getVerifiedPosition — mock GPS detection
  // -------------------------------------------------------------------------
  group('Mock GPS Detection (C3)', () {
    test('allows real GPS position (isMocked=false)', () async {
      final realPosition = _makePosition(isMocked: false);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => realPosition);

      final result = await service.getVerifiedPosition();

      expect(result, realPosition);
      expect(result.isMocked, false);
    });

    test('blocks mocked GPS position (isMocked=true)', () async {
      final mockedPosition = _makePosition(isMocked: true);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => mockedPosition);

      await expectLater(
        () => service.getVerifiedPosition(),
        throwsA(isA<MockGpsDetectedException>()),
      );
    });

    test('exception carries position data for audit logging', () async {
      final mockedPosition = _makePosition(isMocked: true);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => mockedPosition);

      try {
        await service.getVerifiedPosition();
        fail('Expected MockGpsDetectedException');
      } on MockGpsDetectedException catch (e) {
        expect(e.position.latitude, 24.7136);
        expect(e.position.longitude, 46.6753);
        expect(e.position.isMocked, true);
        expect(e.message, contains('محاكاة موقع'));
        expect(e.toString(), contains('محاكاة موقع'));
      }
    });

    test('iOS behavior: isMocked=false always passes through', () async {
      // On iOS, Position.isMocked is always false — no false positives.
      final iosPosition = _makePosition(isMocked: false);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => iosPosition);

      final result = await service.getVerifiedPosition();

      expect(result.isMocked, false);
      expect(result.latitude, 24.7136);
    });

    test('updates currentPosition even when position is valid', () async {
      final realPosition = _makePosition(isMocked: false);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => realPosition);

      await service.getVerifiedPosition();

      expect(service.currentPosition, realPosition);
    });

    test('updates currentPosition before throwing on mock', () async {
      final mockedPosition = _makePosition(isMocked: true);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => mockedPosition);

      try {
        await service.getVerifiedPosition();
      } on MockGpsDetectedException {
        // Position is still set so callers can read coordinates for logging.
        expect(service.currentPosition, mockedPosition);
      }
    });
  });

  // -------------------------------------------------------------------------
  // MockGpsDetectedException unit tests
  // -------------------------------------------------------------------------
  group('MockGpsDetectedException', () {
    test('provides Arabic user-facing message', () {
      final position = _makePosition(isMocked: true);
      final exception = MockGpsDetectedException(position: position);

      expect(exception.message, 'تم اكتشاف تطبيق محاكاة موقع. يرجى تعطيله للاستمرار.');
    });

    test('toString returns the message', () {
      final position = _makePosition(isMocked: true);
      final exception = MockGpsDetectedException(position: position);

      expect(exception.toString(), exception.message);
    });
  });
}
