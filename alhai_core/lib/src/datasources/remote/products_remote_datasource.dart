import '../../dto/products/create_product_request.dart';
import '../../dto/products/product_response.dart';
import '../../dto/products/update_product_request.dart';

/// Remote data source contract for products API calls
/// Repository ↔ DataSource = DTO only
abstract class ProductsRemoteDataSource {
  /// Gets paginated list of products for a store
  Future<List<ProductResponse>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  });

  /// Gets a single product by ID
  Future<ProductResponse> getProduct(String id);

  /// Gets a product by barcode
  Future<ProductResponse?> getByBarcode(String barcode);

  /// Creates a new product
  Future<ProductResponse> createProduct(CreateProductRequest request);

  /// Updates an existing product
  Future<ProductResponse> updateProduct(String id, UpdateProductRequest request);

  /// Deletes a product by ID
  Future<void> deleteProduct(String id);
}

