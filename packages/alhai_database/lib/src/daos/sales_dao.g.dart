// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_dao.dart';

// ignore_for_file: type=lint
mixin _$SalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $SalesTableTable get salesTable => attachedDatabase.salesTable;
  SalesDaoManager get managers => SalesDaoManager(this);
}

class SalesDaoManager {
  final _$SalesDaoMixin _db;
  SalesDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db.attachedDatabase, _db.salesTable);
}
