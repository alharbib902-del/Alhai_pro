// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discounts_dao.dart';

// ignore_for_file: type=lint
mixin _$DiscountsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DiscountsTableTable get discountsTable => attachedDatabase.discountsTable;
  $CouponsTableTable get couponsTable => attachedDatabase.couponsTable;
  $PromotionsTableTable get promotionsTable => attachedDatabase.promotionsTable;
  DiscountsDaoManager get managers => DiscountsDaoManager(this);
}

class DiscountsDaoManager {
  final _$DiscountsDaoMixin _db;
  DiscountsDaoManager(this._db);
  $$DiscountsTableTableTableManager get discountsTable =>
      $$DiscountsTableTableTableManager(
        _db.attachedDatabase,
        _db.discountsTable,
      );
  $$CouponsTableTableTableManager get couponsTable =>
      $$CouponsTableTableTableManager(_db.attachedDatabase, _db.couponsTable);
  $$PromotionsTableTableTableManager get promotionsTable =>
      $$PromotionsTableTableTableManager(
        _db.attachedDatabase,
        _db.promotionsTable,
      );
}
