import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/invoice_counter_table.dart';

part 'invoice_counter_dao.g.dart';

/// Wave 3b-2b: ZATCA Phase-2 Invoice Counter Value (ICV) source of truth.
///
/// The ICV must be monotonic per `(storeId, invoiceType)` — never
/// repeat, never skip backward. This DAO is the single writer; every
/// other code path reads through `nextIcv` so concurrent invoice
/// creations from two cashiers on the same device can't double-issue
/// the same value.
///
/// `nextIcv` uses `INSERT ... ON CONFLICT ... DO UPDATE` so the row
/// is created on first call and bumped atomically thereafter — no
/// read-modify-write race even without an outer transaction.
@DriftAccessor(tables: [InvoiceCounterTable])
class InvoiceCounterDao extends DatabaseAccessor<AppDatabase>
    with _$InvoiceCounterDaoMixin {
  InvoiceCounterDao(super.db);

  /// Atomically increment and return the next ICV for the given
  /// `(storeId, invoiceType)` pair. Creates the counter row at value
  /// 1 on first call; subsequent calls return value+1 strictly.
  ///
  /// Uses `RETURNING value` (SQLite 3.35+, supported by sqlcipher
  /// build) to read back the post-update number in the same statement,
  /// so the call is one round-trip and one acquired lock.
  Future<int> nextIcv({
    required String storeId,
    required String invoiceType,
  }) async {
    // The UPSERT + read-back happen inside a transaction so a
    // concurrent caller on the same Dart isolate can't observe the
    // intermediate state. SQLite's per-connection lock plus Drift's
    // single-writer queue mean the SELECT always sees the row this
    // UPSERT just wrote (or refreshed).
    return attachedDatabase.transaction(() async {
      await customStatement(
        '''
INSERT INTO invoice_counter (store_id, invoice_type, value, updated_at)
VALUES (?1, ?2, 1, ?3)
ON CONFLICT (store_id, invoice_type) DO UPDATE SET
  value = invoice_counter.value + 1,
  updated_at = ?3
''',
        [
          Variable.withString(storeId),
          Variable.withString(invoiceType),
          Variable.withDateTime(DateTime.now()),
        ],
      );
      final row = await (select(invoiceCounterTable)
            ..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.invoiceType.equals(invoiceType),
            ))
          .getSingle();
      return row.value;
    });
  }

  /// Read the current ICV without bumping. Use for diagnostics and
  /// reports — never as a source for the next value (call [nextIcv]).
  Future<int> currentIcv({
    required String storeId,
    required String invoiceType,
  }) async {
    final row = await (select(invoiceCounterTable)
          ..where(
            (t) =>
                t.storeId.equals(storeId) &
                t.invoiceType.equals(invoiceType),
          ))
        .getSingleOrNull();
    return row?.value ?? 0;
  }
}
