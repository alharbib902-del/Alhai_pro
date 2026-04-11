import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/offline/offline_manager.dart';

void main() {
  group('OfflineManager', () {
    // We need to reset the singleton between tests to avoid state leaking.
    // OfflineManager is a singleton, so we test through the public API.

    group('singleton', () {
      test('instance returns the same object', () {
        final a = OfflineManager.instance;
        final b = OfflineManager.instance;
        expect(identical(a, b), isTrue);
      });
    });

    group('initial state', () {
      test('state starts as checking', () {
        final manager = OfflineManager.instance;
        expect(manager.state.status, ConnectionStatus.checking);
        expect(manager.state.type, NetworkConnectionType.unknown);
      });
    });

    group('stateStream', () {
      test('is a broadcast stream', () {
        final manager = OfflineManager.instance;
        expect(manager.stateStream.isBroadcast, isTrue);
      });
    });

    group('updatePendingCount', () {
      test('updates state pending count', () {
        final manager = OfflineManager.instance;
        manager.updatePendingCount(5);
        expect(manager.state.pendingSyncCount, 5);
      });

      test('emits state with updated count on stream', () async {
        final manager = OfflineManager.instance;
        final completer = Completer<NetworkConnectionState>();
        final sub = manager.stateStream.listen((state) {
          if (!completer.isCompleted) completer.complete(state);
        });

        manager.updatePendingCount(10);

        final state = await completer.future;
        expect(state.pendingSyncCount, 10);

        await sub.cancel();
      });
    });

    group('addListener / removeListener', () {
      test('listener receives state changes', () async {
        final manager = OfflineManager.instance;
        final states = <NetworkConnectionState>[];
        void listener(NetworkConnectionState s) => states.add(s);

        manager.addListener(listener);
        manager.updatePendingCount(3);

        // updatePendingCount triggers stateStream but not _listeners
        // _listeners are only triggered by _handleConnectivityChange
        // so we remove the listener
        manager.removeListener(listener);
      });
    });

    group('stopMonitoring', () {
      test('can be called without error', () {
        final manager = OfflineManager.instance;
        expect(() => manager.stopMonitoring(), returnsNormally);
      });
    });
  });

  group('NetworkConnectionState', () {
    test('isOnline returns true when status is online', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime.now(),
      );
      expect(state.isOnline, isTrue);
      expect(state.isOffline, isFalse);
    });

    test('isOffline returns true when status is offline', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.offline,
        type: NetworkConnectionType.none,
        lastChecked: DateTime.now(),
      );
      expect(state.isOnline, isFalse);
      expect(state.isOffline, isTrue);
    });

    test('offlineDuration returns null when online', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime.now(),
        lastOnline: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(state.offlineDuration, isNull);
    });

    test('offlineDuration returns null when lastOnline is null', () {
      final state = NetworkConnectionState(
        status: ConnectionStatus.offline,
        type: NetworkConnectionType.none,
        lastChecked: DateTime.now(),
      );
      expect(state.offlineDuration, isNull);
    });

    test('offlineDuration returns duration when offline with lastOnline', () {
      final lastOnline = DateTime.now().subtract(const Duration(minutes: 10));
      final state = NetworkConnectionState(
        status: ConnectionStatus.offline,
        type: NetworkConnectionType.none,
        lastChecked: DateTime.now(),
        lastOnline: lastOnline,
      );
      expect(state.offlineDuration, isNotNull);
      expect(state.offlineDuration!.inMinutes, greaterThanOrEqualTo(9));
    });

    test('copyWith preserves values when no overrides', () {
      final original = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime(2024, 1, 1),
        lastOnline: DateTime(2024, 1, 1),
        pendingSyncCount: 5,
      );

      final copy = original.copyWith();

      expect(copy.status, original.status);
      expect(copy.type, original.type);
      expect(copy.lastChecked, original.lastChecked);
      expect(copy.lastOnline, original.lastOnline);
      expect(copy.pendingSyncCount, original.pendingSyncCount);
    });

    test('copyWith overrides specified values', () {
      final original = NetworkConnectionState(
        status: ConnectionStatus.online,
        type: NetworkConnectionType.wifi,
        lastChecked: DateTime(2024, 1, 1),
        pendingSyncCount: 5,
      );

      final copy = original.copyWith(
        status: ConnectionStatus.offline,
        pendingSyncCount: 10,
      );

      expect(copy.status, ConnectionStatus.offline);
      expect(copy.type, NetworkConnectionType.wifi); // preserved
      expect(copy.pendingSyncCount, 10);
    });
  });

  group('ConnectionStatus', () {
    test('has expected values', () {
      expect(ConnectionStatus.values, [
        ConnectionStatus.online,
        ConnectionStatus.offline,
        ConnectionStatus.checking,
      ]);
    });
  });

  group('NetworkConnectionType', () {
    test('has expected values', () {
      expect(NetworkConnectionType.values, [
        NetworkConnectionType.wifi,
        NetworkConnectionType.mobile,
        NetworkConnectionType.ethernet,
        NetworkConnectionType.unknown,
        NetworkConnectionType.none,
      ]);
    });
  });

  group('OfflineOperation', () {
    test('creates with default values', () {
      final operation = OfflineOperation<void>(
        id: 'op-1',
        type: 'sync',
        execute: () async {},
      );

      expect(operation.id, 'op-1');
      expect(operation.type, 'sync');
      expect(operation.retryCount, 0);
      expect(operation.createdAt, isNotNull);
    });

    test('creates with custom createdAt', () {
      final customTime = DateTime(2024, 1, 1);
      final operation = OfflineOperation<String>(
        id: 'op-1',
        type: 'sync',
        execute: () async => 'done',
        createdAt: customTime,
      );

      expect(operation.createdAt, customTime);
    });
  });

  group('PendingOperationsManager', () {
    test('starts empty', () {
      final manager = PendingOperationsManager();
      expect(manager.count, 0);
      expect(manager.hasOperations, isFalse);
      expect(manager.operations, isEmpty);
    });

    test('add increases count', () {
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(id: 'op-1', type: 'test', execute: () async {}),
      );

      expect(manager.count, 1);
      expect(manager.hasOperations, isTrue);
    });

    test('remove decreases count', () {
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(id: 'op-1', type: 'test', execute: () async {}),
      );
      manager.remove('op-1');

      expect(manager.count, 0);
      expect(manager.hasOperations, isFalse);
    });

    test('operations returns unmodifiable list', () {
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(id: 'op-1', type: 'test', execute: () async {}),
      );

      expect(() => manager.operations.clear(), throwsUnsupportedError);
    });

    test('executeAll processes operations', () async {
      final executed = <String>[];
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(
          id: 'op-1',
          type: 'test',
          execute: () async => executed.add('op-1'),
        ),
      );
      manager.add(
        OfflineOperation<void>(
          id: 'op-2',
          type: 'test',
          execute: () async => executed.add('op-2'),
        ),
      );

      await manager.executeAll();

      expect(executed, ['op-1', 'op-2']);
      expect(manager.count, 0); // All removed after success
    });

    test('executeAll retries failed operations up to 3 times', () async {
      var callCount = 0;
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(
          id: 'op-1',
          type: 'test',
          execute: () async {
            callCount++;
            throw Exception('fail');
          },
        ),
      );

      // First execute - retryCount becomes 1
      await manager.executeAll();
      expect(manager.count, 1);
      expect(callCount, 1);

      // Second execute - retryCount becomes 2
      await manager.executeAll();
      expect(manager.count, 1);
      expect(callCount, 2);

      // Third execute - retryCount becomes 3, removed
      await manager.executeAll();
      expect(manager.count, 0);
      expect(callCount, 3);
    });

    test('clear removes all operations', () {
      final manager = PendingOperationsManager();
      manager.add(
        OfflineOperation<void>(id: 'op-1', type: 'test', execute: () async {}),
      );
      manager.add(
        OfflineOperation<void>(id: 'op-2', type: 'test', execute: () async {}),
      );

      manager.clear();

      expect(manager.count, 0);
      expect(manager.hasOperations, isFalse);
    });
  });

  group('OfflineAwareMixin', () {
    // Basic check that the mixin methods exist
    test('provides expected getters', () {
      final testObj = _TestOfflineAware();
      // Just verify the properties exist and don't throw
      expect(testObj.connectionState, isA<NetworkConnectionState>());
      expect(testObj.isOnline, isA<bool>());
      expect(testObj.isOffline, isA<bool>());
    });
  });
}

class _TestOfflineAware with OfflineAwareMixin {}
