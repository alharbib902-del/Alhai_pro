import 'package:dio/dio.dart';

import '../../datasources/remote/orders_remote_datasource.dart';
import '../../dto/orders/create_order_request.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/create_order_params.dart';
import '../../models/enums/order_status.dart';
import '../../models/order.dart';
import '../../models/paginated.dart';
import '../orders_repository.dart';

/// Implementation of OrdersRepository (v3.2)
/// Mapping (DTO ↔ Domain) happens here only
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remote;

  OrdersRepositoryImpl({required OrdersRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Order> createOrder(CreateOrderParams params) async {
    try {
      // Convert Domain params to DTO request
      final request = CreateOrderRequest.fromDomain(params);

      // Call remote with DTO
      final response = await _remote.createOrder(request);

      // Convert DTO response to Domain
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Order> getOrder(String id) async {
    try {
      final response = await _remote.getOrder(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Convert OrderStatus enum to String for API
      final statusString = status?.name;

      final responses = await _remote.getOrders(
        status: statusString,
        page: page,
        limit: limit,
      );

      // Convert each DTO to Domain
      final items = responses.map((r) => r.toDomain()).toList();

      // Calculate hasMore based on returned items
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
  Future<Order> updateStatus(String id, OrderStatus status) async {
    try {
      // Convert enum to String for API
      final response = await _remote.updateStatus(id, status.name);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> cancelOrder(String id, {String? reason}) async {
    try {
      await _remote.cancelOrder(id, reason: reason);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
