import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';

import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';

/// Tests specifically for SignaturePolicyIdentifier in XAdES signatures
/// as required by ZATCA Phase 2 compliance.
void main() {
  group('XAdES SignaturePolicyIdentifier — ZATCA Phase 2', () {
    late XadesSigner signer;
    late CertificateInfo testCertificate;

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

    test('signed XML contains SignaturePolicyIdentifier', () {
      final signed = signer.sign(
        invoiceXml: invoiceXml,
        certificate: testCertificate,
      );

      expect(
        signed,
        contains('xades:SignaturePolicyIdentifier'),
        reason:
            'XAdES MUST contain SignaturePolicyIdentifier per ZATCA Phase 2',
      );
    });

    test('SignaturePolicyIdentifier contains correct ZATCA policy URN', () {
      final signed = signer.sign(
        invoiceXml: invoiceXml,
        certificate: testCertificate,
      );

      expect(signed, contains('urn:oid:1.2.250.1.97.1.0.1'));
    });

    test('SignaturePolicyIdentifier contains correct hash value', () {
      final signed = signer.sign(
        invoiceXml: invoiceXml,
        certificate: testCertificate,
      );

      expect(
        signed,
        contains('7HQYrNh3yBlEcaPBPHHbQT0CdfqcQbNgZ8gpccgi3Hk='),
      );
    });

    test('SignaturePolicyIdentifier uses SHA-256 digest method', () {
      final signed = signer.sign(
        invoiceXml: invoiceXml,
        certificate: testCertificate,
      );

      // The policy hash should use SHA-256
      final policySection = _extractBetween(
        signed,
        'xades:SignaturePolicyIdentifier',
      );
      expect(policySection, contains('sha256'));
    });

    test(
      'SignaturePolicyIdentifier appears after SigningCertificate in XML order',
      () {
        final signed = signer.sign(
          invoiceXml: invoiceXml,
          certificate: testCertificate,
        );

        final certIndex = signed.indexOf('xades:SigningCertificate');
        final policyIndex = signed.indexOf('xades:SignaturePolicyIdentifier');

        expect(
          certIndex,
          lessThan(policyIndex),
          reason:
              'XAdES element order: SigningCertificate must precede '
              'SignaturePolicyIdentifier',
        );
      },
    );

    test('exactly one SignaturePolicyIdentifier exists', () {
      final signed = signer.sign(
        invoiceXml: invoiceXml,
        certificate: testCertificate,
      );

      final count = RegExp('xades:SignaturePolicyIdentifier')
          .allMatches(signed)
          .length;
      // Opening + closing tag = 2 occurrences of the element name
      expect(count, equals(2));
    });
  });
}

// ─── Helper to extract content between tags ─────────────────
String _extractBetween(String xml, String tagName) {
  final start = xml.indexOf('<$tagName');
  final end = xml.indexOf('</$tagName>') + '</$tagName>'.length;
  if (start < 0 || end < 0) return '';
  return xml.substring(start, end);
}

// ─── Test helpers (same as xades_signer_test.dart) ───────────
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

String _encodeEcPrivateKeyPemSec1(ECPrivateKey key) {
  final dBytes = _bigIntToBytes(key.d!, 32);
  final oidBytes = <int>[0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x0A];
  final contextOid = <int>[0xA0, oidBytes.length, ...oidBytes];
  final versionBytes = <int>[0x02, 0x01, 0x01];
  final octetString = <int>[0x04, dBytes.length, ...dBytes];
  final innerLen =
      versionBytes.length + octetString.length + contextOid.length;
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
  final versionBytes = ASN1Integer(BigInt.from(2)).encodedBytes;
  tbsCert.add(
    ASN1Object.fromBytes(
      Uint8List.fromList([0xA0, versionBytes.length, ...versionBytes]),
    ),
  );
  tbsCert.add(ASN1Integer(serialNumber));
  final sigAlg = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.4.3.2'));
  tbsCert.add(sigAlg);
  tbsCert.add(_buildName(issuer));
  final validitySeq = ASN1Sequence()
    ..add(ASN1UtcTime(validFrom))
    ..add(ASN1UtcTime(validTo));
  tbsCert.add(validitySeq);
  tbsCert.add(_buildName(subject));
  final spkiAlg = ASN1Sequence()
    ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.2.1'))
    ..add(ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10'));
  final spki = ASN1Sequence()
    ..add(spkiAlg)
    ..add(ASN1BitString(Uint8List.fromList([0x00, ...publicKeyPoint])));
  tbsCert.add(spki);
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
