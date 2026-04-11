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
    return (select(
      categoriesTable,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// الحصول على التصنيفات الرئيسية (بدون parent)
  Future<List<CategoriesTableData>> getRootCategories(String storeId) {
    return (select(categoriesTable)
          ..where(
            (c) =>
                c.storeId.equals(storeId) &
                c.parentId.isNull() &
                c.isActive.equals(true),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// الحصول على التصنيفات الفرعية
  Future<List<CategoriesTableData>> getSubCategories(
    String parentId,
    String storeId,
  ) {
    return (select(categoriesTable)
          ..where(
            (c) =>
                c.storeId.equals(storeId) &
                c.parentId.equals(parentId) &
                c.isActive.equals(true),
          )
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
    return (delete(
      categoriesTable,
    )..where((c) => c.storeId.equals(storeId))).go();
  }

  /// التحقق من أن تعيين parentId لن يُنشئ حلقة
  /// H03: محسّن - يستخدم RECURSIVE CTE بدلاً من N+1 queries
  Future<bool> wouldCreateCycle(String categoryId, String newParentId) async {
    if (categoryId == newParentId) return true;

    final result = await customSelect(
      '''WITH RECURSIVE ancestors(id) AS (
           SELECT parent_id FROM categories WHERE id = ?
           UNION ALL
           SELECT c.parent_id FROM categories c
           INNER JOIN ancestors a ON c.id = a.id
           WHERE a.id IS NOT NULL
         )
         SELECT COUNT(*) as found FROM ancestors WHERE id = ?''',
      variables: [
        Variable.withString(newParentId),
        Variable.withString(categoryId),
      ],
      readsFrom: {categoriesTable},
    ).getSingle();

    return (result.data['found'] as int? ?? 0) > 0;
  }

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// تصنيفات مع عدد المنتجات
  Future<List<CategoryWithProductCount>> getCategoriesWithProductCount(
    String storeId,
  ) async {
    final result = await customSelect(
      '''SELECT c.*, COUNT(p.id) as product_count
         FROM categories c
         LEFT JOIN products p ON c.id = p.category_id
           AND p.is_active = 1 AND p.deleted_at IS NULL
         WHERE c.store_id = ? AND c.is_active = 1
         GROUP BY c.id
         ORDER BY c.sort_order ASC''',
      variables: [Variable.withString(storeId)],
      readsFrom: {categoriesTable},
    ).get();

    return result
        .map(
          (row) => CategoryWithProductCount(
            category: categoriesTable.map(row.data),
            productCount: row.data['product_count'] as int? ?? 0,
          ),
        )
        .toList();
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

/// تصنيف مع عدد المنتجات
class CategoryWithProductCount {
  final CategoriesTableData category;
  final int productCount;

  const CategoryWithProductCount({
    required this.category,
    required this.productCount,
  });
}
