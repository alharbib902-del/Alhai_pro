import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

import 'package:alhai_zatca/src/certificate/csr_generator.dart';
import 'package:alhai_zatca/src/signing/ecdsa_signer.dart';

void main() {
  group('EcdsaSigner', () {
    late EcdsaSigner signer;
    late String testPrivateKeyPem;
    late String testPublicKeyPem;

    setUp(() {
      signer = EcdsaSigner();

      // Generate a fresh secp256k1 key pair for testing
      final keyPair = _generateTestKeyPair();
      testPrivateKeyPem = keyPair['privateKeyPem'] as String;
      testPublicKeyPem = keyPair['publicKeyPem'] as String;
    });

    group('sign', () {
      test('should produce a valid base64 signature', () {
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode('test data')).bytes);

        final signatureBase64 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );

        // Should be valid base64
        expect(() => base64Decode(signatureBase64), returnsNormally);

        // Decoded should be a DER-encoded ECDSA signature
        final sigBytes = base64Decode(signatureBase64);
        // DER signature starts with SEQUENCE tag (0x30)
        expect(sigBytes[0], 0x30);
      });

      test('should produce different signatures for different data', () {
        final digest1 =
            Uint8List.fromList(sha256.convert(utf8.encode('data 1')).bytes);
        final digest2 =
            Uint8List.fromList(sha256.convert(utf8.encode('data 2')).bytes);

        final sig1 = signer.sign(
          digest: digest1,
          privateKeyPem: testPrivateKeyPem,
        );
        final sig2 = signer.sign(
          digest: digest2,
          privateKeyPem: testPrivateKeyPem,
        );

        expect(sig1, isNot(sig2));
      });

      test('should produce deterministic signatures (DET-ECDSA)', () {
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode('same data')).bytes);

        final sig1 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );
        final sig2 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );

        // Deterministic ECDSA (RFC 6979) produces the same signature for the
        // same key+message combination
        expect(sig1, sig2);
      });
    });

    group('verify', () {
      test('should verify a valid signature', () {
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode('verify me')).bytes);

        final signatureBase64 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );

        final isValid = signer.verify(
          digest: digest,
          signature: Uint8List.fromList(base64Decode(signatureBase64)),
          publicKeyPem: testPublicKeyPem,
        );

        expect(isValid, isTrue);
      });

      test('should reject signature with wrong digest', () {
        final originalDigest =
            Uint8List.fromList(sha256.convert(utf8.encode('original')).bytes);
        final tamperedDigest =
            Uint8List.fromList(sha256.convert(utf8.encode('tampered')).bytes);

        final signatureBase64 = signer.sign(
          digest: originalDigest,
          privateKeyPem: testPrivateKeyPem,
        );

        final isValid = signer.verify(
          digest: tamperedDigest,
          signature: Uint8List.fromList(base64Decode(signatureBase64)),
          publicKeyPem: testPublicKeyPem,
        );

        expect(isValid, isFalse);
      });

      test('should reject signature with wrong public key', () {
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode('test')).bytes);

        final signatureBase64 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );

        // Generate a different key pair
        final otherKeyPair = _generateTestKeyPair();
        final otherPublicKeyPem = otherKeyPair['publicKeyPem'] as String;

        final isValid = signer.verify(
          digest: digest,
          signature: Uint8List.fromList(base64Decode(signatureBase64)),
          publicKeyPem: otherPublicKeyPem,
        );

        expect(isValid, isFalse);
      });
    });

    group('sign and verify roundtrip', () {
      test('should sign and verify a SHA-256 digest successfully', () {
        // Simulate the ZATCA signing flow:
        // 1. Compute SHA-256 of invoice data
        const invoiceData = 'invoice-xml-content-here';
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode(invoiceData)).bytes);

        // 2. Sign the digest
        final signatureBase64 = signer.sign(
          digest: digest,
          privateKeyPem: testPrivateKeyPem,
        );

        // 3. Verify the signature
        final isValid = signer.verify(
          digest: digest,
          signature: Uint8List.fromList(base64Decode(signatureBase64)),
          publicKeyPem: testPublicKeyPem,
        );

        expect(isValid, isTrue);
      });

      test('should work with empty digest', () {
        final emptyDigest = Uint8List.fromList(sha256.convert(<int>[]).bytes);

        final signatureBase64 = signer.sign(
          digest: emptyDigest,
          privateKeyPem: testPrivateKeyPem,
        );

        final isValid = signer.verify(
          digest: emptyDigest,
          signature: Uint8List.fromList(base64Decode(signatureBase64)),
          publicKeyPem: testPublicKeyPem,
        );

        expect(isValid, isTrue);
      });

      test('should handle multiple sign/verify cycles', () {
        for (int i = 0; i < 5; i++) {
          final digest =
              Uint8List.fromList(sha256.convert(utf8.encode('cycle $i')).bytes);

          final sig = signer.sign(
            digest: digest,
            privateKeyPem: testPrivateKeyPem,
          );

          final valid = signer.verify(
            digest: digest,
            signature: Uint8List.fromList(base64Decode(sig)),
            publicKeyPem: testPublicKeyPem,
          );

          expect(valid, isTrue, reason: 'Failed on cycle $i');
        }
      });
    });

    group('parsePrivateKey', () {
      test('should extract key components', () {
        final components = signer.parsePrivateKey(testPrivateKeyPem);
        expect(components['curve'], 'secp256k1');
        expect(components['d'], isNotNull);
        expect(components['d'], isNotEmpty);
      });
    });

    group('private key format handling (regression)', () {
      // These tests cover a bug where `_extractPrivateKeyValue` misclassified
      // SEC 1 EC private keys as PKCS#8 (because both start with an INTEGER
      // version field). The fix discriminates by the SECOND element's tag:
      // SEQUENCE (0x30) → PKCS#8 AlgorithmIdentifier,
      // OCTET STRING (0x04) → SEC 1 privateKey.

      test('parses raw SEC 1 EC private key', () {
        // The default test helper uses SEC 1 format.
        final digest =
            Uint8List.fromList(sha256.convert(utf8.encode('sec1-key')).bytes);

        // Should not throw RangeError or FormatException.
        expect(
          () => signer.sign(digest: digest, privateKeyPem: testPrivateKeyPem),
          returnsNormally,
        );

        final sigBase64 =
            signer.sign(digest: digest, privateKeyPem: testPrivateKeyPem);
        final valid = signer.verify(
          digest: digest,
          signature: Uint8List.fromList(base64Decode(sigBase64)),
          publicKeyPem: testPublicKeyPem,
        );
        expect(valid, isTrue);
      });

      test('parses PKCS#8 wrapped SEC1 EC private key from CsrGenerator',
          () async {
        // Exercise the exact path that triggered the original RangeError:
        // CsrGenerator emits a PKCS#8-wrapped SEC 1 EC private key PEM,
        // and EcdsaSigner.sign must be able to parse & use it.
        final csrGenerator = CsrGenerator();
        final result = await csrGenerator.generateCsr(
          commonName: 'Test Store',
          organizationUnit: 'Branch-001',
          organizationName: 'Test Org',
          country: 'SA',
          serialNumber: '1-TestSolution|2-1.0|3-SN001',
          invoiceType: '1100',
          branchLocation: 'Riyadh',
          industryBusinessCategory: 'Food',
        );

        final pkcs8PrivateKeyPem = result['privateKey']!;
        expect(pkcs8PrivateKeyPem, contains('BEGIN PRIVATE KEY'));

        final digest = Uint8List.fromList(
          sha256.convert(utf8.encode('csr-pkcs8-key')).bytes,
        );

        // Should not throw RangeError — this was the reported crash.
        expect(
          () => signer.sign(
            digest: digest,
            privateKeyPem: pkcs8PrivateKeyPem,
          ),
          returnsNormally,
        );

        final signatureBase64 = signer.sign(
          digest: digest,
          privateKeyPem: pkcs8PrivateKeyPem,
        );
        // Valid base64 DER signature
        expect(() => base64Decode(signatureBase64), returnsNormally);
        final sigBytes = base64Decode(signatureBase64);
        expect(sigBytes[0], 0x30); // DER SEQUENCE tag
      });

      test(
          'PKCS#8 key from CsrGenerator does not throw RangeError on recursive parse',
          () async {
        // Before the fix, the recursive call into the inner SEC 1 structure
        // would re-enter the PKCS#8 branch and index past the buffer end.
        final csrGenerator = CsrGenerator();
        final result = await csrGenerator.generateCsr(
          commonName: 'Regression Test',
          organizationUnit: 'OU',
          organizationName: 'O',
          country: 'SA',
          serialNumber: '1-a|2-b|3-c',
          invoiceType: '1000',
          branchLocation: 'Jeddah',
          industryBusinessCategory: 'Retail',
        );

        final digest = Uint8List.fromList(
          sha256.convert(utf8.encode('range-error-regression')).bytes,
        );

        // Specifically assert no RangeError is thrown.
        try {
          signer.sign(
            digest: digest,
            privateKeyPem: result['privateKey']!,
          );
        } on RangeError catch (e) {
          fail('RangeError should not be thrown after the fix: $e');
        }
      });
    });
  });
}

/// Generate a secp256k1 key pair and return PEM-encoded strings.
///
/// This is a test helper that creates a fresh key pair for each test run.
Map<String, String> _generateTestKeyPair() {
  final domainParams = ECDomainParameters('secp256k1');
  final keyGen = ECKeyGenerator();

  keyGen.init(
    ParametersWithRandom(
      ECKeyGeneratorParameters(domainParams),
      FortunaRandom()..seed(KeyParameter(_randomSeed())),
    ),
  );

  final keyPair = keyGen.generateKeyPair();
  final privateKey = keyPair.privateKey as ECPrivateKey;
  final publicKey = keyPair.publicKey as ECPublicKey;

  return {
    'privateKeyPem': _encodeEcPrivateKeyPem(privateKey),
    'publicKeyPem': _encodeEcPublicKeyPem(publicKey),
  };
}

/// Generate a random 32-byte seed for the PRNG
Uint8List _randomSeed() {
  final seed = Uint8List(32);
  final secureRandom = SecureRandom('Fortuna');
  secureRandom.seed(
    KeyParameter(Uint8List.fromList(
      List.generate(32, (i) => DateTime.now().microsecond + i),
    )),
  );
  for (int i = 0; i < 32; i++) {
    seed[i] = secureRandom.nextUint8();
  }
  return seed;
}

/// Encode an EC private key to SEC 1 PEM format
String _encodeEcPrivateKeyPem(ECPrivateKey key) {
  final dBytes = _bigIntToBytes(key.d!, 32);

  // SEC 1 EC Private Key structure (simplified, no public key or parameters):
  // SEQUENCE {
  //   INTEGER 1 (version)
  //   OCTET STRING (private key value)
  //   [0] EXPLICIT OID (secp256k1 = 1.3.132.0.10)
  // }
  final oidBytes = <int>[0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x0A]; // secp256k1
  final contextOid = <int>[0xA0, oidBytes.length, ...oidBytes];
  final versionBytes = <int>[0x02, 0x01, 0x01]; // INTEGER 1
  final octetString = <int>[0x04, dBytes.length, ...dBytes];

  final innerLen = versionBytes.length + octetString.length + contextOid.length;
  final sequence = <int>[
    0x30,
    ..._derLength(innerLen),
    ...versionBytes,
    ...octetString,
    ...contextOid
  ];

  final b64 = base64Encode(sequence);
  final lines = <String>[];
  for (int i = 0; i < b64.length; i += 64) {
    lines.add(b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
  }
  return '-----BEGIN EC PRIVATE KEY-----\n${lines.join('\n')}\n-----END EC PRIVATE KEY-----';
}

/// Encode an EC public key to SubjectPublicKeyInfo PEM format
String _encodeEcPublicKeyPem(ECPublicKey key) {
  final point = key.Q!.getEncoded(false); // uncompressed point

  // SubjectPublicKeyInfo:
  // SEQUENCE {
  //   SEQUENCE { OID ecPublicKey, OID secp256k1 }
  //   BIT STRING (public key point)
  // }
  final ecPubKeyOid = <int>[
    0x06,
    0x07,
    0x2A,
    0x86,
    0x48,
    0xCE,
    0x3D,
    0x02,
    0x01
  ]; // 1.2.840.10045.2.1
  final secp256k1Oid = <int>[
    0x06,
    0x05,
    0x2B,
    0x81,
    0x04,
    0x00,
    0x0A
  ]; // 1.3.132.0.10
  final algIdLen = ecPubKeyOid.length + secp256k1Oid.length;
  final algId = <int>[
    0x30,
    ..._derLength(algIdLen),
    ...ecPubKeyOid,
    ...secp256k1Oid
  ];

  final bitString = <int>[
    0x03,
    ..._derLength(point.length + 1),
    0x00,
    ...point
  ];

  final outerLen = algId.length + bitString.length;
  final sequence = <int>[0x30, ..._derLength(outerLen), ...algId, ...bitString];

  final b64 = base64Encode(sequence);
  final lines = <String>[];
  for (int i = 0; i < b64.length; i += 64) {
    lines.add(b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
  }
  return '-----BEGIN PUBLIC KEY-----\n${lines.join('\n')}\n-----END PUBLIC KEY-----';
}

List<int> _derLength(int length) {
  if (length < 0x80) return [length];
  if (length < 0x100) return [0x81, length];
  return [0x82, (length >> 8) & 0xFF, length & 0xFF];
}

Uint8List _bigIntToBytes(BigInt value, int length) {
  final bytes = Uint8List(length);
  var v = value;
  for (int i = length - 1; i >= 0; i--) {
    bytes[i] = (v & BigInt.from(0xFF)).toInt();
    v = v >> 8;
  }
  return bytes;
}
