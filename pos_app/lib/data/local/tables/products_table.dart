import 'package:drift/drift.dart';

/// جدول المنتجات المحلي
/// يتطابق مع Product model من alhai_core
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
class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  
  // البيانات الأساسية
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  
  // الأسعار
  RealColumn get price => real()();
  RealColumn get costPrice => real().nullable()();
  
  // المخزون
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  IntColumn get minQty => integer().withDefault(const Constant(1))();
  TextColumn get unit => text().nullable()();
  
  // الوصف
  TextColumn get description => text().nullable()();
  
  // الصور (Cloudflare R2)
  TextColumn get imageThumbnail => text().nullable()();
  TextColumn get imageMedium => text().nullable()();
  TextColumn get imageLarge => text().nullable()();
  TextColumn get imageHash => text().nullable()();
  
  // التصنيف والحالة
  TextColumn get categoryId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(true))();
  
  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
