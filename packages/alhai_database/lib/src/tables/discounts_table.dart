import 'package:drift/drift.dart';

/// جدول الخصومات
@TableIndex(name: 'idx_discounts_store_id', columns: {#storeId})
@TableIndex(name: 'idx_discounts_is_active', columns: {#isActive})
class DiscountsTable extends Table {
  @override
  String get tableName => 'discounts';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get type => text()(); // percentage, fixed
  // C-4 Stage A: money stored as INTEGER cents (ROUND_HALF_UP from legacy doubles)
  IntColumn get value => integer()();
  IntColumn get minPurchase => integer().withDefault(const Constant(0))();
  IntColumn get maxDiscount => integer().nullable()();
  TextColumn get appliesTo => text().withDefault(const Constant('all'))();
  TextColumn get productIds => text().nullable()(); // JSON array
  TextColumn get categoryIds => text().nullable()(); // JSON array
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول الكوبونات
@TableIndex(name: 'idx_coupons_store_id', columns: {#storeId})
@TableIndex(name: 'idx_coupons_code', columns: {#code})
@TableIndex(name: 'idx_coupons_is_active', columns: {#isActive})
class CouponsTable extends Table {
  @override
  String get tableName => 'coupons';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get code => text()();
  TextColumn get discountId => text().nullable()();
  TextColumn get type => text()(); // percentage, fixed
  // C-4 Session 4: coupons money cols are int cents (ROUND_HALF_UP).
  IntColumn get value => integer()();
  IntColumn get maxUses => integer().withDefault(const Constant(0))();
  IntColumn get currentUses => integer().withDefault(const Constant(0))();
  IntColumn get minPurchase => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول العروض الترويجية
@TableIndex(name: 'idx_promotions_store_id', columns: {#storeId})
@TableIndex(name: 'idx_promotions_is_active', columns: {#isActive})
class PromotionsTable extends Table {
  @override
  String get tableName => 'promotions';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // buy_x_get_y, bundle, flash_sale
  TextColumn get rules => text().withDefault(const Constant('{}'))(); // JSON
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
