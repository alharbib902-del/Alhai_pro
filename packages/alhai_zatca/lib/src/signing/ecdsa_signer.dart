import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// ECDSA digital signer using secp256k1 curve
///
/// ZATCA requires ECDSA signatures with the secp256k1 curve
/// for signing invoice hashes.
class EcdsaSigner {
  /// Sign a SHA-256 digest with ECDSA using the provided private key
  ///
  /// [digest] - SHA-256 hash bytes to sign
  /// [privateKeyPem] - ECDSA private key in PEM format
  ///
  /// Returns base64-encoded DER-encoded signature value
  String sign({
    required Uint8List digest,
    required String privateKeyPem,
  }) {
    final privateKey = _parsePrivateKeyPem(privateKeyPem);

    // Initialize ECDSA signer with SHA-256
    // We pass the pre-computed digest directly, so use NullDigest
    final signer = Signer('SHA-256/DET-ECDSA');

    signer.init(
      true,
      PrivateKeyParameter<ECPrivateKey>(privateKey),
    );

    final ecSignature = signer.generateSignature(digest) as ECSignature;

    // Encode signature in DER format
    final derBytes = _encodeDerSignature(ecSignature.r, ecSignature.s);

    return base64Encode(derBytes);
  }

  /// Verify an ECDSA signature against a digest and public key
  ///
  /// Used for validating signed invoices.
  bool verify({
    required Uint8List digest,
    required Uint8List signature,
    required String publicKeyPem,
  }) {
    final publicKey = _parsePublicKeyPem(publicKeyPem);

    // Decode DER signature
    final ecSignature = _decodeDerSignature(signature);

    final verifier = Signer('SHA-256/DET-ECDSA');

    verifier.init(
      false,
      PublicKeyParameter<ECPublicKey>(publicKey),
    );

    try {
      return verifier.verifySignature(digest, ecSignature);
    } catch (_) {
      return false;
    }
  }

  /// Parse a PEM-encoded EC private key into its components
  Map<String, dynamic> parsePrivateKey(String pem) {
    final privateKey = _parsePrivateKeyPem(pem);
    final params = privateKey.parameters!;
    final publicKey = params.G * privateKey.d;
    return {
      'd': privateKey.d.toString(),
      'curve': 'secp256k1',
      'publicKeyX': publicKey?.x?.toBigInteger().toString(),
      'publicKeyY': publicKey?.y?.toBigInteger().toString(),
    };
  }

  /// Parse PEM private key to ECPrivateKey
  ECPrivateKey _parsePrivateKeyPem(String pem) {
    final lines = pem
        .replaceAll('-----BEGIN EC PRIVATE KEY-----', '')
        .replaceAll('-----END EC PRIVATE KEY-----', '')
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('\r\n', '')
        .replaceAll('\n', '')
        .trim();

    final derBytes = base64Decode(lines);

    // Parse the ASN.1 DER structure to extract the private key value
    final d = _extractPrivateKeyValue(derBytes);

    final domainParams = ECDomainParameters('secp256k1');
    return ECPrivateKey(d, domainParams);
  }

  /// Parse PEM public key to ECPublicKey
  ECPublicKey _parsePublicKeyPem(String pem) {
    final lines = pem
        .replaceAll('-----BEGIN EC PUBLIC KEY-----', '')
        .replaceAll('-----END EC PUBLIC KEY-----', '')
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\r\n', '')
        .replaceAll('\n', '')
        .trim();

    final derBytes = base64Decode(lines);

    // Extract the public key point from the DER structure
    final point = _extractPublicKeyPoint(derBytes);

    final domainParams = ECDomainParameters('secp256k1');
    final ecPoint = domainParams.curve.decodePoint(point);
    return ECPublicKey(ecPoint, domainParams);
  }

  /// Extract the private key integer from ASN.1 DER-encoded EC private key
  ///
  /// Handles both SEC 1 (EC PRIVATE KEY) and PKCS#8 (PRIVATE KEY) formats.
  BigInt _extractPrivateKeyValue(Uint8List der) {
    // Walk the ASN.1 structure
    int offset = 0;

    // Check for PKCS#8 wrapper (SEQUENCE { version, algorithmIdentifier, privateKey OCTET STRING })
    if (der[offset] == 0x30) {
      offset++; // skip SEQUENCE tag
      offset = _skipLength(der, offset); // skip SEQUENCE length

      // Check if first element is an INTEGER (version) - this is PKCS#8
      if (der[offset] == 0x02) {
        // PKCS#8 format
        offset = _skipTlv(der, offset); // skip version INTEGER
        offset = _skipTlv(der, offset); // skip algorithmIdentifier SEQUENCE

        // Next is OCTET STRING containing the EC private key
        if (der[offset] == 0x04) {
          offset++; // skip OCTET STRING tag
          final len = _readLength(der, offset);
          offset = _skipLength(der, offset);

          // Now parse the inner SEC 1 EC private key
          return _extractPrivateKeyValue(
            Uint8List.fromList(der.sublist(offset, offset + len)),
          );
        }
      }
    }

    // SEC 1 format: SEQUENCE { version INTEGER, privateKey OCTET STRING, ... }
    offset = 0;
    if (der[offset] != 0x30) {
      throw FormatException(
          'Expected SEQUENCE tag, got 0x${der[offset].toRadixString(16)}');
    }
    offset++; // skip SEQUENCE tag
    offset = _skipLength(der, offset); // skip SEQUENCE length

    // Skip version INTEGER
    offset = _skipTlv(der, offset);

    // Private key OCTET STRING
    if (der[offset] != 0x04) {
      throw FormatException(
          'Expected OCTET STRING tag for private key, got 0x${der[offset].toRadixString(16)}');
    }
    offset++; // skip tag
    final keyLen = _readLength(der, offset);
    offset = _skipLength(der, offset);

    final keyBytes = der.sublist(offset, offset + keyLen);
    return _bytesToBigInt(keyBytes);
  }

  /// Extract the public key point bytes from a DER-encoded public key
  Uint8List _extractPublicKeyPoint(Uint8List der) {
    int offset = 0;

    // SEQUENCE { algorithmIdentifier, BIT STRING }
    if (der[offset] != 0x30) {
      throw FormatException('Expected SEQUENCE tag');
    }
    offset++; // skip SEQUENCE tag
    offset = _skipLength(der, offset);

    // Skip algorithmIdentifier SEQUENCE
    offset = _skipTlv(der, offset);

    // BIT STRING containing the public key point
    if (der[offset] != 0x03) {
      throw FormatException('Expected BIT STRING tag');
    }
    offset++; // skip BIT STRING tag
    final bitStringLen = _readLength(der, offset);
    offset = _skipLength(der, offset);

    // First byte of BIT STRING is the number of unused bits (should be 0)
    offset++; // skip unused bits byte

    return Uint8List.fromList(der.sublist(offset, offset + bitStringLen - 1));
  }

  /// Read the length field of an ASN.1 TLV
  int _readLength(Uint8List data, int offset) {
    if (data[offset] < 0x80) {
      return data[offset];
    }
    final numBytes = data[offset] & 0x7F;
    int length = 0;
    for (int i = 0; i < numBytes; i++) {
      length = (length << 8) | data[offset + 1 + i];
    }
    return length;
  }

  /// Skip past the length field, returning the new offset
  int _skipLength(Uint8List data, int offset) {
    if (data[offset] < 0x80) {
      return offset + 1;
    }
    final numBytes = data[offset] & 0x7F;
    return offset + 1 + numBytes;
  }

  /// Skip an entire TLV (Tag-Length-Value), returning offset after Value
  int _skipTlv(Uint8List data, int offset) {
    offset++; // skip tag
    final length = _readLength(data, offset);
    offset = _skipLength(data, offset);
    return offset + length;
  }

  /// Convert big-endian bytes to BigInt
  BigInt _bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  /// Encode ECDSA signature (r, s) in DER format
  ///
  /// DER structure: SEQUENCE { INTEGER r, INTEGER s }
  Uint8List _encodeDerSignature(BigInt r, BigInt s) {
    final rBytes = _bigIntToUnsignedBytes(r);
    final sBytes = _bigIntToUnsignedBytes(s);

    // Build INTEGER for r
    final rDer = _encodeDerInteger(rBytes);
    // Build INTEGER for s
    final sDer = _encodeDerInteger(sBytes);

    // Build SEQUENCE
    final contentLength = rDer.length + sDer.length;
    final result = <int>[
      0x30, // SEQUENCE tag
      ...(_encodeDerLength(contentLength)),
      ...rDer,
      ...sDer,
    ];

    return Uint8List.fromList(result);
  }

  /// Decode a DER-encoded ECDSA signature back to ECSignature
  ECSignature _decodeDerSignature(Uint8List der) {
    int offset = 0;

    // SEQUENCE
    if (der[offset] != 0x30) {
      throw FormatException('Expected SEQUENCE tag in DER signature');
    }
    offset++;
    offset = _skipLength(der, offset);

    // INTEGER r
    if (der[offset] != 0x02) {
      throw FormatException('Expected INTEGER tag for r');
    }
    offset++;
    final rLen = _readLength(der, offset);
    offset = _skipLength(der, offset);
    final rBytes = der.sublist(offset, offset + rLen);
    offset += rLen;

    // INTEGER s
    if (der[offset] != 0x02) {
      throw FormatException('Expected INTEGER tag for s');
    }
    offset++;
    final sLen = _readLength(der, offset);
    offset = _skipLength(der, offset);
    final sBytes = der.sublist(offset, offset + sLen);

    final r = _bytesToBigInt(rBytes);
    final s = _bytesToBigInt(sBytes);

    return ECSignature(r, s);
  }

  /// Encode a DER INTEGER value
  List<int> _encodeDerInteger(List<int> value) {
    // If the high bit is set, prepend a 0x00 byte
    List<int> adjusted = value;
    if (value.isNotEmpty && (value[0] & 0x80) != 0) {
      adjusted = [0x00, ...value];
    }
    return [
      0x02, // INTEGER tag
      ..._encodeDerLength(adjusted.length),
      ...adjusted,
    ];
  }

  /// Encode a DER length field
  List<int> _encodeDerLength(int length) {
    if (length < 0x80) {
      return [length];
    }
    if (length < 0x100) {
      return [0x81, length];
    }
    return [0x82, (length >> 8) & 0xFF, length & 0xFF];
  }

  /// Convert a BigInt to unsigned big-endian bytes (no leading zeros except
  /// when needed for sign bit).
  List<int> _bigIntToUnsignedBytes(BigInt value) {
    if (value == BigInt.zero) return [0];

    final bytes = <int>[];
    var v = value;
    while (v > BigInt.zero) {
      bytes.insert(0, (v & BigInt.from(0xFF)).toInt());
      v = v >> 8;
    }
    return bytes;
  }
}
