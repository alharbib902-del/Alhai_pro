import 'package:drift/drift.dart';

/// جدول بيانات المزامنة الوصفية
/// يتتبع حالة المزامنة لكل جدول: آخر سحب، آخر دفع، عدد المعلقات
///
/// Indexes:
/// - PRIMARY KEY: table_name (نص فريد لكل جدول)
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

  @override
  Set<Column> get primaryKey => {tableName_};
}
