import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------
class FakeStoresRepository implements StoresRepository {
  final List<Store> _stores = [];
  Store? _currentStore;

  void seed(List<Store> stores) => _stores.addAll(stores);
  void setCurrentStore(Store? store) => _currentStore = store;

  @override
  Future<Store> getStore(String id) async {
    return _stores.firstWhere((s) => s.id == id);
  }

  @override
  Future<Store?> getCurrentStore() async => _currentStore;

  @override
  Future<List<Store>> getStores() async => _stores;

  @override
  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    return _stores;
  }

  @override
  Future<Store> updateStore(String id, UpdateStoreParams params) async {
    final idx = _stores.indexWhere((s) => s.id == id);
    _stores[idx] = _stores[idx].copyWith(name: params.name ?? _stores[idx].name);
    return _stores[idx];
  }

  @override
  Future<bool> isStoreOpen(String storeId) async {
    final store = _stores.firstWhere((s) => s.id == storeId);
    return store.isActive;
  }
}

void main() {
  late StoreService storeService;
  late FakeStoresRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeStoresRepository();
    storeService = StoreService(fakeRepo);
  });

  group('StoreService', () {
    test('should be created', () {
      expect(storeService, isNotNull);
    });

    group('getStore', () {
      test('should return store by ID', () async {
        fakeRepo.seed([
          Store(
            id: 'store-1',
            name: 'My Store',
            address: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isActive: true,
            ownerId: 'owner-1',
            createdAt: DateTime.now(),
          ),
        ]);

        final store = await storeService.getStore('store-1');
        expect(store.name, equals('My Store'));
      });
    });

    group('getCurrentStore', () {
      test('should return null when no current store', () async {
        final store = await storeService.getCurrentStore();
        expect(store, isNull);
      });

      test('should return current store when set', () async {
        fakeRepo.setCurrentStore(Store(
          id: 'store-1',
          name: 'Current Store',
          address: 'Riyadh',
          lat: 24.7,
          lng: 46.7,
          isActive: true,
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
        ));

        final store = await storeService.getCurrentStore();
        expect(store, isNotNull);
        expect(store!.name, equals('Current Store'));
      });
    });

    group('getStores', () {
      test('should return all stores', () async {
        fakeRepo.seed([
          Store(
            id: 's1',
            name: 'Store 1',
            address: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isActive: true,
            ownerId: 'o1',
            createdAt: DateTime.now(),
          ),
          Store(
            id: 's2',
            name: 'Store 2',
            address: 'Jeddah',
            lat: 21.5,
            lng: 39.2,
            isActive: true,
            ownerId: 'o1',
            createdAt: DateTime.now(),
          ),
        ]);

        final stores = await storeService.getStores();
        expect(stores, hasLength(2));
      });
    });

    group('getNearbyStores', () {
      test('should return nearby stores', () async {
        fakeRepo.seed([
          Store(
            id: 's1',
            name: 'Nearby',
            address: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isActive: true,
            ownerId: 'o1',
            createdAt: DateTime.now(),
          ),
        ]);

        final stores = await storeService.getNearbyStores(
          lat: 24.7,
          lng: 46.7,
        );
        expect(stores, isNotEmpty);
      });
    });

    group('isStoreOpen', () {
      test('should return true for active store', () async {
        fakeRepo.seed([
          Store(
            id: 's1',
            name: 'Open Store',
            address: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isActive: true,
            ownerId: 'o1',
            createdAt: DateTime.now(),
          ),
        ]);

        final isOpen = await storeService.isStoreOpen('s1');
        expect(isOpen, isTrue);
      });

      test('should return false for inactive store', () async {
        fakeRepo.seed([
          Store(
            id: 's2',
            name: 'Closed Store',
            address: 'Riyadh',
            lat: 24.7,
            lng: 46.7,
            isActive: false,
            ownerId: 'o1',
            createdAt: DateTime.now(),
          ),
        ]);

        final isOpen = await storeService.isStoreOpen('s2');
        expect(isOpen, isFalse);
      });
    });
  });
}
