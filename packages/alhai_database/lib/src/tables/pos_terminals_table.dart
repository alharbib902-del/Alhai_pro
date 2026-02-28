import 'package:drift/drift.dart';

@TableIndex(name: 'idx_pos_terminals_store_id', columns: {#storeId})
@TableIndex(name: 'idx_pos_terminals_org_id', columns: {#orgId})
@TableIndex(name: 'idx_pos_terminals_status', columns: {#status})
@TableIndex(name: 'idx_pos_terminals_is_active', columns: {#isActive})
class PosTerminalsTable extends Table {
  @override
  String get tableName => 'pos_terminals';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get orgId => text()();
  TextColumn get name => text()();
  IntColumn get terminalNumber => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get osVersion => text().nullable()();
  TextColumn get appVersion => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get currentShiftId => text().nullable()();
  TextColumn get currentUserId => text().nullable()();
  DateTimeColumn get lastHeartbeatAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get settings => text().withDefault(const Constant('{}'))();
  TextColumn get receiptHeader => text().nullable()();
  TextColumn get receiptFooter => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
