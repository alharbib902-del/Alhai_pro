import 'package:drift/drift.dart';

/// جدول التصنيفات المحلي
///
/// Indexes:
/// - idx_categories_store_id: للاستعلامات حسب المتجر
/// - idx_categories_parent_id: للاستعلامات حسب التصنيف الأب
/// - idx_categories_sort_order: للترتيب
/// - idx_categories_synced_at: للمزامنة
@TableIndex(name: 'idx_categories_store_id', columns: {#storeId})
@TableIndex(name: 'idx_categories_parent_id', columns: {#parentId})
@TableIndex(name: 'idx_categories_sort_order', columns: {#sortOrder})
@TableIndex(name: 'idx_categories_synced_at', columns: {#syncedAt})
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();

  // البيانات الأساسية
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();

  // الترتيب والحالة
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
