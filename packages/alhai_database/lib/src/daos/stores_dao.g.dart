// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stores_dao.dart';

// ignore_for_file: type=lint
mixin _$StoresDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  StoresDaoManager get managers => StoresDaoManager(this);
}

class StoresDaoManager {
  final _$StoresDaoMixin _db;
  StoresDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
}
