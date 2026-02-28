// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomersDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $CustomerAddressesTableTable get customerAddressesTable =>
      attachedDatabase.customerAddressesTable;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$CustomerAddressesTableTableTableManager get customerAddressesTable =>
      $$CustomerAddressesTableTableTableManager(
          _db.attachedDatabase, _db.customerAddressesTable);
}
