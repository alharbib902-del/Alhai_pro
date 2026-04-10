import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/zatca_buyer.dart';

void main() {
  group('ZatcaBuyer', () {
    // ── Construction ─────────────────────────────────────

    group('construction', () {
      test('creates an empty buyer with all fields null', () {
        const buyer = ZatcaBuyer();
        expect(buyer.name, isNull);
        expect(buyer.vatNumber, isNull);
        expect(buyer.buyerId, isNull);
        expect(buyer.buyerIdScheme, isNull);
        expect(buyer.streetName, isNull);
        expect(buyer.buildingNumber, isNull);
        expect(buyer.city, isNull);
        expect(buyer.district, isNull);
        expect(buyer.postalCode, isNull);
        expect(buyer.countryCode, isNull);
      });

      test('stores all provided fields', () {
        const buyer = ZatcaBuyer(
          name: 'Acme Corp',
          vatNumber: '310987654300003',
          buyerId: '1234567890',
          buyerIdScheme: 'CRN',
          streetName: 'Olaya Street',
          buildingNumber: '4567',
          city: 'Riyadh',
          district: 'Al Olaya',
          postalCode: '12213',
          countryCode: 'SA',
        );

        expect(buyer.name, 'Acme Corp');
        expect(buyer.vatNumber, '310987654300003');
        expect(buyer.buyerId, '1234567890');
        expect(buyer.buyerIdScheme, 'CRN');
        expect(buyer.streetName, 'Olaya Street');
        expect(buyer.buildingNumber, '4567');
        expect(buyer.city, 'Riyadh');
        expect(buyer.district, 'Al Olaya');
        expect(buyer.postalCode, '12213');
        expect(buyer.countryCode, 'SA');
      });
    });

    // ── isValidForStandard ───────────────────────────────

    group('isValidForStandard', () {
      test('returns true when both name and vatNumber are set', () {
        const buyer = ZatcaBuyer(
          name: 'Valid Co',
          vatNumber: '310987654300003',
        );
        expect(buyer.isValidForStandard, isTrue);
      });

      test('returns false when name is null', () {
        const buyer = ZatcaBuyer(vatNumber: '310987654300003');
        expect(buyer.isValidForStandard, isFalse);
      });

      test('returns false when name is empty', () {
        const buyer = ZatcaBuyer(name: '', vatNumber: '310987654300003');
        expect(buyer.isValidForStandard, isFalse);
      });

      test('returns false when vatNumber is null', () {
        const buyer = ZatcaBuyer(name: 'Valid Co');
        expect(buyer.isValidForStandard, isFalse);
      });

      test('returns false when vatNumber is empty', () {
        const buyer = ZatcaBuyer(name: 'Valid Co', vatNumber: '');
        expect(buyer.isValidForStandard, isFalse);
      });

      test('returns false for completely empty buyer', () {
        const buyer = ZatcaBuyer();
        expect(buyer.isValidForStandard, isFalse);
      });
    });

    // ── copyWith ─────────────────────────────────────────

    group('copyWith', () {
      test('returns identical copy when no arguments given', () {
        const original = ZatcaBuyer(
          name: 'Original',
          vatNumber: '310987654300003',
          city: 'Riyadh',
        );
        final copy = original.copyWith();
        expect(copy.name, original.name);
        expect(copy.vatNumber, original.vatNumber);
        expect(copy.city, original.city);
      });

      test('updates only specified fields', () {
        const original = ZatcaBuyer(
          name: 'Original',
          vatNumber: '310987654300003',
          city: 'Riyadh',
        );
        final updated = original.copyWith(name: 'Updated', city: 'Jeddah');
        expect(updated.name, 'Updated');
        expect(updated.city, 'Jeddah');
        // Unchanged
        expect(updated.vatNumber, original.vatNumber);
      });
    });

    // ── Serialization ────────────────────────────────────

    group('toJson / fromJson', () {
      test('empty buyer serializes to empty map', () {
        const buyer = ZatcaBuyer();
        expect(buyer.toJson(), isEmpty);
      });

      test('toJson omits null fields', () {
        const buyer = ZatcaBuyer(name: 'Acme', city: 'Riyadh');
        final json = buyer.toJson();
        expect(json['name'], 'Acme');
        expect(json['city'], 'Riyadh');
        expect(json.containsKey('vatNumber'), isFalse);
        expect(json.containsKey('buyerId'), isFalse);
      });

      test('roundtrips all fields through JSON', () {
        const buyer = ZatcaBuyer(
          name: 'Acme Corp',
          vatNumber: '310987654300003',
          buyerId: 'ID-001',
          buyerIdScheme: 'CRN',
          streetName: 'Olaya Street',
          buildingNumber: '4567',
          city: 'Riyadh',
          district: 'Al Olaya',
          postalCode: '12213',
          countryCode: 'SA',
        );

        final json = buyer.toJson();
        final restored = ZatcaBuyer.fromJson(json);

        expect(restored.name, buyer.name);
        expect(restored.vatNumber, buyer.vatNumber);
        expect(restored.buyerId, buyer.buyerId);
        expect(restored.buyerIdScheme, buyer.buyerIdScheme);
        expect(restored.streetName, buyer.streetName);
        expect(restored.buildingNumber, buyer.buildingNumber);
        expect(restored.city, buyer.city);
        expect(restored.district, buyer.district);
        expect(restored.postalCode, buyer.postalCode);
        expect(restored.countryCode, buyer.countryCode);
      });

      test('fromJson handles an empty map', () {
        final buyer = ZatcaBuyer.fromJson({});
        expect(buyer.name, isNull);
        expect(buyer.vatNumber, isNull);
      });

      test('handles Arabic characters in name', () {
        const buyer = ZatcaBuyer(
          name: 'مؤسسة الاختبار',
          city: 'الرياض',
        );
        final json = buyer.toJson();
        final restored = ZatcaBuyer.fromJson(json);
        expect(restored.name, 'مؤسسة الاختبار');
        expect(restored.city, 'الرياض');
      });
    });

    // ── Smoke test ───────────────────────────────────────

    test('toString does not throw', () {
      const buyer = ZatcaBuyer(name: 'Test');
      expect(buyer.toString(), isNotEmpty);
    });
  });
}
