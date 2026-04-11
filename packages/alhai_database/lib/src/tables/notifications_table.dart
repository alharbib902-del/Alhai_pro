import 'package:drift/drift.dart';

/// جدول الإشعارات
@TableIndex(name: 'idx_notifications_store_id', columns: {#storeId})
@TableIndex(name: 'idx_notifications_user_id', columns: {#userId})
@TableIndex(name: 'idx_notifications_is_read', columns: {#isRead})
@TableIndex(name: 'idx_notifications_created_at', columns: {#createdAt})
class NotificationsTable extends Table {
  @override
  String get tableName => 'notifications';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text().withDefault(
    const Constant('info'),
  )(); // info, warning, error, success
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get data => text().nullable()(); // JSON
  TextColumn get actionUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
