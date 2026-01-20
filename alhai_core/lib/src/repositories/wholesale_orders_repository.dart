import '../models/paginated.dart';
import '../models/wholesale_order.dart';

/// Repository contract for wholesale order operations (v2.6.0)
/// Referenced by: distributor_portal, admin_pos
abstract class WholesaleOrdersRepository {
  /// Gets a wholesale order by ID
  Future<WholesaleOrder> getOrder(String id);

  /// Gets orders for a distributor
  Future<Paginated<WholesaleOrder>> getDistributorOrders(
    String distributorId, {
    int page = 1,
    int limit = 20,
    WholesaleOrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets orders for a store
  Future<Paginated<WholesaleOrder>> getStoreOrders(
    String storeId, {
    int page = 1,
    int limit = 20,
    WholesaleOrderStatus? status,
  });

  /// Creates a new wholesale order
  Future<WholesaleOrder> createOrder({
    required String distributorId,
    required String storeId,
    required List<WholesaleOrderItem> items,
    required WholesalePaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    DateTime? expectedDeliveryDate,
  });

  /// Confirms an order (distributor)
  Future<WholesaleOrder> confirmOrder(String orderId);

  /// Marks order as processing (distributor)
  Future<WholesaleOrder> startProcessing(String orderId);

  /// Marks order as shipped (distributor)
  Future<WholesaleOrder> shipOrder(String orderId, {String? trackingNumber});

  /// Marks order as delivered
  Future<WholesaleOrder> deliverOrder(String orderId);

  /// Cancels an order
  Future<WholesaleOrder> cancelOrder(String orderId, String reason);

  /// Gets order summary for distributor
  Future<WholesaleOrderSummary> getDistributorSummary(
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Wholesale order summary
class WholesaleOrderSummary {
  final String distributorId;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double avgOrderValue;
  final Map<WholesaleOrderStatus, int> byStatus;

  const WholesaleOrderSummary({
    required this.distributorId,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.avgOrderValue,
    required this.byStatus,
  });
}
