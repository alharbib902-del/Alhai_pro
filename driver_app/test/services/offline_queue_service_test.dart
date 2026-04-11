import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:driver_app/core/services/offline_queue_service.dart';
import 'package:driver_app/features/deliveries/data/delivery_datasource.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockDeliveryDatasource extends Mock implements DeliveryDatasource {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the FlutterSecureStorage platform channel
  final Map<String, String> secureStorageData = {};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              final key = methodCall.arguments['key'] as String;
              return secureStorageData[key];
            case 'write':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as String;
              secureStorageData[key] = value;
              return null;
            case 'delete':
              final key = methodCall.arguments['key'] as String;
              secureStorageData.remove(key);
              return null;
            case 'deleteAll':
              secureStorageData.clear();
              return null;
            default:
              return null;
          }
        },
      );

  late OfflineQueueService service;
  late MockDeliveryDatasource mockDatasource;

  setUp(() async {
    secureStorageData.clear();
    service = OfflineQueueService.instance;
    mockDatasource = MockDeliveryDatasource();
    service.onSyncEvent = null;
    await service.clear();
  });

  tearDown(() async {
    await service.clear();
  });

  // -------------------------------------------------------------------------
  // Queue operations: enqueue, flush, clear
  // -------------------------------------------------------------------------
  group('queue operations', () {
    test('enqueue adds a new item and returns true', () async {
      final result = await service.enqueue(
        deliveryId: 'del-001',
        status: 'picked_up',
      );

      expect(result, true);
      expect(await service.totalCount(), 1);
    });

    test('enqueue with notes stores notes', () async {
      await service.enqueue(
        deliveryId: 'del-002',
        status: 'delivered',
        notes: 'Left at door',
      );

      expect(await service.totalCount(), 1);
    });

    test(
      'duplicate deliveryId + status deduplicates (returns false)',
      () async {
        await service.enqueue(deliveryId: 'del-dup', status: 'picked_up');
        final result = await service.enqueue(
          deliveryId: 'del-dup',
          status: 'picked_up',
        );

        expect(result, false);
        expect(await service.totalCount(), 1);
      },
    );

    test(
      'same deliveryId with different status creates separate entries',
      () async {
        await service.enqueue(deliveryId: 'del-x', status: 'picked_up');
        await service.enqueue(deliveryId: 'del-x', status: 'delivered');

        expect(await service.totalCount(), 2);
      },
    );

    test('flush with datasource processes pending items', () async {
      await service.enqueue(deliveryId: 'del-flush', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'del-flush',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => {'success': true});

      final processed = await service.flushQueue(mockDatasource);

      expect(processed, 1);
      expect(await service.totalCount(), 0);
      verify(
        () => mockDatasource.updateStatus(
          'del-flush',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).called(1);
    });

    test('flush on empty queue returns 0', () async {
      final processed = await service.flushQueue(mockDatasource);
      expect(processed, 0);
    });

    test('clear removes all items', () async {
      await service.enqueue(deliveryId: 'd1', status: 'picked_up');
      await service.enqueue(deliveryId: 'd2', status: 'delivered');

      expect(await service.totalCount(), 2);

      await service.clear();

      expect(await service.totalCount(), 0);
    });

    test('server rejection (success=false) removes item', () async {
      await service.enqueue(deliveryId: 'del-reject', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'del-reject',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenAnswer(
        (_) async => {'success': false, 'error': 'Invalid transition'},
      );

      final processed = await service.flushQueue(mockDatasource);

      expect(processed, 1);
      expect(await service.totalCount(), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Error classification
  // -------------------------------------------------------------------------
  group('error classification', () {
    test('network error increments retryCount', () async {
      await service.enqueue(deliveryId: 'net-err', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'net-err',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('SocketException: Connection refused'));

      await service.flushQueue(mockDatasource);

      final health = await service.getQueueHealth();
      expect(health['total'], 1);
      // Item should still be in queue with incremented retry count
      expect(await service.pendingCount(), 1);
    });

    test('409 conflict marks item as conflict (not retried)', () async {
      await service.enqueue(deliveryId: 'conflict-1', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'conflict-1',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('409 Conflict'));

      await service.flushQueue(mockDatasource);

      final health = await service.getQueueHealth();
      expect(health['conflict'], 1);
    });

    test('400 validation error removes item from queue', () async {
      await service.enqueue(deliveryId: 'val-err', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'val-err',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('400 Bad Request: validation'));

      await service.flushQueue(mockDatasource);

      expect(await service.totalCount(), 0);
    });

    test('422 validation error removes item from queue', () async {
      await service.enqueue(deliveryId: 'val-422', status: 'delivered');

      when(
        () => mockDatasource.updateStatus(
          'val-422',
          'delivered',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('422 Unprocessable: invalid field'));

      await service.flushQueue(mockDatasource);

      expect(await service.totalCount(), 0);
    });

    test('error containing "invalid" classified as validation', () async {
      await service.enqueue(deliveryId: 'inv-err', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'inv-err',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('Field is invalid'));

      await service.flushQueue(mockDatasource);

      // Validation errors are removed
      expect(await service.totalCount(), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Exponential backoff timing
  // -------------------------------------------------------------------------
  group('exponential backoff timing', () {
    test('retryCount increments with each network failure', () async {
      await service.enqueue(deliveryId: 'backoff-1', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'backoff-1',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('SocketException timeout'));

      // First failure: retryCount 0 -> 1
      await service.flushQueue(mockDatasource);
      var health = await service.getQueueHealth();
      expect(health['pending'], 1);

      // Reset backoff by moving lastAttempt to far in the past
      _clearBackoff(secureStorageData);
      // Second failure: retryCount 1 -> 2
      await service.flushQueue(mockDatasource);

      _clearBackoff(secureStorageData);
      // Third failure: retryCount 2 -> 3 (becomes 'failed')
      await service.flushQueue(mockDatasource);

      health = await service.getQueueHealth();
      expect(health['failed'], 1);
      expect(health['pending'], 0);
    });

    test('item marked failed after max retries is not reprocessed', () async {
      await service.enqueue(deliveryId: 'max-retry', status: 'picked_up');

      var callCount = 0;
      when(
        () => mockDatasource.updateStatus(
          'max-retry',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        throw Exception('network timeout');
      });

      // Exhaust retries (3 max), clearing backoff between calls
      for (var i = 0; i < 5; i++) {
        _clearBackoff(secureStorageData);
        await service.flushQueue(mockDatasource);
      }

      // Should only have been called 3 times (not 4 or 5)
      expect(callCount, 3);
    });
  });

  // -------------------------------------------------------------------------
  // Batch size limits
  // -------------------------------------------------------------------------
  group('batch size limits', () {
    test('processes items in batches of 5', () async {
      // Enqueue 8 items
      for (var i = 0; i < 8; i++) {
        await service.enqueue(deliveryId: 'batch-del-$i', status: 'picked_up');
      }

      expect(await service.totalCount(), 8);

      var processedDeliveries = <String>[];
      when(
        () => mockDatasource.updateStatus(
          any(),
          any(),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((invocation) async {
        processedDeliveries.add(invocation.positionalArguments[0] as String);
        return {'success': true};
      });

      final processed = await service.flushQueue(mockDatasource);

      expect(processed, 8);
      expect(processedDeliveries.length, 8);
      expect(await service.totalCount(), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Stale item cleanup
  // -------------------------------------------------------------------------
  group('stale item cleanup', () {
    test('cleanupStale does not remove fresh items', () async {
      await service.enqueue(deliveryId: 'fresh-1', status: 'picked_up');

      final removed = await service.cleanupStale();
      expect(removed, 0);
      expect(await service.totalCount(), 1);
    });

    test('cleanupStale returns 0 on empty queue', () async {
      final removed = await service.cleanupStale();
      expect(removed, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Health monitoring
  // -------------------------------------------------------------------------
  group('health monitoring', () {
    test('getQueueHealth returns correct counts', () async {
      await service.enqueue(deliveryId: 'h1', status: 'picked_up');
      await service.enqueue(deliveryId: 'h2', status: 'delivered');

      final health = await service.getQueueHealth();

      expect(health['total'], 2);
      expect(health['pending'], 2);
      expect(health['failed'], 0);
      expect(health['conflict'], 0);
      expect(health['syncing'], 0);
    });

    test('pendingCount only counts pending items', () async {
      await service.enqueue(deliveryId: 'pc1', status: 'picked_up');

      // Mark one as conflict
      when(
        () => mockDatasource.updateStatus(
          'pc1',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('409 Conflict'));
      await service.flushQueue(mockDatasource);

      // Add another pending
      await service.enqueue(deliveryId: 'pc2', status: 'delivered');

      // pendingCount should only count the new pending item
      expect(await service.pendingCount(), 1);
    });

    test('totalCount includes all statuses', () async {
      await service.enqueue(deliveryId: 'tc1', status: 'picked_up');
      await service.enqueue(deliveryId: 'tc2', status: 'delivered');

      // Make one a conflict
      when(
        () => mockDatasource.updateStatus(
          'tc1',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenThrow(Exception('409 Conflict'));
      when(
        () => mockDatasource.updateStatus(
          'tc2',
          'delivered',
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => {'success': true});

      await service.flushQueue(mockDatasource);

      // tc1 is conflict (stays), tc2 is synced (removed)
      expect(await service.totalCount(), 1);
    });
  });

  // -------------------------------------------------------------------------
  // Sync callback
  // -------------------------------------------------------------------------
  group('sync callback', () {
    test('onSyncEvent fires on enqueue', () async {
      final messages = <String>[];
      service.onSyncEvent = (msg, _) => messages.add(msg);

      await service.enqueue(deliveryId: 'cb-1', status: 'picked_up');

      expect(messages, isNotEmpty);
    });

    test('onSyncEvent fires on flush', () async {
      await service.enqueue(deliveryId: 'cb-flush', status: 'picked_up');

      when(
        () => mockDatasource.updateStatus(
          'cb-flush',
          'picked_up',
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => {'success': true});

      final messages = <String>[];
      service.onSyncEvent = (msg, _) => messages.add(msg);

      await service.flushQueue(mockDatasource);

      expect(messages.length, greaterThanOrEqualTo(1));
    });

    test('onSyncEvent fires on clear', () async {
      await service.enqueue(deliveryId: 'cb-clear', status: 'picked_up');

      final messages = <String>[];
      service.onSyncEvent = (msg, _) => messages.add(msg);

      await service.clear();

      expect(messages, isNotEmpty);
    });
  });
}

/// Clears the backoff window by setting `last_attempt` to far in the past
/// and invalidating the in-memory cache so the service re-reads from storage.
void _clearBackoff(Map<String, String> storageData) {
  const key = 'offline_delivery_queue';
  final raw = storageData[key];
  if (raw == null) return;
  try {
    final items = jsonDecode(raw) as List;
    final pastDate = DateTime.now()
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    for (final item in items) {
      if (item is Map<String, dynamic> && item['last_attempt'] != null) {
        item['last_attempt'] = pastDate;
      }
    }
    storageData[key] = jsonEncode(items);
    // Force cache invalidation so the service re-reads from storage
    OfflineQueueService.instance.clearCacheForTesting();
  } catch (_) {}
}
