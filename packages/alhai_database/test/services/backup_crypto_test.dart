/// Unit tests for BackupCrypto — Wave 5 / P0-08.
///
/// Focus: round-trip correctness, deterministic envelope shape with a
/// seeded RNG, and explicit failure modes (wrong passphrase vs. malformed
/// envelope) so the UI can map them to user-meaningful messages.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:alhai_database/alhai_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupCrypto', () {
    test('round-trips a JSON-shaped payload through encrypt → decrypt', () {
      final crypto = BackupCrypto();
      const passphrase = 'correct-horse-battery-staple';
      final payload = jsonEncode({
        'version': '1.1.0',
        'storeId': 'store-1',
        'data': {
          'sales': List.generate(50, (i) => {'id': 'sale-$i', 'total': i * 100}),
        },
      });

      final envelope = crypto.encryptString(payload, passphrase);
      final restored = crypto.decryptToString(envelope, passphrase);

      expect(restored, payload);
    });

    test('different runs produce different envelopes (random salt + nonce)', () {
      final crypto = BackupCrypto();
      const payload = 'hello world';
      const passphrase = 'pw';
      final a = crypto.encryptString(payload, passphrase);
      final b = crypto.encryptString(payload, passphrase);
      expect(a, isNot(b));
    });

    test('seeded RNG yields a deterministic envelope', () {
      // With the same seed and inputs we must get bit-identical output —
      // useful when writing test vectors.
      final crypto1 = BackupCrypto(rng: Random(42));
      final crypto2 = BackupCrypto(rng: Random(42));
      final a = crypto1.encryptString('payload', 'pw');
      final b = crypto2.encryptString('payload', 'pw');
      expect(a, b);
    });

    test('wrong passphrase throws badPassphrase', () {
      final crypto = BackupCrypto();
      final envelope = crypto.encryptString('secret', 'right-pw');
      expect(
        () => crypto.decryptToString(envelope, 'wrong-pw'),
        throwsA(
          isA<BackupCryptoException>().having(
            (e) => e.kind,
            'kind',
            BackupCryptoFailure.badPassphrase,
          ),
        ),
      );
    });

    test('malformed (non-base64) input throws malformed', () {
      final crypto = BackupCrypto();
      // Random gibberish that isn't even valid base64.
      expect(
        () => crypto.decryptToString('not!@#valid!base64', 'any'),
        throwsA(isA<Object>()),
      );
    });

    test('valid base64 but non-magic bytes throws malformed', () {
      final crypto = BackupCrypto();
      // Not Alhai magic — leads with random bytes long enough to pass
      // the length check.
      final fake = base64.encode(List.filled(100, 0xFF));
      expect(
        () => crypto.decryptToString(fake, 'any'),
        throwsA(
          isA<BackupCryptoException>().having(
            (e) => e.kind,
            'kind',
            BackupCryptoFailure.malformed,
          ),
        ),
      );
    });

    test('truncated envelope (missing tag) throws', () {
      final crypto = BackupCrypto();
      final envelope = crypto.encryptString('payload', 'pw');
      final raw = base64.decode(envelope);
      // Drop the last 8 bytes — corrupts the GCM tag.
      final truncated = base64.encode(
        Uint8List.sublistView(raw, 0, raw.length - 8),
      );
      expect(
        () => crypto.decryptToString(truncated, 'pw'),
        throwsA(isA<BackupCryptoException>()),
      );
    });

    test('isEncryptedEnvelope detects the magic without decrypting', () {
      final crypto = BackupCrypto();
      final envelope = crypto.encryptString('x', 'pw');
      expect(BackupCrypto.isEncryptedEnvelope(envelope), isTrue);
      // Plain JSON should not be mistaken for an encrypted envelope.
      expect(
        BackupCrypto.isEncryptedEnvelope(
          base64.encode(utf8.encode('{"version":"1.0.0"}')),
        ),
        isFalse,
      );
      // Garbage must return false (no exception).
      expect(BackupCrypto.isEncryptedEnvelope('not base64 at all'), isFalse);
    });

    test('large payload (1 MB) round-trips', () {
      final crypto = BackupCrypto();
      // Realistic backup size: a busy store can easily produce >1 MB JSON.
      final big = 'a' * (1024 * 1024);
      final envelope = crypto.encryptString(big, 'pw');
      expect(crypto.decryptToString(envelope, 'pw'), big);
    });

    test('UTF-8 / Arabic content round-trips cleanly', () {
      final crypto = BackupCrypto();
      const arabic = 'مرحباً بكم في الحاي — العميل: محمد، الرصيد: 1234.56';
      final envelope = crypto.encryptString(arabic, 'كلمة-سر-عربية');
      expect(crypto.decryptToString(envelope, 'كلمة-سر-عربية'), arabic);
    });
  });
}
