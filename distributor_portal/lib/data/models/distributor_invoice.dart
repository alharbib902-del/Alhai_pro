/// Distributor invoice model.
///
/// Maps to the Supabase `invoices` table (v15 migration).
library;

class DistributorInvoice {
  final String id;
  final String? orgId;
  final String storeId;
  final String invoiceNumber;
  final String
  invoiceType; // simplified_tax | standard_tax | credit_note | debit_note
  final String
  status; // draft | issued | sent | paid | partially_paid | overdue | cancelled | archived
  final String? saleId;
  final String? refInvoiceId;
  final String? refReason;

  // Customer
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerVatNumber;
  final String? customerAddress;

  // Amounts
  final double subtotal;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;

  // Payment
  final String? paymentMethod;
  final double amountPaid;
  final double amountDue;
  final String currency;

  // ZATCA
  final String? zatcaHash;
  final String? zatcaQr;
  final String? zatcaUuid;

  // Storage & notes
  final String? pdfUrl;
  final String? notes;

  // Audit
  final String? createdBy;
  final String? cashierName;

  // Timestamps
  final DateTime? issuedAt;
  final DateTime? dueAt;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DistributorInvoice({
    required this.id,
    this.orgId,
    required this.storeId,
    required this.invoiceNumber,
    this.invoiceType = 'standard_tax',
    this.status = 'issued',
    this.saleId,
    this.refInvoiceId,
    this.refReason,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerVatNumber,
    this.customerAddress,
    this.subtotal = 0,
    this.discount = 0,
    this.taxRate = 15,
    this.taxAmount = 0,
    this.total = 0,
    this.paymentMethod,
    this.amountPaid = 0,
    this.amountDue = 0,
    this.currency = 'SAR',
    this.zatcaHash,
    this.zatcaQr,
    this.zatcaUuid,
    this.pdfUrl,
    this.notes,
    this.createdBy,
    this.cashierName,
    this.issuedAt,
    this.dueAt,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory DistributorInvoice.fromJson(Map<String, dynamic> json) {
    return DistributorInvoice(
      id: json['id'] as String,
      orgId: json['org_id'] as String?,
      storeId: json['store_id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? '',
      invoiceType: json['invoice_type'] as String? ?? 'standard_tax',
      status: json['status'] as String? ?? 'issued',
      saleId: json['sale_id'] as String?,
      refInvoiceId: json['ref_invoice_id'] as String?,
      refReason: json['ref_reason'] as String?,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerVatNumber: json['customer_vat_number'] as String?,
      customerAddress: json['customer_address'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 15,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      zatcaHash: json['zatca_hash'] as String?,
      zatcaQr: json['zatca_qr'] as String?,
      zatcaUuid: json['zatca_uuid'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      cashierName: json['cashier_name'] as String?,
      issuedAt: _tryParseDate(json['issued_at']),
      dueAt: _tryParseDate(json['due_at']),
      paidAt: _tryParseDate(json['paid_at']),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  /// JSON for inserting into Supabase (excludes server-managed timestamps).
  Map<String, dynamic> toInsertJson() => {
    'id': id,
    'org_id': orgId,
    'store_id': storeId,
    'invoice_number': invoiceNumber,
    'invoice_type': invoiceType,
    'status': status,
    'sale_id': saleId,
    'ref_invoice_id': refInvoiceId,
    'ref_reason': refReason,
    'customer_id': customerId,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'customer_email': customerEmail,
    'customer_vat_number': customerVatNumber,
    'customer_address': customerAddress,
    'subtotal': subtotal,
    'discount': discount,
    'tax_rate': taxRate,
    'tax_amount': taxAmount,
    'total': total,
    'payment_method': paymentMethod,
    'amount_paid': amountPaid,
    'amount_due': amountDue,
    'currency': currency,
    'zatca_hash': zatcaHash,
    'zatca_qr': zatcaQr,
    'zatca_uuid': zatcaUuid,
    'notes': notes,
    'created_by': createdBy,
    'cashier_name': cashierName,
    'issued_at': issuedAt?.toIso8601String(),
    'due_at': dueAt?.toIso8601String(),
  };

  static DateTime? _tryParseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistributorInvoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceNumber == other.invoiceNumber &&
          storeId == other.storeId &&
          status == other.status &&
          total == other.total;

  @override
  int get hashCode => Object.hash(id, invoiceNumber, storeId, status, total);
}
