import 'package:customer_app/core/offline/offline_queue_service.dart';
import 'package:customer_app/core/offline/pending_mutation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('OfflineQueueService.enqueue + pendingCount', () {
    test('starts empty and increments on enqueue', () async {
      final service = OfflineQueueService();
      expect(await service.pendingCount(), 0);

      await service.enqueue('order.submit', {'foo': 'bar'});
      expect(await service.pendingCount(), 1);

      await service.enqueue('order.submit', {'baz': 42});
      expect(await service.pendingCount(), 2);
    });

    test('enqueued payload survives a new service instance', () async {
      final first = OfflineQueueService();
      await first.enqueue('order.submit', {'order_id': 'o-1'});

      final second = OfflineQueueService();
      expect(await second.pendingCount(), 1);
    });
  });

  group('OfflineQueueService.processQueue', () {
    test('removes an item when the handler returns success', () async {
      final service = OfflineQueueService();
      service.registerHandler('order.submit', (_) async {
        return MutationOutcome.success;
      });

      await service.enqueue('order.submit', {'id': 'o-1'});
      expect(await service.pendingCount(), 1);

      await service.processQueue();
      expect(await service.pendingCount(), 0);
    });

    test('keeps the item and increments retry on retry outcome', () async {
      final service = OfflineQueueService();
      service.registerHandler('order.submit', (_) async {
        return MutationOutcome.retry;
      });

      await service.enqueue('order.submit', {'id': 'o-1'});
      await service.processQueue();
      expect(await service.pendingCount(), 1);

      // Inspect the stored retry count via raw prefs.
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('offline_queue.pending_orders_v1');
      expect(raw, isNotNull);
      expect(raw, contains('"retryCount":1'));

      await service.processQueue();
      final rawAfterSecond =
          prefs.getString('offline_queue.pending_orders_v1');
      expect(rawAfterSecond, contains('"retryCount":2'));
    });

    test('drops the item after max retries (5) are exhausted', () async {
      final service = OfflineQueueService();
      service.registerHandler('order.submit', (_) async {
        return MutationOutcome.retry;
      });

      await service.enqueue('order.submit', {'id': 'o-1'});
      // 5 attempts → retry counts go 1,2,3,4,5 — drop on the last.
      for (var i = 0; i < 5; i++) {
        await service.processQueue();
      }
      expect(await service.pendingCount(), 0);
    });

    test('drops immediately on MutationOutcome.drop', () async {
      final service = OfflineQueueService();
      service.registerHandler('order.submit', (_) async {
        return MutationOutcome.drop;
      });

      await service.enqueue('order.submit', {'id': 'o-1'});
      await service.processQueue();
      expect(await service.pendingCount(), 0);
    });

    test('dispatcher routes by mutation type', () async {
      final service = OfflineQueueService();
      final seen = <String, int>{'a': 0, 'b': 0};
      service.registerHandler('type.a', (_) async {
        seen['a'] = (seen['a'] ?? 0) + 1;
        return MutationOutcome.success;
      });
      service.registerHandler('type.b', (_) async {
        seen['b'] = (seen['b'] ?? 0) + 1;
        return MutationOutcome.success;
      });

      await service.enqueue('type.a', {'x': 1});
      await service.enqueue('type.b', {'x': 2});
      await service.processQueue();

      expect(seen['a'], 1);
      expect(seen['b'], 1);
      expect(await service.pendingCount(), 0);
    });
  });

  group('PendingMutation JSON roundtrip', () {
    test('toJson/fromJson preserve all fields', () {
      final original = PendingMutation(
        id: 'abc-123',
        type: 'order.submit',
        payload: {
          'clientOrderId': 'cli-1',
          'storeId': 'store-1',
          'items': [
            {'productId': 'p-1', 'qty': 2},
          ],
        },
        createdAt: DateTime.utc(2024, 6, 1, 12, 0, 0),
        retryCount: 3,
        lastError: 'SocketException',
      );

      final roundTripped =
          PendingMutation.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.type, original.type);
      expect(roundTripped.payload, original.payload);
      expect(roundTripped.createdAt.toUtc(), original.createdAt.toUtc());
      expect(roundTripped.retryCount, original.retryCount);
      expect(roundTripped.lastError, original.lastError);
    });

    test('encode/decode produces equivalent mutation', () {
      final original = PendingMutation(
        id: 'id-1',
        type: 'order.submit',
        payload: const {'k': 'v'},
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final decoded = PendingMutation.decode(original.encode());
      expect(decoded.id, 'id-1');
      expect(decoded.payload['k'], 'v');
      expect(decoded.retryCount, 0);
      expect(decoded.lastError, isNull);
    });
  });

  group('offlineQueueBackoff', () {
    test('follows exponential schedule 1s,2s,4s,8s,16s', () {
      expect(offlineQueueBackoff(1), const Duration(seconds: 1));
      expect(offlineQueueBackoff(2), const Duration(seconds: 2));
      expect(offlineQueueBackoff(3), const Duration(seconds: 4));
      expect(offlineQueueBackoff(4), const Duration(seconds: 8));
      expect(offlineQueueBackoff(5), const Duration(seconds: 16));
    });

    test('caps backoff at the 5th retry', () {
      expect(offlineQueueBackoff(6), const Duration(seconds: 16));
      expect(offlineQueueBackoff(10), const Duration(seconds: 16));
    });

    test('returns zero for non-positive retry counts', () {
      expect(offlineQueueBackoff(0), Duration.zero);
      expect(offlineQueueBackoff(-1), Duration.zero);
    });
  });
}
