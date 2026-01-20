import 'package:dio/dio.dart';

import '../../../dto/suppliers/create_supplier_request.dart';
import '../../../dto/suppliers/supplier_response.dart';
import '../../../dto/suppliers/update_supplier_request.dart';
import '../suppliers_remote_datasource.dart';

/// Implementation of SuppliersRemoteDataSource
class SuppliersRemoteDataSourceImpl implements SuppliersRemoteDataSource {
  final Dio _dio;

  SuppliersRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<SupplierResponse>> getSuppliers(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/suppliers',
      queryParameters: {
        'store_id': storeId,
        if (activeOnly != null) 'active_only': activeOnly,
        'page': page,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SupplierResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SupplierResponse> getSupplier(String id) async {
    final response = await _dio.get('/suppliers/$id');
    return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SupplierResponse> createSupplier(CreateSupplierRequest request) async {
    final response = await _dio.post(
      '/suppliers',
      data: request.toJson(),
    );
    return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SupplierResponse> updateSupplier(
    String id,
    UpdateSupplierRequest request,
  ) async {
    final response = await _dio.patch(
      '/suppliers/$id',
      data: request.toJson(),
    );
    return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _dio.delete('/suppliers/$id');
  }

  @override
  Future<List<SupplierResponse>> getSuppliersWithBalance(String storeId) async {
    final response = await _dio.get(
      '/suppliers/with-balance',
      queryParameters: {'store_id': storeId},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SupplierResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
