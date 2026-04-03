import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';

/// Generates Certificate Signing Requests (CSR) for ZATCA onboarding
///
/// The CSR is submitted to ZATCA to obtain a compliance certificate,
/// which is then exchanged for a production certificate.
///
/// CSR requirements:
/// - Key: ECDSA secp256k1
/// - Subject: specific DN fields per ZATCA spec
/// - Extensions: ZATCA-specific OIDs
class CsrGenerator {
  /// OID for EC public key
  static final ASN1ObjectIdentifier _ecPublicKeyOid =
      ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.2.1');

  /// OID for secp256k1 curve
  static final ASN1ObjectIdentifier _secp256k1Oid =
      ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10');

  /// OID for SHA-256 with ECDSA
  static final ASN1ObjectIdentifier _ecdsaWithSha256Oid =
      ASN1ObjectIdentifier.fromComponentString('1.2.840.10045.4.3.2');

  /// OID for Extension Request attribute (PKCS#9)
  static final ASN1ObjectIdentifier _extensionRequestOid =
      ASN1ObjectIdentifier.fromComponentString('1.2.840.113549.1.9.14');

  /// OID for ZATCA certificate template name
  static final ASN1ObjectIdentifier _certTemplateOid =
      ASN1ObjectIdentifier.fromComponentString('1.3.6.1.4.1.311.20.2');

  /// Generate a CSR with ZATCA-required fields
  ///
  /// Returns a map containing:
  /// - 'csr': PEM-encoded CSR string
  /// - 'privateKey': PEM-encoded EC private key
  ///
  /// ZATCA CSR Subject fields:
  /// - CN: Solution Name
  /// - OU: Organization Unit (branch ID)
  /// - O: Organization Name
  /// - C: Country (SA)
  /// - serialNumber: 1-<Solution Name>|2-<Model/Version>|3-<Serial Number>
  ///
  /// ZATCA-specific extensions:
  /// - OID 2.5.29.37 (Extended Key Usage): for ZATCA signing
  /// - OID 1.3.6.1.4.1.311.20.2: Certificate Template Name
  Future<Map<String, String>> generateCsr({
    required String commonName,
    required String organizationUnit,
    required String organizationName,
    required String country,
    required String serialNumber,
    required String invoiceType,
    required String branchLocation,
    required String industryBusinessCategory,
  }) async {
    // 1. Generate ECDSA key pair (secp256k1)
    final keyPair = _generateEcKeyPair();
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    // 2. Build CSR subject DN
    final subject = _buildSubjectSequence(
      commonName: commonName,
      organizationUnit: organizationUnit,
      organizationName: organizationName,
      country: country,
      serialNumber: serialNumber,
    );

    // 3. Build CSR extensions (ZATCA-specific)
    final extensions = _buildExtensions(
      invoiceType: invoiceType,
      branchLocation: branchLocation,
      industryBusinessCategory: industryBusinessCategory,
    );

    // 4. Build the CSR info (tbsCertificationRequest)
    final csrInfo = _buildCsrInfo(
      subject: subject,
      publicKey: publicKey,
      extensions: extensions,
    );

    // 5. Sign CSR with private key
    final csrInfoBytes = csrInfo.encodedBytes;
    final signature = _signData(csrInfoBytes, privateKey);

    // 6. Build the complete CSR structure
    final algSeq = ASN1Sequence()..add(_ecdsaWithSha256Oid);
    final csr = ASN1Sequence()
      ..add(csrInfo)
      ..add(algSeq)
      ..add(ASN1BitString(Uint8List.fromList([0x00, ...signature])));

    // 7. Encode to PEM format
    final csrPem = _encodePem(csr.encodedBytes, 'CERTIFICATE REQUEST');
    final privateKeyPem = _encodeEcPrivateKey(privateKey);

    return {
      'csr': csrPem,
      'privateKey': privateKeyPem,
    };
  }

  /// Generate an ECDSA key pair using secp256k1 curve
  AsymmetricKeyPair<PublicKey, PrivateKey> _generateEcKeyPair() {
    final domainParams = ECDomainParameters('secp256k1');
    final secureRandom = _getSecureRandom();

    final keyGenParams = ECKeyGeneratorParameters(domainParams);
    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(keyGenParams, secureRandom));

    return generator.generateKeyPair();
  }

  /// Get a cryptographically secure random number generator
  SecureRandom _getSecureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List(32);
    final dartRandom = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = dartRandom.nextInt(256);
    }
    random.seed(KeyParameter(seed));
    return random;
  }

  /// Build the CSR subject distinguished name as ASN1 sequence
  ASN1Sequence _buildSubjectSequence({
    required String commonName,
    required String organizationUnit,
    required String organizationName,
    required String country,
    required String serialNumber,
  }) {
    final subject = ASN1Sequence();

    // C = Country
    subject.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.6'),
      ASN1PrintableString(country),
    ));

    // O = Organization
    subject.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.10'),
      ASN1UTF8String(organizationName),
    ));

    // OU = Organization Unit
    subject.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.11'),
      ASN1UTF8String(organizationUnit),
    ));

    // CN = Common Name
    subject.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.3'),
      ASN1UTF8String(commonName),
    ));

    // serialNumber
    subject.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.5'),
      ASN1UTF8String(serialNumber),
    ));

    return subject;
  }

  /// Build a single RDN (Relative Distinguished Name) SET
  ASN1Set _buildRdnSet(ASN1ObjectIdentifier oid, ASN1Object value) {
    final seq = ASN1Sequence()
      ..add(oid)
      ..add(value);
    final rdnSet = ASN1Set()..add(seq);
    return rdnSet;
  }

  /// Build ZATCA-specific CSR extensions
  ASN1Sequence _buildExtensions({
    required String invoiceType,
    required String branchLocation,
    required String industryBusinessCategory,
  }) {
    final extensions = ASN1Sequence();

    // Certificate Template Name extension (OID 1.3.6.1.4.1.311.20.2)
    // ZATCA uses "ZATCA-Code-Signing" as the template name
    final templateExt = ASN1Sequence()
      ..add(_certTemplateOid)
      ..add(ASN1OctetString(
        ASN1UTF8String('ZATCA-Code-Signing').encodedBytes,
      ));
    extensions.add(templateExt);

    // Subject Alternative Name (SAN) with ZATCA-specific directory names
    // Contains: invoiceType, branchLocation, industryBusinessCategory
    final sanOid = ASN1ObjectIdentifier.fromComponentString('2.5.29.17');
    final sanValue = _buildZatcaSan(
      invoiceType: invoiceType,
      branchLocation: branchLocation,
      industryBusinessCategory: industryBusinessCategory,
    );
    final sanExt = ASN1Sequence()
      ..add(sanOid)
      ..add(ASN1Boolean(true)) // critical
      ..add(ASN1OctetString(sanValue.encodedBytes));
    extensions.add(sanExt);

    return extensions;
  }

  /// Build ZATCA Subject Alternative Name with directory names
  ASN1Sequence _buildZatcaSan({
    required String invoiceType,
    required String branchLocation,
    required String industryBusinessCategory,
  }) {
    // SAN contains directory names with custom ZATCA OIDs:
    // OID 2.5.4.4 = SN (used for invoice type, e.g., "1100")
    // OID 2.5.4.26 = registeredAddress (branch location)
    // OID 2.5.4.15 = businessCategory
    final directoryNames = ASN1Sequence();

    directoryNames.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.4'),
      ASN1UTF8String(invoiceType),
    ));
    directoryNames.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.26'),
      ASN1UTF8String(branchLocation),
    ));
    directoryNames.add(_buildRdnSet(
      ASN1ObjectIdentifier.fromComponentString('2.5.4.15'),
      ASN1UTF8String(industryBusinessCategory),
    ));

    return directoryNames;
  }

  /// Build the CertificationRequestInfo (the data to be signed)
  ASN1Sequence _buildCsrInfo({
    required ASN1Sequence subject,
    required ECPublicKey publicKey,
    required ASN1Sequence extensions,
  }) {
    final csrInfo = ASN1Sequence();

    // Version: v1 (0)
    csrInfo.add(ASN1Integer(BigInt.zero));

    // Subject
    csrInfo.add(subject);

    // SubjectPublicKeyInfo
    csrInfo.add(_buildPublicKeyInfo(publicKey));

    // Attributes [0] IMPLICIT - extension request
    final attributes = ASN1Sequence();
    attributes.add(_extensionRequestOid);
    final extSet = ASN1Set()..add(ASN1Sequence()..add(extensions));
    attributes.add(extSet);

    // Tag the attributes as context [0]
    final attrBytes = attributes.encodedBytes;
    final lengthBytes = ASN1Object.encodeLength(attrBytes.length);
    final taggedAttrs = ASN1Object.fromBytes(
      Uint8List.fromList([0xA0, ...lengthBytes, ...attrBytes]),
    );
    csrInfo.add(taggedAttrs);

    return csrInfo;
  }

  /// Build SubjectPublicKeyInfo for an EC public key
  ASN1Sequence _buildPublicKeyInfo(ECPublicKey publicKey) {
    final algorithmId = ASN1Sequence()
      ..add(_ecPublicKeyOid)
      ..add(_secp256k1Oid);

    // Encode the public key point as uncompressed (04 || x || y)
    final q = publicKey.Q!;
    final xBytes = _bigIntToBytes(q.x!.toBigInteger()!, 32);
    final yBytes = _bigIntToBytes(q.y!.toBigInteger()!, 32);
    final publicKeyBytes = Uint8List.fromList([0x04, ...xBytes, ...yBytes]);

    final spki = ASN1Sequence()
      ..add(algorithmId)
      ..add(ASN1BitString(Uint8List.fromList([0x00, ...publicKeyBytes])));

    return spki;
  }

  /// Sign data with ECDSA using SHA-256
  Uint8List _signData(Uint8List data, ECPrivateKey privateKey) {
    final signer = Signer('SHA-256/DET-ECDSA');
    signer.init(
      true,
      PrivateKeyParameter<ECPrivateKey>(privateKey),
    );
    final signature = signer.generateSignature(data) as ECSignature;

    // Encode signature as DER (SEQUENCE { INTEGER r, INTEGER s })
    final derSig = ASN1Sequence()
      ..add(ASN1Integer(signature.r))
      ..add(ASN1Integer(signature.s));

    return Uint8List.fromList(derSig.encodedBytes);
  }

  /// Convert a BigInt to a fixed-length byte array
  Uint8List _bigIntToBytes(BigInt value, int length) {
    final bytes = <int>[];
    var v = value;
    while (v > BigInt.zero) {
      bytes.insert(0, (v & BigInt.from(0xFF)).toInt());
      v >>= 8;
    }
    // Pad to required length
    while (bytes.length < length) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }

  /// Encode bytes as PEM with the given label
  String _encodePem(Uint8List bytes, String label) {
    final base64Content = base64Encode(bytes);
    final lines = <String>[];
    for (var i = 0; i < base64Content.length; i += 64) {
      final end = (i + 64 > base64Content.length)
          ? base64Content.length
          : i + 64;
      lines.add(base64Content.substring(i, end));
    }
    return '-----BEGIN $label-----\n${lines.join('\n')}\n-----END $label-----';
  }

  /// Encode an EC private key in PKCS#8 PEM format
  String _encodeEcPrivateKey(ECPrivateKey privateKey) {
    // ECPrivateKey ::= SEQUENCE {
    //   version        INTEGER { ecPrivkeyVer1(1) },
    //   privateKey     OCTET STRING,
    //   parameters [0] EXPLICIT ECParameters OPTIONAL,
    //   publicKey  [1] EXPLICIT BIT STRING OPTIONAL
    // }
    final dBytes = _bigIntToBytes(privateKey.d!, 32);

    final ecPrivateKey = ASN1Sequence()
      ..add(ASN1Integer(BigInt.one)) // version
      ..add(ASN1OctetString(dBytes));

    // Wrap in PKCS#8: PrivateKeyInfo
    final algorithmId = ASN1Sequence()
      ..add(_ecPublicKeyOid)
      ..add(_secp256k1Oid);

    final pkcs8 = ASN1Sequence()
      ..add(ASN1Integer(BigInt.zero)) // version
      ..add(algorithmId)
      ..add(ASN1OctetString(ecPrivateKey.encodedBytes));

    return _encodePem(Uint8List.fromList(pkcs8.encodedBytes), 'PRIVATE KEY');
  }
}
