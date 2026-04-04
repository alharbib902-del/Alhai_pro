import 'package:alhai_core/alhai_core.dart';

import 'stores_datasource.dart';

class StoresRepositoryImpl implements StoresRepository {
  final StoresDatasource _datasource;

  StoresRepositoryImpl(this._datasource);

  @override
  Future<Store> getStore(String id) => _datasource.getStore(id);

  @override
  Future<Store?> getCurrentStore() async => null; // N/A for customers

  @override
  Future<List<Store>> getStores() => _datasource.getAllStores();

  @override
  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) =>
      _datasource.getNearbyStores(lat: lat, lng: lng, radiusKm: radiusKm);

  @override
  Future<Store> updateStore(String id, UpdateStoreParams params) {
    throw UnimplementedError('Customers cannot update stores');
  }

  @override
  Future<bool> isStoreOpen(String id) async {
    final store = await _datasource.getStore(id);
    return store.isOpenNow();
  }
}
