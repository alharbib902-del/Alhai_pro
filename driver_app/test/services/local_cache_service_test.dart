import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:driver_app/core/services/local_cache_service.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late LocalCacheService cacheService;

  setUp(() async {
    // SharedPreferences test binding
    SharedPreferences.setMockInitialValues({});
    cacheService = LocalCacheService();
  });

  tearDown(() async {
    await cacheService.clearAll();
  });

  // -------------------------------------------------------------------------
  // Write-through caching
  // -------------------------------------------------------------------------
  group('write-through caching', () {
    test('cacheDeliveries stores and retrieves delivery list', () async {
      final deliveries = [
        {'id': 'd1', 'status': 'pending', 'fee': 15.0},
        {'id': 'd2', 'status': 'picked_up', 'fee': 20.0},
      ];

      await cacheService.cacheDeliveries(deliveries);
      final cached = await cacheService.getCachedDeliveries();

      expect(cached, isNotNull);
      expect(cached!.length, 2);
      expect(cached[0]['id'], 'd1');
      expect(cached[1]['status'], 'picked_up');
    });

    test('cacheProfile stores and retrieves profile', () async {
      final profile = {
        'id': 'driver-1',
        'name': 'Ahmed',
        'phone': '0501234567',
      };

      await cacheService.cacheProfile(profile);
      final cached = await cacheService.getCachedProfile();

      expect(cached, isNotNull);
      expect(cached!['name'], 'Ahmed');
      expect(cached['phone'], '0501234567');
    });

    test('cacheDeliveryDetail stores and retrieves single delivery', () async {
      final detail = {
        'id': 'del-100',
        'status': 'delivered',
        'customer_name': 'Mohammed',
        'items': [
          {'name': 'Milk', 'qty': 2},
        ],
      };

      await cacheService.cacheDeliveryDetail('del-100', detail);
      final cached = await cacheService.getCachedDeliveryDetail('del-100');

      expect(cached, isNotNull);
      expect(cached!['customer_name'], 'Mohammed');
      expect((cached['items'] as List).length, 1);
    });

    test('cacheEarnings stores and retrieves earnings by period', () async {
      final dailyEarnings = {
        'total': 350.0,
        'deliveries': 12,
        'tips': 45.0,
      };

      await cacheService.cacheEarnings('daily', dailyEarnings);
      final cached = await cacheService.getCachedEarnings('daily');

      expect(cached, isNotNull);
      expect(cached!['total'], 350.0);
      expect(cached['deliveries'], 12);
    });

    test('different earning periods stored independently', () async {
      await cacheService.cacheEarnings('daily', {'total': 100.0});
      await cacheService.cacheEarnings('weekly', {'total': 700.0});

      final daily = await cacheService.getCachedEarnings('daily');
      final weekly = await cacheService.getCachedEarnings('weekly');

      expect(daily!['total'], 100.0);
      expect(weekly!['total'], 700.0);
    });

    test('overwriting cache replaces old data', () async {
      await cacheService.cacheProfile({'name': 'Old Name'});
      await cacheService.cacheProfile({'name': 'New Name'});

      final cached = await cacheService.getCachedProfile();
      expect(cached!['name'], 'New Name');
    });
  });

  // -------------------------------------------------------------------------
  // TTL expiration (24h)
  // -------------------------------------------------------------------------
  group('TTL expiration (24h)', () {
    test('fresh cache entry is valid', () async {
      await cacheService.cacheDeliveries([
        {'id': 'ttl-1', 'status': 'pending'},
      ]);

      final cached = await cacheService.getCachedDeliveries();
      expect(cached, isNotNull);
      expect(cached!.length, 1);
    });

    test('expired cache entry returns null', () async {
      // Set up SharedPreferences with an old timestamp (> 24h ago)
      final oldTimestamp =
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

      SharedPreferences.setMockInitialValues({
        'cache_deliveries': '[{"id":"old","status":"pending"}]',
        'cache_ts_deliveries': oldTimestamp,
      });

      // Create a fresh service instance to read from the mocked prefs
      final freshService = LocalCacheService();
      final cached = await freshService.getCachedDeliveries();

      // Should return null because the timestamp is expired
      expect(cached, isNull);
    });

    test('expired profile returns null', () async {
      final oldTimestamp =
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

      SharedPreferences.setMockInitialValues({
        'cache_driver_profile': '{"name":"Expired Driver"}',
        'cache_ts_profile': oldTimestamp,
      });

      final freshService = LocalCacheService();
      final cached = await freshService.getCachedProfile();

      expect(cached, isNull);
    });

    test('cache within 24h is still valid', () async {
      final recentTimestamp =
          DateTime.now().subtract(const Duration(hours: 23)).toIso8601String();

      SharedPreferences.setMockInitialValues({
        'cache_deliveries': '[{"id":"recent","status":"active"}]',
        'cache_ts_deliveries': recentTimestamp,
      });

      final freshService = LocalCacheService();
      final cached = await freshService.getCachedDeliveries();

      expect(cached, isNotNull);
      expect(cached!.first['id'], 'recent');
    });

    test('expired delivery detail returns null', () async {
      final oldTimestamp =
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

      SharedPreferences.setMockInitialValues({
        'cache_delivery_del-exp': '{"id":"del-exp","status":"done"}',
        'cache_ts_delivery_del-exp': oldTimestamp,
      });

      final freshService = LocalCacheService();
      final cached = await freshService.getCachedDeliveryDetail('del-exp');

      expect(cached, isNull);
    });

    test('expired earnings returns null', () async {
      final oldTimestamp =
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

      SharedPreferences.setMockInitialValues({
        'cache_earnings_daily': '{"total": 100}',
        'cache_ts_earnings_daily': oldTimestamp,
      });

      final freshService = LocalCacheService();
      final cached = await freshService.getCachedEarnings('daily');

      expect(cached, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Optimistic patching
  // -------------------------------------------------------------------------
  group('optimistic patching', () {
    test('patchCachedDelivery merges patch into existing detail', () async {
      await cacheService.cacheDeliveryDetail('patch-1', {
        'id': 'patch-1',
        'status': 'picked_up',
        'customer_name': 'Ali',
      });

      await cacheService.patchCachedDelivery('patch-1', {
        'status': 'delivered',
      });

      final cached = await cacheService.getCachedDeliveryDetail('patch-1');

      expect(cached, isNotNull);
      expect(cached!['status'], 'delivered');
      expect(cached['customer_name'], 'Ali'); // original field preserved
    });

    test('patchCachedDelivery creates entry if none exists', () async {
      await cacheService.patchCachedDelivery('new-patch', {
        'status': 'delivered',
        'notes': 'Door delivery',
      });

      final cached = await cacheService.getCachedDeliveryDetail('new-patch');

      expect(cached, isNotNull);
      expect(cached!['status'], 'delivered');
    });

    test('patchCachedDelivery also updates the delivery list cache', () async {
      await cacheService.cacheDeliveries([
        {'id': 'list-patch-1', 'status': 'pending'},
        {'id': 'list-patch-2', 'status': 'picked_up'},
      ]);

      await cacheService.patchCachedDelivery('list-patch-1', {
        'status': 'delivered',
      });

      final deliveries = await cacheService.getCachedDeliveries();

      expect(deliveries, isNotNull);
      final patched = deliveries!.firstWhere((d) => d['id'] == 'list-patch-1');
      expect(patched['status'], 'delivered');

      // Other items unchanged
      final unchanged =
          deliveries.firstWhere((d) => d['id'] == 'list-patch-2');
      expect(unchanged['status'], 'picked_up');
    });

    test('patch preserves fields not included in patch map', () async {
      await cacheService.cacheDeliveryDetail('preserve-1', {
        'id': 'preserve-1',
        'status': 'picked_up',
        'fee': 25.0,
        'customer_name': 'Sara',
        'customer_phone': '0551234567',
      });

      await cacheService.patchCachedDelivery('preserve-1', {
        'status': 'delivered',
      });

      final cached = await cacheService.getCachedDeliveryDetail('preserve-1');

      expect(cached!['fee'], 25.0);
      expect(cached['customer_name'], 'Sara');
      expect(cached['customer_phone'], '0551234567');
    });
  });

  // -------------------------------------------------------------------------
  // Cache cleanup
  // -------------------------------------------------------------------------
  group('cache cleanup', () {
    test('clearAll removes all cached data', () async {
      await cacheService.cacheDeliveries([
        {'id': 'clean-1', 'status': 'pending'},
      ]);
      await cacheService.cacheProfile({'name': 'Driver'});
      await cacheService.cacheEarnings('daily', {'total': 100});
      await cacheService.cacheDeliveryDetail('clean-1', {'id': 'clean-1'});

      await cacheService.clearAll();

      expect(await cacheService.getCachedDeliveries(), isNull);
      expect(await cacheService.getCachedProfile(), isNull);
      expect(await cacheService.getCachedEarnings('daily'), isNull);
      expect(await cacheService.getCachedDeliveryDetail('clean-1'), isNull);
    });

    test('clearAll is safe to call multiple times', () async {
      await cacheService.clearAll();
      await cacheService.clearAll();

      // No exception means it handled empty state gracefully.
      expect(true, isTrue);
    });

    test('clearAll clears in-memory caches', () async {
      await cacheService.cacheDeliveries([
        {'id': 'mem-1', 'status': 'pending'},
      ]);
      await cacheService.cacheProfile({'name': 'Memory Test'});

      // First read populates in-memory cache
      expect(await cacheService.getCachedDeliveries(), isNotNull);
      expect(await cacheService.getCachedProfile(), isNotNull);

      await cacheService.clearAll();

      // After clear, even in-memory should be gone
      // (getCachedDeliveries will try to read from prefs, which is also cleared)
      expect(await cacheService.getCachedDeliveries(), isNull);
      expect(await cacheService.getCachedProfile(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Edge cases
  // -------------------------------------------------------------------------
  group('edge cases', () {
    test('getCachedDeliveries returns null when nothing cached', () async {
      final result = await cacheService.getCachedDeliveries();
      expect(result, isNull);
    });

    test('getCachedProfile returns null when nothing cached', () async {
      final result = await cacheService.getCachedProfile();
      expect(result, isNull);
    });

    test('getCachedDeliveryDetail returns null for non-existent id', () async {
      final result = await cacheService.getCachedDeliveryDetail('nonexistent');
      expect(result, isNull);
    });

    test('getCachedEarnings returns null for uncached period', () async {
      final result = await cacheService.getCachedEarnings('monthly');
      expect(result, isNull);
    });

    test('malformed JSON in prefs returns null gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'cache_deliveries': 'not-valid-json{{{',
        'cache_ts_deliveries': DateTime.now().toIso8601String(),
      });

      final freshService = LocalCacheService();
      final result = await freshService.getCachedDeliveries();

      // Should return null (not throw) due to try/catch
      expect(result, isNull);
    });

    test('malformed timestamp in prefs treated as invalid', () async {
      SharedPreferences.setMockInitialValues({
        'cache_deliveries': '[{"id":"ok"}]',
        'cache_ts_deliveries': 'not-a-date',
      });

      final freshService = LocalCacheService();
      final result = await freshService.getCachedDeliveries();

      expect(result, isNull);
    });

    test('empty delivery list caches and retrieves correctly', () async {
      await cacheService.cacheDeliveries([]);
      final cached = await cacheService.getCachedDeliveries();

      expect(cached, isNotNull);
      expect(cached!.isEmpty, isTrue);
    });
  });
}
