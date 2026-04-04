import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة المنتجات والمخزون
/// متوافقة مع ProductsRepository و InventoryRepository من alhai_core
class ProductService {
  final ProductsRepository _productsRepo;
  final InventoryRepository _inventoryRepo;
  final CategoriesRepository _categoriesRepo;

  ProductService(
    this._productsRepo,
    this._inventoryRepo,
    this._categoriesRepo,
  );

  /// الحصول على قائمة المنتجات
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _productsRepo.getProducts(storeId, page: page, limit: limit);
  }

  /// الحصول على منتج بالـ ID
  Future<Product> getProductById(String id) async {
    return await _productsRepo.getProduct(id);
  }

  /// الحصول على منتج بالباركود
  Future<Product?> getProductByBarcode(String barcode) async {
    return await _productsRepo.getByBarcode(barcode);
  }

  /// إضافة منتج جديد
  Future<Product> createProduct(CreateProductParams params) async {
    return await _productsRepo.createProduct(params);
  }

  /// تحديث منتج
  Future<Product> updateProduct(UpdateProductParams params) async {
    return await _productsRepo.updateProduct(params);
  }

  /// حذف منتج
  Future<void> deleteProduct(String id) async {
    await _productsRepo.deleteProduct(id);
  }

  /// تعديل المخزون
  Future<StockAdjustment> adjustStock({
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required double quantity,
    String? reason,
    String? referenceId,
  }) async {
    return await _inventoryRepo.adjustStock(
      productId: productId,
      storeId: storeId,
      type: type,
      quantity: quantity,
      reason: reason,
      referenceId: referenceId,
    );
  }

  /// الحصول على المنتجات منخفضة المخزون
  Future<List<LowStockProduct>> getLowStockProducts(String storeId) async {
    return await _inventoryRepo.getLowStockProducts(storeId);
  }

  /// الحصول على معرفات المنتجات غير المتوفرة
  Future<List<String>> getOutOfStockProductIds(String storeId) async {
    return await _inventoryRepo.getOutOfStockProductIds(storeId);
  }

  /// الحصول على تعديلات المخزون لمنتج
  Future<Paginated<StockAdjustment>> getProductAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _inventoryRepo.getAdjustments(
      productId,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على الفئات
  Future<List<Category>> getCategories(String storeId) async {
    return await _categoriesRepo.getCategories(storeId);
  }
}
