import 'package:dio/dio.dart';

import '../../../dto/inventory/adjust_stock_request.dart';
import '../../../dto/inventory/low_stock_product_response.dart';
import '../../../dto/inventory/stock_adjustment_response.dart';
import '../inventory_remote_datasource.dart';

/// Implementation of InventoryRemoteDataSource
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final Dio _dio;

  InventoryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<StockAdjustmentResponse>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/inventory/adjustments',
      queryParameters: {'product_id': productId, 'page': page, 'limit': limit},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => StockAdjustmentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StockAdjustmentResponse>> getStoreAdjustments(
    String storeId, {
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/inventory/store-adjustments',
      queryParameters: {
        'store_id': storeId,
        if (type != null) 'type': type,
        'page': page,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => StockAdjustmentResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StockAdjustmentResponse> adjustStock(
    AdjustStockRequest request,
  ) async {
    final response = await _dio.post(
      '/inventory/adjust',
      data: request.toJson(),
    );
    return StockAdjustmentResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<LowStockProductResponse>> getLowStockProducts(
    String storeId,
  ) async {
    final response = await _dio.get(
      '/inventory/low-stock',
      queryParameters: {'store_id': storeId},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => LowStockProductResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getOutOfStockProductIds(String storeId) async {
    final response = await _dio.get(
      '/inventory/out-of-stock',
      queryParameters: {'store_id': storeId},
    );
    final list = response.data['data'] as List<dynamic>;
    return list.cast<String>();
  }
}
