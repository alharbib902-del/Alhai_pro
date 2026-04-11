import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/certificate/csr_generator.dart';

void main() {
  group('CsrGenerator', () {
    late CsrGenerator generator;

    setUp(() {
      generator = CsrGenerator();
    });

    // Shared test parameters to keep each test compact
    Future<Map<String, String>> generateTestCsr({
      String commonName = 'AlhaiPOS-EGS',
      String organizationUnit = 'Riyadh-Branch',
      String organizationName = 'Alhai POS Ltd',
      String country = 'SA',
      String serialNumber = '1-AlhaiPOS|2-1.0|3-EGS-001',
      String invoiceType = '1100',
      String branchLocation = 'Riyadh, Saudi Arabia',
      String industryBusinessCategory = 'Retail',
    }) {
      return generator.generateCsr(
        commonName: commonName,
        organizationUnit: organizationUnit,
        organizationName: organizationName,
        country: country,
        serialNumber: serialNumber,
        invoiceType: invoiceType,
        branchLocation: branchLocation,
        industryBusinessCategory: industryBusinessCategory,
      );
    }

    group('generateCsr', () {
      test('returns a map with csr and privateKey fields', () async {
        final result = await generateTestCsr();

        expect(result.containsKey('csr'), isTrue);
        expect(result.containsKey('privateKey'), isTrue);
        expect(result['csr'], isA<String>());
        expect(result['privateKey'], isA<String>());
      });

      test('CSR output is in valid PEM format with expected label', () async {
        final result = await generateTestCsr();
        final csr = result['csr']!;

        expect(csr, startsWith('-----BEGIN CERTIFICATE REQUEST-----'));
        expect(csr, endsWith('-----END CERTIFICATE REQUEST-----'));
        // Should have newlines separating the header/body/footer
        expect(csr.split('\n').length, greaterThan(2));
      });

      test('private key output is PKCS#8 PEM format', () async {
        final result = await generateTestCsr();
        final pk = result['privateKey']!;

        expect(pk, startsWith('-----BEGIN PRIVATE KEY-----'));
        expect(pk, endsWith('-----END PRIVATE KEY-----'));
      });

      test('CSR base64 content decodes to valid DER (SEQUENCE tag)', () async {
        final result = await generateTestCsr();
        final csrPem = result['csr']!;
        final b64 = _stripPem(csrPem);
        final der = base64Decode(b64);

        // X.509 CSR is a DER SEQUENCE (0x30)
        expect(der[0], 0x30);
      });

      test('private key base64 content decodes to valid DER', () async {
        final result = await generateTestCsr();
        final keyPem = result['privateKey']!;
        final b64 = _stripPem(keyPem);
        final der = base64Decode(b64);

        expect(der[0], 0x30);
      });

      test('produces distinct CSRs on each call (fresh key pair)', () async {
        final r1 = await generateTestCsr();
        final r2 = await generateTestCsr();

        // Different keys should produce different CSRs
        expect(r1['csr'], isNot(r2['csr']));
        expect(r1['privateKey'], isNot(r2['privateKey']));
      });

      test('CSR contains the correct common name in subject DN', () async {
        const cn = 'UnitTest-EGS-123';
        final result = await generateTestCsr(commonName: cn);

        final csrInfo = _parseCsrInfo(result['csr']!);
        final subject = csrInfo.subject;
        expect(subject, contains(cn));
      });

      test('CSR contains the organization name and unit', () async {
        const org = 'MyOrg LLC';
        const ou = 'IT-Dept';
        final result = await generateTestCsr(
          organizationName: org,
          organizationUnit: ou,
        );

        final csrInfo = _parseCsrInfo(result['csr']!);
        expect(csrInfo.subject, contains(org));
        expect(csrInfo.subject, contains(ou));
      });

      test('CSR contains the country code', () async {
        final result = await generateTestCsr(country: 'SA');

        final csrInfo = _parseCsrInfo(result['csr']!);
        expect(csrInfo.subject, contains('SA'));
      });

      test('CSR contains the serial number field', () async {
        const sn = '1-AlhaiPOS|2-2.5|3-ABC-999';
        final result = await generateTestCsr(serialNumber: sn);

        final csrInfo = _parseCsrInfo(result['csr']!);
        expect(csrInfo.subject, contains(sn));
      });

      test('CSR includes signature algorithm (ecdsa-with-SHA256)', () async {
        final result = await generateTestCsr();
        final csrInfo = _parseCsrInfo(result['csr']!);

        // ecdsa-with-SHA256 OID = 1.2.840.10045.4.3.2
        expect(csrInfo.signatureAlgorithmOid, '1.2.840.10045.4.3.2');
      });

      test('public key uses secp256k1 curve OID', () async {
        final result = await generateTestCsr();
        final csrInfo = _parseCsrInfo(result['csr']!);

        // secp256k1 OID = 1.3.132.0.10
        expect(csrInfo.curveOid, '1.3.132.0.10');
        // EC public key OID = 1.2.840.10045.2.1
        expect(csrInfo.keyAlgorithmOid, '1.2.840.10045.2.1');
      });

      test('public key point has proper EC uncompressed format', () async {
        final result = await generateTestCsr();
        final csrInfo = _parseCsrInfo(result['csr']!);

        // Uncompressed EC point: 0x04 || x(32) || y(32) = 65 bytes
        // The source wraps it with an extra 0x00 padding-bits byte, so
        // asn1lib's stringValue returns 66 bytes with a leading 0x00.
        final point = csrInfo.publicKeyPoint;
        final actualPoint = point[0] == 0x00 ? point.sublist(1) : point;
        expect(actualPoint.length, 65);
        expect(actualPoint[0], 0x04);
      });

      test(
        'CSR is signed (signature bit string is present and non-empty)',
        () async {
          final result = await generateTestCsr();
          final csrInfo = _parseCsrInfo(result['csr']!);

          expect(csrInfo.signatureBytes, isNotEmpty);
          // Source code wraps the signature with an extra 0x00 padding-bits
          // byte, so strip it if present.
          final sig = csrInfo.signatureBytes[0] == 0x00
              ? csrInfo.signatureBytes.sublist(1)
              : csrInfo.signatureBytes;
          // ECDSA signature is a DER SEQUENCE (0x30)
          expect(sig[0], 0x30);
        },
      );

      test('CSR includes ZATCA certificate template extension', () async {
        final result = await generateTestCsr();
        final pem = result['csr']!;
        final der = base64Decode(_stripPem(pem));

        // The CSR should mention "ZATCA-Code-Signing" in its encoded
        // extensions (we verify via substring on the raw DER).
        final decoded = String.fromCharCodes(der);
        expect(decoded, contains('ZATCA-Code-Signing'));
      });

      test(
        'CSR includes Subject Alternative Name extension OID (2.5.29.17)',
        () async {
          final result = await generateTestCsr();
          final der = base64Decode(_stripPem(result['csr']!));

          // The SAN OID (2.5.29.17) encoded in DER is 06 03 55 1D 11
          final sanOidBytes = [0x06, 0x03, 0x55, 0x1D, 0x11];
          expect(
            _containsSequence(der, sanOidBytes),
            isTrue,
            reason: 'SAN OID should be present in CSR extensions',
          );
        },
      );

      test(
        'CSR embeds invoice type, branch location, and industry category',
        () async {
          const invoiceType = '1000';
          const branchLoc = 'Jeddah-Bldg-Z';
          const industry = 'Grocery';
          final result = await generateTestCsr(
            invoiceType: invoiceType,
            branchLocation: branchLoc,
            industryBusinessCategory: industry,
          );
          final der = base64Decode(_stripPem(result['csr']!));
          final decoded = String.fromCharCodes(der);

          expect(decoded, contains(invoiceType));
          expect(decoded, contains(branchLoc));
          expect(decoded, contains(industry));
        },
      );

      test(
        'generated private key is usable (parseable DER structure)',
        () async {
          final result = await generateTestCsr();
          final der = base64Decode(_stripPem(result['privateKey']!));

          // PKCS#8 PrivateKeyInfo is a SEQUENCE starting with 0x30
          expect(der[0], 0x30);
          // Should be at least 32 bytes for the raw EC scalar
          expect(der.length, greaterThanOrEqualTo(32));

          // Verify we can parse it back as ASN.1
          final parsed = ASN1Parser(Uint8List.fromList(der)).nextObject();
          expect(parsed, isA<ASN1Sequence>());
        },
      );
    });
  });
}

// ─── Helpers ─────────────────────────────────────────────

String _stripPem(String pem) => pem
    .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
    .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
    .replaceAll(RegExp(r'\s'), '');

bool _containsSequence(List<int> haystack, List<int> needle) {
  if (needle.isEmpty || needle.length > haystack.length) return false;
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

class _CsrInfo {
  final String subject;
  final String keyAlgorithmOid;
  final String curveOid;
  final List<int> publicKeyPoint;
  final String signatureAlgorithmOid;
  final List<int> signatureBytes;

  _CsrInfo({
    required this.subject,
    required this.keyAlgorithmOid,
    required this.curveOid,
    required this.publicKeyPoint,
    required this.signatureAlgorithmOid,
    required this.signatureBytes,
  });
}

/// Minimal CSR parser to inspect the generated structure
_CsrInfo _parseCsrInfo(String csrPem) {
  final der = base64Decode(_stripPem(csrPem));
  final parser = ASN1Parser(Uint8List.fromList(der));
  final top = parser.nextObject() as ASN1Sequence;

  // CSR ::= SEQUENCE {
  //   certificationRequestInfo
  //   signatureAlgorithm
  //   signature BIT STRING
  // }
  final tbsInfo = top.elements[0] as ASN1Sequence;
  final sigAlg = top.elements[1] as ASN1Sequence;
  final sigBitString = top.elements[2] as ASN1BitString;

  // tbsInfo = { version(INT), subject(SEQ), SPKI(SEQ), attributes[0] }
  // element [0]: version INTEGER
  // element [1]: subject SEQUENCE
  // element [2]: SubjectPublicKeyInfo SEQUENCE
  final subjectSeq = tbsInfo.elements[1] as ASN1Sequence;
  final subjectStr = _dnToString(subjectSeq);

  final spki = tbsInfo.elements[2] as ASN1Sequence;
  final algId = spki.elements[0] as ASN1Sequence;
  final keyAlgOid = (algId.elements[0] as ASN1ObjectIdentifier).identifier;
  final curveOid = (algId.elements[1] as ASN1ObjectIdentifier).identifier;
  final pkBitString = spki.elements[1] as ASN1BitString;
  // ASN1BitString.stringValue in asn1lib gives us the bit string content
  // (public key point) without the leading padding-bits count byte.
  final publicKeyPoint = List<int>.from(pkBitString.stringValue);

  final sigOid = (sigAlg.elements[0] as ASN1ObjectIdentifier).identifier;
  final sigBytes = List<int>.from(sigBitString.stringValue);

  return _CsrInfo(
    subject: subjectStr,
    keyAlgorithmOid: keyAlgOid ?? '',
    curveOid: curveOid ?? '',
    publicKeyPoint: publicKeyPoint,
    signatureAlgorithmOid: sigOid ?? '',
    signatureBytes: sigBytes,
  );
}

String _dnToString(ASN1Sequence dn) {
  final parts = <String>[];
  for (final rdn in dn.elements) {
    if (rdn is ASN1Set) {
      for (final atv in rdn.elements) {
        if (atv is ASN1Sequence && atv.elements.length >= 2) {
          final oid = atv.elements[0];
          final value = atv.elements[1];
          final oidStr = oid is ASN1ObjectIdentifier
              ? (oid.identifier ?? '')
              : '';
          String valueStr = '';
          if (value is ASN1UTF8String) {
            valueStr = value.utf8StringValue;
          } else if (value is ASN1PrintableString) {
            valueStr = value.stringValue;
          } else {
            try {
              valueStr = utf8.decode(value.valueBytes());
            } catch (_) {
              valueStr = '';
            }
          }
          parts.add('$oidStr=$valueStr');
        }
      }
    }
  }
  return parts.join(', ');
}
