import '../models/store.dart';

/// Repository contract for store operations
/// UI ↔ Repository = Domain Models only
abstract class StoresRepository {
  /// Gets a store by ID
  Future<Store> getStore(String id);

  /// Gets the current user's store (for employees/owners)
  Future<Store?> getCurrentStore();

  /// Gets all stores (for admin)
  Future<List<Store>> getStores();

  /// Gets nearby stores within radius (km)
  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  });

  /// Updates store information (owner only)
  Future<Store> updateStore(String id, UpdateStoreParams params);

  /// Checks if store is open
  Future<bool> isStoreOpen(String id);
}

/// Parameters for updating a store
class UpdateStoreParams {
  final String? name;
  final String? address;
  final double? lat;
  final double? lng;
  final bool? isActive;
  final String? phone;
  final String? imageUrl;

  const UpdateStoreParams({
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.isActive,
    this.phone,
    this.imageUrl,
  });
}
