import 'package:drift/drift.dart';

import 'stores_table.dart';

/// جدول الفواتير الرسمية
///
/// يدعم أنواع الفواتير حسب ZATCA:
/// - simplified_tax: فاتورة ضريبية مبسطة (B2C - نقطة البيع)
/// - standard_tax: فاتورة ضريبية (B2B)
/// - credit_note: إشعار دائن (مرتجع/تعديل بالنقص)
/// - debit_note: إشعار مدين (تعديل بالزيادة)
///
/// كل فاتورة مرتبطة بـ sale (عملية بيع) أو مستقلة
@TableIndex(name: 'idx_invoices_store_id', columns: {#storeId})
@TableIndex(
  name: 'idx_invoices_number',
  columns: {#storeId, #invoiceNumber},
  unique: true,
)
@TableIndex(name: 'idx_invoices_type', columns: {#storeId, #invoiceType})
@TableIndex(name: 'idx_invoices_status', columns: {#status})
@TableIndex(name: 'idx_invoices_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_invoices_customer', columns: {#customerId})
@TableIndex(name: 'idx_invoices_sale', columns: {#saleId})
class InvoicesTable extends Table {
  @override
  String get tableName => 'invoices';

  // ═══════════ المعرفات ═══════════
  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get storeId => text().references(StoresTable, #id)();

  // ═══════════ بيانات الفاتورة ═══════════
  /// رقم الفاتورة الرسمي (تسلسلي حسب النوع)
  /// مثال: INV-2026-00001, CN-2026-00001, DN-2026-00001
  TextColumn get invoiceNumber => text()();

  /// نوع الفاتورة
  /// simplified_tax | standard_tax | credit_note | debit_note
  TextColumn get invoiceType =>
      text().withDefault(const Constant('simplified_tax'))();

  /// حالة الفاتورة
  /// draft | issued | sent | paid | partially_paid | overdue | cancelled | archived
  TextColumn get status => text().withDefault(const Constant('issued'))();

  // ═══════════ الربط ═══════════
  /// معرف عملية البيع المرتبطة (اختياري)
  TextColumn get saleId => text().nullable()();

  /// معرف الفاتورة المرجعية (لإشعارات الدائن/المدين)
  TextColumn get refInvoiceId => text().nullable()();

  /// سبب الإشعار (لإشعارات الدائن/المدين)
  TextColumn get refReason => text().nullable()();

  // ═══════════ العميل ═══════════
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get customerEmail => text().nullable()();
  TextColumn get customerVatNumber =>
      text().nullable()(); // للفاتورة الضريبية B2B
  TextColumn get customerAddress => text().nullable()();

  // ═══════════ المبالغ ═══════════
  // C-4 Session 2: money columns are int cents (ROUND_HALF_UP).
  // taxRate stays Real — it's a percentage (0.15 = 15%), not money.
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  RealColumn get taxRate => real().withDefault(const Constant(15))(); // 15% VAT
  IntColumn get taxAmount => integer().withDefault(const Constant(0))();
  IntColumn get total => integer().withDefault(const Constant(0))();

  // ═══════════ الدفع ═══════════
  TextColumn get paymentMethod =>
      text().nullable()(); // cash, card, mixed, credit, transfer
  IntColumn get amountPaid => integer().withDefault(const Constant(0))();
  IntColumn get amountDue => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();

  // ═══════════ ZATCA ═══════════
  TextColumn get zatcaHash => text().nullable()();
  TextColumn get zatcaQr => text().nullable()();
  TextColumn get zatcaUuid => text().nullable()();

  // Wave 3b-2b: Phase-2 outputs from ZatcaInvoiceService.processInvoice.
  // All nullable so a Phase-1-only row stays valid (Phase-2 is a
  // per-store opt-in via store_settings.zatca_phase2_enabled).
  /// Base64-encoded XAdES-signed UBL XML returned by the signer.
  /// ~2-10KB per invoice; local-only by design (ZATCA portal already
  /// has its own copy, we don't sync this column to Supabase).
  TextColumn get signedXml => text().nullable()();

  /// One of: pending, reported, cleared, failed, queued. Mirrors the
  /// `ReportingStatus` enum in alhai_zatca; persisted as text so a DB
  /// schema bump doesn't follow every enum addition.
  TextColumn get reportingStatus => text().nullable()();

  /// JSON array of warning strings from ZatcaInvoiceService (compliance
  /// checker non-blocking warnings + cert near-expiry hints + ZATCA
  /// portal warnings). UI can show these when the cashier opens the
  /// invoice; they don't gate the receipt.
  TextColumn get zatcaWarnings => text().nullable()();

  /// JSON array of error strings — populated when reportingStatus is
  /// `failed` or `queued`. Read this for retry diagnostics.
  TextColumn get zatcaErrors => text().nullable()();

  /// Invoice Counter Value (ICV / BT-X) — monotonic per (storeId,
  /// invoiceType). Required by ZATCA Phase-2 for the chain integrity
  /// check on the portal side. Populated from `invoice_counter` table
  /// at `createFromSale` time.
  IntColumn get icv => integer().nullable()();

  // ═══════════ الأرشفة ═══════════
  TextColumn get pdfUrl => text().nullable()(); // رابط PDF في Supabase Storage
  TextColumn get notes => text().nullable()();

  // ═══════════ الموظف ═══════════
  TextColumn get createdBy => text().nullable()(); // الكاشير/الموظف
  TextColumn get cashierName => text().nullable()();

  // ═══════════ التواريخ ═══════════
  DateTimeColumn get issuedAt => dateTime().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()(); // تاريخ الاستحقاق
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
