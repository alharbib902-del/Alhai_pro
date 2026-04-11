import 'package:dio/dio.dart';

import '../../datasources/remote/products_remote_datasource.dart';
import '../../dto/products/create_product_request.dart';
import '../../dto/products/update_product_request.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/create_product_params.dart';
import '../../models/paginated.dart';
import '../../models/product.dart';
import '../../models/update_product_params.dart';
import '../products_repository.dart';

/// Implementation of ProductsRepository (v3.2)
/// Mapping (DTO ↔ Domain) happens here only
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remote;

  ProductsRepositoryImpl({required ProductsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      final responses = await _remote.getProducts(
        storeId,
        page: page,
        limit: limit,
        categoryId: categoryId,
        searchQuery: searchQuery,
      );

      final items = responses.map((r) => r.toDomain()).toList();
      final hasMore = items.length >= limit;

      return Paginated(
        items: items,
        page: page,
        limit: limit,
        hasMore: hasMore,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
      final response = await _remote.getProduct(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    try {
      final response = await _remote.getByBarcode(barcode);
      return response?.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Product> createProduct(CreateProductParams params) async {
    try {
      final request = CreateProductRequest.fromDomain(params);
      final response = await _remote.createProduct(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Product> updateProduct(UpdateProductParams params) async {
    try {
      final request = UpdateProductRequest.fromDomain(params);
      final response = await _remote.updateProduct(params.id, request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _remote.deleteProduct(id);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
