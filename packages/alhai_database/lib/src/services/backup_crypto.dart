/// BackupCrypto — AES-256-GCM with PBKDF2-derived key for backup files.
///
/// Wave 5 (P0-08): the previous backup pipeline shipped plaintext JSON via
/// the system clipboard or a share sheet — anyone who handled the file
/// (cloud storage indexer, neighbouring app on the device, IT support) had
/// raw access to customer phone numbers, balances, sale history, and the
/// ZATCA invoice chain. This service wraps each backup payload in an
/// authenticated envelope so neither casual readers nor a stolen file
/// gives anything up without the passphrase.
///
/// Threat model
/// ------------
/// * **In scope:** opportunistic exposure (cloud sync, lost SD card,
///   misdirected file share). The passphrase is the only secret; without
///   it the ciphertext is indistinguishable from random.
/// * **Out of scope:** an attacker with the passphrase, an attacker who
///   compromises the device while the backup screen is open, or any
///   side-channel against the cashier's brain. Backups are only as
///   strong as the passphrase the cashier picks.
///
/// Envelope format
/// ---------------
/// All multi-byte fields are big-endian.
///
/// ```
/// offset  size   field
/// ──────  ────   ─────────────────────────────────────────
///      0     8   magic            ASCII "ALHAIB01"
///      8     1   version          0x01 (envelope version)
///      9     4   kdfIterations    PBKDF2 iteration count (uint32)
///     13    16   salt             random per backup
///     29    12   nonce            random per backup (GCM IV)
///     41    n    ciphertext+tag   AES-256-GCM(plaintext) || 16-byte tag
/// ```
///
/// Total envelope overhead: 41 + 16 = 57 bytes. Output is base64-encoded
/// so it can ride through any text transport.
///
/// Versioning lives in two layers: the magic+version bytes guard the
/// envelope shape (so we can rotate KDF or cipher in the future without
/// silently misreading old files), and the BackupBundle's `schemaVersion`
/// guard catches plaintext-level Drift migrations.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Thrown when a backup envelope can't be parsed or decrypted. Tag the
/// failure category so UI can show a user-meaningful message ("wrong
/// passphrase" vs "this file isn't a valid Alhai backup").
class BackupCryptoException implements Exception {
  final String message;
  final BackupCryptoFailure kind;

  const BackupCryptoException(this.message, this.kind);

  @override
  String toString() => 'BackupCryptoException(${kind.name}): $message';
}

enum BackupCryptoFailure {
  /// Envelope magic / version doesn't match. File is not a backup or
  /// belongs to a future envelope rev we don't understand.
  malformed,

  /// AES-GCM auth tag failed: wrong passphrase OR file was tampered with.
  /// Surface generically — "wrong passphrase" — so we don't leak which.
  badPassphrase,
}

/// AES-256-GCM with PBKDF2-HMAC-SHA256 KDF. All sizes baked in so callers
/// don't have to think about them.
class BackupCrypto {
  // Envelope constants — keep aligned with the docstring above.
  static const _magic = [
    0x41, 0x4C, 0x48, 0x41, 0x49, 0x42, 0x30, 0x31, // "ALHAIB01"
  ];
  static const _envelopeVersion = 0x01;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _keyLength = 32; // 256 bits
  static const _gcmTagLength = 16;

  /// 100k iterations is the OWASP 2023 baseline for PBKDF2-HMAC-SHA256.
  /// Backup decrypt happens once per restore, so the latency is amortised
  /// over a long workflow — we don't need Argon2 here.
  static const int kdfIterations = 100000;

  final Random _rng;

  /// Production callers should use the default [Random.secure]; tests can
  /// pass a seeded [Random] for deterministic envelopes.
  BackupCrypto({Random? rng}) : _rng = rng ?? Random.secure();

  // ===========================================================================
  // ENCRYPT
  // ===========================================================================

  /// Wrap [plaintext] in an encrypted envelope keyed by [passphrase].
  ///
  /// Returns base64(envelope) so the result can ride through clipboard,
  /// share-sheet, or file APIs without binary-handling concerns. Pass the
  /// raw output to [decryptToString] (or [decrypt]) to round-trip.
  String encryptString(String plaintext, String passphrase) {
    final bytes = utf8.encode(plaintext);
    return base64.encode(encrypt(bytes, passphrase));
  }

  Uint8List encrypt(List<int> plaintext, String passphrase) {
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final key = _deriveKey(passphrase, salt);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(key),
          _gcmTagLength * 8, // mac size in bits
          nonce,
          Uint8List(0), // no additional authenticated data
        ),
      );

    final ciphertext = cipher.process(Uint8List.fromList(plaintext));

    final envelope = BytesBuilder()
      ..add(_magic)
      ..addByte(_envelopeVersion)
      ..add(_int32BE(kdfIterations))
      ..add(salt)
      ..add(nonce)
      ..add(ciphertext);
    return envelope.toBytes();
  }

  // ===========================================================================
  // DECRYPT
  // ===========================================================================

  /// Inverse of [encryptString]. Throws [BackupCryptoException] on a
  /// malformed envelope or a wrong passphrase.
  String decryptToString(String base64Envelope, String passphrase) {
    final raw = base64.decode(base64Envelope.trim());
    return utf8.decode(decrypt(raw, passphrase));
  }

  Uint8List decrypt(List<int> envelope, String passphrase) {
    final bytes = Uint8List.fromList(envelope);
    if (bytes.length < _magic.length + 1 + 4 + _saltLength + _nonceLength + _gcmTagLength) {
      throw const BackupCryptoException(
        'Envelope too short to be a valid backup',
        BackupCryptoFailure.malformed,
      );
    }

    // 1) Magic + envelope version.
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) {
        throw const BackupCryptoException(
          'Magic bytes mismatch — file is not an Alhai backup',
          BackupCryptoFailure.malformed,
        );
      }
    }
    final version = bytes[_magic.length];
    if (version != _envelopeVersion) {
      throw BackupCryptoException(
        'Unsupported envelope version: $version. '
        'Update the app to read this backup.',
        BackupCryptoFailure.malformed,
      );
    }

    // 2) KDF iterations (4 bytes big-endian uint32).
    final iterations = (bytes[_magic.length + 1] << 24) |
        (bytes[_magic.length + 2] << 16) |
        (bytes[_magic.length + 3] << 8) |
        bytes[_magic.length + 4];

    // 3) Salt + nonce + ciphertext slices.
    var offset = _magic.length + 1 + 4;
    final salt = Uint8List.sublistView(bytes, offset, offset + _saltLength);
    offset += _saltLength;
    final nonce = Uint8List.sublistView(bytes, offset, offset + _nonceLength);
    offset += _nonceLength;
    final ciphertext = Uint8List.sublistView(bytes, offset);

    final key = _deriveKey(passphrase, salt, iterations: iterations);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          _gcmTagLength * 8,
          nonce,
          Uint8List(0),
        ),
      );

    try {
      return cipher.process(Uint8List.fromList(ciphertext));
    } on InvalidCipherTextException catch (_) {
      // Could be wrong passphrase or tampered ciphertext — same outcome
      // from the caller's perspective. Don't disambiguate.
      throw const BackupCryptoException(
        'Wrong passphrase or corrupt backup',
        BackupCryptoFailure.badPassphrase,
      );
    }
  }

  // ===========================================================================
  // INSPECT
  // ===========================================================================

  /// True if [base64Envelope] looks like an Alhai-encrypted backup (magic
  /// bytes match). Doesn't verify the passphrase or run AES.
  static bool isEncryptedEnvelope(String base64Envelope) {
    try {
      final bytes = base64.decode(base64Envelope.trim());
      if (bytes.length < _magic.length) return false;
      for (var i = 0; i < _magic.length; i++) {
        if (bytes[i] != _magic[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // INTERNALS
  // ===========================================================================

  Uint8List _deriveKey(
    String passphrase,
    Uint8List salt, {
    int iterations = kdfIterations,
  }) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac.withDigest(SHA256Digest()))
      ..init(Pbkdf2Parameters(salt, iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  Uint8List _randomBytes(int length) {
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = _rng.nextInt(256);
    }
    return out;
  }

  Uint8List _int32BE(int value) {
    final b = Uint8List(4);
    b[0] = (value >> 24) & 0xFF;
    b[1] = (value >> 16) & 0xFF;
    b[2] = (value >> 8) & 0xFF;
    b[3] = value & 0xFF;
    return b;
  }
}
