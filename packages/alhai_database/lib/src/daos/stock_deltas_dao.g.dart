// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_deltas_dao.dart';

// ignore_for_file: type=lint
mixin _$StockDeltasDaoMixin on DatabaseAccessor<AppDatabase> {
  $StockDeltasTableTable get stockDeltasTable =>
      attachedDatabase.stockDeltasTable;
  StockDeltasDaoManager get managers => StockDeltasDaoManager(this);
}

class StockDeltasDaoManager {
  final _$StockDeltasDaoMixin _db;
  StockDeltasDaoManager(this._db);
  $$StockDeltasTableTableTableManager get stockDeltasTable =>
      $$StockDeltasTableTableTableManager(
        _db.attachedDatabase,
        _db.stockDeltasTable,
      );
}
