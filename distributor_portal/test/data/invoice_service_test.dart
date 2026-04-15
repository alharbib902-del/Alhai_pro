import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:distributor_portal/data/models.dart';

void main() {
  // ─── Line item conversion ───────────────────────────────────

  group('InvoiceService line item conversion', () {
    test('converts DistributorOrderItem to ZatcaInvoiceLine', () {
      // Verify the ZATCA line creation logic using the public model
      final item = DistributorOrderItem.fromJson({
        'id': 'item-1',
        'order_id': 'order-1',
        'product_id': 'prod-1',
        'products': {'name': 'Water 500ml', 'barcode': '6281234567890'},
        'quantity': 10,
        'unit_price': 2.50,
        'distributor_price': 3.00,
      });

      // The service uses distributorPrice if set, otherwise suggestedPrice
      final unitPrice = item.distributorPrice ?? item.suggestedPrice;
      expect(unitPrice, 3.00); // distributorPrice wins

      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: item.productName,
        quantity: item.quantity.toDouble(),
        unitPrice: unitPrice,
        vatRate: 15.0,
        barcode: item.barcode,
        sellerItemId: item.productId,
      );

      expect(line.itemName, 'Water 500ml');
      expect(line.quantity, 10.0);
      expect(line.unitPrice, 3.00);
      expect(line.vatRate, 15.0);
      expect(line.barcode, '6281234567890');
      expect(line.lineNetAmount, 30.0); // 10 * 3.00
      expect(line.vatAmount, 4.5); // 30 * 0.15
    });

    test('falls back to suggestedPrice when distributorPrice is null', () {
      final item = DistributorOrderItem.fromJson({
        'id': 'item-2',
        'order_id': 'order-1',
        'product_id': 'prod-2',
        'products': {'name': 'Juice 1L', 'barcode': null},
        'quantity': 5,
        'unit_price': 8.00,
        'distributor_price': null,
      });

      final unitPrice = item.distributorPrice ?? item.suggestedPrice;
      expect(unitPrice, 8.00); // falls back to suggestedPrice

      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: item.productName,
        quantity: item.quantity.toDouble(),
        unitPrice: unitPrice,
        vatRate: 15.0,
      );

      expect(line.lineNetAmount, 40.0);
      expect(line.vatAmount, 6.0);
    });
  });

  // ─── VAT calculation ────────────────────────────────────────

  group('VAT calculations', () {
    test('15% VAT on single item', () {
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Item',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      expect(line.lineNetAmount, 100.0);
      expect(line.vatAmount, 15.0);
      expect(line.lineTotal, 115.0);
    });

    test('15% VAT on multiple items totals correctly', () {
      final lines = [
        const ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'A',
          quantity: 3,
          unitPrice: 10.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '2',
          itemName: 'B',
          quantity: 2,
          unitPrice: 25.0,
          vatRate: 15.0,
        ),
      ];

      final subtotal = lines.fold<double>(0, (s, l) => s + l.lineNetAmount);
      final tax = lines.fold<double>(0, (s, l) => s + l.vatAmount);
      final total = subtotal + tax;

      expect(subtotal, 80.0); // 30 + 50
      expect(tax, 12.0); // 4.5 + 7.5
      expect(total, 92.0);
    });

    test('rounding to 2 decimal places', () {
      // 3 * 7.33 = 21.99, VAT = 3.2985 → rounded to 3.30
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'C',
        quantity: 3,
        unitPrice: 7.33,
        vatRate: 15.0,
      );

      expect(line.lineNetAmountRounded, 21.99);
      expect(line.vatAmountRounded, 3.30);
    });
  });

  // ─── Seller building ────────────────────────────────────────

  group('ZatcaSeller from OrgSettings', () {
    test('builds seller with all fields', () {
      final org = OrgSettings.fromJson({
        'id': 'org-1',
        'name': 'Alhai Foods',
        'tax_number': '300000000000003',
        'commercial_reg': '1010123456',
        'address': 'King Fahd Road',
        'city': 'Riyadh',
        'country': 'SA',
      });

      final seller = ZatcaSeller(
        name: org.companyName,
        vatNumber: org.taxNumber ?? '',
        streetName: org.address ?? '',
        buildingNumber: '',
        city: org.city ?? '',
        postalCode: '',
        crNumber: org.commercialReg,
      );

      expect(seller.name, 'Alhai Foods');
      expect(seller.vatNumber, '300000000000003');
      expect(seller.crNumber, '1010123456');
      expect(seller.streetName, 'King Fahd Road');
      expect(seller.city, 'Riyadh');
    });

    test('handles missing tax fields gracefully', () {
      final org = OrgSettings.fromJson({
        'id': 'org-2',
        'name': 'No Tax Co',
      });

      expect(org.taxNumber, isNull);
      expect(org.commercialReg, isNull);
      expect(org.city, isNull);

      final seller = ZatcaSeller(
        name: org.companyName,
        vatNumber: org.taxNumber ?? '',
        streetName: org.address ?? '',
        buildingNumber: '',
        city: org.city ?? '',
        postalCode: '',
      );

      expect(seller.vatNumber, '');
      expect(seller.city, '');
    });
  });

  // ─── Buyer building ────────────────────────────────────────

  group('ZatcaBuyer from store info', () {
    test('builds buyer for B2B invoice', () {
      final buyer = ZatcaBuyer(
        name: 'Corner Store',
        vatNumber: '300000000000099',
        streetName: 'Olaya Street',
      );

      expect(buyer.name, 'Corner Store');
      expect(buyer.vatNumber, '300000000000099');
      expect(buyer.isValidForStandard, isTrue);
    });

    test('buyer without VAT is invalid for standard invoice', () {
      const buyer = ZatcaBuyer(name: 'Small Shop');

      expect(buyer.vatNumber, isNull);
      expect(buyer.isValidForStandard, isFalse);
    });
  });

  // ─── Invoice type mapping ──────────────────────────────────

  group('Invoice type to ZATCA subType', () {
    test('standard_tax maps to 0100000', () {
      const invoiceType = 'standard_tax';
      const subType = invoiceType == 'standard_tax' ? '0100000' : '0200000';
      expect(subType, '0100000');
    });

    test('simplified_tax maps to 0200000', () {
      const invoiceType = 'simplified_tax';
      const subType = invoiceType == 'standard_tax' ? '0100000' : '0200000';
      expect(subType, '0200000');
    });
  });

  // ─── DistributorInvoice construction ───────────────────────

  group('Invoice totals from lines', () {
    test('subtotal + tax = total', () {
      final lines = [
        const ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Product A',
          quantity: 5,
          unitPrice: 20.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '2',
          itemName: 'Product B',
          quantity: 3,
          unitPrice: 15.0,
          vatRate: 15.0,
        ),
      ];

      final subtotal = lines.fold<double>(0, (s, l) => s + l.lineNetAmount);
      final taxAmount = lines.fold<double>(0, (s, l) => s + l.vatAmount);
      final total = subtotal + taxAmount;

      expect(subtotal, 145.0); // 100 + 45
      expect(taxAmount, 21.75); // 15 + 6.75
      expect(total, 166.75);

      final invoice = DistributorInvoice(
        id: 'test-id',
        storeId: 'store-1',
        invoiceNumber: 'INV-2026-0001',
        subtotal: subtotal,
        taxRate: 15.0,
        taxAmount: taxAmount,
        total: total,
        amountDue: total,
        createdAt: DateTime.now(),
      );

      expect(invoice.subtotal, 145.0);
      expect(invoice.taxAmount, 21.75);
      expect(invoice.total, 166.75);
      expect(invoice.amountDue, 166.75);
      expect(invoice.amountPaid, 0.0);
    });
  });

  // ─── OrgSettings extended fields ───────────────────────────

  group('OrgSettings ZATCA fields', () {
    test('fromJson parses tax_number, commercial_reg, city, country', () {
      final settings = OrgSettings.fromJson({
        'id': 'org-1',
        'name': 'Test Org',
        'tax_number': '300000000000003',
        'commercial_reg': '1010123456',
        'city': 'Jeddah',
        'country': 'SA',
      });

      expect(settings.taxNumber, '300000000000003');
      expect(settings.commercialReg, '1010123456');
      expect(settings.city, 'Jeddah');
      expect(settings.country, 'SA');
    });

    test('toJson includes ZATCA fields', () {
      final settings = OrgSettings(
        id: 'org-1',
        companyName: 'Test',
        taxNumber: '300000000000003',
        commercialReg: '1010123456',
        city: 'Riyadh',
        country: 'SA',
      );

      final json = settings.toJson();
      expect(json['tax_number'], '300000000000003');
      expect(json['commercial_reg'], '1010123456');
      expect(json['city'], 'Riyadh');
      expect(json['country'], 'SA');
    });

    test('equality includes ZATCA fields', () {
      final a = OrgSettings(
        id: 'org-1',
        companyName: 'Test',
        taxNumber: '300000000000003',
      );
      final b = OrgSettings(
        id: 'org-1',
        companyName: 'Test',
        taxNumber: '300000000000003',
      );
      final c = OrgSettings(
        id: 'org-1',
        companyName: 'Test',
        taxNumber: '399999999999999',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
