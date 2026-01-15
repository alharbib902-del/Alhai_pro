import 'package:dio/dio.dart';

import '../../datasources/remote/addresses_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/address.dart';
import '../addresses_repository.dart';

/// Implementation of AddressesRepository
class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesRemoteDataSource _remote;

  AddressesRepositoryImpl({
    required AddressesRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final responses = await _remote.getAddresses();
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Address?> getDefaultAddress() async {
    try {
      final addresses = await getAddresses();
      return addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw Exception('No addresses'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Address> getAddress(String id) async {
    try {
      final response = await _remote.getAddress(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Address> createAddress(CreateAddressParams params) async {
    try {
      final data = {
        'label': params.label,
        'full_address': params.fullAddress,
        'city': params.city,
        'district': params.district,
        'street': params.street,
        'building_number': params.buildingNumber,
        'apartment_number': params.apartmentNumber,
        'landmark': params.landmark,
        'lat': params.lat,
        'lng': params.lng,
        'is_default': params.isDefault,
      };

      final response = await _remote.createAddress(data);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Address> updateAddress(String id, UpdateAddressParams params) async {
    try {
      final data = <String, dynamic>{};
      if (params.label != null) data['label'] = params.label;
      if (params.fullAddress != null) data['full_address'] = params.fullAddress;
      if (params.city != null) data['city'] = params.city;
      if (params.district != null) data['district'] = params.district;
      if (params.street != null) data['street'] = params.street;
      if (params.buildingNumber != null) data['building_number'] = params.buildingNumber;
      if (params.apartmentNumber != null) data['apartment_number'] = params.apartmentNumber;
      if (params.landmark != null) data['landmark'] = params.landmark;
      if (params.lat != null) data['lat'] = params.lat;
      if (params.lng != null) data['lng'] = params.lng;

      final response = await _remote.updateAddress(id, data);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _remote.deleteAddress(id);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      await _remote.setDefaultAddress(id);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
