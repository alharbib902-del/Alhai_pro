// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuditLogTableTable get auditLogTable => attachedDatabase.auditLogTable;
  AuditLogDaoManager get managers => AuditLogDaoManager(this);
}

class AuditLogDaoManager {
  final _$AuditLogDaoMixin _db;
  AuditLogDaoManager(this._db);
  $$AuditLogTableTableTableManager get auditLogTable =>
      $$AuditLogTableTableTableManager(_db.attachedDatabase, _db.auditLogTable);
}
