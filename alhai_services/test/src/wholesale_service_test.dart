import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeWholesaleOrdersRepo implements WholesaleOrdersRepository {
  @override
  Future<WholesaleOrder> getOrder(String orderId) async =>
      throw UnimplementedError();
  @override
  Future<Paginated<WholesaleOrder>> getDistributorOrders(String distributorId,
          {int page = 1,
          int limit = 20,
          WholesaleOrderStatus? status,
          DateTime? startDate,
          DateTime? endDate}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Paginated<WholesaleOrder>> getStoreOrders(String storeId,
          {int page = 1, int limit = 20, WholesaleOrderStatus? status}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<WholesaleOrder> createOrder(
          {required String distributorId,
          required String storeId,
          required List<WholesaleOrderItem> items,
          required WholesalePaymentMethod paymentMethod,
          String? notes,
          String? deliveryAddress,
          DateTime? expectedDeliveryDate}) async =>
      WholesaleOrder(
          id: 'wo-1',
          orderNumber: 'WO-0001',
          distributorId: distributorId,
          storeId: storeId,
          storeName: 'Test Store',
          items: items,
          paymentMethod: paymentMethod,
          status: WholesaleOrderStatus.pending,
          subtotal: 100.0,
          total: 100.0,
          createdAt: DateTime.now());
  @override
  Future<WholesaleOrder> confirmOrder(String orderId) async =>
      throw UnimplementedError();
  @override
  Future<WholesaleOrder> startProcessing(String orderId) async =>
      throw UnimplementedError();
  @override
  Future<WholesaleOrder> shipOrder(String orderId,
          {String? trackingNumber}) async =>
      throw UnimplementedError();
  @override
  Future<WholesaleOrder> deliverOrder(String orderId) async =>
      throw UnimplementedError();
  @override
  Future<WholesaleOrder> cancelOrder(String orderId, String reason) async =>
      throw UnimplementedError();
  @override
  Future<WholesaleOrderSummary> getDistributorSummary(String distributorId,
          {DateTime? startDate, DateTime? endDate}) async =>
      WholesaleOrderSummary(
          distributorId: distributorId,
          totalOrders: 10,
          pendingOrders: 2,
          completedOrders: 7,
          cancelledOrders: 1,
          totalRevenue: 5000.0,
          avgOrderValue: 500.0,
          byStatus: {});
}

void main() {
  late WholesaleService wholesaleService;
  setUp(() {
    wholesaleService = WholesaleService(FakeWholesaleOrdersRepo());
  });

  group('WholesaleService', () {
    test('should be created', () {
      expect(wholesaleService, isNotNull);
    });

    test('createOrder should create wholesale order', () async {
      final order = await wholesaleService.createOrder(
        distributorId: 'dist-1',
        storeId: 'store-1',
        items: [
          WholesaleOrderItem(
              productId: 'p1',
              productName: 'Beans',
              quantity: 100,
              unitPrice: 50.0,
              totalPrice: 5000.0)
        ],
        paymentMethod: WholesalePaymentMethod.bankTransfer,
      );
      expect(order.status, equals(WholesaleOrderStatus.pending));
      expect(order.total, equals(100.0));
    });

    test('getDistributorOrders should return paginated', () async {
      final result = await wholesaleService.getDistributorOrders('dist-1');
      expect(result, isA<Paginated<WholesaleOrder>>());
    });

    test('getStoreOrders should return paginated', () async {
      final result = await wholesaleService.getStoreOrders('store-1');
      expect(result, isA<Paginated<WholesaleOrder>>());
    });

    test('getDistributorSummary should return summary', () async {
      final summary = await wholesaleService.getDistributorSummary('dist-1');
      expect(summary.totalOrders, equals(10));
      expect(summary.totalRevenue, equals(5000.0));
    });
  });
}
