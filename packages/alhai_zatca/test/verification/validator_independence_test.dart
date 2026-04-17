/// Independent verification for Fix #4: XML Validator (with cascade fix).
///
/// Verifies that:
/// 1. Validator works WITHOUT SignaturePolicyIdentifier (post-revert)
/// 2. Validator catches real structural defects
/// 3. Validator handles malformed/empty/non-XML input gracefully
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/services/invoice_xml_validator.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

void main() {
  late InvoiceXmlValidator validator;
  late UblInvoiceBuilder builder;
  late String validXml;

  setUp(() {
    validator = InvoiceXmlValidator();
    builder = UblInvoiceBuilder();
    validXml = builder.build(validInvoice());
  });

  group('VERIFICATION — Fix #4: Validator post-cascade-fix', () {
    // -----------------------------------------------------------------------
    // 1. Validator works without SignaturePolicyIdentifier
    // -----------------------------------------------------------------------
    test('valid XML passes validate() without errors', () {
      final result = validator.validate(validXml);
      expect(result.isValid, isTrue, reason: 'Valid invoice must pass');
      expect(result.errors, isEmpty);
    });

    test('valid XML passes validateSigned() without errors', () {
      // After Fix #2 revert, validateSigned should not require
      // SignaturePolicyIdentifier
      final result = validator.validateSigned(validXml);
      expect(
        result.isValid,
        isTrue,
        reason: 'validateSigned must work without SignaturePolicyIdentifier',
      );
    });

    // -----------------------------------------------------------------------
    // 2. Validator catches real structural defects
    // -----------------------------------------------------------------------
    test('catches missing <cbc:ID>', () {
      final xml = validXml.replaceAll(
        RegExp(r'<cbc:ID>INV-VERIFY-001</cbc:ID>'),
        '',
      );
      final result = validator.validate(xml);
      expect(
        result.errors.any((e) => e.code == 'MISSING_ID'),
        isTrue,
        reason: 'Must detect missing ID',
      );
    });

    test('catches missing <cbc:IssueDate>', () {
      final xml = validXml.replaceAll(
        RegExp(r'<cbc:IssueDate>[^<]+</cbc:IssueDate>'),
        '',
      );
      final result = validator.validate(xml);
      expect(
        result.errors.any((e) => e.code == 'MISSING_ISSUEDATE'),
        isTrue,
        reason: 'Must detect missing IssueDate',
      );
    });

    test('catches missing TaxTotal', () {
      final xml = validXml.replaceAll(
        RegExp(r'<cac:TaxTotal>[\s\S]*?</cac:TaxTotal>'),
        '',
      );
      final result = validator.validate(xml);
      expect(
        result.errors.any((e) => e.code == 'MISSING_TAX_TOTALS'),
        isTrue,
        reason: 'Must detect missing TaxTotal',
      );
    });

    test('catches missing LegalMonetaryTotal', () {
      final xml = validXml.replaceAll(
        RegExp(r'<cac:LegalMonetaryTotal>[\s\S]*?</cac:LegalMonetaryTotal>'),
        '',
      );
      final result = validator.validate(xml);
      expect(
        result.errors.any((e) => e.code == 'MISSING_LEGALMONETARYTOTAL'),
        isTrue,
        reason: 'Must detect missing LegalMonetaryTotal',
      );
    });

    test('catches missing InvoiceLine', () {
      final xml = validXml.replaceAll(
        RegExp(r'<cac:InvoiceLine>[\s\S]*?</cac:InvoiceLine>'),
        '',
      );
      final result = validator.validate(xml);
      expect(
        result.errors.any((e) => e.code == 'MISSING_INVOICE_LINES'),
        isTrue,
        reason: 'Must detect missing InvoiceLine',
      );
    });

    test('catches wrong root element', () {
      final result = validator.validate('<?xml version="1.0"?><Order></Order>');
      expect(
        result.errors.any((e) => e.code == 'INVALID_ROOT'),
        isTrue,
        reason: 'Non-Invoice root must be rejected',
      );
    });

    // -----------------------------------------------------------------------
    // 3. Handles malformed/empty/non-XML input
    // -----------------------------------------------------------------------
    test('handles incomplete XML (parse error)', () {
      final result = validator.validate('<Invoice><cbc:ID>broken');
      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'PARSE_ERROR'), isTrue);
    });

    test('handles empty string', () {
      final result = validator.validate('');
      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'PARSE_ERROR'), isTrue);
    });

    test('handles non-XML string', () {
      final result = validator.validate('not xml at all');
      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'PARSE_ERROR'), isTrue);
    });

    test('validateSigned also handles malformed XML', () {
      final result = validator.validateSigned('totally broken <xml');
      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'PARSE_ERROR'), isTrue);
    });
  });
}

ZatcaInvoice validInvoice() => ZatcaInvoice(
  invoiceNumber: 'INV-VERIFY-001',
  uuid: '550e8400-e29b-41d4-a716-446655440088',
  issueDate: DateTime(2026, 4, 14),
  issueTime: DateTime(2026, 4, 14, 10, 0, 0),
  typeCode: InvoiceTypeCode.standard,
  subType: InvoiceSubType.standardB2B,
  seller: const ZatcaSeller(
    name: 'Verify Seller',
    vatNumber: '310122393500003',
    streetName: 'King Fahd Rd',
    buildingNumber: '1234',
    city: 'Riyadh',
    postalCode: '12345',
    region: 'Riyadh Region',
  ),
  buyer: const ZatcaBuyer(
    name: 'Verify Buyer',
    vatNumber: '399999999900003',
    streetName: 'Main St',
    buildingNumber: '5678',
    city: 'Jeddah',
    postalCode: '21589',
    countryCode: 'SA',
  ),
  lines: const [
    ZatcaInvoiceLine(
      lineId: '1',
      itemName: 'Verification Widget',
      quantity: 2,
      unitPrice: 100.0,
      vatRate: 15.0,
      vatCategoryCode: 'S',
    ),
  ],
);
