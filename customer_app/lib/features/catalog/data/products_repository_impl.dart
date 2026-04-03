import 'package:alhai_core/alhai_core.dart';

import 'products_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDatasource _datasource;

  ProductsRepositoryImpl(this._datasource);

  @override
  Future<Paginated<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
  }) => _datasource.getProducts(
    storeId,
    page: page,
    limit: limit,
    categoryId: categoryId,
    searchQuery: searchQuery,
  );

  @override
  Future<Product> getProduct(String id) => _datasource.getProduct(id);

  @override
  Future<Product?> getByBarcode(String barcode) {
    throw UnimplementedError('Not needed in customer app');
  }

  @override
  Future<Product> createProduct(CreateProductParams params) {
    throw UnimplementedError('Customers cannot create products');
  }

  @override
  Future<Product> updateProduct(UpdateProductParams params) {
    throw UnimplementedError('Customers cannot update products');
  }

  @override
  Future<void> deleteProduct(String id) {
    throw UnimplementedError('Customers cannot delete products');
  }
}
