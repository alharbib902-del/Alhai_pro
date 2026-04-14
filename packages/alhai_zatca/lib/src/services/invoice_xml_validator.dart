import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/xml/ubl_namespaces.dart';

/// Validates a generated ZATCA invoice XML against structural requirements.
///
/// This validator inspects the XML *output* (after generation, before or after
/// signing) to catch missing elements that would cause ZATCA rejection.  It
/// complements [ZatcaComplianceChecker] which validates the *model* input.
class InvoiceXmlValidator {
  /// Validate an invoice XML string.
  ///
  /// Returns [XmlValidationResult] with errors and warnings.
  XmlValidationResult validate(String invoiceXml) {
    final errors = <XmlValidationError>[];
    final warnings = <XmlValidationWarning>[];

    late XmlDocument document;
    try {
      document = XmlDocument.parse(invoiceXml);
    } catch (e) {
      errors.add(XmlValidationError('PARSE_ERROR', 'XML parsing failed: $e'));
      return XmlValidationResult(errors: errors, warnings: warnings);
    }

    final root = document.rootElement;

    // 1. Root element
    if (root.name.local != 'Invoice') {
      errors.add(XmlValidationError(
        'INVALID_ROOT',
        'Root element must be Invoice, got ${root.name.local}',
      ));
      return XmlValidationResult(errors: errors, warnings: warnings);
    }

    // 2. Required header fields
    _requireChild(root, 'ProfileID', errors);
    _requireChild(root, 'ID', errors);
    _requireChild(root, 'UUID', errors);
    _requireChild(root, 'IssueDate', errors);
    _requireChild(root, 'IssueTime', errors);
    _requireChild(root, 'InvoiceTypeCode', errors);
    _requireChild(root, 'DocumentCurrencyCode', errors);
    _requireChild(root, 'TaxCurrencyCode', errors);

    // 3. Parties
    _validateSupplierParty(root, errors, warnings);
    _validateCustomerParty(root, errors, warnings);

    // 4. Tax totals
    _validateTaxTotals(root, errors);

    // 5. Legal monetary total
    _requireDescendant(root, 'LegalMonetaryTotal', errors);

    // 6. Invoice lines
    final lines = root.childElements
        .where((e) => e.name.local == 'InvoiceLine')
        .toList();
    if (lines.isEmpty) {
      errors.add(const XmlValidationError(
        'MISSING_INVOICE_LINES',
        'At least one InvoiceLine is required',
      ));
    }

    // 7. ZATCA-specific: ICV document reference
    _validateDocumentReference(root, 'ICV', errors);

    return XmlValidationResult(errors: errors, warnings: warnings);
  }

  /// Validate the signed XML (after XAdES signing).
  ///
  /// Includes all checks from [validate] plus signature-specific checks.
  XmlValidationResult validateSigned(String signedXml) {
    final result = validate(signedXml);
    final errors = List<XmlValidationError>.from(result.errors);
    final warnings = List<XmlValidationWarning>.from(result.warnings);

    // Don't check signature elements if parsing already failed
    if (errors.any((e) => e.code == 'PARSE_ERROR')) {
      return XmlValidationResult(errors: errors, warnings: warnings);
    }

    // Check SignaturePolicyIdentifier (Fix #2)
    if (!signedXml.contains('SignaturePolicyIdentifier')) {
      errors.add(const XmlValidationError(
        'MISSING_SIGNATURE_POLICY',
        'XAdES SignaturePolicyIdentifier is required by ZATCA Phase 2',
      ));
    }

    // Check policy URN
    if (signedXml.contains('SignaturePolicyIdentifier') &&
        !signedXml.contains('urn:oid:1.2.250.1.97.1.0.1')) {
      errors.add(const XmlValidationError(
        'WRONG_POLICY_URN',
        'SignaturePolicyIdentifier must use URN urn:oid:1.2.250.1.97.1.0.1',
      ));
    }

    return XmlValidationResult(errors: errors, warnings: warnings);
  }

  // ─── Private helpers ──────────────────────────────────────

  void _validateSupplierParty(
    XmlElement root,
    List<XmlValidationError> errors,
    List<XmlValidationWarning> warnings,
  ) {
    final suppliers =
        root.findAllElements('AccountingSupplierParty', namespace: '*');
    if (suppliers.isEmpty) {
      errors.add(const XmlValidationError(
        'MISSING_SUPPLIER',
        'AccountingSupplierParty is required',
      ));
      return;
    }

    final party = suppliers.first.findAllElements('Party', namespace: '*');
    if (party.isEmpty) return;

    final address =
        party.first.findAllElements('PostalAddress', namespace: '*');
    if (address.isEmpty) {
      errors.add(const XmlValidationError(
        'MISSING_SUPPLIER_ADDRESS',
        'Seller PostalAddress is required',
      ));
      return;
    }

    _requireChild(address.first, 'StreetName', errors);
    _requireChild(address.first, 'BuildingNumber', errors);
    _requireChild(address.first, 'CityName', errors);
    _requireChild(address.first, 'PostalZone', errors);

    // CountrySubentity check (Fix #3)
    final subentities =
        address.first.findAllElements('CountrySubentity', namespace: '*');
    if (subentities.isEmpty) {
      warnings.add(const XmlValidationWarning(
        'MISSING_COUNTRY_SUBENTITY',
        'Seller PostalAddress should contain CountrySubentity per UBL 2.1',
      ));
    }

    // Country
    final countries =
        address.first.findAllElements('Country', namespace: '*');
    if (countries.isEmpty) {
      errors.add(const XmlValidationError(
        'MISSING_SELLER_COUNTRY',
        'Seller Country element is required',
      ));
    }
  }

  void _validateCustomerParty(
    XmlElement root,
    List<XmlValidationError> errors,
    List<XmlValidationWarning> warnings,
  ) {
    final customers =
        root.findAllElements('AccountingCustomerParty', namespace: '*');
    if (customers.isEmpty) {
      errors.add(const XmlValidationError(
        'MISSING_CUSTOMER',
        'AccountingCustomerParty is required',
      ));
    }
    // Buyer postal address is optional for simplified invoices
  }

  void _validateTaxTotals(
    XmlElement root,
    List<XmlValidationError> errors,
  ) {
    final taxTotals =
        root.childElements.where((e) => e.name.local == 'TaxTotal').toList();
    if (taxTotals.length < 2) {
      errors.add(XmlValidationError(
        'MISSING_TAX_TOTALS',
        'ZATCA requires exactly 2 TaxTotal elements at invoice level '
            '(found ${taxTotals.length})',
      ));
    }
  }

  void _validateDocumentReference(
    XmlElement root,
    String expectedUuid,
    List<XmlValidationError> errors,
  ) {
    final refs =
        root.findAllElements('AdditionalDocumentReference', namespace: '*');
    final hasRef = refs.any((ref) {
      final uuids = ref.findAllElements('UUID', namespace: '*');
      return uuids.any((u) => u.innerText == expectedUuid);
    });
    if (!hasRef) {
      errors.add(XmlValidationError(
        'MISSING_$expectedUuid',
        'AdditionalDocumentReference with UUID=$expectedUuid is required',
      ));
    }
  }

  void _requireChild(
    XmlElement parent,
    String localName,
    List<XmlValidationError> errors,
  ) {
    final found = parent.childElements.any((e) => e.name.local == localName);
    if (!found) {
      errors.add(XmlValidationError(
        'MISSING_$localName'.toUpperCase(),
        '$localName element is required in ${parent.name.local}',
      ));
    }
  }

  void _requireDescendant(
    XmlElement root,
    String localName,
    List<XmlValidationError> errors,
  ) {
    final found = root.findAllElements(localName, namespace: '*');
    if (found.isEmpty) {
      errors.add(XmlValidationError(
        'MISSING_$localName'.toUpperCase(),
        '$localName element is required',
      ));
    }
  }
}

/// An error from XML structural validation.
class XmlValidationError {
  final String code;
  final String message;

  const XmlValidationError(this.code, this.message);

  @override
  String toString() => '[$code] $message';
}

/// A warning from XML structural validation.
class XmlValidationWarning {
  final String code;
  final String message;

  const XmlValidationWarning(this.code, this.message);

  @override
  String toString() => '[$code] $message';
}

/// Result of XML structural validation.
class XmlValidationResult {
  final List<XmlValidationError> errors;
  final List<XmlValidationWarning> warnings;

  const XmlValidationResult({
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => errors.isEmpty;
}
