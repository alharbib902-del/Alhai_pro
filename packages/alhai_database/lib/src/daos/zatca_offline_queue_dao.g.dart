// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zatca_offline_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$ZatcaOfflineQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $ZatcaOfflineQueueTableTable get zatcaOfflineQueueTable =>
      attachedDatabase.zatcaOfflineQueueTable;
  $ZatcaDeadLetterTableTable get zatcaDeadLetterTable =>
      attachedDatabase.zatcaDeadLetterTable;
  ZatcaOfflineQueueDaoManager get managers => ZatcaOfflineQueueDaoManager(this);
}

class ZatcaOfflineQueueDaoManager {
  final _$ZatcaOfflineQueueDaoMixin _db;
  ZatcaOfflineQueueDaoManager(this._db);
  $$ZatcaOfflineQueueTableTableTableManager get zatcaOfflineQueueTable =>
      $$ZatcaOfflineQueueTableTableTableManager(
          _db.attachedDatabase, _db.zatcaOfflineQueueTable);
  $$ZatcaDeadLetterTableTableTableManager get zatcaDeadLetterTable =>
      $$ZatcaDeadLetterTableTableTableManager(
          _db.attachedDatabase, _db.zatcaDeadLetterTable);
}
