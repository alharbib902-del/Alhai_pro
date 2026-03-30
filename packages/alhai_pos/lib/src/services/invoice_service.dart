import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';

import 'receipt_pdf_generator.dart';

/// أنواع الفواتير المدعومة
enum InvoiceType {
  /// فاتورة ضريبية مبسطة (B2C - نقطة البيع)
  simplifiedTax('simplified_tax', 'INV'),

  /// فاتورة ضريبية (B2B - بين الشركات)
  standardTax('standard_tax', 'TAX'),

  /// إشعار دائن (مرتجع/تعديل بالنقص)
  creditNote('credit_note', 'CN'),

  /// إشعار مدين (تعديل بالزيادة)
  debitNote('debit_note', 'DN');

  final String value;
  final String prefix;

  const InvoiceType(this.value, this.prefix);
}

/// خدمة الفواتير المتكاملة
///
/// تدعم:
/// - إنشاء فواتير تلقائية عند البيع
/// - ترقيم تسلسلي حسب النوع والسنة
/// - إشعارات دائن/مدين
/// - أرشفة PDF في Supabase Storage
/// - تقارير وإحصائيات
class InvoiceService {
  final AppDatabase _db;
  final ImageUploadService? _uploadService;
  static const _uuid = Uuid();

  InvoiceService({
    required AppDatabase db,
    ImageUploadService? uploadService,
  })  : _db = db,
        _uploadService = uploadService;

  /// إنشاء فاتورة تلقائية عند عملية بيع
  ///
  /// يُستدعى بعد إتمام البيع لإنشاء الفاتورة الرسمية
  Future<InvoicesTableData?> createFromSale({
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    InvoiceType type = InvoiceType.simplifiedTax,
    StoreInfo store = StoreInfo.defaultStore,
    String? cashierName,
    String? customerVatNumber,
    String? customerAddress,
    DateTime? dueAt,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final invoiceNumber = await _generateInvoiceNumber(
        storeId: sale.storeId,
        type: type,
      );

      final companion = InvoicesTableCompanion.insert(
        id: id,
        orgId: Value(sale.orgId),
        storeId: sale.storeId,
        invoiceNumber: invoiceNumber,
        invoiceType: Value(type.value),
        status: Value(sale.isPaid ? 'paid' : 'issued'),
        saleId: Value(sale.id),
        customerId: Value(sale.customerId),
        customerName: Value(sale.customerName),
        customerPhone: Value(sale.customerPhone),
        customerVatNumber: Value(customerVatNumber),
        customerAddress: Value(customerAddress),
        subtotal: Value(sale.subtotal),
        discount: Value(sale.discount),
        taxAmount: Value(sale.tax),
        total: Value(sale.total),
        paymentMethod: Value(sale.paymentMethod),
        amountPaid: Value(sale.isPaid ? sale.total : 0),
        amountDue: Value(sale.isPaid ? 0 : sale.total),
        createdBy: Value(sale.cashierId),
        cashierName: Value(cashierName),
        issuedAt: Value(now),
        dueAt: Value(dueAt),
        paidAt: sale.isPaid ? Value(now) : const Value.absent(),
        createdAt: now,
      );

      await _db.invoicesDao.upsertInvoice(companion);

      // توليد وأرشفة PDF
      await _generateAndArchivePdf(
        invoiceId: id,
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName ?? 'كاشير',
        invoiceNumber: invoiceNumber,
        invoiceType: type,
      );

      return _db.invoicesDao.getById(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: createFromSale failed: $e');
      }
      return null;
    }
  }

  /// إنشاء إشعار دائن (مرتجع)
  Future<InvoicesTableData?> createCreditNote({
    required String storeId,
    required String refInvoiceId,
    required String reason,
    required double amount,
    required double taxAmount,
    String? orgId,
    String? customerId,
    String? customerName,
    String? createdBy,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final invoiceNumber = await _generateInvoiceNumber(
        storeId: storeId,
        type: InvoiceType.creditNote,
      );

      final companion = InvoicesTableCompanion.insert(
        id: id,
        orgId: Value(orgId),
        storeId: storeId,
        invoiceNumber: invoiceNumber,
        invoiceType: const Value('credit_note'),
        status: const Value('issued'),
        refInvoiceId: Value(refInvoiceId),
        refReason: Value(reason),
        customerId: Value(customerId),
        customerName: Value(customerName),
        subtotal: Value(amount),
        taxAmount: Value(taxAmount),
        total: Value(amount + taxAmount),
        amountPaid: Value(amount + taxAmount),
        createdBy: Value(createdBy),
        issuedAt: Value(now),
        createdAt: now,
      );

      await _db.invoicesDao.upsertInvoice(companion);
      return _db.invoicesDao.getById(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: createCreditNote failed: $e');
      }
      return null;
    }
  }

  /// إنشاء إشعار مدين (تعديل بالزيادة)
  Future<InvoicesTableData?> createDebitNote({
    required String storeId,
    required String refInvoiceId,
    required String reason,
    required double amount,
    required double taxAmount,
    String? orgId,
    String? customerId,
    String? customerName,
    String? createdBy,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final invoiceNumber = await _generateInvoiceNumber(
        storeId: storeId,
        type: InvoiceType.debitNote,
      );

      final companion = InvoicesTableCompanion.insert(
        id: id,
        orgId: Value(orgId),
        storeId: storeId,
        invoiceNumber: invoiceNumber,
        invoiceType: const Value('debit_note'),
        status: const Value('issued'),
        refInvoiceId: Value(refInvoiceId),
        refReason: Value(reason),
        customerId: Value(customerId),
        customerName: Value(customerName),
        subtotal: Value(amount),
        taxAmount: Value(taxAmount),
        total: Value(amount + taxAmount),
        amountDue: Value(amount + taxAmount),
        createdBy: Value(createdBy),
        issuedAt: Value(now),
        createdAt: now,
      );

      await _db.invoicesDao.upsertInvoice(companion);
      return _db.invoicesDao.getById(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: createDebitNote failed: $e');
      }
      return null;
    }
  }

  // ═══════════ الترقيم ═══════════

  /// توليد رقم فاتورة تسلسلي
  ///
  /// الصيغة: {PREFIX}-{YEAR}-{SEQUENCE:5}
  /// مثال: INV-2026-00001, CN-2026-00002
  Future<String> _generateInvoiceNumber({
    required String storeId,
    required InvoiceType type,
  }) async {
    final year = DateTime.now().year;
    final lastSeq = await _db.invoicesDao.getLastSequence(
      storeId,
      type.prefix,
      year,
    );
    final nextSeq = (lastSeq + 1).toString().padLeft(5, '0');
    return '${type.prefix}-$year-$nextSeq';
  }

  // ═══════════ PDF ═══════════

  /// توليد وأرشفة PDF للفاتورة
  Future<void> _generateAndArchivePdf({
    required String invoiceId,
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    required StoreInfo store,
    required String cashierName,
    required String invoiceNumber,
    required InvoiceType invoiceType,
  }) async {
    try {
      // توليد PDF
      final pdfBytes = await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
      );

      // أرشفة في Supabase Storage (إذا متاح)
      if (_uploadService != null) {
        final pdfUrl = await _uploadService.archiveInvoicePdf(
          storeId: sale.storeId,
          invoiceNumber: invoiceNumber,
          pdfBytes: pdfBytes,
        );

        if (pdfUrl != null) {
          await _db.invoicesDao.updatePdfUrl(invoiceId, pdfUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: PDF generation/archive failed: $e');
      }
    }
  }

  /// إعادة توليد PDF لفاتورة موجودة
  Future<Uint8List?> regeneratePdf({
    required String invoiceId,
    required SalesTableData sale,
    required List<SaleItemsTableData> items,
    StoreInfo store = StoreInfo.defaultStore,
    String cashierName = 'كاشير',
  }) async {
    try {
      return await ReceiptPdfGenerator.generate(
        sale: sale,
        items: items,
        store: store,
        cashierName: cashierName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InvoiceService: regeneratePdf failed: $e');
      }
      return null;
    }
  }
}
