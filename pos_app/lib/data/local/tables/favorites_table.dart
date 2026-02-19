import 'package:drift/drift.dart';

/// جدول المنتجات المفضلة
@TableIndex(name: 'idx_favorites_store_id', columns: {#storeId})
@TableIndex(name: 'idx_favorites_product_id', columns: {#productId})
class FavoritesTable extends Table {
  @override
  String get tableName => 'favorites';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
