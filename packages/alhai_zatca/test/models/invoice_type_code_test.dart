import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';

void main() {
  group('InvoiceTypeCode', () {
    // ── Enum values ──────────────────────────────────────

    group('enum values', () {
      test('exposes three ZATCA invoice types', () {
        expect(InvoiceTypeCode.values.length, 3);
        expect(
          InvoiceTypeCode.values,
          containsAll([
            InvoiceTypeCode.standard,
            InvoiceTypeCode.creditNote,
            InvoiceTypeCode.debitNote,
          ]),
        );
      });

      test('standard has UBL code 388', () {
        expect(InvoiceTypeCode.standard.code, '388');
        expect(InvoiceTypeCode.standard.name, 'Standard Tax Invoice');
      });

      test('creditNote has UBL code 381', () {
        expect(InvoiceTypeCode.creditNote.code, '381');
        expect(InvoiceTypeCode.creditNote.name, 'Credit Note');
      });

      test('debitNote has UBL code 383', () {
        expect(InvoiceTypeCode.debitNote.code, '383');
        expect(InvoiceTypeCode.debitNote.name, 'Debit Note');
      });
    });

    // ── fromCode ─────────────────────────────────────────

    group('fromCode', () {
      test('parses 388 to standard', () {
        expect(InvoiceTypeCode.fromCode('388'), InvoiceTypeCode.standard);
      });

      test('parses 381 to creditNote', () {
        expect(InvoiceTypeCode.fromCode('381'), InvoiceTypeCode.creditNote);
      });

      test('parses 383 to debitNote', () {
        expect(InvoiceTypeCode.fromCode('383'), InvoiceTypeCode.debitNote);
      });

      test('throws ArgumentError for unknown code', () {
        expect(() => InvoiceTypeCode.fromCode('999'), throwsArgumentError);
      });

      test('throws ArgumentError for empty string', () {
        expect(() => InvoiceTypeCode.fromCode(''), throwsArgumentError);
      });

      test('is case-sensitive (numeric codes)', () {
        // '388' is numeric so casing doesn't really matter, but ensure
        // any alphanumeric lookalike is rejected.
        expect(() => InvoiceTypeCode.fromCode('38A'), throwsArgumentError);
      });
    });

    // ── toString smoke test ──────────────────────────────

    test('toString does not throw', () {
      expect(InvoiceTypeCode.standard.toString(), isA<String>());
      expect(InvoiceTypeCode.creditNote.toString(), isNotEmpty);
    });
  });

  group('InvoiceSubType', () {
    // ── Constants ────────────────────────────────────────

    group('constants', () {
      test('standardB2B is 7-character code starting with 01', () {
        expect(InvoiceSubType.standardB2B, '0100000');
        expect(InvoiceSubType.standardB2B.length, 7);
        expect(InvoiceSubType.standardB2B.substring(0, 2), '01');
      });

      test('simplifiedB2C is 7-character code starting with 02', () {
        expect(InvoiceSubType.simplifiedB2C, '0200000');
        expect(InvoiceSubType.simplifiedB2C.length, 7);
        expect(InvoiceSubType.simplifiedB2C.substring(0, 2), '02');
      });

      test('standardThirdParty sets third-party flag at index 2', () {
        expect(InvoiceSubType.standardThirdParty, '0110000');
        expect(InvoiceSubType.standardThirdParty[2], '1');
      });

      test('simplifiedThirdParty sets simplified and third-party flags', () {
        expect(InvoiceSubType.simplifiedThirdParty, '0210000');
        expect(InvoiceSubType.simplifiedThirdParty[1], '2');
        expect(InvoiceSubType.simplifiedThirdParty[2], '1');
      });

      test('standardExport sets export flag at index 4', () {
        expect(InvoiceSubType.standardExport, '0100100');
        expect(InvoiceSubType.standardExport[4], '1');
      });

      test('standardSelfBilled sets self-billed flag at index 5', () {
        expect(InvoiceSubType.standardSelfBilled, '0100010');
        expect(InvoiceSubType.standardSelfBilled[5], '1');
      });

      test('all subtype codes are exactly 7 chars', () {
        final codes = [
          InvoiceSubType.standardB2B,
          InvoiceSubType.simplifiedB2C,
          InvoiceSubType.standardThirdParty,
          InvoiceSubType.simplifiedThirdParty,
          InvoiceSubType.standardExport,
          InvoiceSubType.standardSelfBilled,
        ];
        for (final code in codes) {
          expect(code.length, 7, reason: 'subtype $code should be 7 chars');
        }
      });

      test('all subtype codes contain only digits', () {
        final codes = [
          InvoiceSubType.standardB2B,
          InvoiceSubType.simplifiedB2C,
          InvoiceSubType.standardThirdParty,
          InvoiceSubType.simplifiedThirdParty,
          InvoiceSubType.standardExport,
          InvoiceSubType.standardSelfBilled,
        ];
        final digitsOnly = RegExp(r'^\d+$');
        for (final code in codes) {
          expect(digitsOnly.hasMatch(code), isTrue, reason: 'subtype $code');
        }
      });
    });
  });
}
