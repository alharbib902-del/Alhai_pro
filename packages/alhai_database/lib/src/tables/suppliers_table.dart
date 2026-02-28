import 'package:drift/drift.dart';

/// جدول بيانات الموردين
@TableIndex(name: 'idx_suppliers_store_id', columns: {#storeId})
@TableIndex(name: 'idx_suppliers_phone', columns: {#phone})
@TableIndex(name: 'idx_suppliers_is_active', columns: {#isActive})
class SuppliersTable extends Table {
  @override
  String get tableName => 'suppliers';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get paymentTerms => text().nullable()();
  /// Rating from 0 to 5. Range validation (0 <= rating <= 5) is enforced
  /// in [SuppliersDao.insertSupplier] and [SuppliersDao.updateSupplier]
  /// which throw [InvalidSupplierRatingException] for out-of-range values.
  /// Use [SuppliersDao.clampRating] to safely clamp before insert if needed.
  IntColumn get rating => integer().withDefault(const Constant(0))();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
