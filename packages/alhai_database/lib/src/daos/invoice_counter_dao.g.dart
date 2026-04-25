// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_counter_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoiceCounterDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $InvoiceCounterTableTable get invoiceCounterTable =>
      attachedDatabase.invoiceCounterTable;
  InvoiceCounterDaoManager get managers => InvoiceCounterDaoManager(this);
}

class InvoiceCounterDaoManager {
  final _$InvoiceCounterDaoMixin _db;
  InvoiceCounterDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$InvoiceCounterTableTableTableManager get invoiceCounterTable =>
      $$InvoiceCounterTableTableTableManager(
          _db.attachedDatabase, _db.invoiceCounterTable);
}
