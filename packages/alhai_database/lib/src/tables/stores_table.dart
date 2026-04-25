import 'package:drift/drift.dart';

/// جدول بيانات المتاجر/الفروع
@TableIndex(name: 'idx_stores_is_active', columns: {#isActive})
class StoresTable extends Table {
  @override
  String get tableName => 'stores';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialReg => text().nullable()();

  // Wave 3b-2b: ZATCA Phase-2 structured address fields. The legacy
  // `address` column holds free text — useful for receipts but not
  // accepted by the portal. ZATCA mandates the seller's address
  // broken into: street_name, building_number, plot_identification,
  // city (already exists), district, postal_code, plus an optional
  // additional_address_number. Until populated, the Phase-2 enable
  // toggle should refuse to flip ON for the store.
  TextColumn get streetName => text().nullable()();
  TextColumn get buildingNumber => text().nullable()();
  TextColumn get plotIdentification => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get postalCode => text().nullable()();
  TextColumn get additionalAddressNumber => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Riyadh'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
