// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_dao.dart';

// ignore_for_file: type=lint
mixin _$OrdersDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $OrdersTableTable get ordersTable => attachedDatabase.ordersTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $OrderItemsTableTable get orderItemsTable => attachedDatabase.orderItemsTable;
  OrdersDaoManager get managers => OrdersDaoManager(this);
}

class OrdersDaoManager {
  final _$OrdersDaoMixin _db;
  OrdersDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
        _db.attachedDatabase,
        _db.customersTable,
      );
  $$OrdersTableTableTableManager get ordersTable =>
      $$OrdersTableTableTableManager(_db.attachedDatabase, _db.ordersTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$OrderItemsTableTableTableManager get orderItemsTable =>
      $$OrderItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.orderItemsTable,
      );
}
