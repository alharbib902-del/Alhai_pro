/// Local Categories Repository
///
/// Provides access to categories from the local database (Drift)
/// instead of external API - offline-first for Cashier app
library;

import 'package:alhai_core/alhai_core.dart';

import 'package:alhai_database/alhai_database.dart';

/// Local implementation of CategoriesRepository
class LocalCategoriesRepository implements CategoriesRepository {
  final AppDatabase _db;

  LocalCategoriesRepository(this._db);

  /// Convert from Drift Data to Domain Model
  Category _toCategory(CategoriesTableData data) {
    return Category(
      id: data.id,
      name: data.name,
      parentId: data.parentId,
      imageUrl: data.imageUrl,
      sortOrder: data.sortOrder,
      isActive: data.isActive,
    );
  }

  @override
  Future<List<Category>> getCategories(String storeId) async {
    final results = await _db.categoriesDao.getAllCategories(storeId);
    return results.map(_toCategory).toList();
  }

  @override
  Future<Category> getCategory(String id) async {
    final data = await _db.categoriesDao.getCategoryById(id);
    if (data == null) {
      throw NotFoundException('Category not found: $id');
    }
    return _toCategory(data);
  }

  @override
  Future<List<Category>> getRootCategories(String storeId) async {
    final results = await _db.categoriesDao.getRootCategories(storeId);
    return results.map(_toCategory).toList();
  }

  @override
  Future<List<Category>> getChildCategories(String parentId) async {
    final parent = await _db.categoriesDao.getCategoryById(parentId);
    if (parent == null) {
      return [];
    }
    final results =
        await _db.categoriesDao.getSubCategories(parentId, parent.storeId);
    return results.map(_toCategory).toList();
  }

  // ============================================================================
  // ADDITIONAL LOCAL METHODS
  // ============================================================================

  /// Subcategories with storeId
  Future<List<Category>> getSubCategories(
      String parentId, String storeId) async {
    final results =
        await _db.categoriesDao.getSubCategories(parentId, storeId);
    return results.map(_toCategory).toList();
  }

  /// Watch categories (Stream)
  Stream<List<Category>> watchCategories(String storeId) {
    return _db.categoriesDao
        .watchCategories(storeId)
        .map((list) => list.map(_toCategory).toList());
  }

  /// Categories count
  Future<int> getCategoriesCount(String storeId) async {
    return _db.categoriesDao.getCategoriesCount(storeId);
  }
}
