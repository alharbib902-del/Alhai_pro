import 'package:drift/drift.dart';

/// جدول سجل التدقيق للعمليات الحساسة
///
/// Indexes:
/// - idx_audit_store_id: للاستعلامات حسب المتجر
/// - idx_audit_user_id: للاستعلامات حسب المستخدم
/// - idx_audit_action: لفلترة حسب نوع العملية
/// - idx_audit_created_at: للاستعلامات حسب التاريخ
/// - idx_audit_entity: استعلام مركب للكيان
/// - idx_audit_synced_at: للمزامنة
@TableIndex(name: 'idx_audit_store_id', columns: {#storeId})
@TableIndex(name: 'idx_audit_user_id', columns: {#userId})
@TableIndex(name: 'idx_audit_action', columns: {#action})
@TableIndex(name: 'idx_audit_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_audit_entity', columns: {#entityType, #entityId})
@TableIndex(name: 'idx_audit_synced_at', columns: {#syncedAt})
class AuditLogTable extends Table {
  @override
  String get tableName => 'audit_log';

  // المعرفات
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get userId => text()();
  TextColumn get userName => text()();

  // نوع العملية
  TextColumn get action => text()();
  // login, logout, sale_create, sale_cancel, refund,
  // price_change, stock_adjust, payment_record,
  // shift_open, shift_close, settings_change

  // تفاصيل العملية
  TextColumn get entityType =>
      text().nullable()(); // sale, product, customer, etc.
  TextColumn get entityId => text().nullable()();
  TextColumn get oldValue => text().nullable()(); // JSON
  TextColumn get newValue => text().nullable()(); // JSON
  TextColumn get description => text().nullable()();

  // معلومات إضافية
  TextColumn get ipAddress => text().nullable()();
  TextColumn get deviceInfo => text().nullable()();

  // التاريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
