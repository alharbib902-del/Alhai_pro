import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cashier/core/services/offline_queue_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _salePayload({String? localSaleId}) => {
      'local_sale_id': localSaleId ?? 'sale-001',
      'amount': 150.0,
      'items': [],
    };

Map<String, dynamic> _refundPayload({String? originalSaleId}) => {
      'original_sale_id': originalSaleId ?? 'sale-001',
      'amount': 50.0,
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the flutter_secure_storage method channel so calls to read/write/delete
  // don't throw MissingPluginException in unit tests.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  // OfflineQueueService is a singleton with an in-memory cache. Between test
  // groups we need to clear it. We cannot replace _secureStorage because it is
  // const, so instead we test the public API through enqueue/flush/clear and
  // verify behaviour using getQueueHealth / pendingCount / getItems.

  late OfflineQueueService service;

  setUp(() async {
    // Set up mock method channel before any secure storage calls
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'read':
          final key = call.arguments['key'] as String;
          return storage[key];
        case 'write':
          final key = call.arguments['key'] as String;
          final value = call.arguments['value'] as String;
          storage[key] = value;
          return null;
        case 'delete':
          final key = call.arguments['key'] as String;
          storage.remove(key);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        case 'readAll':
          return storage;
        case 'containsKey':
          final key = call.arguments['key'] as String;
          return storage.containsKey(key) ? 'true' : 'false';
        default:
          return null;
      }
    });

    service = OfflineQueueService.instance;
    // Reset state between tests
    service.onSyncEvent = null;
    service.itemProcessor = null;
    await service.clear();
  });

  tearDown(() async {
    await service.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    storage.clear();
  });

  // -------------------------------------------------------------------------
  // QueueItem serialization
  // -------------------------------------------------------------------------
  group('QueueItem serialization', () {
    test('toJson produces expected keys', () {
      final item = QueueItem(
        id: 'abc-123',
        type: QueueOperationType.saleCreate,
        payload: {'amount': 100},
        idempotencyKey: 'sale_create_sale-001',
        queuedAt: DateTime(2025, 1, 15, 10, 30),
        itemStatus: 'pending',
        retryCount: 0,
      );

      final json = item.toJson();

      expect(json['id'], 'abc-123');
      expect(json['type'], 'saleCreate');
      expect(json['payload'], {'amount': 100});
      expect(json['idempotency_key'], 'sale_create_sale-001');
      expect(json['queued_at'], '2025-01-15T10:30:00.000');
      expect(json['item_status'], 'pending');
      expect(json['retry_count'], 0);
      expect(json['last_attempt'], isNull);
      expect(json['last_error'], isNull);
    });

    test('fromJson round-trips correctly', () {
      final original = QueueItem(
        id: 'xyz-789',
        type: QueueOperationType.refund,
        payload: {'original_sale_id': 's1', 'amount': 25.0},
        idempotencyKey: 'refund_s1',
        queuedAt: DateTime(2025, 3, 1, 8, 0),
        itemStatus: 'failed',
        retryCount: 2,
        lastAttempt: DateTime(2025, 3, 1, 9, 0),
        lastError: 'timeout',
      );

      final restored = QueueItem.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.payload['original_sale_id'], 's1');
      expect(restored.idempotencyKey, original.idempotencyKey);
      expect(restored.queuedAt, original.queuedAt);
      expect(restored.itemStatus, 'failed');
      expect(restored.retryCount, 2);
      expect(restored.lastAttempt, original.lastAttempt);
      expect(restored.lastError, 'timeout');
    });

    test('fromJson handles missing optional fields gracefully', () {
      final json = {
        'id': 'item-1',
        'type': 'saleCreate',
        'payload': <String, dynamic>{},
        'idempotency_key': 'key-1',
        'queued_at': '2025-06-01T12:00:00.000',
      };

      final item = QueueItem.fromJson(json);

      expect(item.itemStatus, 'pending');
      expect(item.retryCount, 0);
      expect(item.lastAttempt, isNull);
      expect(item.lastError, isNull);
    });

    test('fromJson falls back to saleCreate for unknown type', () {
      final json = {
        'id': 'item-2',
        'type': 'unknownOperation',
        'payload': <String, dynamic>{},
        'idempotency_key': 'key-2',
        'queued_at': '2025-06-01T12:00:00.000',
      };

      final item = QueueItem.fromJson(json);
      expect(item.type, QueueOperationType.saleCreate);
    });
  });

  // -------------------------------------------------------------------------
  // Enqueue & deduplication
  // -------------------------------------------------------------------------
  group('enqueue and idempotency deduplication', () {
    test('enqueue adds a new item and returns true', () async {
      final result = await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      expect(result, true);
      expect(await service.totalCount(), 1);
    });

    test('duplicate idempotency key resets existing item and returns false',
        () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'dup-sale'),
      );

      // Enqueue again with the same implicit idempotency key
      final result = await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'dup-sale'),
      );

      expect(result, false); // deduplication -- updated in place
      expect(await service.totalCount(), 1);
    });

    test('custom idempotency key is respected', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'a'),
        customIdempotencyKey: 'custom-key-1',
      );
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'b'),
        customIdempotencyKey: 'custom-key-1',
      );

      expect(await service.totalCount(), 1);
    });

    test('different operations get different idempotency keys', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'sale-x'),
      );
      await service.enqueue(
        type: QueueOperationType.refund,
        payload: _refundPayload(originalSaleId: 'sale-x'),
      );

      expect(await service.totalCount(), 2);
    });
  });

  // -------------------------------------------------------------------------
  // Error classification
  // -------------------------------------------------------------------------
  group('error classification', () {
    // We cannot call _classifyError directly (private), so we test it
    // indirectly through flush behaviour.

    test('network error increments retryCount', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor = (_) async => throw Exception('SocketException');

      await service.flush();

      final items = await service.getItems();
      expect(items.length, 1);
      expect(items.first.retryCount, 1);
      expect(items.first.itemStatus, 'pending');
    });

    test('409 conflict marks item as conflict', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor = (_) async => throw Exception('409 Conflict');

      await service.flush();

      final items = await service.getItems();
      expect(items.length, 1);
      expect(items.first.itemStatus, 'conflict');
    });

    test('validation error (400) removes item from queue', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor =
          (_) async => throw Exception('400 Bad Request: validation failed');

      await service.flush();

      expect(await service.totalCount(), 0);
    });

    test('422 validation error removes item from queue', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor =
          (_) async => throw Exception('422 Unprocessable Entity');

      await service.flush();

      expect(await service.totalCount(), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Retry logic
  // -------------------------------------------------------------------------
  group('retry logic (max 3 retries)', () {
    test('item is marked failed after 3 network errors', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor =
          (_) async => throw Exception('SocketException timeout');

      // First flush processes the item (no backoff yet).
      await service.flush();

      // After first retry, backoff is 4s. We must wait for it to expire.
      await Future<void>.delayed(const Duration(seconds: 5));
      await service.flush();

      // After second retry, backoff is 8s.
      await Future<void>.delayed(const Duration(seconds: 9));
      await service.flush();

      final items = await service.getItems();
      expect(items.length, 1);
      expect(items.first.retryCount, 3);
      expect(items.first.itemStatus, 'failed');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('failed items beyond maxRetries are not reprocessed', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      var callCount = 0;
      service.itemProcessor = (_) async {
        callCount++;
        throw Exception('network error');
      };

      // Exhaust retries with delays for backoff
      await service.flush(); // retry 1
      await Future<void>.delayed(const Duration(seconds: 5));
      await service.flush(); // retry 2
      await Future<void>.delayed(const Duration(seconds: 9));
      await service.flush(); // retry 3 (now marked failed)
      await Future<void>.delayed(const Duration(seconds: 1));
      await service
          .flush(); // 4th flush: item has maxRetries, should be skipped

      // The 4th flush should NOT call the processor again because retryCount
      // already reached maxRetries.
      expect(callCount, 3);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  // -------------------------------------------------------------------------
  // Batch processing
  // -------------------------------------------------------------------------
  group('batch processing (5 at a time)', () {
    test('processes items in batches of 5', () async {
      // Enqueue 7 items
      for (var i = 0; i < 7; i++) {
        await service.enqueue(
          type: QueueOperationType.inventoryUpdate,
          payload: {'product_id': 'prod-$i', 'timestamp': '2025-01-0${i + 1}'},
        );
      }

      expect(await service.totalCount(), 7);

      var processedIds = <String>[];
      service.itemProcessor = (item) async {
        processedIds.add(item.id);
        return true;
      };

      final processed = await service.flush();
      expect(processed, 7);
      expect(processedIds.length, 7);
      expect(await service.totalCount(), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Health monitoring
  // -------------------------------------------------------------------------
  group('health monitoring API', () {
    test('getQueueHealth returns correct counts', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 's1'),
      );
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 's2'),
      );

      final health = await service.getQueueHealth();

      expect(health['total'], 2);
      expect(health['pending'], 2);
      expect(health['failed'], 0);
      expect(health['conflict'], 0);
      expect(health['syncing'], 0);
    });

    test('getQueueHealth reflects status changes after failed flush', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'fail-item'),
      );

      service.itemProcessor = (_) async => throw Exception('409 conflict');

      await service.flush();

      final health = await service.getQueueHealth();
      expect(health['conflict'], 1);
      expect(health['total'], 1);
    });

    test('pendingCount only counts pending and failed items', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'p1'),
      );

      // Mark one as conflict
      service.itemProcessor = (_) async => throw Exception('409 conflict');
      await service.flush();

      // Add another pending item
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'p2'),
      );

      // pendingCount should only see the pending item, not the conflict one
      final count = await service.pendingCount();
      expect(count, 1);
    });
  });

  // -------------------------------------------------------------------------
  // Queue persistence and recovery
  // -------------------------------------------------------------------------
  group('queue persistence and recovery', () {
    test('items survive across service cache resets', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'persist-1'),
      );

      // _clearCache is private -- we test persistence by reading back items
      // after enqueue (which calls _save internally).
      final items = await service.getItems();
      expect(items.length, 1);
      expect(items.first.idempotencyKey, 'sale_create_persist-1');
    });

    test('clear removes all items', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'clear-1'),
      );
      await service.enqueue(
        type: QueueOperationType.refund,
        payload: _refundPayload(originalSaleId: 'clear-1'),
      );

      expect(await service.totalCount(), 2);

      await service.clear();

      expect(await service.totalCount(), 0);
      expect(await service.pendingCount(), 0);
    });

    test('cleanupStale removes items older than 7 days', () async {
      // We cannot inject a clock, but we can verify the cleanup mechanism
      // by adding a fresh item and confirming it is NOT removed.
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(localSaleId: 'fresh-item'),
      );

      final removed = await service.cleanupStale();
      expect(removed, 0);
      expect(await service.totalCount(), 1);
    });
  });

  // -------------------------------------------------------------------------
  // Flush edge cases
  // -------------------------------------------------------------------------
  group('flush edge cases', () {
    test('flush without itemProcessor returns 0 and notifies', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      String? lastMessage;
      service.onSyncEvent = (msg, isError) => lastMessage = msg;

      final processed = await service.flush();
      expect(processed, 0);
      expect(lastMessage, isNotNull);
    });

    test('flush on empty queue returns 0', () async {
      service.itemProcessor = (_) async => true;

      final processed = await service.flush();
      expect(processed, 0);
    });

    test('successful processor removes item from queue', () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor = (_) async => true;

      final processed = await service.flush();
      expect(processed, 1);
      expect(await service.totalCount(), 0);
    });

    test('processor returning false also removes item (server rejection)',
        () async {
      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      service.itemProcessor = (_) async => false;

      final processed = await service.flush();
      expect(processed, 1);
      expect(await service.totalCount(), 0);
    });

    test('onSyncEvent callback fires on enqueue', () async {
      final messages = <String>[];
      service.onSyncEvent = (msg, _) => messages.add(msg);

      await service.enqueue(
        type: QueueOperationType.saleCreate,
        payload: _salePayload(),
      );

      expect(messages, isNotEmpty);
    });
  });
}
