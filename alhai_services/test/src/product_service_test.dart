import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------
class FakeProductsRepository implements ProductsRepository {
  final List<Product> _products = [];

  void seed(List<Product> products) => _products.addAll(products);

  @override
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) async {
    final filtered = _products.where((p) => p.storeId == storeId).toList();
    return Paginated(
      items: filtered.take(limit).toList(),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Product> getProduct(String id) async =>
      _products.firstWhere((p) => p.id == id);

  @override
  Future<Product?> getByBarcode(String barcode) async {
    final matches = _products.where((p) => p.barcode == barcode);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<Product> createProduct(CreateProductParams params) async {
    final product = Product(
      id: 'prod-${_products.length + 1}',
      storeId: params.storeId,
      name: params.name,
      price: params.price,
      barcode: params.barcode,
      stockQty: 0,
      categoryId: params.categoryId,
      isActive: true,
      createdAt: DateTime.now(),
    );
    _products.add(product);
    return product;
  }

  @override
  Future<Product> updateProduct(UpdateProductParams params) async {
    final idx = _products.indexWhere((p) => p.id == params.id);
    _products[idx] = _products[idx].copyWith(
      name: params.name ?? _products[idx].name,
      price: params.price ?? _products[idx].price,
    );
    return _products[idx];
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }
}

class FakeInventoryRepository implements InventoryRepository {
  @override
  Future<StockAdjustment> adjustStock({
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required double quantity,
    String? reason,
    String? referenceId,
  }) async {
    return StockAdjustment(
      id: 'adj-1',
      productId: productId,
      storeId: storeId,
      type: type,
      quantity: quantity,
      previousQty: 100,
      newQty: type == AdjustmentType.received ? 100 + quantity : 100 - quantity,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<LowStockProduct>> getLowStockProducts(String storeId) async {
    return [
      LowStockProduct(
        productId: 'prod-1',
        productName: 'Low Stock Item',
        currentQty: 2,
        minQty: 10,
      ),
    ];
  }

  @override
  Future<List<String>> getOutOfStockProductIds(String storeId) async =>
      ['prod-out-1', 'prod-out-2'];

  @override
  Future<Paginated<StockAdjustment>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    return Paginated(items: [], total: 0, page: page, limit: limit);
  }

  @override
  Future<Paginated<StockAdjustment>> getStoreAdjustments(
    String storeId, {
    AdjustmentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    return Paginated(items: [], total: 0, page: page, limit: limit);
  }
}

class FakeCategoriesRepository implements CategoriesRepository {
  @override
  Future<List<Category>> getCategories(String storeId) async {
    return [
      const Category(
        id: 'cat-1',
        name: 'Beverages',
      ),
    ];
  }

  @override
  Future<Category> getCategory(String id) async => throw UnimplementedError();

  @override
  Future<List<Category>> getRootCategories(String storeId) async => [];

  @override
  Future<List<Category>> getChildCategories(String parentId) async => [];
}

void main() {
  late ProductService productService;
  late FakeProductsRepository fakeProductsRepo;

  setUp(() {
    fakeProductsRepo = FakeProductsRepository();
    productService = ProductService(
      fakeProductsRepo,
      FakeInventoryRepository(),
      FakeCategoriesRepository(),
    );
  });

  group('ProductService', () {
    test('should be created', () {
      expect(productService, isNotNull);
    });

    group('getProducts', () {
      test('should return products for store', () async {
        fakeProductsRepo.seed([
          Product(
            id: 'p1',
            storeId: 'store-1',
            name: 'Coffee',
            price: 15.0,
            stockQty: 100,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        ]);

        final result = await productService.getProducts('store-1');
        expect(result.items, hasLength(1));
        expect(result.items.first.name, equals('Coffee'));
      });

      test('should return empty for unknown store', () async {
        final result = await productService.getProducts('unknown');
        expect(result.items, isEmpty);
      });
    });

    group('getProductByBarcode', () {
      test('should find product by barcode', () async {
        fakeProductsRepo.seed([
          Product(
            id: 'p1',
            storeId: 'store-1',
            name: 'Coffee',
            price: 15.0,
            barcode: '6281234567890',
            stockQty: 100,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        ]);

        final product =
            await productService.getProductByBarcode('6281234567890');
        expect(product, isNotNull);
        expect(product!.name, equals('Coffee'));
      });

      test('should return null for unknown barcode', () async {
        final product =
            await productService.getProductByBarcode('0000000000000');
        expect(product, isNull);
      });
    });

    group('createProduct', () {
      test('should create product', () async {
        final product = await productService.createProduct(
          CreateProductParams(
            storeId: 'store-1',
            name: 'New Product',
            price: 25.0,
          ),
        );

        expect(product.id, isNotEmpty);
        expect(product.name, equals('New Product'));
      });
    });

    group('getLowStockProducts', () {
      test('should return low stock products', () async {
        final products = await productService.getLowStockProducts('store-1');
        expect(products, isNotEmpty);
        expect(products.first.currentQty, lessThan(products.first.minQty));
      });
    });

    group('getOutOfStockProductIds', () {
      test('should return out-of-stock product IDs', () async {
        final ids = await productService.getOutOfStockProductIds('store-1');
        expect(ids, hasLength(2));
      });
    });

    group('adjustStock', () {
      test('should adjust stock', () async {
        final adj = await productService.adjustStock(
          productId: 'prod-1',
          storeId: 'store-1',
          type: AdjustmentType.received,
          quantity: 10,
          reason: 'Restock',
        );

        expect(adj.productId, equals('prod-1'));
        expect(adj.quantity, equals(10));
      });
    });

    group('getCategories', () {
      test('should return categories', () async {
        final categories = await productService.getCategories('store-1');
        expect(categories, isNotEmpty);
        expect(categories.first.name, equals('Beverages'));
      });
    });
  });
}
