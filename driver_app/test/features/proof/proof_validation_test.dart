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
import 'package:signature/signature.dart';

import 'package:driver_app/features/deliveries/data/delivery_datasource.dart';
import 'package:driver_app/features/deliveries/providers/delivery_providers.dart';
import 'package:driver_app/features/proof/data/proof_datasource.dart';
import 'package:driver_app/features/proof/screens/delivery_proof_screen.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

class MockProofDatasource extends Mock implements ProofDatasource {}

class MockDeliveryDatasource extends Mock implements DeliveryDatasource {}

/// Returns in-memory JPEG bytes via Future.value (safe for FakeAsync).
class _FakeXFile extends Fake implements XFile {
  static final _jpegBytes =
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

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
  }) =>
      Future.value(_FakeXFile());
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Position _makeRealPosition() {
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
    isMocked: false,
  );
}

class _StatusUpdateTracker {
  final calls = <({String id, String status, String? notes})>[];

  Future<Map<String, dynamic>> call(
      String id, String status, String? notes) async {
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

/// Finds the submit [FilledButton] (works with FilledButton.icon subclass).
Finder get _submitButtonFinder =>
    find.byWidgetPredicate((w) => w is FilledButton);

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
        updateDeliveryStatusProvider.overrideWith(
          (ref, params) async {
            return tracker.call(params.id, params.status, params.notes);
          },
        ),
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
  late MockGeolocatorPlatform mockGeo;
  late MockProofDatasource mockProofDs;
  late MockDeliveryDatasource mockDeliveryDs;

  setUp(() {
    mockGeo = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeo;

    // Fake ImagePicker — returns in-memory JPEG bytes (no real I/O).
    ImagePickerPlatform.instance = _FakeImagePickerPlatform();

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

  group('GH-1: Proof validation — mandatory photo or signature', () {
    testWidgets('blocks submit when no photo and no signature',
        (tester) async {
      _setPhoneViewport(tester);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Submit button must be disabled (onPressed == null)
      final button = tester.widget<FilledButton>(_submitButtonFinder);
      expect(button.onPressed, isNull,
          reason: 'Submit button should be disabled without proof');

      // Tapping the disabled button does nothing
      await tester.tap(find.text('تأكيد التسليم'));
      await tester.pumpAndSettle();

      // Verify: submitProof was NOT called
      verifyNever(
        () => mockProofDs.submitProof(
          deliveryId: any(named: 'deliveryId'),
          photoBytes: any(named: 'photoBytes'),
          signatureData: any(named: 'signatureData'),
          recipientName: any(named: 'recipientName'),
          notes: any(named: 'notes'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        ),
      );
    });

    testWidgets('allows submit with photo only', (tester) async {
      _setPhoneViewport(tester);

      final realPosition = _makeRealPosition();
      when(
        () => mockGeo.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => realPosition);

      final tracker = _StatusUpdateTracker();
      await tester.pumpWidget(_buildTestWidget(tracker: tracker));
      await tester.pumpAndSettle();

      // Button disabled initially
      var button = tester.widget<FilledButton>(_submitButtonFinder);
      expect(button.onPressed, isNull);

      // Tap photo area to capture (triggers fake ImagePicker)
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();

      // Button should now be enabled
      button = tester.widget<FilledButton>(_submitButtonFinder);
      expect(button.onPressed, isNotNull,
          reason: 'Submit should enable after capturing photo');

      // Tap submit
      await tester.tap(find.text('تأكيد التسليم'));
      await tester.pumpAndSettle();

      // Verify proof submitted with photo bytes
      verify(
        () => mockProofDs.submitProof(
          deliveryId: 'test-delivery-001',
          photoBytes: any(named: 'photoBytes', that: isNotNull),
          signatureData: null,
          recipientName: null,
          notes: null,
          lat: realPosition.latitude,
          lng: realPosition.longitude,
        ),
      ).called(1);

      // Verify delivery marked delivered
      expect(tracker.calls, hasLength(1));
      expect(tracker.calls.first.status, 'delivered');
    });

    testWidgets('allows submit with signature only', (tester) async {
      _setPhoneViewport(tester);

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Button disabled initially
      var button = tester.widget<FilledButton>(_submitButtonFinder);
      expect(button.onPressed, isNull);

      // Draw on signature pad
      await tester.drag(find.byType(Signature), const Offset(50, 30));
      await tester.pump();

      // Button should now be enabled
      button = tester.widget<FilledButton>(_submitButtonFinder);
      expect(button.onPressed, isNotNull,
          reason: 'Submit should enable after drawing signature');

      // NOTE: We do not test full submit here because compute() (used by
      // signature PNG encoding) spawns a real isolate which cannot complete
      // in FakeAsync widget tests. The photo-only test above already
      // proves the end-to-end submit flow works.
    });
  });
}
