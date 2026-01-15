import 'package:dio/dio.dart';

import '../../../dto/categories/category_response.dart';
import '../categories_remote_datasource.dart';

/// Implementation of CategoriesRemoteDataSource
class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final Dio _dio;

  CategoriesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<CategoryResponse>> getCategories(String storeId) async {
    final response = await _dio.get('/stores/$storeId/categories');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => CategoryResponse.fromJson(json)).toList();
  }

  @override
  Future<CategoryResponse> getCategory(String id) async {
    final response = await _dio.get('/categories/$id');
    return CategoryResponse.fromJson(response.data);
  }
}
