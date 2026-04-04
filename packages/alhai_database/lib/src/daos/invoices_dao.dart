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
          ..where((i) =>
              i.storeId.equals(storeId) & i.invoiceType.equals(invoiceType))
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
    return (select(invoicesTable)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// جلب فاتورة بالرقم
  Future<InvoicesTableData?> getByNumber(String storeId, String number) {
    return (select(invoicesTable)
          ..where((i) =>
              i.storeId.equals(storeId) & i.invoiceNumber.equals(number)))
        .getSingleOrNull();
  }

  /// جلب فاتورة مرتبطة بعملية بيع
  Future<InvoicesTableData?> getBySaleId(String saleId) {
    return (select(invoicesTable)..where((i) => i.saleId.equals(saleId)))
        .getSingleOrNull();
  }

  /// جلب فواتير عميل معين
  Future<List<InvoicesTableData>> getByCustomer(
    String storeId,
    String customerId, {
    int limit = 50,
  }) {
    return (select(invoicesTable)
          ..where((i) =>
              i.storeId.equals(storeId) & i.customerId.equals(customerId))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(limit))
        .get();
  }

  /// جلب الفواتير غير المدفوعة (المستحقة)
  Future<List<InvoicesTableData>> getUnpaid(String storeId) {
    return (select(invoicesTable)
          ..where((i) =>
              i.storeId.equals(storeId) &
              i.amountDue.isBiggerThanValue(0) &
              i.status.isNotIn(['cancelled', 'archived']))
          ..orderBy([(i) => OrderingTerm.asc(i.dueAt)]))
        .get();
  }

  /// جلب الفواتير المتأخرة
  Future<List<InvoicesTableData>> getOverdue(String storeId) {
    final now = DateTime.now();
    return (select(invoicesTable)
          ..where((i) =>
              i.storeId.equals(storeId) &
              i.amountDue.isBiggerThanValue(0) &
              i.dueAt.isSmallerThanValue(now) &
              i.status.isNotIn(['cancelled', 'archived', 'paid']))
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

  /// تسجيل دفعة
  Future<int> recordPayment(String id, double amount) async {
    final invoice = await getById(id);
    if (invoice == null) return 0;

    final newPaid = invoice.amountPaid + amount;
    final double newDue = (invoice.total - newPaid).clamp(0.0, double.infinity);
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
      ..where(invoicesTable.storeId.equals(storeId) &
          invoicesTable.amountDue.isBiggerThanValue(0) &
          invoicesTable.status.isNotIn(['cancelled', 'archived']));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
