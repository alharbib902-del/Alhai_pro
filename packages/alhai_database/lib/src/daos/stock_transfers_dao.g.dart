// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transfers_dao.dart';

// ignore_for_file: type=lint
mixin _$StockTransfersDaoMixin on DatabaseAccessor<AppDatabase> {
  $StockTransfersTableTable get stockTransfersTable =>
      attachedDatabase.stockTransfersTable;
  StockTransfersDaoManager get managers => StockTransfersDaoManager(this);
}

class StockTransfersDaoManager {
  final _$StockTransfersDaoMixin _db;
  StockTransfersDaoManager(this._db);
  $$StockTransfersTableTableTableManager get stockTransfersTable =>
      $$StockTransfersTableTableTableManager(
          _db.attachedDatabase, _db.stockTransfersTable);
}
