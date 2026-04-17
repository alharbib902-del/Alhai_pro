import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

void main() {
  late UblInvoiceBuilder builder;

  setUp(() {
    builder = UblInvoiceBuilder();
  });

  group('CountrySubentity — UBL 2.1 / ZATCA', () {
    test('seller PostalAddress contains CountrySubentity when region set', () {
      final invoice = _makeInvoice(sellerRegion: 'Makkah Region');
      final xml = builder.build(invoice);
      final doc = XmlDocument.parse(xml);

      final supplier = doc.rootElement
          .findAllElements('AccountingSupplierParty', namespace: '*')
          .first;
      final address = supplier
          .findAllElements('PostalAddress', namespace: '*')
          .first;
      final subentities = address.findAllElements(
        'CountrySubentity',
        namespace: '*',
      );

      expect(subentities.length, equals(1));
      expect(subentities.first.innerText, equals('Makkah Region'));
    });

    test('buyer PostalAddress contains CountrySubentity when region set', () {
      final invoice = _makeInvoice(
        sellerRegion: 'Riyadh Region',
        buyerRegion: 'Eastern Province',
      );
      final xml = builder.build(invoice);
      final doc = XmlDocument.parse(xml);

      final customer = doc.rootElement
          .findAllElements('AccountingCustomerParty', namespace: '*')
          .first;
      final address = customer
          .findAllElements('PostalAddress', namespace: '*')
          .first;
      final subentities = address.findAllElements(
        'CountrySubentity',
        namespace: '*',
      );

      expect(subentities.length, equals(1));
      expect(subentities.first.innerText, equals('Eastern Province'));
    });

    test('CountrySubentity appears after PostalZone and before Country', () {
      final invoice = _makeInvoice(sellerRegion: 'Riyadh Region');
      final xml = builder.build(invoice);

      // Use indices in the full XML string
      final postalZoneIdx = xml.indexOf('PostalZone');
      final subentityIdx = xml.indexOf('CountrySubentity');
      final countryIdx = xml.indexOf('IdentificationCode');

      expect(postalZoneIdx, greaterThan(-1));
      expect(subentityIdx, greaterThan(-1));
      expect(countryIdx, greaterThan(-1));

      expect(
        postalZoneIdx,
        lessThan(subentityIdx),
        reason: 'PostalZone must precede CountrySubentity',
      );
      expect(
        subentityIdx,
        lessThan(countryIdx),
        reason: 'CountrySubentity must precede Country',
      );
    });

    test('CountrySubentity omitted when seller region is null', () {
      final invoice = _makeInvoice(sellerRegion: null);
      final xml = builder.build(invoice);

      final doc = XmlDocument.parse(xml);
      final supplier = doc.rootElement
          .findAllElements('AccountingSupplierParty', namespace: '*')
          .first;
      final address = supplier
          .findAllElements('PostalAddress', namespace: '*')
          .first;
      final subentities = address.findAllElements(
        'CountrySubentity',
        namespace: '*',
      );

      expect(
        subentities,
        isEmpty,
        reason: 'No CountrySubentity when region is null',
      );
    });

    test('XML remains valid and parseable with CountrySubentity', () {
      final invoice = _makeInvoice(
        sellerRegion: 'Makkah Region',
        buyerRegion: 'Riyadh Region',
      );
      final xml = builder.build(invoice);
      expect(() => XmlDocument.parse(xml), returnsNormally);
    });
  });
}

ZatcaInvoice _makeInvoice({String? sellerRegion, String? buyerRegion}) {
  return ZatcaInvoice(
    invoiceNumber: 'INV-TEST-CS',
    uuid: '550e8400-e29b-41d4-a716-446655440099',
    issueDate: DateTime(2026, 4, 10),
    issueTime: DateTime(2026, 4, 10, 12, 0, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardB2B,
    seller: ZatcaSeller(
      name: 'Test Seller LLC',
      vatNumber: '310122393500003',
      streetName: 'King Fahd Road',
      buildingNumber: '1234',
      city: 'Riyadh',
      postalCode: '12345',
      region: sellerRegion,
    ),
    buyer: ZatcaBuyer(
      name: 'Test Buyer Co',
      vatNumber: '399999999900003',
      streetName: 'Prince Sultan St',
      buildingNumber: '5678',
      city: 'Jeddah',
      postalCode: '21589',
      countryCode: 'SA',
      region: buyerRegion,
    ),
    lines: const [
      ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test Product',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
        vatCategoryCode: 'S',
      ),
    ],
  );
}
