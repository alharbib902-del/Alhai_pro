// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_dao.dart';

// ignore_for_file: type=lint
mixin _$LoyaltyDaoMixin on DatabaseAccessor<AppDatabase> {
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $LoyaltyPointsTableTable get loyaltyPointsTable =>
      attachedDatabase.loyaltyPointsTable;
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $ShiftsTableTable get shiftsTable => attachedDatabase.shiftsTable;
  $SalesTableTable get salesTable => attachedDatabase.salesTable;
  $LoyaltyTransactionsTableTable get loyaltyTransactionsTable =>
      attachedDatabase.loyaltyTransactionsTable;
  $LoyaltyRewardsTableTable get loyaltyRewardsTable =>
      attachedDatabase.loyaltyRewardsTable;
  LoyaltyDaoManager get managers => LoyaltyDaoManager(this);
}

class LoyaltyDaoManager {
  final _$LoyaltyDaoMixin _db;
  LoyaltyDaoManager(this._db);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$LoyaltyPointsTableTableTableManager get loyaltyPointsTable =>
      $$LoyaltyPointsTableTableTableManager(
          _db.attachedDatabase, _db.loyaltyPointsTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db.attachedDatabase, _db.shiftsTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db.attachedDatabase, _db.salesTable);
  $$LoyaltyTransactionsTableTableTableManager get loyaltyTransactionsTable =>
      $$LoyaltyTransactionsTableTableTableManager(
          _db.attachedDatabase, _db.loyaltyTransactionsTable);
  $$LoyaltyRewardsTableTableTableManager get loyaltyRewardsTable =>
      $$LoyaltyRewardsTableTableTableManager(
          _db.attachedDatabase, _db.loyaltyRewardsTable);
}
