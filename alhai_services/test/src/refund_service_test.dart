import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeRefundsRepository implements RefundsRepository {
  @override Future<Refund> createRefund({required String originalSaleId, required String storeId, required String cashierId, String? customerId, required RefundReason reason, required RefundMethod method, required List<RefundItem> items, String? notes, String? supervisorId}) async => throw UnimplementedError();
  @override Future<Refund> getRefund(String id) async => throw UnimplementedError();
  @override Future<Paginated<Refund>> getStoreRefunds(String storeId, {RefundStatus? status, String? cashierId, DateTime? startDate, DateTime? endDate, int page = 1, int limit = 20}) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override Future<Refund> approveRefund(String refundId, String supervisorId) async => throw UnimplementedError();
  @override Future<Refund> rejectRefund(String refundId, String supervisorId, String reason) async => throw UnimplementedError();
  @override Future<Refund> completeRefund(String refundId) async => throw UnimplementedError();
  @override Future<RefundsSummary> getStoreSummary(String storeId, {DateTime? startDate, DateTime? endDate}) async => RefundsSummary(storeId: storeId, totalRefundedAmount: 500.0, totalRefundCount: 5, pendingCount: 2, byReason: {}, byMethod: {});
  @override Future<OriginalSaleInfo?> findOriginalSale(String receiptNumber) async => receiptNumber == 'POS-0001' ? OriginalSaleInfo(saleId: 'sale-1', receiptNumber: 'POS-0001', saleDate: DateTime(2026,3,15), totalAmount: 100.0, items: [], alreadyRefundedAmount: 0) : null;
}

void main() {
  late RefundService refundService;
  setUp(() { refundService = RefundService(FakeRefundsRepository()); });

  group('RefundService', () {
    test('should be created', () { expect(refundService, isNotNull); });
    test('getStoreRefunds should return paginated', () async {
      final result = await refundService.getStoreRefunds('store-1');
      expect(result, isA<Paginated<Refund>>());
    });
    test('getPendingRefunds should return paginated', () async {
      final result = await refundService.getPendingRefunds('store-1');
      expect(result, isA<Paginated<Refund>>());
    });
    test('getStoreSummary should return summary', () async {
      final summary = await refundService.getStoreSummary('store-1');
      expect(summary.totalRefundCount, equals(5));
      expect(summary.totalRefundedAmount, equals(500.0));
    });
    test('findOriginalSale should find existing sale', () async {
      final sale = await refundService.findOriginalSale('POS-0001');
      expect(sale, isNotNull);
      expect(sale!.receiptNumber, equals('POS-0001'));
    });
    test('findOriginalSale should return null for unknown', () async {
      final sale = await refundService.findOriginalSale('UNKNOWN');
      expect(sale, isNull);
    });
  });
}
