// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationsTableTable get notificationsTable =>
      attachedDatabase.notificationsTable;
  NotificationsDaoManager get managers => NotificationsDaoManager(this);
}

class NotificationsDaoManager {
  final _$NotificationsDaoMixin _db;
  NotificationsDaoManager(this._db);
  $$NotificationsTableTableTableManager get notificationsTable =>
      $$NotificationsTableTableTableManager(
          _db.attachedDatabase, _db.notificationsTable);
}
