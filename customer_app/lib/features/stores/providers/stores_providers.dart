import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../data/stores_datasource.dart';

/// Nearby stores based on user location.
final nearbyStoresProvider =
    FutureProvider.family<List<Store>, ({double lat, double lng})>(
  (ref, location) async {
    final datasource = locator<StoresDatasource>();
    return datasource.getNearbyStores(
      lat: location.lat,
      lng: location.lng,
    );
  },
);

/// All stores (fallback when location unavailable).
final allStoresProvider = FutureProvider<List<Store>>((ref) async {
  final datasource = locator<StoresDatasource>();
  return datasource.getAllStores();
});

/// Store detail by ID.
final storeDetailProvider =
    FutureProvider.family<Store, String>((ref, storeId) async {
  final datasource = locator<StoresDatasource>();
  return datasource.getStore(storeId);
});
