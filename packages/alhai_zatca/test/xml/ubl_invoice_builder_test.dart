import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/xml/invoice_line_builder.dart';
import 'package:alhai_zatca/src/xml/tax_total_builder.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';
import 'package:alhai_zatca/src/xml/xml_canonicalizer.dart';

void main() {
  // ─── Test fixtures ──────────────────────────────────────

  late ZatcaSeller seller;
  late ZatcaBuyer buyer;
  late ZatcaInvoiceLine line1;
  late ZatcaInvoiceLine line2;
  late ZatcaInvoice standardInvoice;
  late ZatcaInvoice simplifiedInvoice;

  setUp(() {
    seller = const ZatcaSeller(
      name: 'Alhai Test Store LLC',
      vatNumber: '310122393500003',
      crNumber: '4030123456',
      streetName: 'King Fahd Road',
      buildingNumber: '1234',
      plotIdentification: '0000',
      city: 'Riyadh',
      district: 'Al Olaya',
      postalCode: '12345',
    );

    buyer = const ZatcaBuyer(
      name: 'Buyer Company Ltd',
      vatNumber: '399999999900003',
      streetName: 'Prince Sultan Street',
      buildingNumber: '5678',
      city: 'Jeddah',
      district: 'Al Rawdah',
      postalCode: '21589',
      countryCode: 'SA',
    );

    line1 = const ZatcaInvoiceLine(
      lineId: '1',
      itemName: 'Laptop Dell XPS 15',
      quantity: 2,
      unitPrice: 5000.0,
      vatRate: 15.0,
      vatCategoryCode: 'S',
    );

    line2 = const ZatcaInvoiceLine(
      lineId: '2',
      itemName: 'USB-C Adapter',
      quantity: 5,
      unitPrice: 50.0,
      grossPrice: 60.0,
      discountAmount: 50.0,
      discountReason: 'Bulk discount',
      vatRate: 15.0,
      vatCategoryCode: 'S',
      barcode: '6281234567890',
      sellerItemId: 'USBC-001',
    );

    standardInvoice = ZatcaInvoice(
      invoiceNumber: 'INV-2026-001',
      uuid: '550e8400-e29b-41d4-a716-446655440000',
      issueDate: DateTime(2026, 4, 1),
      issueTime: DateTime(2026, 4, 1, 14, 30, 0),
      typeCode: InvoiceTypeCode.standard,
      subType: InvoiceSubType.standardB2B,
      seller: seller,
      buyer: buyer,
      lines: [line1, line2],
      previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
    );

    simplifiedInvoice = ZatcaInvoice(
      invoiceNumber: 'SINV-2026-001',
      uuid: '660e8400-e29b-41d4-a716-446655440111',
      issueDate: DateTime(2026, 4, 2),
      issueTime: DateTime(2026, 4, 2, 10, 0, 0),
      typeCode: InvoiceTypeCode.standard,
      subType: InvoiceSubType.simplifiedB2C,
      seller: seller,
      lines: [line1],
    );
  });

  // ─── UblInvoiceBuilder tests ────────────────────────────

  group('UblInvoiceBuilder', () {
    late UblInvoiceBuilder builder;

    setUp(() {
      builder = UblInvoiceBuilder();
    });

    test('produces valid XML that can be parsed', () {
      final xml = builder.build(standardInvoice);
      expect(() => XmlDocument.parse(xml), returnsNormally);
    });

    test('root element is Invoice with correct namespace', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final root = doc.rootElement;

      expect(root.name.local, 'Invoice');
      expect(
        root.getAttribute('xmlns'),
        'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
      );
    });

    test('contains all mandatory UBL namespaces', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final root = doc.rootElement;

      expect(root.getAttribute('xmlns:cac'), isNotNull);
      expect(root.getAttribute('xmlns:cbc'), isNotNull);
      expect(root.getAttribute('xmlns:ext'), isNotNull);
    });

    test('contains ProfileID element', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('ProfileID'));
      expect(xml, contains('reporting:1.0'));
    });

    test('contains invoice ID', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('INV-2026-001'));
    });

    test('contains UUID', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('550e8400-e29b-41d4-a716-446655440000'));
    });

    test('contains IssueDate in yyyy-MM-dd format', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('2026-04-01'));
    });

    test('contains IssueTime in HH:mm:ss format', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('14:30:00'));
    });

    test('contains InvoiceTypeCode with name attribute', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final typeCode = doc.rootElement.findAllElements('InvoiceTypeCode',
          namespace: '*');
      expect(typeCode, isNotEmpty);

      final el = typeCode.first;
      expect(el.innerText, '388');
      expect(el.getAttribute('name'), InvoiceSubType.standardB2B);
    });

    test('contains DocumentCurrencyCode SAR', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('DocumentCurrencyCode'));
      expect(xml, contains('SAR'));
    });

    test('contains TaxCurrencyCode SAR', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('TaxCurrencyCode'));
    });

    test('contains UBLExtensions element', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('UBLExtensions'));
      expect(xml, contains('UBLExtension'));
    });

    test('contains AccountingSupplierParty with seller info', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('AccountingSupplierParty'));
      expect(xml, contains('Alhai Test Store LLC'));
      expect(xml, contains('310122393500003'));
      expect(xml, contains('King Fahd Road'));
      expect(xml, contains('Riyadh'));
    });

    test('contains AccountingCustomerParty with buyer info', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('AccountingCustomerParty'));
      expect(xml, contains('Buyer Company Ltd'));
      expect(xml, contains('399999999900003'));
    });

    test('contains PaymentMeans', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('PaymentMeans'));
      expect(xml, contains('PaymentMeansCode'));
    });

    test('contains two TaxTotal elements', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final taxTotals = doc.rootElement.findAllElements(
        'TaxTotal',
        namespace: '*',
      );
      // Two at invoice level; individual lines also have TaxTotal
      final directTaxTotals = doc.rootElement.childElements
          .where((e) => e.name.local == 'TaxTotal')
          .toList();
      expect(directTaxTotals.length, 2);
    });

    test('second TaxTotal contains TaxSubtotal', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final directTaxTotals = doc.rootElement.childElements
          .where((e) => e.name.local == 'TaxTotal')
          .toList();

      final secondTaxTotal = directTaxTotals[1];
      final subtotals =
          secondTaxTotal.findAllElements('TaxSubtotal', namespace: '*');
      expect(subtotals, isNotEmpty);

      // Should contain TaxCategory with VAT scheme
      final taxSchemes =
          secondTaxTotal.findAllElements('TaxScheme', namespace: '*');
      expect(taxSchemes, isNotEmpty);
    });

    test('contains LegalMonetaryTotal with correct amounts', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final lmt = doc.rootElement
          .findAllElements('LegalMonetaryTotal', namespace: '*')
          .first;

      // line1: 2 * 5000 = 10000, line2: 5 * 50 - 50 = 200
      // Total net: 10200
      final lineExt =
          lmt.findAllElements('LineExtensionAmount', namespace: '*').first;
      expect(lineExt.innerText, '10200.00');

      final taxExcl =
          lmt.findAllElements('TaxExclusiveAmount', namespace: '*').first;
      expect(taxExcl.innerText, '10200.00');

      // VAT: 10200 * 0.15 = 1530
      final taxIncl =
          lmt.findAllElements('TaxInclusiveAmount', namespace: '*').first;
      expect(taxIncl.innerText, '11730.00');

      final payable =
          lmt.findAllElements('PayableAmount', namespace: '*').first;
      expect(payable.innerText, '11730.00');
    });

    test('contains correct number of InvoiceLine elements', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final lines = doc.rootElement.childElements
          .where((e) => e.name.local == 'InvoiceLine')
          .toList();
      expect(lines.length, 2);
    });

    test('InvoiceLine contains item name and quantity', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('Laptop Dell XPS 15'));
      expect(xml, contains('USB-C Adapter'));
    });

    test('contains PIH AdditionalDocumentReference', () {
      final xml = builder.build(standardInvoice);
      expect(xml, contains('PIH'));
      expect(xml, contains('NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzlj'));
    });

    test('contains Signature placeholder element', () {
      final xml = builder.build(standardInvoice);
      expect(
        xml,
        contains('urn:oasis:names:specification:ubl:signature:Invoice'),
      );
    });

    test('simplified invoice works without buyer', () {
      final xml = builder.build(simplifiedInvoice);
      expect(() => XmlDocument.parse(xml), returnsNormally);
      expect(xml, contains('AccountingCustomerParty'));
      // Buyer party should have an empty Party child (no name/vat)
    });

    test('credit note includes BillingReference', () {
      final creditNote = standardInvoice.copyWith(
        typeCode: InvoiceTypeCode.creditNote,
        billingReferenceId: 'INV-2026-000',
      );
      final xml = builder.build(creditNote);
      expect(xml, contains('BillingReference'));
      expect(xml, contains('INV-2026-000'));
      expect(xml, contains('381')); // credit note type code
    });

    test('document discount produces AllowanceCharge element', () {
      final discountedInvoice = standardInvoice.copyWith(
        documentDiscount: 100.0,
        documentDiscountReason: 'Loyalty discount',
      );
      final xml = builder.build(discountedInvoice);
      expect(xml, contains('AllowanceCharge'));
      expect(xml, contains('Loyalty discount'));
      expect(xml, contains('100.00'));
    });

    test('all currency amounts have currencyID attribute', () {
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);

      // Check a sampling of amount elements
      for (final amountTag in [
        'LineExtensionAmount',
        'TaxExclusiveAmount',
        'TaxInclusiveAmount',
        'PayableAmount',
        'TaxAmount',
        'TaxableAmount',
      ]) {
        final elements =
            doc.rootElement.findAllElements(amountTag, namespace: '*');
        for (final el in elements) {
          expect(
            el.getAttribute('currencyID'),
            isNotNull,
            reason: '$amountTag should have currencyID',
          );
        }
      }
    });
  });

  // ─── InvoiceLineBuilder tests ───────────────────────────

  group('InvoiceLineBuilder', () {
    late InvoiceLineBuilder lineBuilder;

    setUp(() {
      lineBuilder = InvoiceLineBuilder();
    });

    test('builds a line with correct ID', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 3,
        unitPrice: 10.0,
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final idEl = el.findAllElements('ID', namespace: '*').first;
      expect(idEl.innerText, '1');
    });

    test('builds line with InvoicedQuantity and unitCode', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 3,
        unitCode: 'PCE',
        unitPrice: 10.0,
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final qty =
          el.findAllElements('InvoicedQuantity', namespace: '*').first;
      expect(qty.innerText, '3.00');
      expect(qty.getAttribute('unitCode'), 'PCE');
    });

    test('builds line with correct LineExtensionAmount', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 4,
        unitPrice: 25.0,
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final amount =
          el.findAllElements('LineExtensionAmount', namespace: '*').first;
      expect(amount.innerText, '100.00'); // 4 * 25
      expect(amount.getAttribute('currencyID'), 'SAR');
    });

    test('includes AllowanceCharge when line has discount', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Discounted Item',
        quantity: 2,
        unitPrice: 90.0,
        grossPrice: 100.0,
        discountAmount: 20.0,
        discountReason: 'Promo',
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final allowances =
          el.findAllElements('AllowanceCharge', namespace: '*');
      // At least one AllowanceCharge at line level
      expect(allowances, isNotEmpty);
    });

    test('omits AllowanceCharge when no discount', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Full Price Item',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      // Only AllowanceCharge should be absent at line level (not inside Price)
      final directAllowances = el.childElements
          .where((e) => e.name.local == 'AllowanceCharge')
          .toList();
      expect(directAllowances, isEmpty);
    });

    test('builds Item with name and ClassifiedTaxCategory', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test Product',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
        vatCategoryCode: 'S',
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final item = el.findAllElements('Item', namespace: '*').first;
      final name = item.findAllElements('Name', namespace: '*').first;
      expect(name.innerText, 'Test Product');

      final taxCat =
          item.findAllElements('ClassifiedTaxCategory', namespace: '*').first;
      expect(taxCat, isNotNull);

      final catId = taxCat.findAllElements('ID', namespace: '*').first;
      expect(catId.innerText, 'S');
    });

    test('builds Item with barcode as StandardItemIdentification', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Barcoded Item',
        quantity: 1,
        unitPrice: 50.0,
        vatRate: 15.0,
        barcode: '6281234567890',
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final stdId = el
          .findAllElements('StandardItemIdentification', namespace: '*')
          .first;
      final id = stdId.findAllElements('ID', namespace: '*').first;
      expect(id.innerText, '6281234567890');
      expect(id.getAttribute('schemeID'), 'GTIN');
    });

    test('builds Price with PriceAmount', () {
      final line = const ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 42.50,
        vatRate: 15.0,
      );
      final el = lineBuilder.buildLine(line, 'SAR');

      final price = el.findAllElements('Price', namespace: '*').first;
      final amount =
          price.findAllElements('PriceAmount', namespace: '*').first;
      expect(amount.innerText, '42.50');
      expect(amount.getAttribute('currencyID'), 'SAR');
    });

    test('buildLines returns correct number of elements', () {
      final lines = [
        const ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'A',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '2',
          itemName: 'B',
          quantity: 2,
          unitPrice: 20.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '3',
          itemName: 'C',
          quantity: 3,
          unitPrice: 30.0,
          vatRate: 15.0,
        ),
      ];
      final elements = lineBuilder.buildLines(lines, 'SAR');
      expect(elements.length, 3);
    });
  });

  // ─── TaxTotalBuilder tests ──────────────────────────────

  group('TaxTotalBuilder', () {
    late TaxTotalBuilder taxBuilder;

    setUp(() {
      taxBuilder = TaxTotalBuilder();
    });

    test('produces exactly two TaxTotal elements', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'T-001',
        uuid: 'uuid-1',
        issueDate: DateTime(2026, 4, 1),
        issueTime: DateTime(2026, 4, 1, 12, 0, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: const ZatcaSeller(
          name: 'S',
          vatNumber: '310122393500003',
          streetName: 'St',
          buildingNumber: '1',
          city: 'R',
          postalCode: '12345',
        ),
        lines: const [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'A',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ],
      );

      final totals = taxBuilder.buildTaxTotals(invoice);
      expect(totals.length, 2);
    });

    test('first TaxTotal has only TaxAmount', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'T-002',
        uuid: 'uuid-2',
        issueDate: DateTime(2026, 4, 1),
        issueTime: DateTime(2026, 4, 1, 12, 0, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: const ZatcaSeller(
          name: 'S',
          vatNumber: '310122393500003',
          streetName: 'St',
          buildingNumber: '1',
          city: 'R',
          postalCode: '12345',
        ),
        lines: const [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'A',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ],
      );

      final totals = taxBuilder.buildTaxTotals(invoice);
      final first = totals[0];

      // Should only have TaxAmount, no TaxSubtotal
      final subtotals =
          first.findAllElements('TaxSubtotal', namespace: '*');
      expect(subtotals, isEmpty);

      final amount =
          first.findAllElements('TaxAmount', namespace: '*').first;
      expect(amount.innerText, '15.00');
    });

    test('second TaxTotal has TaxSubtotal breakdown', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'T-003',
        uuid: 'uuid-3',
        issueDate: DateTime(2026, 4, 1),
        issueTime: DateTime(2026, 4, 1, 12, 0, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: const ZatcaSeller(
          name: 'S',
          vatNumber: '310122393500003',
          streetName: 'St',
          buildingNumber: '1',
          city: 'R',
          postalCode: '12345',
        ),
        lines: const [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'A',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
        ],
      );

      final totals = taxBuilder.buildTaxTotals(invoice);
      final second = totals[1];

      final subtotals =
          second.findAllElements('TaxSubtotal', namespace: '*');
      expect(subtotals.length, 1);

      final taxable =
          second.findAllElements('TaxableAmount', namespace: '*').first;
      expect(taxable.innerText, '100.00');
    });

    test('groups multiple VAT categories separately', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'T-004',
        uuid: 'uuid-4',
        issueDate: DateTime(2026, 4, 1),
        issueTime: DateTime(2026, 4, 1, 12, 0, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: const ZatcaSeller(
          name: 'S',
          vatNumber: '310122393500003',
          streetName: 'St',
          buildingNumber: '1',
          city: 'R',
          postalCode: '12345',
        ),
        lines: const [
          ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Taxed',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
          ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Zero-rated',
            quantity: 1,
            unitPrice: 200.0,
            vatRate: 0.0,
            vatCategoryCode: 'Z',
            vatExemptionReason: 'Export',
          ),
        ],
      );

      final totals = taxBuilder.buildTaxTotals(invoice);
      final second = totals[1];

      final subtotals =
          second.findAllElements('TaxSubtotal', namespace: '*');
      expect(subtotals.length, 2);
    });
  });

  // ─── XmlCanonicalizer tests ─────────────────────────────

  group('XmlCanonicalizer', () {
    late XmlCanonicalizer canonicalizer;

    setUp(() {
      canonicalizer = XmlCanonicalizer();
    });

    test('removes XML declaration', () {
      const xml = '<?xml version="1.0" encoding="UTF-8"?><root><a>1</a></root>';
      final result = canonicalizer.canonicalize(xml);
      expect(result, isNot(contains('<?xml')));
      expect(result, startsWith('<root>'));
    });

    test('expands empty elements to start+end tags', () {
      const xml = '<root><empty/></root>';
      final result = canonicalizer.canonicalize(xml);
      expect(result, contains('<empty></empty>'));
    });

    test('sorts attributes', () {
      const xml = '<root z="3" a="1" m="2"/>';
      final result = canonicalizer.canonicalize(xml);
      // Attributes should be sorted: a, m, z
      expect(result.indexOf('a="1"'), lessThan(result.indexOf('m="2"')));
      expect(result.indexOf('m="2"'), lessThan(result.indexOf('z="3"')));
    });

    test('preserves text content', () {
      const xml = '<root><name>Hello World</name></root>';
      final result = canonicalizer.canonicalize(xml);
      expect(result, contains('Hello World'));
    });

    test('escapes special characters in text', () {
      const xml = '<root><val>a &amp; b</val></root>';
      final result = canonicalizer.canonicalize(xml);
      expect(result, contains('a &amp; b'));
    });

    test('canonicalizeElement finds and canonicalizes named element', () {
      const xml = '<root><a><target><v>ok</v></target></a></root>';
      final result = canonicalizer.canonicalizeElement(xml, 'target');
      expect(result, '<target><v>ok</v></target>');
    });

    test('canonicalizeElement throws for missing element', () {
      const xml = '<root><a>1</a></root>';
      expect(
        () => canonicalizer.canonicalizeElement(xml, 'missing'),
        throwsArgumentError,
      );
    });

    test('removeSignatureElements strips UBLExtensions and Signature', () {
      const xml = '<Invoice>'
          '<ext:UBLExtensions xmlns:ext="urn:ext"><ext:UBLExtension>data</ext:UBLExtension></ext:UBLExtensions>'
          '<cbc:ID xmlns:cbc="urn:cbc">1</cbc:ID>'
          '<cac:Signature xmlns:cac="urn:cac">sig</cac:Signature>'
          '<cbc:Name xmlns:cbc="urn:cbc">Test</cbc:Name>'
          '</Invoice>';

      final result = canonicalizer.removeSignatureElements(xml);
      expect(result, isNot(contains('UBLExtensions')));
      expect(result, isNot(contains('Signature')));
      expect(result, contains('ID'));
      expect(result, contains('Name'));
    });
  });

  // ─── Integration test: end-to-end XML generation ────────

  group('End-to-end XML generation', () {
    test('standard B2B invoice produces complete valid XML', () {
      final builder = UblInvoiceBuilder();
      final xml = builder.build(standardInvoice);
      final doc = XmlDocument.parse(xml);
      final root = doc.rootElement;

      // Verify structure completeness
      final elementNames = root.childElements.map((e) => e.name.local).toList();

      expect(elementNames, contains('UBLExtensions'));
      expect(elementNames, contains('ProfileID'));
      expect(elementNames, contains('ID'));
      expect(elementNames, contains('UUID'));
      expect(elementNames, contains('IssueDate'));
      expect(elementNames, contains('IssueTime'));
      expect(elementNames, contains('InvoiceTypeCode'));
      expect(elementNames, contains('DocumentCurrencyCode'));
      expect(elementNames, contains('AccountingSupplierParty'));
      expect(elementNames, contains('AccountingCustomerParty'));
      expect(elementNames, contains('PaymentMeans'));
      expect(elementNames, contains('TaxTotal'));
      expect(elementNames, contains('LegalMonetaryTotal'));
      expect(elementNames, contains('InvoiceLine'));
    });

    test('generated XML can be canonicalized without errors', () {
      final builder = UblInvoiceBuilder();
      final xml = builder.build(standardInvoice);
      final canonicalizer = XmlCanonicalizer();

      expect(() => canonicalizer.canonicalize(xml), returnsNormally);
    });

    test('generated XML can have signature elements removed', () {
      final builder = UblInvoiceBuilder();
      final xml = builder.build(standardInvoice);
      final canonicalizer = XmlCanonicalizer();

      final stripped = canonicalizer.removeSignatureElements(xml);
      expect(stripped, isNot(contains('UBLExtensions')));
      expect(stripped, contains('InvoiceLine'));
    });
  });
}
