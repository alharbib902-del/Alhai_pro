import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeProductsRepoForSearch implements ProductsRepository {
  final List<Product> _products = [];
  void seed(List<Product> products) => _products.addAll(products);

  @override
  Future<Paginated<Product>> getProducts(String storeId,
          {int page = 1,
          int limit = 20,
          String? categoryId,
          String? searchQuery}) async =>
      Paginated(
          items: _products.take(limit).toList(),
          total: _products.length,
          page: page,
          limit: limit);
  @override
  Future<Product> getProduct(String id) async => throw UnimplementedError();
  @override
  Future<Product?> getByBarcode(String barcode) async {
    final m = _products.where((p) => p.barcode == barcode);
    return m.isEmpty ? null : m.first;
  }

  @override
  Future<Product> createProduct(CreateProductParams params) async =>
      throw UnimplementedError();
  @override
  Future<Product> updateProduct(UpdateProductParams params) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteProduct(String id) async {}
}

class FakeOrdersRepoForSearch implements OrdersRepository {
  @override
  Future<Paginated<Order>> getOrders(
          {OrderStatus? status, int page = 1, int limit = 20}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Order> getOrder(String id) async => throw UnimplementedError();
  @override
  Future<Order> createOrder(CreateOrderParams params) async =>
      throw UnimplementedError();
  @override
  Future<Order> updateStatus(String id, OrderStatus status) async =>
      throw UnimplementedError();
  @override
  Future<void> cancelOrder(String id, {String? reason}) async {}
}

class FakeDebtsRepoForSearch implements DebtsRepository {
  @override
  Future<Paginated<Debt>> getDebts(String storeId,
          {DebtType? type,
          bool? overdueOnly,
          int page = 1,
          int limit = 20}) async =>
      Paginated(items: [], total: 0, page: page, limit: limit);
  @override
  Future<Debt> getDebt(String id) async => throw UnimplementedError();
  @override
  Future<List<Debt>> getPartyDebts(String partyId) async => [];
  @override
  Future<Debt> createDebt(CreateDebtParams params) async =>
      throw UnimplementedError();
  @override
  Future<DebtPayment> recordPayment(RecordPaymentParams params) async =>
      throw UnimplementedError();
  @override
  Future<List<DebtPayment>> getPayments(String debtId) async => [];
  @override
  Future<DebtSummary> getDebtSummary(String storeId) async =>
      throw UnimplementedError();
}

void main() {
  late SearchService searchService;
  late FakeProductsRepoForSearch fakeProductsRepo;

  setUp(() {
    fakeProductsRepo = FakeProductsRepoForSearch();
    searchService = SearchService(
        fakeProductsRepo, FakeOrdersRepoForSearch(), FakeDebtsRepoForSearch());
  });

  group('SearchService', () {
    test('should be created', () {
      expect(searchService, isNotNull);
    });

    test('searchProducts should return empty for empty query', () async {
      final results = await searchService.searchProducts('', storeId: 's1');
      expect(results, isEmpty);
    });

    test('searchProducts should find by name', () async {
      fakeProductsRepo.seed([
        Product(
            id: 'p1',
            storeId: 's1',
            name: 'Coffee Arabica',
            price: 15.0,
            stockQty: 100,
            isActive: true,
            createdAt: DateTime.now()),
      ]);
      final results =
          await searchService.searchProducts('Coffee', storeId: 's1');
      expect(results, hasLength(1));
    });

    test('searchByBarcode should return null for empty', () async {
      final result = await searchService.searchByBarcode('', storeId: 's1');
      expect(result, isNull);
    });

    test('searchOrders should return empty for empty query', () async {
      final results = await searchService.searchOrders('', storeId: 's1');
      expect(results, isEmpty);
    });

    test('searchDebts should return empty for empty query', () async {
      final results = await searchService.searchDebts('', storeId: 's1');
      expect(results, isEmpty);
    });

    test('search should return empty for empty query', () async {
      final result = await searchService.search('', storeId: 's1');
      expect(result.isEmpty, isTrue);
      expect(result.totalCount, equals(0));
    });

    test('getSuggestions should return empty for short query', () async {
      final suggestions =
          await searchService.getSuggestions('A', storeId: 's1');
      expect(suggestions, isEmpty);
    });

    test('UnifiedSearchResult.empty should return empty', () {
      final empty = UnifiedSearchResult.empty();
      expect(empty.isEmpty, isTrue);
      expect(empty.query, isEmpty);
    });
  });
}
