import 'package:alhai_core/alhai_core.dart';

import 'addresses_datasource.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesDatasource _datasource;

  AddressesRepositoryImpl(this._datasource);

  @override
  Future<List<Address>> getAddresses() => _datasource.getAddresses();

  @override
  Future<Address?> getDefaultAddress() => _datasource.getDefaultAddress();

  @override
  Future<Address> getAddress(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Address> createAddress(CreateAddressParams params) =>
      _datasource.createAddress(params);

  @override
  Future<Address> updateAddress(String id, UpdateAddressParams params) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAddress(String id) => _datasource.deleteAddress(id);

  @override
  Future<void> setDefaultAddress(String id) =>
      _datasource.setDefaultAddress(id);
}
