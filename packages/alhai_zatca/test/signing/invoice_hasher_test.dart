import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/signing/invoice_hasher.dart';

void main() {
  group('InvoiceHasher', () {
    late InvoiceHasher hasher;

    setUp(() {
      hasher = InvoiceHasher();
    });

    group('hashString', () {
      test('should compute correct SHA-256 hash for empty string', () {
        // SHA-256("") = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        final result = InvoiceHasher.hashString('');
        final expectedDigest = sha256.convert(utf8.encode(''));
        final expected = base64Encode(expectedDigest.bytes);
        expect(result, expected);
      });

      test('should compute correct SHA-256 hash for "0"', () {
        // SHA-256("0") = 5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9
        final result = InvoiceHasher.hashString('0');
        final expectedDigest = sha256.convert(utf8.encode('0'));
        final expected = base64Encode(expectedDigest.bytes);
        expect(result, expected);
        // Verify the hex of the underlying hash
        expect(
          expectedDigest.toString(),
          '5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9',
        );
      });

      test('should compute correct SHA-256 hash for known input', () {
        // SHA-256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
        final result = InvoiceHasher.hashString('hello');
        final expectedDigest = sha256.convert(utf8.encode('hello'));
        final expected = base64Encode(expectedDigest.bytes);
        expect(result, expected);
      });

      test('should return base64-encoded result', () {
        final result = InvoiceHasher.hashString('test');
        // Verify it is valid base64
        expect(() => base64Decode(result), returnsNormally);
        // SHA-256 produces 32 bytes, base64-encoded = 44 chars
        expect(base64Decode(result).length, 32);
      });

      test('should produce consistent results', () {
        final result1 = InvoiceHasher.hashString('test data');
        final result2 = InvoiceHasher.hashString('test data');
        expect(result1, result2);
      });

      test('should produce different hashes for different inputs', () {
        final hash1 = InvoiceHasher.hashString('input1');
        final hash2 = InvoiceHasher.hashString('input2');
        expect(hash1, isNot(hash2));
      });
    });

    group('hashBytes', () {
      test('should compute correct SHA-256 for byte input', () {
        final input = utf8.encode('hello');
        final result = InvoiceHasher.hashBytes(input);
        final expected = sha256.convert(input).bytes;
        expect(result, expected);
        expect(result.length, 32); // SHA-256 = 32 bytes
      });
    });

    group('computeHash', () {
      test('should hash a simple XML document', () {
        const xml = '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final result = hasher.computeHash(xml);

        // Result should be valid base64
        expect(() => base64Decode(result), returnsNormally);
        expect(base64Decode(result).length, 32);
      });

      test('should strip UBLExtensions before hashing', () {
        const xmlWithExtensions =
            '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
            ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">'
            '<ext:UBLExtensions><ext:UBLExtension><ext:ExtensionContent>SIGN</ext:ExtensionContent></ext:UBLExtension></ext:UBLExtensions>'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        const xmlWithoutExtensions =
            '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
            ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final hashWith = hasher.computeHash(xmlWithExtensions);
        final hashWithout = hasher.computeHash(xmlWithoutExtensions);

        // Both should produce the same hash since UBLExtensions is stripped
        expect(hashWith, hashWithout);
      });

      test('should strip Signature elements before hashing', () {
        const xmlWithSignature =
            '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
            ' xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">'
            '<cac:Signature><cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">sig1</cbc:ID></cac:Signature>'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        const xmlWithoutSignature =
            '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
            ' xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final hashWith = hasher.computeHash(xmlWithSignature);
        final hashWithout = hasher.computeHash(xmlWithoutSignature);

        expect(hashWith, hashWithout);
      });

      test('should produce consistent hash for same XML', () {
        const xml = '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final hash1 = hasher.computeHash(xml);
        final hash2 = hasher.computeHash(xml);
        expect(hash1, hash2);
      });
    });

    group('computeDigestBytes', () {
      test('should return 32 raw bytes', () {
        const xml = '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final digestBytes = hasher.computeDigestBytes(xml);
        expect(digestBytes.length, 32);
      });

      test('digest bytes should match base64 hash', () {
        const xml = '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">'
            '<cbc:ID xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">INV-001</cbc:ID>'
            '</Invoice>';

        final digestBytes = hasher.computeDigestBytes(xml);
        final hashBase64 = hasher.computeHash(xml);

        // The base64 of digestBytes should equal computeHash result
        expect(base64Encode(digestBytes), hashBase64);
      });
    });
  });
}
