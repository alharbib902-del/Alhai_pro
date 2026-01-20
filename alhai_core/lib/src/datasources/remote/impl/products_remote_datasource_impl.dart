import 'package:dio/dio.dart';

import '../../../dto/products/create_product_request.dart';
import '../../../dto/products/product_response.dart';
import '../../../dto/products/update_product_request.dart';
import '../products_remote_datasource.dart';

/// Implementation of ProductsRemoteDataSource
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio _dio;

  ProductsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ProductResponse>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {
        'store_id': storeId,
        'page': page,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductResponse> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return ProductResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductResponse?> getByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '/products/barcode/$barcode',
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<ProductResponse> createProduct(CreateProductRequest request) async {
    final response = await _dio.post(
      '/products',
      data: request.toJson(),
    );
    return ProductResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductResponse> updateProduct(
    String id,
    UpdateProductRequest request,
  ) async {
    final response = await _dio.patch(
      '/products/$id',
      data: request.toJson(),
    );
    return ProductResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete('/products/$id');
  }
}
