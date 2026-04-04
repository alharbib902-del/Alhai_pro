import 'package:drift/drift.dart';

/// جدول المنتجات المفضلة
@TableIndex(name: 'idx_favorites_store_id', columns: {#storeId})
@TableIndex(name: 'idx_favorites_product_id', columns: {#productId})
@TableIndex(
    name: 'idx_favorites_store_product_unique',
    columns: {#storeId, #productId},
    unique: true)
class FavoritesTable extends Table {
  @override
  String get tableName => 'favorites';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get orgId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
