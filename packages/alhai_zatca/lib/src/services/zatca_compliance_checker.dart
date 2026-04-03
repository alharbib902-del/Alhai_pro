import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';

/// Pre-submission validation of ZATCA invoices
///
/// Validates that an invoice meets all ZATCA Phase 2 requirements
/// before attempting XML generation and signing.
class ZatcaComplianceChecker {
  /// Validate an invoice against ZATCA business rules
  ///
  /// Returns a list of validation errors. Empty list means valid.
  List<ComplianceError> validate(ZatcaInvoice invoice) {
    final errors = <ComplianceError>[];

    // ─── Identity Checks ────────────────────────────────────
    _validateIdentity(invoice, errors);

    // ─── Type & SubType Checks ──────────────────────────────
    _validateTypeCode(invoice, errors);

    // ─── Seller Validation ──────────────────────────────────
    _validateSeller(invoice, errors);

    // ─── Buyer Validation ───────────────────────────────────
    _validateBuyer(invoice, errors);

    // ─── Line Items Validation ──────────────────────────────
    _validateLines(invoice, errors);

    // ─── Amount Consistency ─────────────────────────────────
    _validateAmounts(invoice, errors);

    // ─── Credit/Debit Note Reference ────────────────────────
    _validateBillingReference(invoice, errors);

    // ─── Currency ───────────────────────────────────────────
    _validateCurrency(invoice, errors);

    return errors;
  }

  /// Quick check - is the invoice valid?
  bool isValid(ZatcaInvoice invoice) => validate(invoice).isEmpty;

  /// Validate and return a result object
  ComplianceResult check(ZatcaInvoice invoice) {
    final errors = validate(invoice);
    return ComplianceResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ─── Private Validation Methods ───────────────────────────

  void _validateIdentity(ZatcaInvoice invoice, List<ComplianceError> errors) {
    if (invoice.invoiceNumber.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-1',
        field: 'invoiceNumber',
        message: 'Invoice number is required',
        severity: ComplianceSeverity.error,
      ));
    }
    if (invoice.uuid.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-124',
        field: 'uuid',
        message: 'Invoice UUID is required',
        severity: ComplianceSeverity.error,
      ));
    }
    // UUID format check (should be a valid v4 UUID)
    if (invoice.uuid.isNotEmpty &&
        !RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
            .hasMatch(invoice.uuid)) {
      errors.add(const ComplianceError(
        code: 'BT-124',
        field: 'uuid',
        message: 'Invoice UUID must be a valid UUID format',
        severity: ComplianceSeverity.error,
      ));
    }
  }

  void _validateTypeCode(ZatcaInvoice invoice, List<ComplianceError> errors) {
    // Validate subType is a 7-character binary string
    if (invoice.subType.length != 7 ||
        !RegExp(r'^[0-9]{7}$').hasMatch(invoice.subType)) {
      errors.add(const ComplianceError(
        code: 'KSA-2',
        field: 'subType',
        message: 'Invoice sub-type must be a 7-digit code (e.g., 0100000)',
        severity: ComplianceSeverity.error,
      ));
    }

    // Validate payment means code
    final validPaymentCodes = ['10', '30', '42', '48', '1'];
    if (!validPaymentCodes.contains(invoice.paymentMeansCode)) {
      errors.add(ComplianceError(
        code: 'BT-81',
        field: 'paymentMeansCode',
        message: 'Invalid payment means code: ${invoice.paymentMeansCode}. '
            'Must be one of: ${validPaymentCodes.join(', ')}',
        severity: ComplianceSeverity.warning,
      ));
    }
  }

  void _validateSeller(ZatcaInvoice invoice, List<ComplianceError> errors) {
    final seller = invoice.seller;

    if (seller.name.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-27',
        field: 'seller.name',
        message: 'Seller name is required',
        severity: ComplianceSeverity.error,
      ));
    }

    if (!seller.isVatValid) {
      errors.add(const ComplianceError(
        code: 'BT-31',
        field: 'seller.vatNumber',
        message:
            'Invalid seller VAT number format (must be 15 digits starting with 3)',
        severity: ComplianceSeverity.error,
      ));
    }

    if (seller.streetName.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-35',
        field: 'seller.streetName',
        message: 'Seller street name is required',
        severity: ComplianceSeverity.error,
      ));
    }

    if (seller.buildingNumber.isEmpty) {
      errors.add(const ComplianceError(
        code: 'KSA-17',
        field: 'seller.buildingNumber',
        message: 'Seller building number is required',
        severity: ComplianceSeverity.error,
      ));
    }

    if (seller.city.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-37',
        field: 'seller.city',
        message: 'Seller city is required',
        severity: ComplianceSeverity.error,
      ));
    }

    if (seller.postalCode.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BT-38',
        field: 'seller.postalCode',
        message: 'Seller postal code is required',
        severity: ComplianceSeverity.error,
      ));
    }

    // Postal code format (5 digits for Saudi Arabia)
    if (seller.postalCode.isNotEmpty &&
        !RegExp(r'^\d{5}$').hasMatch(seller.postalCode)) {
      errors.add(const ComplianceError(
        code: 'BT-38',
        field: 'seller.postalCode',
        message: 'Seller postal code must be 5 digits',
        severity: ComplianceSeverity.warning,
      ));
    }

    if (seller.countryCode != 'SA') {
      errors.add(const ComplianceError(
        code: 'BT-40',
        field: 'seller.countryCode',
        message: 'Seller country code must be SA',
        severity: ComplianceSeverity.error,
      ));
    }
  }

  void _validateBuyer(ZatcaInvoice invoice, List<ComplianceError> errors) {
    // Buyer info is required for standard (B2B) invoices
    if (invoice.isStandard) {
      if (invoice.buyer == null) {
        errors.add(const ComplianceError(
          code: 'BT-44',
          field: 'buyer',
          message: 'Buyer information is required for standard (B2B) invoices',
          severity: ComplianceSeverity.error,
        ));
        return;
      }

      if (!invoice.buyer!.isValidForStandard) {
        errors.add(const ComplianceError(
          code: 'BT-44',
          field: 'buyer',
          message:
              'Buyer name and VAT number are required for standard invoices',
          severity: ComplianceSeverity.error,
        ));
      }

      // Validate buyer VAT if provided
      if (invoice.buyer!.vatNumber != null &&
          invoice.buyer!.vatNumber!.isNotEmpty) {
        final vat = invoice.buyer!.vatNumber!;
        if (vat.length != 15 || !vat.startsWith('3') || !RegExp(r'^\d+$').hasMatch(vat)) {
          errors.add(const ComplianceError(
            code: 'BT-48',
            field: 'buyer.vatNumber',
            message:
                'Invalid buyer VAT number format (must be 15 digits starting with 3)',
            severity: ComplianceSeverity.error,
          ));
        }
      }
    }
  }

  void _validateLines(ZatcaInvoice invoice, List<ComplianceError> errors) {
    if (invoice.lines.isEmpty) {
      errors.add(const ComplianceError(
        code: 'BG-25',
        field: 'lines',
        message: 'At least one invoice line is required',
        severity: ComplianceSeverity.error,
      ));
      return;
    }

    for (var i = 0; i < invoice.lines.length; i++) {
      final line = invoice.lines[i];

      if (line.itemName.isEmpty) {
        errors.add(ComplianceError(
          code: 'BT-153',
          field: 'lines[$i].itemName',
          message: 'Line ${line.lineId}: item name is required',
          severity: ComplianceSeverity.error,
        ));
      }

      if (line.quantity <= 0) {
        errors.add(ComplianceError(
          code: 'BT-129',
          field: 'lines[$i].quantity',
          message: 'Line ${line.lineId}: quantity must be positive',
          severity: ComplianceSeverity.error,
        ));
      }

      if (line.unitPrice < 0) {
        errors.add(ComplianceError(
          code: 'BT-146',
          field: 'lines[$i].unitPrice',
          message: 'Line ${line.lineId}: unit price cannot be negative',
          severity: ComplianceSeverity.error,
        ));
      }

      // Validate VAT category code
      final validVatCategories = ['S', 'Z', 'E', 'O'];
      if (!validVatCategories.contains(line.vatCategoryCode)) {
        errors.add(ComplianceError(
          code: 'BT-151',
          field: 'lines[$i].vatCategoryCode',
          message: 'Line ${line.lineId}: invalid VAT category code '
              '"${line.vatCategoryCode}". Must be S, Z, E, or O',
          severity: ComplianceSeverity.error,
        ));
      }

      // Check exemption reason for exempt/zero-rated items
      if ((line.vatCategoryCode == 'E' || line.vatCategoryCode == 'Z') &&
          (line.vatExemptionReason == null ||
              line.vatExemptionReason!.isEmpty)) {
        errors.add(ComplianceError(
          code: 'BT-120',
          field: 'lines[$i].vatExemptionReason',
          message:
              'Line ${line.lineId}: exemption reason required for category ${line.vatCategoryCode}',
          severity: ComplianceSeverity.error,
        ));
      }

      // Standard rate must be 15% for category S in Saudi Arabia
      if (line.vatCategoryCode == 'S' && line.vatRate != 15.0) {
        errors.add(ComplianceError(
          code: 'KSA-EN16931-08',
          field: 'lines[$i].vatRate',
          message:
              'Line ${line.lineId}: standard VAT rate must be 15% (got ${line.vatRate}%)',
          severity: ComplianceSeverity.warning,
        ));
      }

      // Zero-rated and exempt items must have 0% VAT
      if ((line.vatCategoryCode == 'Z' || line.vatCategoryCode == 'E') &&
          line.vatRate != 0.0) {
        errors.add(ComplianceError(
          code: 'BT-152',
          field: 'lines[$i].vatRate',
          message:
              'Line ${line.lineId}: VAT rate must be 0% for category ${line.vatCategoryCode}',
          severity: ComplianceSeverity.error,
        ));
      }

      // Discount cannot exceed line amount
      if (line.discountAmount > (line.unitPrice * line.quantity)) {
        errors.add(ComplianceError(
          code: 'BT-136',
          field: 'lines[$i].discountAmount',
          message:
              'Line ${line.lineId}: discount exceeds line gross amount',
          severity: ComplianceSeverity.error,
        ));
      }
    }
  }

  void _validateAmounts(ZatcaInvoice invoice, List<ComplianceError> errors) {
    // Total with VAT must be non-negative
    if (invoice.totalWithVat < 0) {
      errors.add(const ComplianceError(
        code: 'BT-112',
        field: 'totalWithVat',
        message: 'Invoice total with VAT cannot be negative',
        severity: ComplianceSeverity.error,
      ));
    }

    // Document discount cannot exceed total line net amount
    if (invoice.documentDiscount > invoice.totalLineNetAmount) {
      errors.add(const ComplianceError(
        code: 'BT-107',
        field: 'documentDiscount',
        message: 'Document discount exceeds total line net amount',
        severity: ComplianceSeverity.error,
      ));
    }

    // Verify VAT amount consistency
    final computedVat = invoice.totalVatAmount;
    final taxableAmount = invoice.taxableAmount;
    if (taxableAmount > 0) {
      // Allow a small rounding tolerance (0.02 SAR)
      final expectedVat = taxableAmount * 0.15;
      final allStandard = invoice.lines.every((l) => l.vatCategoryCode == 'S');
      if (allStandard && (computedVat - expectedVat).abs() > 0.02) {
        errors.add(ComplianceError(
          code: 'KSA-EN16931-09',
          field: 'totalVatAmount',
          message:
              'VAT amount ($computedVat) does not match expected '
              '(${expectedVat.toStringAsFixed(2)}) for taxable amount $taxableAmount',
          severity: ComplianceSeverity.warning,
        ));
      }
    }
  }

  void _validateBillingReference(
    ZatcaInvoice invoice,
    List<ComplianceError> errors,
  ) {
    // Credit/debit notes must reference an original invoice
    final isCreditOrDebit = invoice.typeCode == InvoiceTypeCode.creditNote ||
        invoice.typeCode == InvoiceTypeCode.debitNote;

    if (isCreditOrDebit &&
        (invoice.billingReferenceId == null ||
            invoice.billingReferenceId!.isEmpty)) {
      errors.add(const ComplianceError(
        code: 'BT-25',
        field: 'billingReferenceId',
        message:
            'Billing reference (original invoice number) is required for credit/debit notes',
        severity: ComplianceSeverity.error,
      ));
    }
  }

  void _validateCurrency(ZatcaInvoice invoice, List<ComplianceError> errors) {
    // ZATCA invoices must use SAR
    if (invoice.currencyCode != 'SAR') {
      errors.add(ComplianceError(
        code: 'BT-5',
        field: 'currencyCode',
        message:
            'Currency must be SAR for ZATCA invoices (got ${invoice.currencyCode})',
        severity: ComplianceSeverity.error,
      ));
    }
  }
}

/// A compliance validation error
class ComplianceError {
  /// ZATCA field code (e.g., BT-1, KSA-13)
  final String code;

  /// Field path that has the error
  final String field;

  /// Human-readable error message
  final String message;

  /// Severity of the error
  final ComplianceSeverity severity;

  const ComplianceError({
    required this.code,
    this.field = '',
    required this.message,
    this.severity = ComplianceSeverity.error,
  });

  @override
  String toString() => '[$code] $message';
}

/// Severity level of a compliance error
enum ComplianceSeverity {
  /// Blocks submission -- must fix
  error,

  /// Allowed but may cause issues
  warning,

  /// Informational only
  info,
}

/// Result of a compliance check
class ComplianceResult {
  final bool isValid;
  final List<ComplianceError> errors;

  const ComplianceResult({
    required this.isValid,
    required this.errors,
  });

  /// Get only blocking errors (not warnings)
  List<ComplianceError> get blockingErrors =>
      errors.where((e) => e.severity == ComplianceSeverity.error).toList();

  /// Get only warnings
  List<ComplianceError> get warnings =>
      errors.where((e) => e.severity == ComplianceSeverity.warning).toList();

  /// Whether there are only warnings (no blocking errors)
  bool get hasOnlyWarnings => blockingErrors.isEmpty && warnings.isNotEmpty;
}
