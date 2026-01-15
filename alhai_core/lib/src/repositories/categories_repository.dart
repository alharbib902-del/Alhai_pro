import '../models/category.dart';

/// Repository contract for category operations
/// UI ↔ Repository = Domain Models only
abstract class CategoriesRepository {
  /// Gets all categories for a store
  Future<List<Category>> getCategories(String storeId);

  /// Gets a single category by ID
  Future<Category> getCategory(String id);

  /// Gets root categories (no parent)
  Future<List<Category>> getRootCategories(String storeId);

  /// Gets child categories of a parent
  Future<List<Category>> getChildCategories(String parentId);
}
