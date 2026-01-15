import '../../dto/stores/store_response.dart';

/// Remote data source contract for stores API calls
abstract class StoresRemoteDataSource {
  /// Gets a store by ID
  Future<StoreResponse> getStore(String id);

  /// Gets the current user's store
  Future<StoreResponse?> getCurrentStore();

  /// Gets all stores (for admin)
  Future<List<StoreResponse>> getStores();

  /// Gets nearby stores within radius
  Future<List<StoreResponse>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  });

  /// Updates store information
  Future<StoreResponse> updateStore(String id, Map<String, dynamic> data);

  /// Checks if store is open
  Future<bool> isStoreOpen(String id);
}
