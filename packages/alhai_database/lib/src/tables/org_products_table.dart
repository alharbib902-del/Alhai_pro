import 'package:drift/drift.dart';

import 'organizations_table.dart';
import 'categories_table.dart';

/// كتالوج منتجات المنظمة المركزي
/// صور وبيانات افتراضية مشتركة بين كل فروع المنظمة
/// كل فرع (store) يمكنه تخصيص السعر والصورة والمخزون
///
/// العلاقة: org_products (1) → products (N) عبر org_product_id
@TableIndex(name: 'idx_org_products_org_id', columns: {#orgId})
@TableIndex(name: 'idx_org_products_sku', columns: {#sku})
@TableIndex(name: 'idx_org_products_barcode', columns: {#barcode})
@TableIndex(name: 'idx_org_products_category', columns: {#categoryId})
class OrgProductsTable extends Table {
  @override
  String get tableName => 'org_products';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().references(OrganizationsTable, #id)();

  // البيانات الأساسية
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get description => text().nullable()();

  // الأسعار الافتراضية
  RealColumn get defaultPrice => real()();
  RealColumn get costPrice => real().nullable()();

  // التصنيف
  TextColumn get categoryId => text().nullable().references(CategoriesTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get unit => text().nullable()();

  // صور المنظمة (الافتراضية لكل الفروع)
  TextColumn get orgImageThumbnail => text().nullable()();
  TextColumn get orgImageMedium => text().nullable()();
  TextColumn get orgImageLarge => text().nullable()();
  TextColumn get orgImageHash => text().nullable()();

  // إعدادات أونلاين افتراضية
  BoolColumn get onlineAvailable => boolean().withDefault(const Constant(false))();
  RealColumn get onlineMaxQty => real().nullable()();
  RealColumn get minAlertQty => real().nullable()();
  BoolColumn get autoReorder => boolean().withDefault(const Constant(false))();
  RealColumn get reorderQty => real().nullable()();

  // الحالة
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
