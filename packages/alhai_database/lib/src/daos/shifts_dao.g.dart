// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shifts_dao.dart';

// ignore_for_file: type=lint
mixin _$ShiftsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShiftsTableTable get shiftsTable => attachedDatabase.shiftsTable;
  $CashMovementsTableTable get cashMovementsTable =>
      attachedDatabase.cashMovementsTable;
  ShiftsDaoManager get managers => ShiftsDaoManager(this);
}

class ShiftsDaoManager {
  final _$ShiftsDaoMixin _db;
  ShiftsDaoManager(this._db);
  $$ShiftsTableTableTableManager get shiftsTable =>
      $$ShiftsTableTableTableManager(_db.attachedDatabase, _db.shiftsTable);
  $$CashMovementsTableTableTableManager get cashMovementsTable =>
      $$CashMovementsTableTableTableManager(
          _db.attachedDatabase, _db.cashMovementsTable);
}
