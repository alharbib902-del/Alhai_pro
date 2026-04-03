import 'package:alhai_core/alhai_core.dart';

import 'categories_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesDatasource _datasource;

  CategoriesRepositoryImpl(this._datasource);

  @override
  Future<List<Category>> getCategories(String storeId) =>
      _datasource.getCategories(storeId);

  @override
  Future<Category> getCategory(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getRootCategories(String storeId) =>
      _datasource.getRootCategories(storeId);

  @override
  Future<List<Category>> getChildCategories(String parentId) {
    throw UnimplementedError();
  }
}
