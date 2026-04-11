/// No separate InventoryService exists in the codebase.
/// Inventory operations are handled by ProductService via InventoryRepository.
/// This file tests the inventory-related methods of ProductService.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeProductsRepoForInventory implements ProductsRepository {
  @override
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Product> getProduct(String id) async => throw UnimplementedError();
  @override
  Future<Product?> getByBarcode(String barcode) async => null;
  @override
  Future<Product> createProduct(CreateProductParams params) async =>
      throw UnimplementedError();
  @override
  Future<Product> updateProduct(UpdateProductParams params) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteProduct(String id) async {}
}

class FakeInventoryRepoForTest implements InventoryRepository {
  final List<StockAdjustment> _adjustments = [];

  @override
  Future<StockAdjustment> adjustStock({
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required double quantity,
    String? reason,
    String? referenceId,
  }) async {
    final adj = StockAdjustment(
      id: 'adj-${_adjustments.length + 1}',
      productId: productId,
      storeId: storeId,
      type: type,
      quantity: quantity,
      previousQty: 100,
      newQty: 100 + quantity,
      reason: reason,
      referenceId: referenceId,
      createdAt: DateTime.now(),
    );
    _adjustments.add(adj);
    return adj;
  }

  @override
  Future<List<LowStockProduct>> getLowStockProducts(String storeId) async => [
    LowStockProduct(
      productId: 'p1',
      productName: 'Low A',
      currentQty: 3,
      minQty: 10,
    ),
    LowStockProduct(
      productId: 'p2',
      productName: 'Low B',
      currentQty: 1,
      minQty: 5,
    ),
  ];

  @override
  Future<List<String>> getOutOfStockProductIds(String storeId) async => [
    'p-out-1',
    'p-out-2',
    'p-out-3',
  ];

  @override
  Future<Paginated<StockAdjustment>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    final filtered = _adjustments
        .where((a) => a.productId == productId)
        .toList();
    return Paginated(
      items: filtered.take(limit).toList(),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Paginated<StockAdjustment>> getStoreAdjustments(
    String storeId, {
    AdjustmentType? type,
    int page = 1,
    int limit = 20,
  }) async => Paginated(items: [], total: 0, page: page, limit: limit);
}

class FakeCategoriesRepoForInventory implements CategoriesRepository {
  @override
  Future<List<Category>> getCategories(String storeId) async => [];
  @override
  Future<Category> getCategory(String id) async => throw UnimplementedError();
  @override
  Future<List<Category>> getRootCategories(String storeId) async => [];
  @override
  Future<List<Category>> getChildCategories(String parentId) async => [];
}

void main() {
  late ProductService productService;
  late FakeInventoryRepoForTest fakeInventoryRepo;

  setUp(() {
    fakeInventoryRepo = FakeInventoryRepoForTest();
    productService = ProductService(
      FakeProductsRepoForInventory(),
      fakeInventoryRepo,
      FakeCategoriesRepoForInventory(),
    );
  });

  group('Inventory operations (via ProductService)', () {
    test('adjustStock should create adjustment', () async {
      final adj = await productService.adjustStock(
        productId: 'prod-1',
        storeId: 'store-1',
        type: AdjustmentType.received,
        quantity: 50,
        reason: 'Received shipment',
      );
      expect(adj.productId, equals('prod-1'));
      expect(adj.quantity, equals(50));
    });

    test(
      'getLowStockProducts should return below-threshold products',
      () async {
        final products = await productService.getLowStockProducts('store-1');
        expect(products, hasLength(2));
        for (final p in products) {
          expect(p.currentQty, lessThan(p.minQty));
        }
      },
    );

    test('getOutOfStockProductIds should return IDs', () async {
      final ids = await productService.getOutOfStockProductIds('store-1');
      expect(ids, hasLength(3));
    });

    test('getProductAdjustments should return for specific product', () async {
      await productService.adjustStock(
        productId: 'prod-1',
        storeId: 's1',
        type: AdjustmentType.received,
        quantity: 10,
      );
      await productService.adjustStock(
        productId: 'prod-2',
        storeId: 's1',
        type: AdjustmentType.received,
        quantity: 20,
      );
      final result = await productService.getProductAdjustments('prod-1');
      expect(result.items, hasLength(1));
    });

    test('getProductAdjustments should return empty for unknown', () async {
      final result = await productService.getProductAdjustments('unknown');
      expect(result.items, isEmpty);
    });
  });
}
