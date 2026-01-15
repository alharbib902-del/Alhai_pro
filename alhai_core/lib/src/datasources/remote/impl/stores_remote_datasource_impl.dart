import 'package:dio/dio.dart';

import '../../../dto/stores/store_response.dart';
import '../stores_remote_datasource.dart';

/// Implementation of StoresRemoteDataSource
class StoresRemoteDataSourceImpl implements StoresRemoteDataSource {
  final Dio _dio;

  StoresRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<StoreResponse> getStore(String id) async {
    final response = await _dio.get('/stores/$id');
    return StoreResponse.fromJson(response.data);
  }

  @override
  Future<StoreResponse?> getCurrentStore() async {
    try {
      final response = await _dio.get('/stores/me');
      return StoreResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<StoreResponse>> getStores() async {
    final response = await _dio.get('/stores');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => StoreResponse.fromJson(json)).toList();
  }

  @override
  Future<List<StoreResponse>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    final response = await _dio.get('/stores/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radiusKm,
    });
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => StoreResponse.fromJson(json)).toList();
  }

  @override
  Future<StoreResponse> updateStore(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/stores/$id', data: data);
    return StoreResponse.fromJson(response.data);
  }

  @override
  Future<bool> isStoreOpen(String id) async {
    final response = await _dio.get('/stores/$id/status');
    return response.data['is_open'] ?? false;
  }
}
