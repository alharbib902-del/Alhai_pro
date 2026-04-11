import 'package:alhai_core/alhai_core.dart';

/// خدمة البحث الموحد
/// تستخدم من: cashier, admin_pos, customer_app
class SearchService {
  final ProductsRepository _productsRepo;
  final OrdersRepository _ordersRepo;
  final DebtsRepository _debtsRepo;

  SearchService(this._productsRepo, this._ordersRepo, this._debtsRepo);

  /// بحث سريع في المنتجات
  Future<List<Product>> searchProducts(
    String query, {
    required String storeId,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final result = await _productsRepo.getProducts(storeId, limit: limit);

    // Filter locally by name or barcode
    return result.items.where((product) {
      return product.name.contains(query) ||
          (product.barcode?.contains(query) ?? false) ||
          (product.sku?.contains(query) ?? false);
    }).toList();
  }

  /// بحث بالباركود
  Future<Product?> searchByBarcode(
    String barcode, {
    required String storeId,
  }) async {
    if (barcode.isEmpty) return null;

    try {
      return await _productsRepo.getByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  /// بحث في الطلبات
  Future<List<Order>> searchOrders(
    String query, {
    required String storeId,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    // Search by order number or customer name/phone
    final result = await _ordersRepo.getOrders(page: 1, limit: limit);

    // Filter locally
    return result.items.where((order) {
      return (order.orderNumber?.contains(query) ?? false) ||
          (order.customerName?.contains(query) ?? false) ||
          (order.customerPhone?.contains(query) ?? false);
    }).toList();
  }

  /// بحث في الديون
  Future<List<Debt>> searchDebts(
    String query, {
    required String storeId,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final result = await _debtsRepo.getDebts(storeId, page: 1, limit: limit);

    // Filter locally
    return result.items.where((debt) {
      return debt.partyName.contains(query) ||
          (debt.partyPhone?.contains(query) ?? false);
    }).toList();
  }

  /// بحث موحد
  Future<UnifiedSearchResult> search(
    String query, {
    required String storeId,
    int limit = 10,
  }) async {
    if (query.isEmpty) {
      return UnifiedSearchResult.empty();
    }

    final results = await Future.wait([
      searchProducts(query, storeId: storeId, limit: limit),
      searchOrders(query, storeId: storeId, limit: limit),
      searchDebts(query, storeId: storeId, limit: limit),
    ]);

    return UnifiedSearchResult(
      query: query,
      products: results[0] as List<Product>,
      orders: results[1] as List<Order>,
      debts: results[2] as List<Debt>,
    );
  }

  /// اقتراحات البحث (Auto-complete)
  Future<List<String>> getSuggestions(
    String query, {
    required String storeId,
    int limit = 5,
  }) async {
    if (query.length < 2) return [];

    final products = await searchProducts(
      query,
      storeId: storeId,
      limit: limit,
    );

    return products.map((p) => p.name).toList();
  }
}

/// نتيجة البحث الموحد
class UnifiedSearchResult {
  final String query;
  final List<Product> products;
  final List<Order> orders;
  final List<Debt> debts;

  const UnifiedSearchResult({
    required this.query,
    required this.products,
    required this.orders,
    required this.debts,
  });

  factory UnifiedSearchResult.empty() =>
      const UnifiedSearchResult(query: '', products: [], orders: [], debts: []);

  int get totalCount => products.length + orders.length + debts.length;
  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => !isEmpty;
}
