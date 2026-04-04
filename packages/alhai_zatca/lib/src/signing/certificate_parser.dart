import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:asn1lib/asn1lib.dart';

/// Parses X.509 certificates for ZATCA signing
///
/// Extracts required fields from PEM certificates for use in
/// XAdES signatures and API authentication.
class CertificateParser {
  /// Parse a PEM certificate and extract key fields
  ///
  /// Returns a map with:
  /// - serialNumber: certificate serial number (hex)
  /// - issuerName: issuer distinguished name
  /// - subjectName: subject distinguished name
  /// - publicKey: public key bytes
  /// - validFrom: not-before date
  /// - validTo: not-after date
  Map<String, dynamic> parseCertificate(String pemCertificate) {
    final derBytes = pemToDer(pemCertificate);
    final asn1Parser = ASN1Parser(Uint8List.fromList(derBytes));
    final topSequence = asn1Parser.nextObject() as ASN1Sequence;

    // TBSCertificate is the first element in the top sequence
    final tbsCert = topSequence.elements![0] as ASN1Sequence;

    int elementIndex = 0;

    // Check for explicit version tag [0]
    if (tbsCert.elements![0].tag == 0xA0) {
      elementIndex++; // skip version
    }

    // Serial number
    final serialNumberObj = tbsCert.elements![elementIndex] as ASN1Integer;
    final serialNumber = serialNumberObj.valueAsBigInteger.toRadixString(16);
    elementIndex++;

    // Skip signature algorithm
    elementIndex++;

    // Issuer
    final issuerSeq = tbsCert.elements![elementIndex] as ASN1Sequence;
    final issuerName = _parseDistinguishedName(issuerSeq);
    elementIndex++;

    // Validity
    final validitySeq = tbsCert.elements![elementIndex] as ASN1Sequence;
    final validFrom = _parseAsn1Time(validitySeq.elements![0]);
    final validTo = _parseAsn1Time(validitySeq.elements![1]);
    elementIndex++;

    // Subject
    final subjectSeq = tbsCert.elements![elementIndex] as ASN1Sequence;
    final subjectName = _parseDistinguishedName(subjectSeq);
    elementIndex++;

    // SubjectPublicKeyInfo
    final pubKeyInfoSeq = tbsCert.elements![elementIndex] as ASN1Sequence;
    final pubKeyBitString = pubKeyInfoSeq.elements![1] as ASN1BitString;
    final publicKeyBytes = pubKeyBitString.valueBytes();

    return {
      'serialNumber': serialNumber,
      'issuerName': issuerName,
      'subjectName': subjectName,
      'publicKey': publicKeyBytes,
      'validFrom': validFrom,
      'validTo': validTo,
    };
  }

  /// Extract the certificate serial number as a hex string
  String extractSerialNumber(String pemCertificate) {
    final info = parseCertificate(pemCertificate);
    return info['serialNumber'] as String;
  }

  /// Extract the issuer name in LDAP string format
  /// e.g. "CN=ZATCA-SubCA-1,DC=zatca,DC=gov,DC=sa"
  String extractIssuerName(String pemCertificate) {
    final info = parseCertificate(pemCertificate);
    return info['issuerName'] as String;
  }

  /// Compute the SHA-256 digest of the certificate (DER-encoded)
  ///
  /// This is used in the XAdES SigningCertificate reference.
  String computeCertificateDigest(String pemCertificate) {
    final derBytes = pemToDer(pemCertificate);
    final digest = sha256.convert(derBytes);
    return base64Encode(digest.bytes);
  }

  /// Extract the public key from a PEM certificate
  List<int> extractPublicKey(String pemCertificate) {
    final info = parseCertificate(pemCertificate);
    return info['publicKey'] as List<int>;
  }

  /// Extract the certificate's signature bytes (signatureValue)
  ///
  /// In the X.509 ASN.1 structure the top-level SEQUENCE contains:
  ///   [0] TBSCertificate  [1] signatureAlgorithm  [2] signatureValue
  ///
  /// The signatureValue is a BIT STRING whose content bytes (excluding
  /// the leading padding-bits octet) are the raw signature.
  /// This is what ZATCA requires for QR tag 9.
  List<int> extractSignatureBytes(String pemCertificate) {
    final derBytes = pemToDer(pemCertificate);
    final asn1Parser = ASN1Parser(Uint8List.fromList(derBytes));
    final topSequence = asn1Parser.nextObject() as ASN1Sequence;

    // The third element is the signatureValue BIT STRING
    final sigBitString = topSequence.elements![2] as ASN1BitString;
    final rawBytes = sigBitString.valueBytes();

    // BIT STRING content starts with a padding-bits count octet (usually 0).
    // Strip it to get the actual signature bytes.
    if (rawBytes.isNotEmpty && rawBytes[0] == 0) {
      return rawBytes.sublist(1);
    }
    return rawBytes;
  }

  /// Strip PEM headers/footers and decode base64 to get DER bytes
  List<int> pemToDer(String pem) {
    final b64 = pem
        .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    return base64Decode(b64);
  }

  /// Parse an ASN.1 Distinguished Name sequence into LDAP string format
  String _parseDistinguishedName(ASN1Sequence dnSequence) {
    final parts = <String>[];

    for (final rdn in dnSequence.elements!) {
      if (rdn is ASN1Set) {
        for (final atv in rdn.elements!) {
          if (atv is ASN1Sequence && atv.elements!.length >= 2) {
            final oid = atv.elements![0] as ASN1ObjectIdentifier;
            final value = atv.elements![1];

            final oidStr = _oidToShortName(oid.identifier ?? oid.oi.join('.'));
            final valueStr = _extractStringValue(value);
            parts.add('$oidStr=$valueStr');
          }
        }
      }
    }

    return parts.join(', ');
  }

  /// Map common OIDs to their short names
  String _oidToShortName(String oid) {
    const oidMap = {
      '2.5.4.3': 'CN',
      '2.5.4.6': 'C',
      '2.5.4.7': 'L',
      '2.5.4.8': 'ST',
      '2.5.4.10': 'O',
      '2.5.4.11': 'OU',
      '2.5.4.5': 'SERIALNUMBER',
      '2.5.4.12': 'T',
      '2.5.4.4': 'SN',
      '2.5.4.42': 'GN',
      '0.9.2342.19200300.100.1.25': 'DC',
      '1.2.840.113549.1.9.1': 'E',
      '2.5.4.15': 'businessCategory',
      // ZATCA specific OIDs
      '2.5.4.97': 'organizationIdentifier',
    };
    return oidMap[oid] ?? oid;
  }

  /// Extract the string value from an ASN.1 object
  String _extractStringValue(ASN1Object obj) {
    if (obj is ASN1UTF8String) {
      return obj.utf8StringValue ?? '';
    }
    if (obj is ASN1PrintableString) {
      return obj.stringValue ?? '';
    }
    if (obj is ASN1IA5String) {
      return obj.stringValue ?? '';
    }
    // Fallback: try to read the raw value bytes as UTF-8
    try {
      final bytes = obj.valueBytes();
      if (bytes.isNotEmpty) {
        try {
          return utf8.decode(bytes);
        } catch (_) {
          return bytes
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join('');
        }
      }
    } catch (_) {
      // valueBytes() may throw if no encoded bytes
    }
    return '';
  }

  /// Parse ASN.1 time values (UTCTime or GeneralizedTime) to DateTime
  DateTime _parseAsn1Time(ASN1Object timeObj) {
    if (timeObj is ASN1UtcTime) {
      return timeObj.dateTimeValue!;
    }
    if (timeObj is ASN1GeneralizedTime) {
      return timeObj.dateTimeValue!;
    }
    // Fallback: try to parse from raw bytes
    try {
      final bytes = timeObj.valueBytes();
      final timeStr = String.fromCharCodes(bytes);
      return _parseTimeString(timeStr);
    } catch (_) {
      // valueBytes() may throw
    }
    throw FormatException(
        'Cannot parse ASN.1 time object with tag ${timeObj.tag}');
  }

  /// Parse a time string in UTCTime or GeneralizedTime format
  DateTime _parseTimeString(String timeStr) {
    // UTCTime: YYMMDDHHMMSSZ
    if (timeStr.length == 13) {
      final year = int.parse(timeStr.substring(0, 2));
      final fullYear = year >= 50 ? 1900 + year : 2000 + year;
      return DateTime.utc(
        fullYear,
        int.parse(timeStr.substring(2, 4)),
        int.parse(timeStr.substring(4, 6)),
        int.parse(timeStr.substring(6, 8)),
        int.parse(timeStr.substring(8, 10)),
        int.parse(timeStr.substring(10, 12)),
      );
    }
    // GeneralizedTime: YYYYMMDDHHMMSSZ
    if (timeStr.length == 15) {
      return DateTime.utc(
        int.parse(timeStr.substring(0, 4)),
        int.parse(timeStr.substring(4, 6)),
        int.parse(timeStr.substring(6, 8)),
        int.parse(timeStr.substring(8, 10)),
        int.parse(timeStr.substring(10, 12)),
        int.parse(timeStr.substring(12, 14)),
      );
    }
    throw FormatException('Cannot parse time string: $timeStr');
  }
}
