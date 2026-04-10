import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeSuppliersRepo implements SuppliersRepository {
  @override Future<Paginated<Supplier>> getSuppliers(String storeId, {bool? activeOnly, int page = 1, int limit = 20}) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override Future<Supplier> getSupplier(String id) async => throw UnimplementedError();
  @override Future<Supplier> createSupplier(CreateSupplierParams params) async => throw UnimplementedError();
  @override Future<Supplier> updateSupplier(String id, UpdateSupplierParams params) async => throw UnimplementedError();
  @override Future<void> deleteSupplier(String id) async {}
  @override Future<List<Supplier>> getSuppliersWithBalance(String storeId) async => [];
}

class FakePurchasesRepo implements PurchasesRepository {
  @override Future<PurchaseOrder> createPurchaseOrder(CreatePurchaseOrderParams params) async => throw UnimplementedError();
  @override Future<Paginated<PurchaseOrder>> getPurchaseOrders(String storeId, {String? supplierId, PurchaseOrderStatus? status, int page = 1, int limit = 20}) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override Future<PurchaseOrder> getPurchaseOrder(String id) async => throw UnimplementedError();
  @override Future<PurchaseOrder> updatePurchaseOrder(String id, UpdatePurchaseOrderParams params) async => throw UnimplementedError();
  @override Future<PurchaseOrder> receiveItems(String purchaseId, List<ReceivedItem> items) async => throw UnimplementedError();
  @override Future<void> cancelPurchaseOrder(String id, {String? reason}) async {}
  @override Future<PurchaseOrder> recordPayment(String id, double amount) async => throw UnimplementedError();
}

void main() {
  late SupplierService supplierService;
  setUp(() { supplierService = SupplierService(FakeSuppliersRepo(), FakePurchasesRepo()); });

  group('SupplierService', () {
    test('should be created', () { expect(supplierService, isNotNull); });
    test('getSuppliers should return paginated', () async {
      final result = await supplierService.getSuppliers('store-1');
      expect(result, isA<Paginated<Supplier>>());
    });
    test('getSuppliersWithBalance should return list', () async {
      final suppliers = await supplierService.getSuppliersWithBalance('store-1');
      expect(suppliers, isA<List<Supplier>>());
    });
    test('deleteSupplier should not throw', () async {
      await supplierService.deleteSupplier('sup-1');
    });
    test('getPurchaseOrders should return paginated', () async {
      final result = await supplierService.getPurchaseOrders('store-1');
      expect(result, isA<Paginated<PurchaseOrder>>());
    });
    test('cancelPurchaseOrder should not throw', () async {
      await supplierService.cancelPurchaseOrder('po-1');
    });
  });
}
