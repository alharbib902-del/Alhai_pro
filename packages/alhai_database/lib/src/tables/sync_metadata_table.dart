import 'package:drift/drift.dart';

/// جدول بيانات المزامنة الوصفية
/// يتتبع حالة المزامنة لكل جدول: آخر سحب، آخر دفع، عدد المعلقات
///
/// Indexes:
/// - PRIMARY KEY: table_name (نص فريد لكل جدول)
///
/// NOTE: [tableName_] is used as the primary key by design. Each row represents
/// sync metadata for a specific table (e.g. 'products', 'sales'). Using the
/// table name as the primary key ensures exactly one metadata row per tracked
/// table and allows direct O(1) lookup without needing a surrogate UUID key.
/// This is intentional and different from the UUID-based primary keys used
/// in other tables.
class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  /// اسم الجدول المتتبع (products, sales, etc.)
  TextColumn get tableName_ => text().named('table_name')();

  /// آخر وقت سحب ناجح من السيرفر
  DateTimeColumn get lastPullAt => dateTime().nullable()();

  /// آخر وقت دفع ناجح للسيرفر
  DateTimeColumn get lastPushAt => dateTime().nullable()();

  /// عدد السجلات المعلقة للدفع
  IntColumn get pendingCount => integer().withDefault(const Constant(0))();

  /// عدد السجلات التي فشل دفعها
  IntColumn get failedCount => integer().withDefault(const Constant(0))();

  /// هل تمت المزامنة الأولية؟
  BoolColumn get isInitialSynced =>
      boolean().withDefault(const Constant(false))();

  /// عدد السجلات التي تمت مزامنتها في آخر عملية
  IntColumn get lastSyncCount => integer().withDefault(const Constant(0))();

  /// آخر خطأ حدث أثناء المزامنة
  TextColumn get lastError => text().nullable()();

  /// عدد التعارضات المكتشفة
  IntColumn get conflictCount => integer().withDefault(const Constant(0))();

  /// آخر وقت حدث فيه تعارض
  DateTimeColumn get lastConflictAt => dateTime().nullable()();

  /// هل يتطلب مراجعة يدوية؟
  BoolColumn get requiresManualReview =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {tableName_};
}
