import '../../dto/categories/category_response.dart';

/// Remote data source contract for categories API calls
/// Repository ↔ DataSource = DTO only
abstract class CategoriesRemoteDataSource {
  /// Gets all categories for a store
  Future<List<CategoryResponse>> getCategories(String storeId);

  /// Gets a single category by ID
  Future<CategoryResponse> getCategory(String id);
}
