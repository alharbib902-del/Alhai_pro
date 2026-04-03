import 'package:alhai_core/alhai_core.dart';

import 'orders_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDatasource _datasource;

  OrdersRepositoryImpl(this._datasource);

  @override
  Future<Order> createOrder(CreateOrderParams params) =>
      _datasource.createOrder(params);

  @override
  Future<Order> getOrder(String id) =>
      _datasource.getOrder(id);

  @override
  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) => _datasource.getOrders(status: status, page: page, limit: limit);

  @override
  Future<Order> updateStatus(String id, OrderStatus status) {
    throw UnimplementedError('Customers cannot update order status');
  }

  @override
  Future<void> cancelOrder(String id, {String? reason}) =>
      _datasource.cancelOrder(id, reason: reason);
}
