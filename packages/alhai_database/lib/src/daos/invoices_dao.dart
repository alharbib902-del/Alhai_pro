import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/invoices_table.dart';

part 'invoices_dao.g.dart';

/// DAO للفواتير الرسمية
@DriftAccessor(tables: [InvoicesTable])
class InvoicesDao extends DatabaseAccessor<AppDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  // ═══════════ القراءة ═══════════

  /// جلب فواتير المتجر
  Future<List<InvoicesTableData>> getByStore(
    String storeId, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(invoicesTable)
          ..where((i) => i.storeId.equals(storeId))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// جلب فواتير حسب النوع
  Future<List<InvoicesTableData>> getByType(
    String storeId,
    String invoiceType, {
    int limit = 50,
  }) {
    return (select(invoicesTable)
          ..where(
            (i) =>
                i.storeId.equals(storeId) & i.invoiceType.equals(invoiceType),
          )
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit))
        .get();
  }

  /// جلب فواتير حسب الحالة
  Future<List<InvoicesTableData>> getByStatus(
    String storeId,
    String status, {
    int limit = 50,
  }) {
    return (select(invoicesTable)
          ..where((i) => i.storeId.equals(storeId) & i.status.equals(status))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit))
        .get();
  }

  /// جلب فاتورة بالمعرف
  Future<InvoicesTableData?> getById(String id) {
    return (select(
      invoicesTable,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// جلب فاتورة بالرقم
  Future<InvoicesTableData?> getByNumber(String storeId, String number) {
    return (select(invoicesTable)..where(
          (i) => i.storeId.equals(storeId) & i.invoiceNumber.equals(number),
        ))
        .getSingleOrNull();
  }

  /// جلب فاتورة مرتبطة بعملية بيع
  Future<InvoicesTableData?> getBySaleId(String saleId) {
    return (select(
      invoicesTable,
    )..where((i) => i.saleId.equals(saleId))).getSingleOrNull();
  }

  /// جلب فواتير عميل معين
  Future<List<InvoicesTableData>> getByCustomer(
    String storeId,
    String customerId, {
    int limit = 50,
  }) {
    return (select(invoicesTable)
          ..where(
            (i) => i.storeId.equals(storeId) & i.customerId.equals(customerId),
          )
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit))
        .get();
  }

  /// جلب الفواتير غير المدفوعة (المستحقة)
  Future<List<InvoicesTableData>> getUnpaid(String storeId) {
    return (select(invoicesTable)
          ..where(
            (i) =>
                i.storeId.equals(storeId) &
                i.amountDue.isBiggerThanValue(0) &
                i.status.isNotIn(['cancelled', 'archived']),
          )
          ..orderBy([(i) => OrderingTerm.asc(i.dueAt)]))
        .get();
  }

  /// جلب الفواتير المتأخرة
  Future<List<InvoicesTableData>> getOverdue(String storeId) {
    final now = DateTime.now();
    return (select(invoicesTable)
          ..where(
            (i) =>
                i.storeId.equals(storeId) &
                i.amountDue.isBiggerThanValue(0) &
                i.dueAt.isSmallerThanValue(now) &
                i.status.isNotIn(['cancelled', 'archived', 'paid']),
          )
          ..orderBy([(i) => OrderingTerm.asc(i.dueAt)]))
        .get();
  }

  // ═══════════ الترقيم ═══════════

  /// الحصول على آخر رقم فاتورة لنوع معين في سنة معينة
  Future<int> getLastSequence(String storeId, String prefix, int year) async {
    final pattern = '$prefix-$year-%';
    final result = await customSelect(
      'SELECT invoice_number FROM invoices '
      'WHERE store_id = ? AND invoice_number LIKE ? '
      'ORDER BY invoice_number DESC LIMIT 1',
      variables: [Variable.withString(storeId), Variable.withString(pattern)],
    ).getSingleOrNull();

    if (result == null) return 0;

    final number = result.data['invoice_number'] as String;
    // INV-2026-00001 → 1
    final parts = number.split('-');
    if (parts.length >= 3) {
      return int.tryParse(parts.last) ?? 0;
    }
    return 0;
  }

  // ═══════════ الكتابة ═══════════

  /// إدراج أو تحديث فاتورة
  Future<int> upsertInvoice(InvoicesTableCompanion invoice) =>
      into(invoicesTable).insertOnConflictUpdate(invoice);

  /// تحديث حالة الفاتورة
  Future<int> updateStatus(String id, String status) {
    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// تحديث رابط PDF
  Future<int> updatePdfUrl(String id, String pdfUrl) {
    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(
        pdfUrl: Value(pdfUrl),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// تحديث رمز ZATCA QR للفاتورة.
  ///
  /// ZATCA Phase-1 compliance: كل فاتورة ضريبية مبسطة يجب أن تحمل QR
  /// مرمّز TLV مع اسم البائع، الرقم الضريبي، الطابع الزمني، والمجاميع.
  /// يُخزَّن بعد إنشاء الفاتورة مباشرةً (في نفس طلب createFromSale) حتى
  /// يتم دفعه ضمن نفس payload التزامن بدل توليده لاحقاً عند كل طباعة.
  Future<int> updateZatcaQr(String id, String qrBase64) {
    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(
        zatcaQr: Value(qrBase64),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Wave 3b-2b: persist the result of `ZatcaInvoiceService.processInvoice`
  /// back to the local invoices row. All parameters except [id] are
  /// optional / nullable so callers can update a partial set (e.g.
  /// status-only after a re-submit, or warnings-only after offline retry)
  /// without clobbering the others.
  ///
  /// Each `Value(null)` replaces the column; `null` itself (i.e. omitted)
  /// leaves it untouched. Translates to `Value.absent()` for omitted
  /// args via the named-default pattern below.
  Future<int> updateZatcaPhase2Result({
    required String id,
    String? signedXml,
    String? reportingStatus,
    String? warningsJson,
    String? errorsJson,
    String? zatcaQr,
    String? zatcaHash,
    int? icv,
    bool clearWarnings = false,
    bool clearErrors = false,
  }) {
    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(
        signedXml: signedXml != null ? Value(signedXml) : const Value.absent(),
        reportingStatus: reportingStatus != null
            ? Value(reportingStatus)
            : const Value.absent(),
        zatcaWarnings: clearWarnings
            ? const Value(null)
            : (warningsJson != null
                  ? Value(warningsJson)
                  : const Value.absent()),
        zatcaErrors: clearErrors
            ? const Value(null)
            : (errorsJson != null
                  ? Value(errorsJson)
                  : const Value.absent()),
        zatcaQr: zatcaQr != null ? Value(zatcaQr) : const Value.absent(),
        zatcaHash: zatcaHash != null ? Value(zatcaHash) : const Value.absent(),
        icv: icv != null ? Value(icv) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// تسجيل دفعة
  ///
  /// `amount` is SAR (double). Converts to int cents at the boundary per
  /// C-4 Session 2 money-type migration.
  Future<int> recordPayment(String id, double amount) async {
    final invoice = await getById(id);
    if (invoice == null) return 0;

    final amountCents = (amount * 100).round();
    final int newPaid = invoice.amountPaid + amountCents;
    final int newDue = newPaid >= invoice.total ? 0 : invoice.total - newPaid;
    final newStatus = newDue <= 0 ? 'paid' : 'partially_paid';

    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(
        amountPaid: Value(newPaid),
        amountDue: Value(newDue),
        status: Value(newStatus),
        paidAt: newDue <= 0 ? Value(DateTime.now()) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// تعيين كمزامنة
  Future<int> markAsSynced(String id) {
    return (update(invoicesTable)..where((i) => i.id.equals(id))).write(
      InvoicesTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  // ═══════════ الإحصائيات ═══════════

  /// إحصائيات الفواتير لفترة معينة
  Future<Map<String, dynamic>> getStats(
    String storeId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await customSelect(
      '''SELECT
        COUNT(*) as total_count,
        COALESCE(SUM(total), 0) as total_amount,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COALESCE(SUM(amount_due), 0) as total_due,
        COALESCE(SUM(CASE WHEN invoice_type = 'credit_note' THEN total ELSE 0 END), 0) as credit_notes_total
      FROM invoices
      WHERE store_id = ? AND created_at >= ? AND created_at <= ?
        AND status != 'cancelled'
      ''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
    ).getSingle();

    return result.data;
  }

  // ═══════════ المراقبة ═══════════

  /// مراقبة فواتير المتجر
  Stream<List<InvoicesTableData>> watchByStore(String storeId) {
    return (select(invoicesTable)
          ..where((i) => i.storeId.equals(storeId))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(100))
        .watch();
  }

  /// مراقبة عدد الفواتير غير المدفوعة
  Stream<int> watchUnpaidCount(String storeId) {
    final count = invoicesTable.id.count();
    final query = selectOnly(invoicesTable)
      ..addColumns([count])
      ..where(
        invoicesTable.storeId.equals(storeId) &
            invoicesTable.amountDue.isBiggerThanValue(0) &
            invoicesTable.status.isNotIn(['cancelled', 'archived']),
      );
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// Count of invoices that have been successfully sent to ZATCA (M7).
  ///
  /// The offline queue removes a row on successful submission, so "sent"
  /// is defined as: has a `zatca_hash` (was signed) AND is not currently
  /// sitting in either the pending queue or the dead-letter table.
  ///
  /// Store-scoped when [storeId] is provided.
  Future<int> getZatcaSentCount({String? storeId}) async {
    final sql = StringBuffer(
      'SELECT COUNT(*) AS c FROM invoices i '
      'WHERE i.zatca_hash IS NOT NULL '
      'AND NOT EXISTS ('
      '  SELECT 1 FROM zatca_offline_queue q '
      '  WHERE q.invoice_number = i.invoice_number'
      ') '
      'AND NOT EXISTS ('
      '  SELECT 1 FROM zatca_dead_letter d '
      '  WHERE d.invoice_number = i.invoice_number'
      ') ',
    );
    final args = <Variable>[];
    if (storeId != null) {
      sql.write('AND i.store_id = ?');
      args.add(Variable.withString(storeId));
    }
    final result = await customSelect(
      sql.toString(),
      variables: args,
      readsFrom: {invoicesTable},
    ).getSingle();
    return result.data['c'] as int? ?? 0;
  }
}
