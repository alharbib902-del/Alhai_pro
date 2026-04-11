import 'package:alhai_core/alhai_core.dart';

/// خدمة طلبات الجملة (B2B)
/// تستخدم من: distributor_portal, admin_pos
class WholesaleService {
  final WholesaleOrdersRepository _ordersRepo;

  WholesaleService(this._ordersRepo);

  // ==================== الطلبات ====================

  /// الحصول على طلب بالـ ID
  Future<WholesaleOrder> getOrder(String orderId) async {
    return await _ordersRepo.getOrder(orderId);
  }

  /// الحصول على طلبات الموزع
  Future<Paginated<WholesaleOrder>> getDistributorOrders(
    String distributorId, {
    int page = 1,
    int limit = 20,
    WholesaleOrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _ordersRepo.getDistributorOrders(
      distributorId,
      page: page,
      limit: limit,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// الحصول على طلبات المتجر
  Future<Paginated<WholesaleOrder>> getStoreOrders(
    String storeId, {
    int page = 1,
    int limit = 20,
    WholesaleOrderStatus? status,
  }) async {
    return await _ordersRepo.getStoreOrders(
      storeId,
      page: page,
      limit: limit,
      status: status,
    );
  }

  /// إنشاء طلب جملة جديد
  Future<WholesaleOrder> createOrder({
    required String distributorId,
    required String storeId,
    required List<WholesaleOrderItem> items,
    required WholesalePaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    DateTime? expectedDeliveryDate,
  }) async {
    return await _ordersRepo.createOrder(
      distributorId: distributorId,
      storeId: storeId,
      items: items,
      paymentMethod: paymentMethod,
      notes: notes,
      deliveryAddress: deliveryAddress,
      expectedDeliveryDate: expectedDeliveryDate,
    );
  }

  // ==================== إدارة حالة الطلب ====================

  /// تأكيد الطلب (الموزع)
  Future<WholesaleOrder> confirmOrder(String orderId) async {
    return await _ordersRepo.confirmOrder(orderId);
  }

  /// بدء معالجة الطلب (الموزع)
  Future<WholesaleOrder> startProcessing(String orderId) async {
    return await _ordersRepo.startProcessing(orderId);
  }

  /// شحن الطلب (الموزع)
  Future<WholesaleOrder> shipOrder(
    String orderId, {
    String? trackingNumber,
  }) async {
    return await _ordersRepo.shipOrder(orderId, trackingNumber: trackingNumber);
  }

  /// تسليم الطلب
  Future<WholesaleOrder> deliverOrder(String orderId) async {
    return await _ordersRepo.deliverOrder(orderId);
  }

  /// إلغاء الطلب
  Future<WholesaleOrder> cancelOrder(String orderId, String reason) async {
    return await _ordersRepo.cancelOrder(orderId, reason);
  }

  // ==================== الإحصائيات ====================

  /// ملخص طلبات الموزع
  Future<WholesaleOrderSummary> getDistributorSummary(
    String distributorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _ordersRepo.getDistributorSummary(
      distributorId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
