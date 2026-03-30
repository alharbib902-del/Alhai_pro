import 'package:drift/drift.dart';

/// جدول بيانات العملاء
@TableIndex(name: 'idx_customers_store_id', columns: {#storeId})
@TableIndex(name: 'idx_customers_phone', columns: {#phone})
@TableIndex(name: 'idx_customers_name', columns: {#name})
@TableIndex(name: 'idx_customers_is_active', columns: {#isActive})
@TableIndex(name: 'idx_customers_store_phone', columns: {#storeId, #phone})
class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('individual'))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول عناوين العملاء
@TableIndex(name: 'idx_customer_addresses_customer_id', columns: {#customerId})
class CustomerAddressesTable extends Table {
  @override
  String get tableName => 'customer_addresses';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get label => text().withDefault(const Constant('home'))();
  TextColumn get address => text()();
  TextColumn get city => text().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
