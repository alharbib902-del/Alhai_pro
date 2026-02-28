import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/connectivity_service.dart';

import '../helpers/sync_test_helpers.dart';

/// Custom ConnectivityService that accepts injected Connectivity for testing.
class TestableConnectivityService extends ConnectivityService {
  final Connectivity connectivity;

  TestableConnectivityService(this.connectivity);

  // We cannot directly override private _connectivity,
  // so we test via the public API and accept that the internal
  // Connectivity instance is the real one.
  // Instead, we test the logic through unit tests of the
  // connection state checking logic.
}

void main() {
  setUpAll(() {
    registerSyncFallbackValues();
  });

  group('ConnectivityService', () {
    group('initial state', () {
      test('isOnline defaults to true', () {
        final service = ConnectivityService();
        expect(service.isOnline, isTrue);
        expect(service.isOffline, isFalse);
        service.dispose();
      });
    });

    group('isOnline / isOffline', () {
      test('isOffline is the inverse of isOnline', () {
        final service = ConnectivityService();
        // Default state
        expect(service.isOnline, !service.isOffline);
        service.dispose();
      });
    });

    group('onConnectivityChanged', () {
      test('returns a broadcast stream', () {
        final service = ConnectivityService();
        final stream = service.onConnectivityChanged;
        expect(stream.isBroadcast, isTrue);
        service.dispose();
      });
    });

    group('dispose', () {
      test('does not throw when called', () {
        final service = ConnectivityService();
        expect(() => service.dispose(), returnsNormally);
      });

      test('can be called multiple times without error', () {
        final service = ConnectivityService();
        service.dispose();
        // Second dispose should not throw
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
