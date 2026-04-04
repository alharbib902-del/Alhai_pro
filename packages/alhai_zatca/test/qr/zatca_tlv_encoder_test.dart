import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_zatca/src/qr/zatca_tlv_encoder.dart';

void main() {
  late ZatcaTlvEncoder encoder;

  setUp(() {
    encoder = ZatcaTlvEncoder();
  });

  group('ZatcaTlvEncoder', () {
    // ─── encodeSimplified (Phase 1, tags 1-5) ──────────────────

    group('encodeSimplified', () {
      test('encodes tags 1-5 as valid base64', () {
        final result = encoder.encodeSimplified(
          sellerName: 'Bobs Records',
          vatNumber: '310122393500003',
          timestamp: DateTime(2022, 4, 25, 15, 30, 0),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        // Must produce a non-empty base64 string
        expect(result, isNotEmpty);
        expect(() => base64Decode(result), returnsNormally);
      });

      test('round-trip: decode matches original values', () {
        const sellerName = 'Bobs Records';
        const vatNumber = '310122393500003';
        final timestamp = DateTime(2022, 4, 25, 15, 30, 0);
        const totalWithVat = 115.0;
        const vatAmount = 15.0;

        final encoded = encoder.encodeSimplified(
          sellerName: sellerName,
          vatNumber: vatNumber,
          timestamp: timestamp,
          totalWithVat: totalWithVat,
          vatAmount: vatAmount,
        );

        final decoded = encoder.decodeToStrings(encoded);

        expect(decoded[1], equals(sellerName));
        expect(decoded[2], equals(vatNumber));
        expect(decoded[3], equals(timestamp.toIso8601String()));
        expect(decoded[4], equals('115.00'));
        expect(decoded[5], equals('15.00'));
      });

      test('encodes Arabic seller name correctly', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'شركة اختبار',
          vatNumber: '300075588700003',
          timestamp: DateTime(2024, 1, 1, 12, 0, 0),
          totalWithVat: 230.0,
          vatAmount: 30.0,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[1], equals('شركة اختبار'));
      });

      test('handles zero amounts', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'Test Seller',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 6, 1),
          totalWithVat: 0.0,
          vatAmount: 0.0,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[4], equals('0.00'));
        expect(decoded[5], equals('0.00'));
      });

      test('formats amounts to 2 decimal places', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'Test',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.1,
          vatAmount: 13.04347826,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[4], equals('100.10'));
        expect(decoded[5], equals('13.04'));
      });

      test('only contains tags 1 through 5', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'Test',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final decoded = encoder.decode(encoded);
        expect(decoded.keys.toList()..sort(), equals([1, 2, 3, 4, 5]));
      });
    });

    // ─── encode (Phase 2, tags 1-9) ────────────────────────────

    group('encode', () {
      // Sample binary data as base64 for tags 6-8
      final fakeHash = base64Encode(
        Uint8List.fromList(List.generate(32, (i) => i)),
      );
      final fakeSignature = base64Encode(
        Uint8List.fromList(List.generate(64, (i) => i + 100)),
      );
      final fakePublicKey = base64Encode(
        Uint8List.fromList(List.generate(33, (i) => i + 200)),
      );

      test('encodes tags 1-8 for simplified invoices (no tag 9)', () {
        final result = encoder.encode(
          sellerName: 'Test Seller',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 3, 15, 10, 30, 0),
          totalWithVat: 1150.00,
          vatAmount: 150.00,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
        );

        expect(result, isNotEmpty);
        final decoded = encoder.decode(result);

        // Tags 1-8 should be present, tag 9 absent
        expect(decoded.containsKey(1), isTrue);
        expect(decoded.containsKey(2), isTrue);
        expect(decoded.containsKey(3), isTrue);
        expect(decoded.containsKey(4), isTrue);
        expect(decoded.containsKey(5), isTrue);
        expect(decoded.containsKey(6), isTrue);
        expect(decoded.containsKey(7), isTrue);
        expect(decoded.containsKey(8), isTrue);
        expect(decoded.containsKey(9), isFalse);
      });

      test('encodes tags 1-9 for standard invoices (with tag 9)', () {
        final fakeCertSig = base64Encode(
          Uint8List.fromList(List.generate(64, (i) => i + 50)),
        );

        final result = encoder.encode(
          sellerName: 'Test Seller',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 3, 15, 10, 30, 0),
          totalWithVat: 1150.00,
          vatAmount: 150.00,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
          certificateSignature: fakeCertSig,
        );

        final decoded = encoder.decode(result);
        expect(decoded.containsKey(9), isTrue);
        expect(decoded[9]!.length, equals(64));
      });

      test('tag 6 contains raw SHA-256 hash bytes (32 bytes)', () {
        final result = encoder.encode(
          sellerName: 'X',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
        );

        final decoded = encoder.decode(result);
        expect(decoded[6]!.length, equals(32));
        // Verify the bytes match the original
        final originalBytes = base64Decode(fakeHash);
        expect(decoded[6], equals(Uint8List.fromList(originalBytes)));
      });

      test('tag 7 contains raw signature bytes', () {
        final result = encoder.encode(
          sellerName: 'X',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
        );

        final decoded = encoder.decode(result);
        expect(decoded[7]!.length, equals(64));
      });

      test('tag 8 contains raw public key bytes', () {
        final result = encoder.encode(
          sellerName: 'X',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
        );

        final decoded = encoder.decode(result);
        expect(decoded[8]!.length, equals(33));
      });

      test('round-trip preserves all string tags', () {
        final result = encoder.encode(
          sellerName: 'شركة الاختبار للتقنية',
          vatNumber: '300075588700003',
          timestamp: DateTime(2024, 6, 15, 8, 0, 0),
          totalWithVat: 5750.50,
          vatAmount: 750.07,
          invoiceHash: fakeHash,
          digitalSignature: fakeSignature,
          publicKey: fakePublicKey,
        );

        final strings = encoder.decodeToStrings(result);
        expect(strings[1], equals('شركة الاختبار للتقنية'));
        expect(strings[2], equals('300075588700003'));
        expect(strings[4], equals('5750.50'));
        expect(strings[5], equals('750.07'));
      });
    });

    // ─── Variable-length encoding ──────────────────────────────

    group('variable-length encoding', () {
      test('handles values with length <= 127 (single-byte length)', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'Short',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 10.0,
          vatAmount: 1.30,
        );

        // Should encode and decode correctly
        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[1], equals('Short'));
      });

      test('handles values with length > 127 (multi-byte length)', () {
        // Create a long seller name that will exceed 127 bytes in UTF-8
        final longName = 'A' * 200;

        final encoded = encoder.encodeSimplified(
          sellerName: longName,
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 10.0,
          vatAmount: 1.30,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[1], equals(longName));
        expect(decoded[1]!.length, equals(200));
      });

      test('handles large binary values in tag 7 (long signature)', () {
        // 256-byte signature (> 127, needs multi-byte length)
        final largeSig = base64Encode(
          Uint8List.fromList(List.generate(256, (i) => i % 256)),
        );
        final fakeHash = base64Encode(Uint8List(32));
        final fakeKey = base64Encode(Uint8List(33));

        final encoded = encoder.encode(
          sellerName: 'X',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 10.0,
          vatAmount: 1.30,
          invoiceHash: fakeHash,
          digitalSignature: largeSig,
          publicKey: fakeKey,
        );

        final decoded = encoder.decode(encoded);
        expect(decoded[7]!.length, equals(256));
      });
    });

    // ─── decode ────────────────────────────────────────────────

    group('decode', () {
      test('returns empty map for empty base64', () {
        final decoded = encoder.decode(base64Encode(Uint8List(0)));
        expect(decoded, isEmpty);
      });

      test('decodeToStrings returns UTF-8 for tags 1-5 and base64 for 6+', () {
        final hash = base64Encode(Uint8List.fromList([1, 2, 3]));
        final sig = base64Encode(Uint8List.fromList([4, 5, 6]));
        final key = base64Encode(Uint8List.fromList([7, 8, 9]));

        final encoded = encoder.encode(
          sellerName: 'Test',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
          invoiceHash: hash,
          digitalSignature: sig,
          publicKey: key,
        );

        final strings = encoder.decodeToStrings(encoded);

        // Tags 1-5 should be plain strings
        expect(strings[1], isA<String>());
        expect(strings[2], isA<String>());
        expect(strings[4], equals('100.00'));

        // Tags 6-8 should be base64-encoded
        expect(strings[6], equals(hash));
        expect(strings[7], equals(sig));
        expect(strings[8], equals(key));
      });
    });

    // ─── Edge cases ────────────────────────────────────────────

    group('edge cases', () {
      test('handles empty seller name', () {
        final encoded = encoder.encodeSimplified(
          sellerName: '',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 0.0,
          vatAmount: 0.0,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[1], equals(''));
      });

      test('handles very large total amounts', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'Test',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 999999999.99,
          vatAmount: 130434782.61,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[4], equals('999999999.99'));
        expect(decoded[5], equals('130434782.61'));
      });

      test('handles mixed Arabic and English in seller name', () {
        final encoded = encoder.encodeSimplified(
          sellerName: 'شركة ABC للتقنية',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
        );

        final decoded = encoder.decodeToStrings(encoded);
        expect(decoded[1], equals('شركة ABC للتقنية'));
      });
    });
  });
}
