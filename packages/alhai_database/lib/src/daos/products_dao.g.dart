// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  ProductsDaoManager get managers => ProductsDaoManager(this);
}

class ProductsDaoManager {
  final _$ProductsDaoMixin _db;
  ProductsDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
}
