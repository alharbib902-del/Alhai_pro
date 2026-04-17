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

  setUp(() {
    validator = InvoiceXmlValidator();
    builder = UblInvoiceBuilder();
  });

  ZatcaInvoice validInvoice() => ZatcaInvoice(
    invoiceNumber: 'INV-001',
    uuid: '550e8400-e29b-41d4-a716-446655440000',
    issueDate: DateTime(2026, 4, 10),
    issueTime: DateTime(2026, 4, 10, 12, 0, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardB2B,
    seller: const ZatcaSeller(
      name: 'Test Seller',
      vatNumber: '310122393500003',
      streetName: 'King Fahd Rd',
      buildingNumber: '1234',
      city: 'Riyadh',
      postalCode: '12345',
      region: 'Riyadh Region',
    ),
    buyer: const ZatcaBuyer(
      name: 'Buyer Co',
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
        itemName: 'Widget',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15.0,
        vatCategoryCode: 'S',
      ),
    ],
  );

  group('InvoiceXmlValidator', () {
    test('passes a fully valid invoice XML', () {
      final xml = builder.build(validInvoice());
      final result = validator.validate(xml);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('catches unparseable XML', () {
      final result = validator.validate('<broken');

      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'PARSE_ERROR'), isTrue);
    });

    test('catches wrong root element', () {
      final result = validator.validate(
        '<?xml version="1.0"?><CreditNote></CreditNote>',
      );

      expect(result.hasErrors, isTrue);
      expect(result.errors.any((e) => e.code == 'INVALID_ROOT'), isTrue);
    });

    test('catches missing ProfileID', () {
      // Build XML then strip ProfileID
      var xml = builder.build(validInvoice());
      xml = xml.replaceAll(RegExp(r'<cbc:ProfileID>.*?</cbc:ProfileID>'), '');
      final result = validator.validate(xml);

      expect(result.errors.any((e) => e.code == 'MISSING_PROFILEID'), isTrue);
    });

    test('catches missing invoice lines', () {
      // Build with lines then remove them
      var xml = builder.build(validInvoice());
      xml = xml.replaceAll(
        RegExp(r'<cac:InvoiceLine>[\s\S]*?</cac:InvoiceLine>'),
        '',
      );
      final result = validator.validate(xml);

      expect(
        result.errors.any((e) => e.code == 'MISSING_INVOICE_LINES'),
        isTrue,
      );
    });

    test('catches missing TaxTotal elements', () {
      var xml = builder.build(validInvoice());
      xml = xml.replaceAll(
        RegExp(r'<cac:TaxTotal>[\s\S]*?</cac:TaxTotal>'),
        '',
      );
      final result = validator.validate(xml);

      expect(result.errors.any((e) => e.code == 'MISSING_TAX_TOTALS'), isTrue);
    });

    test('warns when CountrySubentity is missing', () {
      final invoiceNoRegion = ZatcaInvoice(
        invoiceNumber: 'INV-002',
        uuid: '550e8400-e29b-41d4-a716-446655440001',
        issueDate: DateTime(2026, 4, 10),
        issueTime: DateTime(2026, 4, 10, 12, 0, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '310122393500003',
          streetName: 'St',
          buildingNumber: '1',
          city: 'Riyadh',
          postalCode: '12345',
          // region is null
        ),
        lines: const [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'A',
            quantity: 1,
            unitPrice: 10.0,
            vatRate: 15.0,
          ),
        ],
      );
      final xml = builder.build(invoiceNoRegion);
      final result = validator.validate(xml);

      expect(
        result.warnings.any((w) => w.code == 'MISSING_COUNTRY_SUBENTITY'),
        isTrue,
        reason: 'Should warn when seller CountrySubentity is missing',
      );
    });
  });

  group('InvoiceXmlValidator.validateSigned', () {
    test('delegates to validate() for structural checks', () {
      final xml = builder.build(validInvoice());
      final result = validator.validateSigned(xml);

      // validateSigned should return same result as validate
      final baseResult = validator.validate(xml);
      expect(result.errors.length, equals(baseResult.errors.length));
      expect(result.isValid, equals(baseResult.isValid));
    });
  });
}
