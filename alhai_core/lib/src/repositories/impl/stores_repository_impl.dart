import 'package:dio/dio.dart';

import '../../datasources/remote/stores_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/store.dart';
import '../stores_repository.dart';

/// Implementation of StoresRepository
class StoresRepositoryImpl implements StoresRepository {
  final StoresRemoteDataSource _remote;

  StoresRepositoryImpl({
    required StoresRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Store> getStore(String id) async {
    try {
      final response = await _remote.getStore(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Store?> getCurrentStore() async {
    try {
      final response = await _remote.getCurrentStore();
      return response?.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Store>> getStores() async {
    try {
      final responses = await _remote.getStores();
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    try {
      final responses = await _remote.getNearbyStores(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Store> updateStore(String id, UpdateStoreParams params) async {
    try {
      final data = <String, dynamic>{};
      if (params.name != null) data['name'] = params.name;
      if (params.address != null) data['address'] = params.address;
      if (params.lat != null) data['lat'] = params.lat;
      if (params.lng != null) data['lng'] = params.lng;
      if (params.isActive != null) data['is_active'] = params.isActive;
      if (params.phone != null) data['phone'] = params.phone;
      if (params.imageUrl != null) data['image_url'] = params.imageUrl;

      final response = await _remote.updateStore(id, data);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<bool> isStoreOpen(String id) async {
    try {
      return await _remote.isStoreOpen(id);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
