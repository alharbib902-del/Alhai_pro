import 'package:drift/drift.dart';

/// جدول طابور المزامنة للعمل بدون إنترنت
/// كل عملية تُكتب هنا أولاً ثم تُرسل للسيرفر
///
/// Indexes:
/// - idx_sync_status: للحصول على العمليات المعلقة
/// - idx_sync_priority: للترتيب حسب الأولوية
/// - idx_sync_created_at: للترتيب الزمني
/// - idx_sync_idempotency: لمنع التكرار
@TableIndex(name: 'idx_sync_status', columns: {#status})
@TableIndex(name: 'idx_sync_priority', columns: {#priority})
@TableIndex(name: 'idx_sync_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_sync_idempotency', columns: {#idempotencyKey}, unique: true)
@TableIndex(name: 'idx_sync_status_priority', columns: {#status, #priority})
@TableIndex(name: 'idx_sync_status_priority_created', columns: {#status, #priority, #createdAt})
@TableIndex(name: 'idx_sync_table_record_status', columns: {#tableName_, #recordId, #status})
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  // المعرفات
  TextColumn get id => text()();
  
  // الجدول والسجل المتأثر
  TextColumn get tableName_ => text().named('table_name')(); // products, sales, etc
  TextColumn get recordId => text()();
  
  // نوع العملية
  TextColumn get operation => text()(); // CREATE, UPDATE, DELETE
  
  // البيانات
  TextColumn get payload => text()(); // JSON payload
  
  // مفتاح Idempotency لمنع التكرار
  TextColumn get idempotencyKey => text()();
  
  // حالة المزامنة
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, syncing, synced, failed
  
  // إعادة المحاولة
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  TextColumn get lastError => text().nullable()();
  
  // الأولوية (للمبيعات أولوية عالية)
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 1=low, 2=normal, 3=high
  
  // التواريخ
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
