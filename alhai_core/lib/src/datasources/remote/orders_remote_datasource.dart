import 'package:dio/dio.dart';

import '../../dto/orders/create_order_request.dart';
import '../../dto/orders/order_response.dart';

/// Remote data source contract for orders API calls
/// Repository ↔ DataSource = DTO only
abstract class OrdersRemoteDataSource {
  /// Creates a new order
  Future<OrderResponse> createOrder(CreateOrderRequest request);

  /// Gets a single order by ID
  Future<OrderResponse> getOrder(String id);

  /// Gets paginated list of orders
  Future<List<OrderResponse>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Updates order status
  Future<OrderResponse> updateStatus(String id, String status);

  /// Cancels an order
  Future<void> cancelOrder(String id, {String? reason});
}

/// Implementation of OrdersRemoteDataSource
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio _dio;

  OrdersRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<OrderResponse> createOrder(CreateOrderRequest request) async {
    final response = await _dio.post(
      '/orders',
      data: request.toJson(),
    );
    return OrderResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderResponse> getOrder(String id) async {
    final response = await _dio.get('/orders/$id');
    return OrderResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderResponse>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    // Build query parameters, only include status if not null
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _dio.get(
      '/orders',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Handle paginated response wrapper { "data": [...], "meta": {...} }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<OrderResponse> updateStatus(String id, String status) async {
    final response = await _dio.patch(
      '/orders/$id/status',
      data: {'status': status},
    );
    return OrderResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelOrder(String id, {String? reason}) async {
    await _dio.post(
      '/orders/$id/cancel',
      data: reason != null ? {'reason': reason} : <String, dynamic>{},
    );
  }
}
