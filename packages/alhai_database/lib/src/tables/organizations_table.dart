import 'package:drift/drift.dart';

@TableIndex(name: 'idx_organizations_is_active', columns: {#isActive})
@TableIndex(name: 'idx_organizations_slug', columns: {#slug})
class OrganizationsTable extends Table {
  @override
  String get tableName => 'organizations';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get slug => text().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('SA'))();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialReg => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Riyadh'))();
  TextColumn get locale => text().withDefault(const Constant('ar'))();
  TextColumn get plan => text().withDefault(const Constant('free'))();
  IntColumn get maxStores => integer().withDefault(const Constant(1))();
  IntColumn get maxUsers => integer().withDefault(const Constant(3))();
  IntColumn get maxProducts => integer().withDefault(const Constant(100))();
  TextColumn get status => text().withDefault(const Constant('trial'))();
  TextColumn get companyType => text().withDefault(const Constant('agency'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get trialEndsAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_subscriptions_org_id', columns: {#orgId})
@TableIndex(name: 'idx_subscriptions_status', columns: {#status})
class SubscriptionsTable extends Table {
  @override
  String get tableName => 'subscriptions';

  TextColumn get id => text()();
  TextColumn get orgId => text()();
  TextColumn get plan => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get billingCycle =>
      text().withDefault(const Constant('monthly'))();
  DateTimeColumn get currentPeriodStart => dateTime()();
  DateTimeColumn get currentPeriodEnd => dateTime()();
  BoolColumn get cancelAtPeriodEnd =>
      boolean().withDefault(const Constant(false))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get externalSubscriptionId => text().nullable()();
  TextColumn get features => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
