import 'package:drift/drift.dart';

/// جدول تتبع تواريخ صلاحية المنتجات
@TableIndex(name: 'idx_product_expiry_product_id', columns: {#productId})
@TableIndex(name: 'idx_product_expiry_store_id', columns: {#storeId})
@TableIndex(name: 'idx_product_expiry_expiry_date', columns: {#expiryDate})
class ProductExpiryTable extends Table {
  @override
  String get tableName => 'product_expiry';

  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get storeId => text()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expiryDate => dateTime()();
  IntColumn get quantity => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
