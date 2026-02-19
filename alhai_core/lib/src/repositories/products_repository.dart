import '../models/create_product_params.dart';
import '../models/paginated.dart';
import '../models/product.dart';
import '../models/update_product_params.dart';

/// Repository contract for product operations (v3.3)
/// UI ↔ Repository = Domain Models only
abstract class ProductsRepository {
  /// Gets paginated list of products for a store
  ///
  /// [categoryId] - فلترة حسب التصنيف (اختياري)
  /// [searchQuery] - البحث في اسم المنتج (اختياري)
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  });

  /// Gets a single product by ID
  Future<Product> getProduct(String id);

  /// Gets a product by barcode (null if not found)
  Future<Product?> getByBarcode(String barcode);

  /// Creates a new product
  Future<Product> createProduct(CreateProductParams params);

  /// Updates an existing product
  Future<Product> updateProduct(UpdateProductParams params);

  /// Deletes a product by ID
  Future<void> deleteProduct(String id);
}
