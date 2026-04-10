import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/zatca_seller.dart';

void main() {
  group('ZatcaSeller', () {
    ZatcaSeller buildSeller({
      String name = 'Test Store',
      String vatNumber = '310122393500003',
      String streetName = 'King Fahd Road',
      String buildingNumber = '1234',
      String city = 'Riyadh',
      String postalCode = '12345',
    }) {
      return ZatcaSeller(
        name: name,
        vatNumber: vatNumber,
        streetName: streetName,
        buildingNumber: buildingNumber,
        city: city,
        postalCode: postalCode,
      );
    }

    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('creates with all required fields', () {
        final seller = buildSeller();
        expect(seller.name, 'Test Store');
        expect(seller.vatNumber, '310122393500003');
        expect(seller.streetName, 'King Fahd Road');
        expect(seller.buildingNumber, '1234');
        expect(seller.city, 'Riyadh');
        expect(seller.postalCode, '12345');
      });

      test('defaults countryCode to SA', () {
        final seller = buildSeller();
        expect(seller.countryCode, 'SA');
      });

      test('stores optional fields when provided', () {
        final seller = ZatcaSeller(
          name: 'Store',
          vatNumber: '310122393500003',
          streetName: 'Street',
          buildingNumber: '1234',
          city: 'Riyadh',
          postalCode: '12345',
          crNumber: '1010101010',
          plotIdentification: 'Plot 42',
          district: 'Al Olaya',
          countryCode: 'SA',
          additionalId: '1234567890',
          additionalIdScheme: 'CRN',
        );
        expect(seller.crNumber, '1010101010');
        expect(seller.plotIdentification, 'Plot 42');
        expect(seller.district, 'Al Olaya');
        expect(seller.additionalId, '1234567890');
        expect(seller.additionalIdScheme, 'CRN');
      });

      test('optional fields default to null', () {
        final seller = buildSeller();
        expect(seller.crNumber, isNull);
        expect(seller.plotIdentification, isNull);
        expect(seller.district, isNull);
        expect(seller.additionalId, isNull);
        expect(seller.additionalIdScheme, isNull);
      });
    });

    // ── isVatValid ───────────────────────────────────────

    group('isVatValid', () {
      test('accepts 15-digit VAT starting with 3', () {
        final seller = buildSeller(vatNumber: '310122393500003');
        expect(seller.isVatValid, isTrue);
      });

      test('rejects VAT with fewer than 15 digits', () {
        final seller = buildSeller(vatNumber: '3101223935000');
        expect(seller.isVatValid, isFalse);
      });

      test('rejects VAT with more than 15 digits', () {
        final seller = buildSeller(vatNumber: '31012239350000300');
        expect(seller.isVatValid, isFalse);
      });

      test('rejects VAT not starting with 3', () {
        final seller = buildSeller(vatNumber: '410122393500003');
        expect(seller.isVatValid, isFalse);
      });

      test('rejects VAT containing non-digits', () {
        final seller = buildSeller(vatNumber: '31012239350000A');
        expect(seller.isVatValid, isFalse);
      });

      test('rejects empty VAT', () {
        final seller = buildSeller(vatNumber: '');
        expect(seller.isVatValid, isFalse);
      });

      test('rejects a 15-char non-numeric string', () {
        final seller = buildSeller(vatNumber: 'ABCDEFGHIJKLMNO');
        expect(seller.isVatValid, isFalse);
      });
    });

    // ── copyWith ─────────────────────────────────────────

    group('copyWith', () {
      test('returns identical copy when no arguments given', () {
        final original = buildSeller();
        final copy = original.copyWith();
        expect(copy.name, original.name);
        expect(copy.vatNumber, original.vatNumber);
        expect(copy.countryCode, original.countryCode);
      });

      test('updates only specified fields', () {
        final original = buildSeller(name: 'Old Store');
        final updated = original.copyWith(
          name: 'New Store',
          district: 'Al Malaz',
        );
        expect(updated.name, 'New Store');
        expect(updated.district, 'Al Malaz');
        // Unchanged
        expect(updated.vatNumber, original.vatNumber);
        expect(updated.city, original.city);
      });

      test('can update VAT number', () {
        final original = buildSeller();
        final updated = original.copyWith(vatNumber: '300000000000003');
        expect(updated.vatNumber, '300000000000003');
        expect(updated.isVatValid, isTrue);
      });
    });

    // ── Serialization ────────────────────────────────────

    group('toJson / fromJson', () {
      test('omits null optional fields in JSON', () {
        final seller = buildSeller();
        final json = seller.toJson();
        expect(json.containsKey('crNumber'), isFalse);
        expect(json.containsKey('district'), isFalse);
        expect(json.containsKey('plotIdentification'), isFalse);
        expect(json.containsKey('additionalId'), isFalse);
        expect(json.containsKey('additionalIdScheme'), isFalse);
      });

      test('always includes required fields and countryCode in JSON', () {
        final seller = buildSeller();
        final json = seller.toJson();
        expect(json['name'], 'Test Store');
        expect(json['vatNumber'], '310122393500003');
        expect(json['streetName'], 'King Fahd Road');
        expect(json['buildingNumber'], '1234');
        expect(json['city'], 'Riyadh');
        expect(json['postalCode'], '12345');
        expect(json['countryCode'], 'SA');
      });

      test('roundtrips minimal seller', () {
        final seller = buildSeller();
        final json = seller.toJson();
        final restored = ZatcaSeller.fromJson(json);

        expect(restored.name, seller.name);
        expect(restored.vatNumber, seller.vatNumber);
        expect(restored.streetName, seller.streetName);
        expect(restored.buildingNumber, seller.buildingNumber);
        expect(restored.city, seller.city);
        expect(restored.postalCode, seller.postalCode);
        expect(restored.countryCode, 'SA');
      });

      test('roundtrips all fields', () {
        final seller = ZatcaSeller(
          name: 'My Store',
          vatNumber: '310122393500003',
          crNumber: '1010101010',
          streetName: 'King Fahd Road',
          buildingNumber: '1234',
          plotIdentification: 'Plot 42',
          city: 'Riyadh',
          district: 'Al Olaya',
          postalCode: '12345',
          additionalId: '1234567890',
          additionalIdScheme: 'CRN',
        );
        final json = seller.toJson();
        final restored = ZatcaSeller.fromJson(json);

        expect(restored.name, seller.name);
        expect(restored.crNumber, seller.crNumber);
        expect(restored.plotIdentification, seller.plotIdentification);
        expect(restored.district, seller.district);
        expect(restored.additionalId, seller.additionalId);
        expect(restored.additionalIdScheme, seller.additionalIdScheme);
      });

      test('fromJson defaults countryCode to SA when missing', () {
        final json = <String, dynamic>{
          'name': 'Test',
          'vatNumber': '310122393500003',
          'streetName': 'Street',
          'buildingNumber': '1',
          'city': 'City',
          'postalCode': '12345',
        };
        final seller = ZatcaSeller.fromJson(json);
        expect(seller.countryCode, 'SA');
      });

      test('handles Arabic characters in name and city', () {
        final seller = ZatcaSeller(
          name: 'متجر الاختبار',
          vatNumber: '310122393500003',
          streetName: 'طريق الملك فهد',
          buildingNumber: '1234',
          city: 'الرياض',
          postalCode: '12345',
        );
        final json = seller.toJson();
        final restored = ZatcaSeller.fromJson(json);
        expect(restored.name, 'متجر الاختبار');
        expect(restored.city, 'الرياض');
        expect(restored.streetName, 'طريق الملك فهد');
      });
    });

    // ── Smoke test ───────────────────────────────────────

    test('toString does not throw', () {
      final seller = buildSeller();
      expect(seller.toString(), isNotEmpty);
    });
  });
}
