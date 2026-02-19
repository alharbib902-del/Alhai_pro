import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

/// DAO للتصنيفات
@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// الحصول على جميع التصنيفات للمتجر
  Future<List<CategoriesTableData>> getAllCategories(String storeId) {
    return (select(categoriesTable)
          ..where((c) => c.storeId.equals(storeId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// الحصول على تصنيف بالمعرف
  Future<CategoriesTableData?> getCategoryById(String id) {
    return (select(categoriesTable)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// الحصول على التصنيفات الرئيسية (بدون parent)
  Future<List<CategoriesTableData>> getRootCategories(String storeId) {
    return (select(categoriesTable)
          ..where((c) =>
              c.storeId.equals(storeId) &
              c.parentId.isNull() &
              c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// الحصول على التصنيفات الفرعية
  Future<List<CategoriesTableData>> getSubCategories(
      String parentId, String storeId) {
    return (select(categoriesTable)
          ..where((c) =>
              c.storeId.equals(storeId) &
              c.parentId.equals(parentId) &
              c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// إدراج تصنيف
  Future<int> insertCategory(CategoriesTableCompanion category) {
    return into(categoriesTable).insert(category);
  }

  /// إدراج أو تحديث تصنيف
  Future<int> upsertCategory(CategoriesTableCompanion category) {
    return into(categoriesTable).insertOnConflictUpdate(category);
  }

  /// إدراج تصنيفات متعددة
  Future<void> insertCategories(List<CategoriesTableCompanion> categories) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(categoriesTable, categories);
    });
  }

  /// تحديث تصنيف
  Future<bool> updateCategory(CategoriesTableData category) {
    return update(categoriesTable).replace(category);
  }

  /// حذف تصنيف
  Future<int> deleteCategory(String id) {
    return (delete(categoriesTable)..where((c) => c.id.equals(id))).go();
  }

  /// حذف جميع التصنيفات للمتجر
  Future<int> deleteAllCategories(String storeId) {
    return (delete(categoriesTable)..where((c) => c.storeId.equals(storeId)))
        .go();
  }

  /// مراقبة التصنيفات (Stream)
  Stream<List<CategoriesTableData>> watchCategories(String storeId) {
    return (select(categoriesTable)
          ..where((c) => c.storeId.equals(storeId) & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// عدد التصنيفات
  Future<int> getCategoriesCount(String storeId) async {
    final count = categoriesTable.id.count();
    final query = selectOnly(categoriesTable)
      ..addColumns([count])
      ..where(categoriesTable.storeId.equals(storeId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
