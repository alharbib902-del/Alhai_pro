import '../models/address.dart';

/// Repository contract for address operations
/// Used by Consumer App for managing delivery addresses
abstract class AddressesRepository {
  /// Gets all addresses for current user
  Future<List<Address>> getAddresses();

  /// Gets the default address
  Future<Address?> getDefaultAddress();

  /// Gets a specific address by ID
  Future<Address> getAddress(String id);

  /// Creates a new address
  Future<Address> createAddress(CreateAddressParams params);

  /// Updates an existing address
  Future<Address> updateAddress(String id, UpdateAddressParams params);

  /// Deletes an address
  Future<void> deleteAddress(String id);

  /// Sets an address as default
  Future<void> setDefaultAddress(String id);
}

/// Parameters for creating a new address
class CreateAddressParams {
  final String label;
  final String fullAddress;
  final String city;
  final String? district;
  final String? street;
  final String? buildingNumber;
  final String? apartmentNumber;
  final String? landmark;
  final double lat;
  final double lng;
  final bool isDefault;

  const CreateAddressParams({
    required this.label,
    required this.fullAddress,
    required this.city,
    this.district,
    this.street,
    this.buildingNumber,
    this.apartmentNumber,
    this.landmark,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });
}

/// Parameters for updating an address
class UpdateAddressParams {
  final String? label;
  final String? fullAddress;
  final String? city;
  final String? district;
  final String? street;
  final String? buildingNumber;
  final String? apartmentNumber;
  final String? landmark;
  final double? lat;
  final double? lng;

  const UpdateAddressParams({
    this.label,
    this.fullAddress,
    this.city,
    this.district,
    this.street,
    this.buildingNumber,
    this.apartmentNumber,
    this.landmark,
    this.lat,
    this.lng,
  });
}
