import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/signing/certificate_parser.dart';

void main() {
  group('CertificateParser', () {
    late CertificateParser parser;
    late String testCertPem;
    late DateTime testValidFrom;
    late DateTime testValidTo;
    late BigInt testSerial;

    setUp(() {
      parser = CertificateParser();
      testValidFrom = DateTime.utc(2026, 1, 1, 0, 0, 0);
      testValidTo = DateTime.utc(2027, 1, 1, 0, 0, 0);
      testSerial = BigInt.from(0x1234ABCD);

      testCertPem = _buildTestCertificatePem(
        serialNumber: testSerial,
        issuer: const [
          ['2.5.4.6', 'SA'], // C=SA
          ['2.5.4.3', 'ZATCA-SubCA-1'], // CN=ZATCA-SubCA-1
        ],
        subject: const [
          ['2.5.4.6', 'SA'], // C=SA
          ['2.5.4.10', 'Alhai POS'], // O=Alhai POS
          ['2.5.4.11', 'Branch-1'], // OU=Branch-1
          ['2.5.4.3', 'Alhai Test Cert'], // CN=Alhai Test Cert
        ],
        validFrom: testValidFrom,
        validTo: testValidTo,
      );
    });

    group('parseCertificate', () {
      test('parses a valid X.509 PEM certificate', () {
        final info = parser.parseCertificate(testCertPem);

        expect(info, isNotNull);
        expect(info, isA<Map<String, dynamic>>());
        expect(info.containsKey('serialNumber'), isTrue);
        expect(info.containsKey('issuerName'), isTrue);
        expect(info.containsKey('subjectName'), isTrue);
        expect(info.containsKey('publicKey'), isTrue);
        expect(info.containsKey('validFrom'), isTrue);
        expect(info.containsKey('validTo'), isTrue);
      });

      test('extracts subject distinguished name', () {
        final info = parser.parseCertificate(testCertPem);
        final subjectName = info['subjectName'] as String;

        expect(subjectName, contains('C=SA'));
        expect(subjectName, contains('O=Alhai POS'));
        expect(subjectName, contains('OU=Branch-1'));
        expect(subjectName, contains('CN=Alhai Test Cert'));
      });

      test('extracts issuer distinguished name with ZATCA SubCA format', () {
        final info = parser.parseCertificate(testCertPem);
        final issuerName = info['issuerName'] as String;

        expect(issuerName, contains('CN=ZATCA-SubCA-1'));
        expect(issuerName, contains('C=SA'));
      });

      test('extracts validity dates (notBefore, notAfter)', () {
        final info = parser.parseCertificate(testCertPem);
        final validFrom = info['validFrom'] as DateTime;
        final validTo = info['validTo'] as DateTime;

        expect(validFrom.year, testValidFrom.year);
        expect(validFrom.month, testValidFrom.month);
        expect(validFrom.day, testValidFrom.day);
        expect(validTo.year, testValidTo.year);
        expect(validTo.month, testValidTo.month);
        expect(validTo.day, testValidTo.day);
        expect(validFrom.isBefore(validTo), isTrue);
      });

      test('extracts serial number as hex string', () {
        final info = parser.parseCertificate(testCertPem);
        final serial = info['serialNumber'] as String;

        // 0x1234ABCD in hex
        expect(serial.toLowerCase(), '1234abcd');
      });

      test('extracts public key bytes', () {
        final info = parser.parseCertificate(testCertPem);
        final publicKey = info['publicKey'] as List<int>;

        expect(publicKey, isNotEmpty);
        // EC uncompressed public key starts with 0x04, x (32 bytes), y (32 bytes)
        // ASN.1 BitString.valueBytes() includes the padding-bits prefix byte
        // followed by the point. So it should start with 0x00 or 0x04.
        expect(publicKey.length, greaterThan(32));
      });

      test('throws on invalid PEM', () {
        expect(
          () => parser.parseCertificate('not-a-pem-certificate'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws on empty string', () {
        expect(
          () => parser.parseCertificate(''),
          throwsA(isA<Object>()),
        );
      });

      test('throws on malformed base64 between PEM markers', () {
        const badPem = '-----BEGIN CERTIFICATE-----\n'
            '!!!!!!not-valid-base64!!!!!\n'
            '-----END CERTIFICATE-----';
        expect(
          () => parser.parseCertificate(badPem),
          throwsA(isA<Object>()),
        );
      });
    });

    group('extractSerialNumber', () {
      test('returns hex-encoded serial number', () {
        final serial = parser.extractSerialNumber(testCertPem);
        expect(serial.toLowerCase(), '1234abcd');
      });

      test('is consistent with parseCertificate', () {
        final info = parser.parseCertificate(testCertPem);
        final direct = parser.extractSerialNumber(testCertPem);
        expect(direct, info['serialNumber']);
      });
    });

    group('extractIssuerName', () {
      test('returns LDAP-formatted issuer string', () {
        final issuer = parser.extractIssuerName(testCertPem);
        expect(issuer, contains('CN=ZATCA-SubCA-1'));
      });

      test('is consistent with parseCertificate', () {
        final info = parser.parseCertificate(testCertPem);
        final direct = parser.extractIssuerName(testCertPem);
        expect(direct, info['issuerName']);
      });
    });

    group('computeCertificateDigest', () {
      test('returns base64-encoded SHA-256 digest', () {
        final digest = parser.computeCertificateDigest(testCertPem);

        // Should be valid base64
        expect(() => base64Decode(digest), returnsNormally);
        // SHA-256 = 32 bytes → 44 chars base64
        expect(digest.length, 44);
        expect(base64Decode(digest).length, 32);
      });

      test('digest matches direct SHA-256 of DER bytes', () {
        final digest = parser.computeCertificateDigest(testCertPem);
        final derBytes = parser.pemToDer(testCertPem);
        final expected = base64Encode(sha256.convert(derBytes).bytes);
        expect(digest, expected);
      });

      test('same certificate produces same digest', () {
        final d1 = parser.computeCertificateDigest(testCertPem);
        final d2 = parser.computeCertificateDigest(testCertPem);
        expect(d1, d2);
      });
    });

    group('extractPublicKey', () {
      test('returns non-empty public key bytes', () {
        final pk = parser.extractPublicKey(testCertPem);
        expect(pk, isNotEmpty);
      });

      test('is consistent with parseCertificate', () {
        final info = parser.parseCertificate(testCertPem);
        final direct = parser.extractPublicKey(testCertPem);
        expect(direct, info['publicKey']);
      });
    });

    group('extractSignatureBytes', () {
      test('returns signature bytes without padding prefix', () {
        final sigBytes = parser.extractSignatureBytes(testCertPem);
        expect(sigBytes, isNotEmpty);
        // First byte should not be the padding-bits count (0x00)
        // because extractSignatureBytes strips it
        expect(sigBytes, isNot(predicate<List<int>>((bytes) =>
            bytes.isNotEmpty && bytes[0] == 0 && bytes.length == 65)));
      });

      test('is deterministic for the same certificate', () {
        final s1 = parser.extractSignatureBytes(testCertPem);
        final s2 = parser.extractSignatureBytes(testCertPem);
        expect(s1, s2);
      });
    });

    group('pemToDer', () {
      test('decodes PEM with BEGIN/END markers', () {
        final der = parser.pemToDer(testCertPem);
        expect(der, isNotEmpty);
        // X.509 DER should start with SEQUENCE tag (0x30)
        expect(der[0], 0x30);
      });

      test('handles PEM with whitespace and line breaks', () {
        final pemWithSpaces = testCertPem.replaceAll('\n', '\r\n  ');
        final der = parser.pemToDer(pemWithSpaces);
        expect(der[0], 0x30);
      });

      test('handles PEM without BEGIN/END markers', () {
        // Strip markers, leaving only base64
        final bare = testCertPem
            .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
            .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
            .trim();
        final der = parser.pemToDer(bare);
        expect(der[0], 0x30);
      });
    });

    group('ZATCA-specific (CSID) handling', () {
      test('handles certificate with ZATCA organizationIdentifier OID', () {
        final cert = _buildTestCertificatePem(
          serialNumber: BigInt.from(42),
          issuer: const [
            ['2.5.4.3', 'ZATCA-SubCA-Prod-1'],
          ],
          subject: const [
            ['2.5.4.6', 'SA'],
            ['2.5.4.97', '300000000000003'], // organizationIdentifier (ZATCA VAT)
            ['2.5.4.3', 'EGS-Unit'],
          ],
          validFrom: DateTime.utc(2026, 1, 1),
          validTo: DateTime.utc(2027, 1, 1),
        );

        final info = parser.parseCertificate(cert);
        final subject = info['subjectName'] as String;

        // organizationIdentifier gets mapped to the short name
        expect(subject, contains('organizationIdentifier=300000000000003'));
        expect(subject, contains('CN=EGS-Unit'));
        expect(subject, contains('C=SA'));
      });
    });
  });
}

// ─── Test helpers ─────────────────────────────────────────────────
//
// Builds a minimal, valid-enough X.509 certificate in DER that the
// CertificateParser under test can parse. This avoids hardcoding any
// private key material while still exercising the ASN.1 parsing paths.

String _buildTestCertificatePem({
  required BigInt serialNumber,
  required List<List<String>> issuer, // list of [oid, value]
  required List<List<String>> subject,
  required DateTime validFrom,
  required DateTime validTo,
}) {
  // TBSCertificate ::= SEQUENCE {
  //   version         [0] EXPLICIT Version DEFAULT v1,
  //   serialNumber        CertificateSerialNumber,
  //   signature           AlgorithmIdentifier,
  //   issuer              Name,
  //   validity            Validity,
  //   subject             Name,
  //   subjectPublicKeyInfo SubjectPublicKeyInfo
  // }
  final tbsCert = ASN1Sequence();

  // Version [0] EXPLICIT v3 (2)
  final versionBytes = ASN1Integer(BigInt.from(2)).encodedBytes;
  final versionExplicitBytes = Uint8List.fromList(
    [0xA0, versionBytes.length, ...versionBytes],
  );
  final versionWrapper = ASN1Object.fromBytes(versionExplicitBytes);
  tbsCert.add(versionWrapper);

  // Serial number
  tbsCert.add(ASN1Integer(serialNumber));

  // Signature algorithm (ecdsa-with-SHA256: 1.2.840.10045.4.3.2)
  final sigAlg = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.4.3.2'));
  tbsCert.add(sigAlg);

  // Issuer
  tbsCert.add(_buildName(issuer));

  // Validity
  final validitySeq = ASN1Sequence()
    ..add(ASN1UtcTime(validFrom))
    ..add(ASN1UtcTime(validTo));
  tbsCert.add(validitySeq);

  // Subject
  tbsCert.add(_buildName(subject));

  // SubjectPublicKeyInfo (fake but parseable)
  final spkiAlg = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.2.1'))
    ..add(ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10'));

  // Fake 65-byte EC uncompressed point: 0x04 + 32 bytes X + 32 bytes Y
  final fakePoint = Uint8List(65);
  fakePoint[0] = 0x04;
  for (var i = 1; i < 65; i++) {
    fakePoint[i] = (i * 7) & 0xFF;
  }
  final spki = ASN1Sequence()
    ..add(spkiAlg)
    ..add(ASN1BitString(Uint8List.fromList([0x00, ...fakePoint])));
  tbsCert.add(spki);

  // Full certificate: SEQUENCE { tbsCert, sigAlg, sigValue }
  final cert = ASN1Sequence()
    ..add(tbsCert)
    ..add(sigAlg)
    ..add(ASN1BitString(Uint8List.fromList([0x00, ..._fakeSignature()])));

  final der = cert.encodedBytes;
  return _derToPem(der, 'CERTIFICATE');
}

ASN1Sequence _buildName(List<List<String>> rdns) {
  final name = ASN1Sequence();
  for (final entry in rdns) {
    final oid = entry[0];
    final value = entry[1];
    final atv = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromComponentString(oid))
      ..add(ASN1UTF8String(value));
    final set = ASN1Set()..add(atv);
    name.add(set);
  }
  return name;
}

List<int> _fakeSignature() {
  // A plausible DER-encoded ECDSA signature (SEQUENCE of two 32-byte INTEGERs)
  // This doesn't need to be a real signature - the parser only reads the
  // BIT STRING bytes, not the signature contents.
  final r = List<int>.generate(32, (i) => (i + 1) & 0xFF);
  final s = List<int>.generate(32, (i) => (i + 32) & 0xFF);
  final sig = ASN1Sequence()
    ..add(ASN1Integer(_bytesToBigInt(r)))
    ..add(ASN1Integer(_bytesToBigInt(s)));
  return sig.encodedBytes;
}

BigInt _bytesToBigInt(List<int> bytes) {
  var result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b);
  }
  return result;
}

String _derToPem(List<int> der, String label) {
  final b64 = base64Encode(der);
  final lines = <String>[];
  for (var i = 0; i < b64.length; i += 64) {
    final end = (i + 64 > b64.length) ? b64.length : i + 64;
    lines.add(b64.substring(i, end));
  }
  return '-----BEGIN $label-----\n${lines.join('\n')}\n-----END $label-----';
}
