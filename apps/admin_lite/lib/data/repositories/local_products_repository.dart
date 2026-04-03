/// Local Products Repository
///
/// Provides read-focused access to products from the local Drift database.
/// Used by Admin Lite for monitoring and reporting (no write-heavy operations).
library;

import 'package:alhai_core/alhai_core.dart';
import 'package:drift/drift.dart';
import 'package:alhai_database/alhai_database.dart';

/// Local implementation of ProductsRepository
class LocalProductsRepository implements ProductsRepository {
  final AppDatabase _db;

  LocalProductsRepository(this._db);

  /// Convert from Drift Data to Domain Model
  Product _toProduct(ProductsTableData data) {
    return Product(
      id: data.id,
      storeId: data.storeId,
      name: data.name,
      sku: data.sku,
      barcode: data.barcode,
      price: data.price,
      costPrice: data.costPrice,
      stockQty: data.stockQty,
      minQty: data.minQty,
      unit: data.unit,
      description: data.description,
      imageThumbnail: data.imageThumbnail,
      imageMedium: data.imageMedium,
      imageLarge: data.imageLarge,
      imageHash: data.imageHash,
      categoryId: data.categoryId,
      isActive: data.isActive,
      trackInventory: data.trackInventory,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) async {
    final offset = (page - 1) * limit;

    final total = await _db.productsDao.getProductsCount(
      storeId,
      categoryId: categoryId,
      activeOnly: true,
    );

    final List<ProductsTableData> paginatedData;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      paginatedData = await _db.productsDao.searchProductsPaginated(
        searchQuery,
        storeId,
        offset: offset,
        limit: limit,
      );
    } else {
      paginatedData = await _db.productsDao.getProductsPaginated(
        storeId,
        offset: offset,
        limit: limit,
        categoryId: categoryId,
        activeOnly: true,
      );
    }

    final products = paginatedData.map(_toProduct).toList();

    return Paginated(
      items: products,
      total: total,
      page: page,
      limit: limit,
      hasMore: offset + products.length < total,
    );
  }

  @override
  Future<Product> getProduct(String id) async {
    final data = await _db.productsDao.getProductById(id);
    if (data == null) {
      throw NotFoundException('Product not found: $id');
    }
    return _toProduct(data);
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    const storeId = 'store_demo_001';
    final data = await _db.productsDao.getProductByBarcode(barcode, storeId);
    return data != null ? _toProduct(data) : null;
  }

  @override
  Future<Product> createProduct(CreateProductParams params) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final companion = ProductsTableCompanion.insert(
      id: id,
      storeId: params.storeId,
      name: params.name,
      barcode: Value(params.barcode),
      price: params.price,
      description: Value(params.description),
      imageThumbnail: Value(params.imageUrl),
      categoryId: Value(params.categoryId),
      isActive: Value(params.available),
      createdAt: now,
    );

    await _db.productsDao.insertProduct(companion);

    return getProduct(id);
  }

  @override
  Future<Product> updateProduct(UpdateProductParams params) async {
    final existing = await _db.productsDao.getProductById(params.id);
    if (existing == null) {
      throw NotFoundException('Product not found: ${params.id}');
    }

    final updated = existing.copyWith(
      name: params.name ?? existing.name,
      barcode: Value(params.barcode ?? existing.barcode),
      price: params.price ?? existing.price,
      description: Value(params.description ?? existing.description),
      imageThumbnail: Value(params.imageUrl ?? existing.imageThumbnail),
      categoryId: Value(params.categoryId ?? existing.categoryId),
      isActive: params.available ?? existing.isActive,
      updatedAt: Value(DateTime.now()),
    );

    await _db.productsDao.updateProduct(updated);

    return _toProduct(updated);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.productsDao.deleteProduct(id);
  }

  // ============================================================================
  // ADDITIONAL LOCAL METHODS
  // ============================================================================

  /// Search products
  Future<List<Product>> searchProducts(String query, String storeId) async {
    final results = await _db.productsDao.searchProducts(query, storeId);
    return results.map(_toProduct).toList();
  }

  /// Low stock products
  Future<List<Product>> getLowStockProducts(String storeId) async {
    final results = await _db.productsDao.getLowStockProducts(storeId);
    return results.map(_toProduct).toList();
  }

  /// Products by category
  Future<List<Product>> getProductsByCategory(
      String categoryId, String storeId) async {
    final results =
        await _db.productsDao.getProductsByCategory(categoryId, storeId);
    return results.map(_toProduct).toList();
  }

  /// Watch products (Stream)
  Stream<List<Product>> watchProducts(String storeId) {
    return _db.productsDao
        .watchProducts(storeId)
        .map((list) => list.map(_toProduct).toList());
  }

  /// Update stock quantity
  Future<void> updateStock(String productId, double newQty) async {
    await _db.productsDao.updateStock(productId, newQty);
  }
}
