import '../../dto/addresses/address_response.dart';

/// Remote data source contract for addresses API calls
abstract class AddressesRemoteDataSource {
  /// Gets all addresses for current user
  Future<List<AddressResponse>> getAddresses();

  /// Gets a specific address by ID
  Future<AddressResponse> getAddress(String id);

  /// Creates a new address
  Future<AddressResponse> createAddress(Map<String, dynamic> data);

  /// Updates an existing address
  Future<AddressResponse> updateAddress(String id, Map<String, dynamic> data);

  /// Deletes an address
  Future<void> deleteAddress(String id);

  /// Sets an address as default
  Future<void> setDefaultAddress(String id);
}
