/// Independent verification for Fix #3: CountrySubentity ordering in UBL 2.1.
///
/// Checks that the PostalAddress elements follow UBL 2.1 / ZATCA ordering
/// and that null/empty region is handled safely.
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

  ZatcaInvoice _makeInvoice({String? sellerRegion, String? buyerRegion}) {
    return ZatcaInvoice(
      invoiceNumber: 'INV-VERIFY-CS',
      uuid: '550e8400-e29b-41d4-a716-446655440077',
      issueDate: DateTime(2026, 4, 14),
      issueTime: DateTime(2026, 4, 14, 10, 0, 0),
      typeCode: InvoiceTypeCode.standard,
      subType: InvoiceSubType.standardB2B,
      seller: ZatcaSeller(
        name: 'Verify Seller LLC',
        vatNumber: '310122393500003',
        streetName: 'King Fahd Road',
        buildingNumber: '1234',
        city: 'Riyadh',
        postalCode: '12345',
        region: sellerRegion,
      ),
      buyer: ZatcaBuyer(
        name: 'Verify Buyer Co',
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
          itemName: 'Verification Product',
          quantity: 1,
          unitPrice: 100.0,
          vatRate: 15.0,
          vatCategoryCode: 'S',
        ),
      ],
    );
  }

  group('VERIFICATION — Fix #3: CountrySubentity ordering', () {
    test('full UBL 2.1 ordering of seller PostalAddress elements', () {
      final invoice = _makeInvoice(sellerRegion: 'Makkah Region');
      final xml = builder.build(invoice);
      final doc = XmlDocument.parse(xml);

      final supplier = doc.rootElement
          .findAllElements('AccountingSupplierParty', namespace: '*')
          .first;
      final address = supplier
          .findAllElements('PostalAddress', namespace: '*')
          .first;

      final childNames = address.childElements
          .map((e) => e.name.local)
          .toList();

      // UBL 2.1 mandated order:
      // StreetName, BuildingNumber, [PlotIdentification], [CitySubdivisionName],
      // CityName, PostalZone, [CountrySubentity], Country
      final expectedOrder = [
        'StreetName',
        'BuildingNumber',
        // PlotIdentification and CitySubdivisionName are optional
        'CityName',
        'PostalZone',
        'CountrySubentity',
        'Country',
      ];

      // Verify each expected element appears in order
      int lastIdx = -1;
      for (final name in expectedOrder) {
        final idx = childNames.indexOf(name);
        expect(
          idx,
          greaterThan(-1),
          reason: '$name must exist in PostalAddress',
        );
        expect(
          idx,
          greaterThan(lastIdx),
          reason: '$name must come after previous elements (UBL order)',
        );
        lastIdx = idx;
      }
    });

    test('CountrySubentity value is "Makkah Region"', () {
      final invoice = _makeInvoice(sellerRegion: 'Makkah Region');
      final xml = builder.build(invoice);
      final doc = XmlDocument.parse(xml);

      final subentity = doc.rootElement
          .findAllElements('CountrySubentity', namespace: '*')
          .first;
      expect(subentity.innerText, equals('Makkah Region'));
    });

    test('CountrySubentity omitted entirely when region is null', () {
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
        reason: 'Null region must NOT produce empty CountrySubentity',
      );
    });

    test('Country element still present when region is null', () {
      final invoice = _makeInvoice(sellerRegion: null);
      final xml = builder.build(invoice);
      final doc = XmlDocument.parse(xml);

      final supplier = doc.rootElement
          .findAllElements('AccountingSupplierParty', namespace: '*')
          .first;
      final address = supplier
          .findAllElements('PostalAddress', namespace: '*')
          .first;
      final country = address.findAllElements('Country', namespace: '*');

      expect(
        country.length,
        equals(1),
        reason: 'Country must still exist even when region is null',
      );
    });

    test('buyer PostalAddress also follows correct order when region set', () {
      final invoice = _makeInvoice(
        sellerRegion: 'Riyadh Region',
        buyerRegion: 'Eastern Province',
      );
      final xml = builder.build(invoice);

      // String-level ordering check for buyer
      final buyerSubentityIdx = xml.lastIndexOf('CountrySubentity');
      final buyerPostalZoneIdx = xml.lastIndexOf('PostalZone');
      final buyerCountryIdx = xml.lastIndexOf('IdentificationCode');

      expect(
        buyerPostalZoneIdx,
        lessThan(buyerSubentityIdx),
        reason: 'Buyer: PostalZone must precede CountrySubentity',
      );
      expect(
        buyerSubentityIdx,
        lessThan(buyerCountryIdx),
        reason: 'Buyer: CountrySubentity must precede Country',
      );
    });
  });
}
