import 'package:dio/dio.dart';

import '../../../dto/addresses/address_response.dart';
import '../addresses_remote_datasource.dart';

/// Implementation of AddressesRemoteDataSource
class AddressesRemoteDataSourceImpl implements AddressesRemoteDataSource {
  final Dio _dio;

  AddressesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AddressResponse>> getAddresses() async {
    final response = await _dio.get('/addresses');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => AddressResponse.fromJson(json)).toList();
  }

  @override
  Future<AddressResponse> getAddress(String id) async {
    final response = await _dio.get('/addresses/$id');
    return AddressResponse.fromJson(response.data);
  }

  @override
  Future<AddressResponse> createAddress(Map<String, dynamic> data) async {
    final response = await _dio.post('/addresses', data: data);
    return AddressResponse.fromJson(response.data);
  }

  @override
  Future<AddressResponse> updateAddress(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/addresses/$id', data: data);
    return AddressResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete('/addresses/$id');
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await _dio.post('/addresses/$id/default');
  }
}
