import 'dart:typed_data';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:driver_app/features/deliveries/data/delivery_datasource.dart';
import 'package:driver_app/features/deliveries/providers/delivery_providers.dart';
import 'package:driver_app/features/proof/data/proof_datasource.dart';
import 'package:driver_app/features/proof/screens/delivery_proof_screen.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockProofDatasource extends Mock implements ProofDatasource {}

class MockDeliveryDatasource extends Mock implements DeliveryDatasource {}

/// Returns in-memory JPEG bytes via Future.value (safe for FakeAsync).
class _FakeXFile extends Fake implements XFile {
  static final _jpegBytes = Uint8List.fromList([
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
  ]);

  @override
  Future<Uint8List> readAsBytes() => Future.value(_jpegBytes);
}

class _FakeImagePickerPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions? options,
  }) => Future.value(_FakeXFile());
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

/// Tracks calls to updateDeliveryStatus.
class _StatusUpdateTracker {
  final calls = <({String id, String status, String? notes})>[];

  Future<Map<String, dynamic>> call(
    String id,
    String status,
    String? notes,
  ) async {
    calls.add((id: id, status: status, notes: notes));
    return {'success': true};
  }
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Capture a fake photo to satisfy GH-1 proof requirement.
Future<void> _capturePhoto(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.camera_alt_outlined));
  await tester.pumpAndSettle();
}

Widget _buildTestWidget({_StatusUpdateTracker? tracker}) {
  final router = GoRouter(
    initialLocation: '/proof',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/proof',
        builder: (_, __) =>
            const DeliveryProofScreen(deliveryId: 'test-delivery-001'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (tracker != null)
        updateDeliveryStatusProvider.overrideWith((ref, params) async {
          return tracker.call(params.id, params.status, params.notes);
        }),
    ],
    child: MaterialApp.router(
      title: 'Test',
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late MockProofDatasource mockProofDs;
  late MockDeliveryDatasource mockDeliveryDs;

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;

    // Fake ImagePicker — returns in-memory JPEG bytes (no real I/O).
    ImagePickerPlatform.instance = _FakeImagePickerPlatform();

    // Reset GetIt and register mocks.
    final locator = GetIt.instance;
    if (locator.isRegistered<ProofDatasource>()) {
      locator.unregister<ProofDatasource>();
    }
    if (locator.isRegistered<DeliveryDatasource>()) {
      locator.unregister<DeliveryDatasource>();
    }

    mockProofDs = MockProofDatasource();
    mockDeliveryDs = MockDeliveryDatasource();
    locator.registerSingleton<ProofDatasource>(mockProofDs);
    locator.registerSingleton<DeliveryDatasource>(mockDeliveryDs);

    // Default stubs — overridden in individual tests as needed.
    when(
      () => mockProofDs.submitProof(
        deliveryId: any(named: 'deliveryId'),
        photoBytes: any(named: 'photoBytes'),
        signatureData: any(named: 'signatureData'),
        recipientName: any(named: 'recipientName'),
        notes: any(named: 'notes'),
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockDeliveryDs.logMockGpsDetected(
        lat: any(named: 'lat'),
        lng: any(named: 'lng'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    final locator = GetIt.instance;
    if (locator.isRegistered<ProofDatasource>()) {
      locator.unregister<ProofDatasource>();
    }
    if (locator.isRegistered<DeliveryDatasource>()) {
      locator.unregister<DeliveryDatasource>();
    }
  });

  group('DeliveryProofScreen Mock GPS Guard (V1)', () {
    testWidgets('blocks submission when mock GPS detected', (tester) async {
      _setPhoneViewport(tester);

      // Setup: mock GPS returns isMocked=true
      final mockedPosition = _makePosition(isMocked: true);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => mockedPosition);

      final tracker = _StatusUpdateTracker();
      await tester.pumpWidget(_buildTestWidget(tracker: tracker));
      await tester.pumpAndSettle();

      // GH-1: capture photo to satisfy proof requirement
      await _capturePhoto(tester);

      // Tap the submit button
      final submitButton = find.text('تأكيد التسليم');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify: SnackBar with mock GPS error appears
      expect(
        find.text('تم اكتشاف تطبيق محاكاة موقع. يرجى تعطيله للاستمرار.'),
        findsOneWidget,
      );

      // Verify: updateDeliveryStatus NOT called (delivery not completed)
      expect(tracker.calls, isEmpty);

      // Verify: audit log WAS called
      verify(
        () => mockDeliveryDs.logMockGpsDetected(
          lat: mockedPosition.latitude,
          lng: mockedPosition.longitude,
        ),
      ).called(1);

      // Verify: still on proof screen (not navigated away)
      expect(find.text('إثبات التسليم'), findsOneWidget);
    });

    testWidgets('allows submission with real GPS', (tester) async {
      _setPhoneViewport(tester);

      // Setup: real GPS returns isMocked=false
      final realPosition = _makePosition(isMocked: false);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => realPosition);

      final tracker = _StatusUpdateTracker();
      await tester.pumpWidget(_buildTestWidget(tracker: tracker));
      await tester.pumpAndSettle();

      // GH-1: capture photo to satisfy proof requirement
      await _capturePhoto(tester);

      // Tap the submit button
      final submitButton = find.text('تأكيد التسليم');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify: updateDeliveryStatus called with 'delivered'
      expect(tracker.calls, hasLength(1));
      expect(tracker.calls.first.status, 'delivered');
      expect(tracker.calls.first.id, 'test-delivery-001');

      // Verify: proof was submitted with GPS coordinates
      verify(
        () => mockProofDs.submitProof(
          deliveryId: 'test-delivery-001',
          photoBytes: any(named: 'photoBytes'),
          signatureData: null,
          recipientName: null,
          notes: null,
          lat: realPosition.latitude,
          lng: realPosition.longitude,
        ),
      ).called(1);
    });

    testWidgets('blocks submission even if audit log fails', (tester) async {
      _setPhoneViewport(tester);

      // Setup: mock GPS detected + audit log throws
      final mockedPosition = _makePosition(isMocked: true);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => mockedPosition);

      when(
        () => mockDeliveryDs.logMockGpsDetected(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      ).thenThrow(Exception('network error'));

      final tracker = _StatusUpdateTracker();
      await tester.pumpWidget(_buildTestWidget(tracker: tracker));
      await tester.pumpAndSettle();

      // GH-1: capture photo to satisfy proof requirement
      await _capturePhoto(tester);

      await tester.tap(find.text('تأكيد التسليم'));
      await tester.pumpAndSettle();

      // Delivery must still be blocked even though audit log failed
      expect(tracker.calls, isEmpty);
      expect(
        find.text('تم اكتشاف تطبيق محاكاة موقع. يرجى تعطيله للاستمرار.'),
        findsOneWidget,
      );
    });
  });
}
