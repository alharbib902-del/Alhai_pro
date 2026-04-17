// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_terminals_dao.dart';

// ignore_for_file: type=lint
mixin _$PosTerminalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PosTerminalsTableTable get posTerminalsTable =>
      attachedDatabase.posTerminalsTable;
  PosTerminalsDaoManager get managers => PosTerminalsDaoManager(this);
}

class PosTerminalsDaoManager {
  final _$PosTerminalsDaoMixin _db;
  PosTerminalsDaoManager(this._db);
  $$PosTerminalsTableTableTableManager get posTerminalsTable =>
      $$PosTerminalsTableTableTableManager(
        _db.attachedDatabase,
        _db.posTerminalsTable,
      );
}
