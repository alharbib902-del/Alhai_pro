import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';

/// Tests for [XadesSigner].
///
/// These tests cover the structural correctness of the generated XAdES-BES
/// signature. We don't verify cryptographic validity against the ZATCA
/// sandbox — that would require the ZATCA test environment and is covered
/// by the `zatca_sandbox_test.dart` integration test.
void main() {
  group('XadesSigner', () {
    late XadesSigner signer;
    late CertificateInfo testCertificate;

    // Minimal UBL invoice XML with a UBLExtensions placeholder so the
    // signer has a valid target to embed the signature block into.
    const invoiceXml =
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
        ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"'
        ' xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"'
        ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">'
        '<ext:UBLExtensions>'
        '<ext:UBLExtension><ext:ExtensionContent>PLACEHOLDER</ext:ExtensionContent></ext:UBLExtension>'
        '</ext:UBLExtensions>'
        '<cbc:ProfileID>reporting:1.0</cbc:ProfileID>'
        '<cbc:ID>INV-TEST-001</cbc:ID>'
        '<cbc:IssueDate>2026-04-10</cbc:IssueDate>'
        '<cbc:IssueTime>12:00:00</cbc:IssueTime>'
        '<cbc:InvoiceTypeCode name="0100000">388</cbc:InvoiceTypeCode>'
        '</Invoice>';

    setUpAll(() {
      // Generate a real secp256k1 keypair for the test certificate
      final keyPair = _generateSecp256k1KeyPair();
      final privateKey = keyPair.privateKey as ECPrivateKey;
      final publicKey = keyPair.publicKey as ECPublicKey;

      final privateKeyPem = _encodeEcPrivateKeyPemSec1(privateKey);
      final publicKeyPoint = publicKey.Q!.getEncoded(false);
      final certPem = _buildTestCertificatePem(
        serialNumber: BigInt.from(0xABCDEF),
        issuer: const [
          ['2.5.4.6', 'SA'],
          ['2.5.4.3', 'ZATCA-SubCA-Test'],
        ],
        subject: const [
          ['2.5.4.6', 'SA'],
          ['2.5.4.3', 'XadesTest'],
        ],
        validFrom: DateTime.utc(2026, 1, 1),
        validTo: DateTime.utc(2027, 1, 1),
        publicKeyPoint: publicKeyPoint,
      );

      testCertificate = CertificateInfo(
        certificatePem: certPem,
        privateKeyPem: privateKeyPem,
        csid: 'test-csid',
        secret: 'test-secret',
        isProduction: false,
      );
    });

    setUp(() {
      signer = XadesSigner();
    });

    group('sign', () {
      test('returns a non-empty signed XML string', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, isNotEmpty);
        expect(signed, isNot(equals(invoiceXml)));
      });

      test('signed XML contains ds:Signature element', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('<ds:Signature'));
        expect(signed, contains('</ds:Signature>'));
      });

      test('signed XML contains xades:QualifyingProperties', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('xades:QualifyingProperties'));
        expect(signed, contains('xades:SignedProperties'));
      });

      test('signed XML includes SigningTime', () {
        final signingTime = DateTime.utc(2026, 4, 10, 14, 30, 0);
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
          signingTime: signingTime,
        );
        expect(signed, contains('xades:SigningTime'));
        expect(signed, contains('2026-04-10T14:30:00Z'));
      });

      test('signed XML embeds the certificate digest in SignedProperties', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('xades:CertDigest'));
        expect(signed, contains('ds:DigestValue'));
        expect(signed, contains('sha256'));
      });

      test('signed XML embeds the certificate issuer and serial', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('ds:X509IssuerName'));
        expect(signed, contains('ds:X509SerialNumber'));
        expect(signed, contains('ZATCA-SubCA-Test'));
      });

      test('signed XML embeds the base64 certificate body', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('ds:X509Certificate'));
        // The base64 body (with newlines stripped) should appear in the output
        final certBase64 = testCertificate.certificatePem
            .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
            .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
            .replaceAll(RegExp(r'\s'), '');
        expect(signed, contains(certBase64));
      });

      test('signed XML uses exc-c14n (c14n11) canonicalization', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('http://www.w3.org/2006/12/xml-c14n11'));
      });

      test('signed XML uses ECDSA-SHA256 signature method', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(
          signed,
          contains('http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256'),
        );
      });

      test('signed XML contains both SignedInfo references', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        // Should have 2 ds:Reference elements: one for the invoice body,
        // and one for the SignedProperties (#xadesSignedProperties)
        final referenceMatches = RegExp(
          r'<ds:Reference',
        ).allMatches(signed).length;
        expect(referenceMatches, 2);
        expect(signed, contains('#xadesSignedProperties'));
      });

      test('signed XML preserves original invoice fields', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        expect(signed, contains('INV-TEST-001'));
        expect(signed, contains('2026-04-10'));
      });

      test('SignatureValue element is present and non-empty', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );

        final match = RegExp(
          r'<ds:SignatureValue>([^<]+)</ds:SignatureValue>',
        ).firstMatch(signed);
        expect(match, isNotNull);

        final sigValue = match!.group(1)!;
        expect(sigValue, isNotEmpty);
        // SignatureValue is base64
        expect(() => base64Decode(sigValue), returnsNormally);
      });

      test(
        'signing the same invoice twice produces deterministic signature',
        () {
          // DET-ECDSA (RFC 6979) is deterministic for same key + message
          final fixedTime = DateTime.utc(2026, 4, 10, 12, 0, 0);
          final signed1 = signer.sign(
            invoiceXml: invoiceXml,
            certificate: testCertificate,
            signingTime: fixedTime,
          );
          final signed2 = signer.sign(
            invoiceXml: invoiceXml,
            certificate: testCertificate,
            signingTime: fixedTime,
          );
          expect(signed1, signed2);
        },
      );

      test('different signing times produce different signatures', () {
        final time1 = DateTime.utc(2026, 4, 10, 12, 0, 0);
        final time2 = DateTime.utc(2026, 4, 10, 13, 0, 0);
        final signed1 = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
          signingTime: time1,
        );
        final signed2 = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
          signingTime: time2,
        );
        expect(signed1, isNot(equals(signed2)));
      });

      test('replaces UBLExtensions placeholder with signature block', () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );
        // The placeholder text should be gone, replaced by the real signature
        expect(signed, isNot(contains('PLACEHOLDER')));
        expect(signed, contains('sig:UBLDocumentSignatures'));
        expect(signed, contains('sac:SignatureInformation'));
      });
    });

    group('computeInvoiceHash', () {
      test('returns a base64-encoded SHA-256 hash', () {
        final hash = signer.computeInvoiceHash(invoiceXml);
        expect(hash, isNotEmpty);
        expect(() => base64Decode(hash), returnsNormally);
        // SHA-256 = 32 bytes → 44-char base64
        expect(hash.length, 44);
        expect(base64Decode(hash).length, 32);
      });

      test('is deterministic for the same invoice', () {
        final hash1 = signer.computeInvoiceHash(invoiceXml);
        final hash2 = signer.computeInvoiceHash(invoiceXml);
        expect(hash1, hash2);
      });

      test('produces different hashes for different invoices', () {
        const otherInvoice =
            '<?xml version="1.0" encoding="UTF-8"?>'
            '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
            ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">'
            '<cbc:ID>INV-DIFFERENT-999</cbc:ID>'
            '</Invoice>';
        final hash1 = signer.computeInvoiceHash(invoiceXml);
        final hash2 = signer.computeInvoiceHash(otherInvoice);
        expect(hash1, isNot(equals(hash2)));
      });
    });
  });
}

// ─── Test helpers ─────────────────────────────────────────────

AsymmetricKeyPair<PublicKey, PrivateKey> _generateSecp256k1KeyPair() {
  final domainParams = ECDomainParameters('secp256k1');
  final keyGen = ECKeyGenerator();
  final seed = Uint8List(32);
  for (int i = 0; i < 32; i++) {
    seed[i] = (DateTime.now().microsecondsSinceEpoch + i * 31) & 0xFF;
  }
  keyGen.init(
    ParametersWithRandom(
      ECKeyGeneratorParameters(domainParams),
      FortunaRandom()..seed(KeyParameter(seed)),
    ),
  );
  return keyGen.generateKeyPair();
}

/// Encode an EC private key to SEC 1 PEM format (what EcdsaSigner expects).
String _encodeEcPrivateKeyPemSec1(ECPrivateKey key) {
  final dBytes = _bigIntToBytes(key.d!, 32);

  // SEQUENCE {
  //   INTEGER 1 (version)
  //   OCTET STRING (d)
  //   [0] EXPLICIT OID (secp256k1)
  // }
  final oidBytes = <int>[0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x0A];
  final contextOid = <int>[0xA0, oidBytes.length, ...oidBytes];
  final versionBytes = <int>[0x02, 0x01, 0x01];
  final octetString = <int>[0x04, dBytes.length, ...dBytes];

  final innerLen = versionBytes.length + octetString.length + contextOid.length;
  final sequence = <int>[
    0x30,
    ..._derLength(innerLen),
    ...versionBytes,
    ...octetString,
    ...contextOid,
  ];

  final b64 = base64Encode(sequence);
  final lines = <String>[];
  for (var i = 0; i < b64.length; i += 64) {
    lines.add(b64.substring(i, i + 64 > b64.length ? b64.length : i + 64));
  }
  return '-----BEGIN EC PRIVATE KEY-----\n${lines.join('\n')}\n-----END EC PRIVATE KEY-----';
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

String _buildTestCertificatePem({
  required BigInt serialNumber,
  required List<List<String>> issuer,
  required List<List<String>> subject,
  required DateTime validFrom,
  required DateTime validTo,
  required Uint8List publicKeyPoint,
}) {
  final tbsCert = ASN1Sequence();

  // Version [0] EXPLICIT v3 (2)
  final versionBytes = ASN1Integer(BigInt.from(2)).encodedBytes;
  tbsCert.add(
    ASN1Object.fromBytes(
      Uint8List.fromList([0xA0, versionBytes.length, ...versionBytes]),
    ),
  );

  // Serial
  tbsCert.add(ASN1Integer(serialNumber));

  // Signature algorithm
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

  // SubjectPublicKeyInfo
  final spkiAlg = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.2.1'))
    ..add(ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10'));
  final spki = ASN1Sequence()
    ..add(spkiAlg)
    ..add(ASN1BitString(Uint8List.fromList([0x00, ...publicKeyPoint])));
  tbsCert.add(spki);

  // Full certificate
  final cert = ASN1Sequence()
    ..add(tbsCert)
    ..add(sigAlg)
    ..add(ASN1BitString(Uint8List.fromList([0x00, ..._fakeSignature()])));

  return _derToPem(cert.encodedBytes, 'CERTIFICATE');
}

ASN1Sequence _buildName(List<List<String>> rdns) {
  final name = ASN1Sequence();
  for (final entry in rdns) {
    final atv = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromComponentString(entry[0]))
      ..add(ASN1UTF8String(entry[1]));
    final set = ASN1Set()..add(atv);
    name.add(set);
  }
  return name;
}

List<int> _fakeSignature() {
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
