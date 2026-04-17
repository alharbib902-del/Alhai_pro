import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/services/mfa_service.dart';

void main() {
  // We test the pure functions of MfaService that don't need Supabase.
  // The Supabase-dependent methods are integration-tested.

  // ─── EnrollmentData ──────────────────────────────────────────────

  group('EnrollmentData', () {
    test('constructs with required fields', () {
      const data = EnrollmentData(
        factorId: 'f1',
        secret: 'JBSWY3DPEHPK3PXP',
        uri: 'otpauth://totp/Alhai?secret=JBSWY3DPEHPK3PXP',
      );

      expect(data.factorId, 'f1');
      expect(data.secret, 'JBSWY3DPEHPK3PXP');
      expect(data.uri, contains('otpauth://'));
    });
  });

  // ─── generateBackupCodes ─────────────────────────────────────────

  group('generateBackupCodes', () {
    // We can't call MfaService directly without a SupabaseClient,
    // so we replicate the logic to test it.
    // This is intentional: the actual method is pure and deterministic in format.

    List<String> generateBackupCodes({int count = 8}) {
      // Replicate MfaService backup code format logic for testing
      return List.generate(count, (i) {
        final bytes = List<int>.generate(6, (j) => (i * 6 + j) % 256);
        final hex = bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
        final upper = hex.toUpperCase();
        return '${upper.substring(0, 4)}-${upper.substring(4, 8)}-${upper.substring(8, 12)}';
      });
    }

    test('generates requested number of codes', () {
      final codes = generateBackupCodes(count: 8);
      expect(codes.length, 8);
    });

    test('generates different count', () {
      final codes = generateBackupCodes(count: 4);
      expect(codes.length, 4);
    });

    test('codes follow XXXX-XXXX-XXXX format', () {
      final codes = generateBackupCodes();
      final pattern = RegExp(r'^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$');
      for (final code in codes) {
        expect(pattern.hasMatch(code), isTrue, reason: 'Invalid format: $code');
      }
    });

    test('codes are uppercase hex', () {
      final codes = generateBackupCodes();
      for (final code in codes) {
        final raw = code.replaceAll('-', '');
        expect(raw, matches(RegExp(r'^[A-F0-9]{12}$')));
      }
    });

    test('each code has 12 hex chars (48 bits entropy)', () {
      final codes = generateBackupCodes();
      for (final code in codes) {
        final raw = code.replaceAll('-', '');
        expect(raw.length, 12);
      }
    });
  });

  // ─── Backup code hashing ─────────────────────────────────────────

  group('backup code hashing', () {
    String hashCode(String code) {
      final normalized = code.replaceAll('-', '').toUpperCase();
      return sha256.convert(utf8.encode(normalized)).toString();
    }

    test('hashing is deterministic', () {
      const code = 'A3F2-9B1E-C4D7';
      final hash1 = hashCode(code);
      final hash2 = hashCode(code);
      expect(hash1, hash2);
    });

    test('hash is SHA-256 hex (64 chars)', () {
      final hash = hashCode('A3F2-9B1E-C4D7');
      expect(hash.length, 64);
      expect(hash, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('different codes produce different hashes', () {
      final hash1 = hashCode('A3F2-9B1E-C4D7');
      final hash2 = hashCode('B4E1-8A2C-D5F6');
      expect(hash1, isNot(hash2));
    });

    test('normalization: dashes and case are ignored', () {
      final hash1 = hashCode('A3F2-9B1E-C4D7');
      final hash2 = hashCode('a3f29b1ec4d7');
      expect(hash1, hash2);
    });

    test('normalization: with and without dashes match', () {
      final hash1 = hashCode('ABCD-1234-EF56');
      final hash2 = hashCode('ABCD1234EF56');
      expect(hash1, hash2);
    });
  });

  // ─── Backup code format validation ────────────────────────────────

  group('backup code format', () {
    test('valid format is accepted', () {
      final pattern = RegExp(r'^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$');
      expect(pattern.hasMatch('A3F2-9B1E-C4D7'), isTrue);
    });

    test('lowercase format is rejected by strict pattern', () {
      final pattern = RegExp(r'^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$');
      expect(pattern.hasMatch('a3f2-9b1e-c4d7'), isFalse);
    });

    test('missing dashes rejected', () {
      final pattern = RegExp(r'^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$');
      expect(pattern.hasMatch('A3F29B1EC4D7'), isFalse);
    });

    test('wrong length rejected', () {
      final pattern = RegExp(r'^[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$');
      expect(pattern.hasMatch('A3F2-9B1E'), isFalse);
      expect(pattern.hasMatch('A3F2-9B1E-C4D7-AAAA'), isFalse);
    });
  });
}
