import '../models/create_order_params.dart';
import '../models/enums/order_status.dart';
import '../models/order.dart';
import '../models/paginated.dart';

/// Repository contract for order operations (v3.2)
/// UI ↔ Repository = Domain Models only
abstract class OrdersRepository {
  /// Creates a new order
  Future<Order> createOrder(CreateOrderParams params);

  /// Gets a single order by ID
  Future<Order> getOrder(String id);

  /// Gets paginated list of orders with optional status filter
  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Updates order status
  Future<Order> updateStatus(String id, OrderStatus status);

  /// Cancels an order with optional reason
  Future<void> cancelOrder(String id, {String? reason});
}
