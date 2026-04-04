import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';

/// Complete ZATCA Phase 2 invoice model
///
/// Contains all fields required by ZATCA for UBL 2.1 e-invoicing,
/// including seller/buyer info, line items, tax totals, and metadata.
class ZatcaInvoice {
  // ─── Identity ──────────────────────────────────────────────

  /// Invoice number (BT-1)
  final String invoiceNumber;

  /// UUID (BT-124) - unique identifier for this invoice
  final String uuid;

  /// Issue date (BT-2) in format yyyy-MM-dd
  final DateTime issueDate;

  /// Issue time (KSA-25) in format HH:mm:ss
  final DateTime issueTime;

  // ─── Type ──────────────────────────────────────────────────

  /// Invoice type code (BT-3): 388=standard, 381=credit, 383=debit
  final InvoiceTypeCode typeCode;

  /// Invoice sub-type (7-char flag string, e.g. '0100000')
  final String subType;

  /// Currency code (BT-5), default SAR
  final String currencyCode;

  // ─── Parties ───────────────────────────────────────────────

  /// Seller information
  final ZatcaSeller seller;

  /// Buyer information (optional for simplified invoices)
  final ZatcaBuyer? buyer;

  // ─── Line Items ────────────────────────────────────────────

  /// Invoice line items
  final List<ZatcaInvoiceLine> lines;

  // ─── Document-Level Allowance/Charge ───────────────────────

  /// Document-level discount amount (BT-107)
  final double documentDiscount;

  /// Document-level discount reason
  final String? documentDiscountReason;

  // ─── Payment ───────────────────────────────────────────────

  /// Payment means code (BT-81): 10=cash, 30=credit, 42=bank, 48=card
  final String paymentMeansCode;

  /// Additional payment instructions note
  final String? paymentNote;

  // ─── References ────────────────────────────────────────────

  /// Original invoice reference (for credit/debit notes) (BT-25)
  final String? billingReferenceId;

  /// Purchase order reference (BT-13)
  final String? purchaseOrderId;

  /// Contract reference (BT-12)
  final String? contractId;

  // ─── ZATCA-specific ────────────────────────────────────────

  /// Previous invoice hash for chaining (KSA-13)
  final String? previousInvoiceHash;

  /// QR code data (KSA-16)
  final String? qrCode;

  /// Digital signature (signed XML)
  final String? signedXml;

  /// Invoice hash (SHA-256 of canonical XML)
  final String? invoiceHash;

  // ─── Submission Status ─────────────────────────────────────

  /// Invoice Counter Value (ICV) - sequential integer required by ZATCA
  ///
  /// Must be a pure numeric counter (1, 2, 3, ...) without any prefix.
  /// If null, falls back to extracting digits from [invoiceNumber].
  final int? invoiceCounterValue;

  /// Current reporting status
  final ReportingStatus reportingStatus;

  /// ZATCA response warnings
  final List<String> warnings;

  /// ZATCA response errors
  final List<String> errors;

  const ZatcaInvoice({
    required this.invoiceNumber,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.typeCode,
    required this.subType,
    this.currencyCode = 'SAR',
    required this.seller,
    this.buyer,
    required this.lines,
    this.documentDiscount = 0.0,
    this.documentDiscountReason,
    this.paymentMeansCode = '10',
    this.paymentNote,
    this.billingReferenceId,
    this.purchaseOrderId,
    this.contractId,
    this.previousInvoiceHash,
    this.qrCode,
    this.signedXml,
    this.invoiceHash,
    this.invoiceCounterValue,
    this.reportingStatus = ReportingStatus.pending,
    this.warnings = const [],
    this.errors = const [],
  });

  // ─── Computed Totals ───────────────────────────────────────

  /// Sum of all line net amounts
  double get totalLineNetAmount =>
      lines.fold(0.0, (sum, line) => sum + line.lineNetAmount);

  /// Total allowance (document-level discount)
  double get totalAllowance => documentDiscount;

  /// Taxable amount = totalLineNetAmount - totalAllowance
  double get taxableAmount => totalLineNetAmount - totalAllowance;

  /// Total VAT amount
  double get totalVatAmount =>
      lines.fold(0.0, (sum, line) => sum + line.vatAmount);

  /// Total with VAT
  double get totalWithVat => taxableAmount + totalVatAmount;

  /// Whether this is a simplified (B2C) invoice
  bool get isSimplified => subType.startsWith('02');

  /// Whether this is a standard (B2B) invoice
  bool get isStandard => subType.startsWith('01');

  // ─── Copy ──────────────────────────────────────────────────

  /// Resolved ICV: uses [invoiceCounterValue] if set, otherwise
  /// extracts digits from [invoiceNumber] as fallback.
  String get resolvedIcv {
    if (invoiceCounterValue != null) {
      return invoiceCounterValue.toString();
    }
    // Fallback: extract digits from invoiceNumber (e.g. "INV-2026-00001" → "202600001")
    final digits = invoiceNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty ? digits : '1';
  }

  ZatcaInvoice copyWith({
    String? invoiceNumber,
    String? uuid,
    DateTime? issueDate,
    DateTime? issueTime,
    InvoiceTypeCode? typeCode,
    String? subType,
    String? currencyCode,
    ZatcaSeller? seller,
    ZatcaBuyer? buyer,
    List<ZatcaInvoiceLine>? lines,
    double? documentDiscount,
    String? documentDiscountReason,
    String? paymentMeansCode,
    String? paymentNote,
    String? billingReferenceId,
    String? purchaseOrderId,
    String? contractId,
    String? previousInvoiceHash,
    String? qrCode,
    String? signedXml,
    String? invoiceHash,
    int? invoiceCounterValue,
    ReportingStatus? reportingStatus,
    List<String>? warnings,
    List<String>? errors,
  }) {
    return ZatcaInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      uuid: uuid ?? this.uuid,
      issueDate: issueDate ?? this.issueDate,
      issueTime: issueTime ?? this.issueTime,
      typeCode: typeCode ?? this.typeCode,
      subType: subType ?? this.subType,
      currencyCode: currencyCode ?? this.currencyCode,
      seller: seller ?? this.seller,
      buyer: buyer ?? this.buyer,
      lines: lines ?? this.lines,
      documentDiscount: documentDiscount ?? this.documentDiscount,
      documentDiscountReason:
          documentDiscountReason ?? this.documentDiscountReason,
      paymentMeansCode: paymentMeansCode ?? this.paymentMeansCode,
      paymentNote: paymentNote ?? this.paymentNote,
      billingReferenceId: billingReferenceId ?? this.billingReferenceId,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      contractId: contractId ?? this.contractId,
      previousInvoiceHash: previousInvoiceHash ?? this.previousInvoiceHash,
      qrCode: qrCode ?? this.qrCode,
      signedXml: signedXml ?? this.signedXml,
      invoiceHash: invoiceHash ?? this.invoiceHash,
      invoiceCounterValue: invoiceCounterValue ?? this.invoiceCounterValue,
      reportingStatus: reportingStatus ?? this.reportingStatus,
      warnings: warnings ?? this.warnings,
      errors: errors ?? this.errors,
    );
  }
}
