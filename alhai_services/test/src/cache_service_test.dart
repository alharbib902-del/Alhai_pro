import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late CacheService cacheService;

  setUp(() {
    cacheService = CacheService();
  });

  group('CacheService', () {
    test('should be created', () {
      expect(cacheService, isNotNull);
    });

    group('set and get', () {
      test('should store and retrieve string value', () {
        cacheService.set('key', 'value');
        expect(cacheService.get<String>('key'), equals('value'));
      });

      test('should store and retrieve int value', () {
        cacheService.set('count', 42);
        expect(cacheService.get<int>('count'), equals(42));
      });

      test('should store and retrieve list value', () {
        cacheService.set('items', [1, 2, 3]);
        expect(cacheService.get<List<int>>('items'), equals([1, 2, 3]));
      });

      test('should return null for non-existent key', () {
        expect(cacheService.get<String>('missing'), isNull);
      });

      test('should overwrite existing value', () {
        cacheService.set('key', 'old');
        cacheService.set('key', 'new');
        expect(cacheService.get<String>('key'), equals('new'));
      });
    });

    group('expiry', () {
      test('should return value before expiry', () {
        cacheService.set('key', 'value', expiry: const Duration(hours: 1));
        expect(cacheService.get<String>('key'), equals('value'));
      });

      test('should store value with no expiry indefinitely', () {
        cacheService.set('key', 'value');
        // No expiry set, should always be available
        expect(cacheService.get<String>('key'), equals('value'));
        expect(cacheService.containsKey('key'), isTrue);
      });
    });

    group('remove', () {
      test('should remove a single key', () {
        cacheService.set('key1', 'value1');
        cacheService.set('key2', 'value2');

        cacheService.remove('key1');

        expect(cacheService.get<String>('key1'), isNull);
        expect(cacheService.get<String>('key2'), equals('value2'));
      });

      test('should handle removing non-existent key gracefully', () {
        cacheService.remove('non-existent');
        // Should not throw
      });
    });

    group('removeByPrefix', () {
      test('should remove all keys with given prefix', () {
        cacheService.set('products:1', 'A');
        cacheService.set('products:2', 'B');
        cacheService.set('orders:1', 'C');

        cacheService.removeByPrefix('products:');

        expect(cacheService.get<String>('products:1'), isNull);
        expect(cacheService.get<String>('products:2'), isNull);
        expect(cacheService.get<String>('orders:1'), equals('C'));
      });
    });

    group('clear', () {
      test('should clear all entries', () {
        cacheService.set('a', 1);
        cacheService.set('b', 2);
        cacheService.set('c', 3);

        cacheService.clear();

        expect(cacheService.length, equals(0));
        expect(cacheService.get<int>('a'), isNull);
      });
    });

    group('containsKey', () {
      test('should return true for existing key', () {
        cacheService.set('key', 'value');
        expect(cacheService.containsKey('key'), isTrue);
      });

      test('should return false for missing key', () {
        expect(cacheService.containsKey('missing'), isFalse);
      });
    });

    group('getOrLoad', () {
      test('should return cached value if present', () async {
        cacheService.set('key', 'cached');
        var loaderCalled = false;

        final result = await cacheService.getOrLoad('key', () async {
          loaderCalled = true;
          return 'loaded';
        });

        expect(result, equals('cached'));
        expect(loaderCalled, isFalse);
      });

      test('should call loader and cache when key is missing', () async {
        final result = await cacheService.getOrLoad('key', () async {
          return 'loaded';
        });

        expect(result, equals('loaded'));
        expect(cacheService.get<String>('key'), equals('loaded'));
      });
    });

    group('length and keys', () {
      test('should return correct length', () {
        cacheService.set('a', 1);
        cacheService.set('b', 2);

        expect(cacheService.length, equals(2));
      });

      test('should return all keys', () {
        cacheService.set('key1', 'v1');
        cacheService.set('key2', 'v2');

        expect(cacheService.keys, containsAll(['key1', 'key2']));
      });
    });

    group('static key helpers', () {
      test('storeKey should format correctly', () {
        expect(CacheService.storeKey('s1'), equals('store:s1'));
      });

      test('productsKey should format correctly', () {
        expect(CacheService.productsKey('s1'), equals('products:s1'));
      });

      test('categoriesKey should format correctly', () {
        expect(CacheService.categoriesKey('s1'), equals('categories:s1'));
      });

      test('settingsKey should format correctly', () {
        expect(CacheService.settingsKey('s1'), equals('settings:s1'));
      });

      test('userKey should format correctly', () {
        expect(CacheService.userKey('u1'), equals('user:u1'));
      });
    });

    group('cleanup', () {
      test('should not remove non-expired entries', () {
        cacheService.set('key', 'value', expiry: const Duration(hours: 1));

        cacheService.cleanup();

        expect(cacheService.get<String>('key'), equals('value'));
      });
    });
  });
}
