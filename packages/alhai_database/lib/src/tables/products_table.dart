import 'package:drift/drift.dart';

import 'stores_table.dart';
import 'categories_table.dart';

/// جدول المنتجات المحلي
/// يتطابق مع Product model من alhai_core
///
/// Local-only columns (not synced to Supabase):
/// - [stockQty], [minQty]: managed locally; Supabase uses a separate inventory table
/// - [imageThumbnail], [imageMedium], [imageLarge], [imageHash]: local image cache
///   metadata; Supabase stores only the original image URL
/// - [trackInventory]: local POS setting, not present in Supabase products table
/// - [syncedAt], [deletedAt]: local sync bookkeeping columns
///
/// Indexes:
/// - idx_products_store_id: للاستعلامات حسب المتجر
/// - idx_products_barcode: للبحث السريع بالباركود
/// - idx_products_sku: للبحث بـ SKU
/// - idx_products_category_id: للفلترة حسب التصنيف
/// - idx_products_name: للبحث بالاسم
/// - idx_products_synced_at: للمزامنة
@TableIndex(name: 'idx_products_store_id', columns: {#storeId})
@TableIndex(name: 'idx_products_barcode', columns: {#barcode})
@TableIndex(name: 'idx_products_sku', columns: {#sku})
@TableIndex(name: 'idx_products_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_products_name', columns: {#name})
@TableIndex(name: 'idx_products_synced_at', columns: {#syncedAt})
@TableIndex(name: 'idx_products_is_active', columns: {#isActive})
@TableIndex(name: 'idx_products_store_barcode', columns: {#storeId, #barcode})
@TableIndex(name: 'idx_products_store_category_active', columns: {#storeId, #categoryId, #isActive})
class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().references(StoresTable, #id, onDelete: KeyAction.restrict)();

  // البيانات الأساسية
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();

  // الأسعار
  RealColumn get price => real()();
  RealColumn get costPrice => real().nullable()();

  // المخزون
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  IntColumn get minQty => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().nullable()();

  // الوصف
  TextColumn get description => text().nullable()();

  // الصور (Cloudflare R2)
  TextColumn get imageThumbnail => text().nullable()();
  TextColumn get imageMedium => text().nullable()();
  TextColumn get imageLarge => text().nullable()();
  TextColumn get imageHash => text().nullable()();

  // التصنيف والحالة
  TextColumn get categoryId => text().nullable().references(CategoriesTable, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(true))();

  // صور المنظمة المركزية (مشتركة بين الفروع)
  TextColumn get orgImageThumbnail => text().nullable()();
  TextColumn get orgImageMedium => text().nullable()();
  TextColumn get orgImageLarge => text().nullable()();
  TextColumn get orgImageHash => text().nullable()();

  // ربط بكتالوج المنظمة
  TextColumn get orgProductId => text().nullable()();

  // إعدادات الطلب الأونلاين
  BoolColumn get onlineAvailable => boolean().withDefault(const Constant(false))();
  RealColumn get onlineMaxQty => real().nullable()();
  RealColumn get onlineReservedQty => real().withDefault(const Constant(0))();
  RealColumn get minAlertQty => real().nullable()();
  BoolColumn get autoReorder => boolean().withDefault(const Constant(false))();
  RealColumn get reorderQty => real().nullable()();
  RealColumn get turnoverRate => real().nullable()();

  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
