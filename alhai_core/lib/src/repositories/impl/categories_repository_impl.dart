import 'package:dio/dio.dart';

import '../../datasources/remote/categories_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/category.dart';
import '../categories_repository.dart';

/// Implementation of CategoriesRepository
/// Mapping (DTO ↔ Domain) happens here only
class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remote;

  CategoriesRepositoryImpl({required CategoriesRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<Category>> getCategories(String storeId) async {
    try {
      final responses = await _remote.getCategories(storeId);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Category> getCategory(String id) async {
    try {
      final response = await _remote.getCategory(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Category>> getRootCategories(String storeId) async {
    try {
      final responses = await _remote.getCategories(storeId);
      return responses
          .where((r) => r.parentId == null)
          .map((r) => r.toDomain())
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<Category>> getChildCategories(String parentId) async {
    try {
      // Note: This implementation fetches all categories and filters
      // A more efficient API would have a dedicated endpoint
      final responses = await _remote.getCategories(parentId);
      return responses
          .where((r) => r.parentId == parentId)
          .map((r) => r.toDomain())
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
