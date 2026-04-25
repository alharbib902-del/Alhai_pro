import 'package:drift/drift.dart';

import 'stores_table.dart';

/// Wave 3b-2b: ZATCA Phase-2 Invoice Counter Value (ICV) source of truth.
///
/// ZATCA's chain-integrity check on the portal requires every invoice
/// to carry a strictly monotonic counter scoped to the (storeId,
/// invoiceType) pair. The counter must never decrease — even if local
/// invoices are deleted — and must never skip values once a number is
/// assigned. The PoS chain hash and the ICV together let the portal
/// detect missing or out-of-order invoices.
///
/// The composite primary key (`storeId`, `invoiceType`) means each
/// store keeps separate counters for simplified / standard / credit /
/// debit notes. Per ZATCA spec credit notes share the standard chain,
/// but keeping them separate here lets the report screens filter
/// without joining sales — small storage cost, big ergonomic win.
///
/// Atomic increment lives in `InvoiceCounterDao.nextIcv` (raw SQL via
/// `INSERT ... ON CONFLICT ... DO UPDATE`).
@TableIndex(
  name: 'idx_invoice_counter_lookup',
  columns: {#storeId, #invoiceType},
  unique: true,
)
class InvoiceCounterTable extends Table {
  @override
  String get tableName => 'invoice_counter';

  TextColumn get storeId =>
      text().references(StoresTable, #id, onDelete: KeyAction.cascade)();

  /// One of `simplified_tax | standard_tax | credit_note | debit_note`
  /// — matches `InvoiceType.value` in alhai_pos.
  TextColumn get invoiceType => text()();

  /// Last issued ICV. Caller computes `nextIcv = value + 1` atomically.
  IntColumn get value => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {storeId, invoiceType};
}
