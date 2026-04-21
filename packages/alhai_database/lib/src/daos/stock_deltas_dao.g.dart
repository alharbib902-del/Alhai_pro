// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_deltas_dao.dart';

// ignore_for_file: type=lint
mixin _$StockDeltasDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $StockDeltasTableTable get stockDeltasTable =>
      attachedDatabase.stockDeltasTable;
  StockDeltasDaoManager get managers => StockDeltasDaoManager(this);
}

class StockDeltasDaoManager {
  final _$StockDeltasDaoMixin _db;
  StockDeltasDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
          _db.attachedDatabase, _db.categoriesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$StockDeltasTableTableTableManager get stockDeltasTable =>
      $$StockDeltasTableTableTableManager(
          _db.attachedDatabase, _db.stockDeltasTable);
}
