import 'package:drift/drift.dart';

/// جدول سجل تغييرات حالة الطلبات
@TableIndex(name: 'idx_order_status_history_order_id', columns: {#orderId})
@TableIndex(name: 'idx_order_status_history_created_at', columns: {#createdAt})
class OrderStatusHistoryTable extends Table {
  @override
  String get tableName => 'order_status_history';

  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get fromStatus => text().nullable()();
  TextColumn get toStatus => text()();
  TextColumn get changedBy => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
