import 'package:drift/drift.dart';

/// جدول الورديات
@TableIndex(name: 'idx_shifts_store_id', columns: {#storeId})
@TableIndex(name: 'idx_shifts_cashier_id', columns: {#cashierId})
@TableIndex(name: 'idx_shifts_status', columns: {#status})
@TableIndex(name: 'idx_shifts_opened_at', columns: {#openedAt})
@TableIndex(
  name: 'idx_shifts_store_cashier_status',
  columns: {#storeId, #cashierId, #status},
)
class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get terminalId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get cashierName => text()();
  // C-4 Session 3: shifts money columns are int cents (ROUND_HALF_UP).
  // totalSales and totalRefunds are count columns — already int.
  IntColumn get openingCash => integer().withDefault(const Constant(0))();
  IntColumn get closingCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  IntColumn get difference => integer().nullable()();
  IntColumn get totalSales => integer().withDefault(const Constant(0))();
  IntColumn get totalSalesAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalRefunds => integer().withDefault(const Constant(0))();
  IntColumn get totalRefundsAmount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  // ═══════════ ZATCA Chain Snapshots (Sprint 1 / P0-06 + P0-07) ═══════════
  //
  // These nullable columns capture the position of the ZATCA invoice chain
  // at the moment the shift opens and closes. Z-Report reconciliation needs
  // them to answer "which invoices belong to this shift?" without relying
  // on `invoices.shift_id` (which only links *new* invoices, not late-
  // arriving offline-queue submissions). They also let an audit detect
  // chain breaks across shifts: openingLastPih on shift N+1 must equal
  // closingLastPih on shift N — any divergence flags a missing invoice.
  //
  // All migrated rows (pre-v47 shifts) leave these NULL; readers must
  // tolerate the absence and fall back to the legacy "no snapshot"
  // reconciliation path.

  /// Number of invoices issued by the store at the moment this shift
  /// opened. The opening counter for the next shift's "invoices issued
  /// during this shift" calculation = closingInvoiceCount of THIS shift.
  IntColumn get openingInvoiceCount => integer().nullable()();

  /// `zatca_hash` (PIH — Previous Invoice Hash) of the most recent
  /// invoice when the shift opened. Used by the ZATCA chain validator
  /// to confirm continuity across shift boundaries.
  TextColumn get openingLastPih => text().nullable()();

  /// UTC ISO-8601 timestamp captured when the shift opened — separate
  /// from `openedAt` (which is local time) so audit / Z-Report tooling
  /// has a timezone-unambiguous reference even if the device clock skew
  /// changes between open and close.
  TextColumn get openingTimestampUtc => text().nullable()();

  /// Number of invoices issued by the store at the moment this shift
  /// closed. (closingInvoiceCount − openingInvoiceCount) = invoices
  /// physically issued during this shift.
  IntColumn get closingInvoiceCount => integer().nullable()();

  /// `zatca_hash` of the most recent invoice when the shift closed.
  /// Will become the next shift's openingLastPih.
  TextColumn get closingLastPih => text().nullable()();

  /// UTC ISO-8601 timestamp at close — see [openingTimestampUtc].
  TextColumn get closingTimestampUtc => text().nullable()();

  /// Number of invoices still in `zatca_offline_queue` when the shift
  /// closed (not yet sent to the gateway). Surfacing this on the
  /// Z-Report alerts the cashier that some receipts shown in this
  /// shift's totals are pending ZATCA acknowledgement.
  IntColumn get pendingZatcaAtClose => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول حركات الصندوق
@TableIndex(name: 'idx_cash_movements_shift_id', columns: {#shiftId})
@TableIndex(name: 'idx_cash_movements_store_id', columns: {#storeId})
@TableIndex(name: 'idx_cash_movements_created_at', columns: {#createdAt})
class CashMovementsTable extends Table {
  @override
  String get tableName => 'cash_movements';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get shiftId => text()();
  TextColumn get storeId => text()();
  TextColumn get type => text()(); // in, out
  // C-4 Session 3: amount is int cents (ROUND_HALF_UP).
  IntColumn get amount => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get reference => text().nullable()();

  /// NOTE: Naming inconsistency - this column is called [createdBy] but other
  /// tables (audit_log, notifications, inventory_movements, org_members) use
  /// [userId] for the same concept. Preferred standard: [userId] to match
  /// Supabase auth.uid(). Keep [createdBy] here for backward compatibility
  /// but align in future migrations.
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
