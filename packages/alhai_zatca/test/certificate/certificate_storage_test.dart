import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';

/// Test-only implementation of JsonCertificateStorage backed by an
/// in-memory map. Used to exercise the JSON serialization logic.
class _TestJsonStorage extends JsonCertificateStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> readValue(String key) async => _data[key];

  @override
  Future<void> writeValue(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  /// Inject corrupted data for testing error handling.
  void corrupt(String key, String corruptedValue) {
    _data[key] = corruptedValue;
  }

  int get entryCount => _data.length;
}

void main() {
  // Helper to create a sample certificate
  CertificateInfo sampleCertificate({
    String csid = 'csid-123',
    bool isProduction = true,
    DateTime? validTo,
  }) {
    return CertificateInfo(
      certificatePem:
          '-----BEGIN CERTIFICATE-----\nCERT\n-----END CERTIFICATE-----',
      privateKeyPem:
          '-----BEGIN EC PRIVATE KEY-----\nKEY\n-----END EC PRIVATE KEY-----',
      csid: csid,
      secret: 'secret-value',
      serialNumber: 'SN-001',
      issuerName: 'ZATCA CA',
      subjectName: 'CN=Alhai Test',
      validFrom: DateTime(2026, 1, 1),
      validTo: validTo ?? DateTime(2027, 1, 1),
      isProduction: isProduction,
    );
  }

  group('InMemoryCertificateStorage', () {
    late InMemoryCertificateStorage storage;
    const storeId = 'store-1';

    setUp(() {
      storage = InMemoryCertificateStorage();
    });

    group('saveCertificate / getCertificate', () {
      test('stores and retrieves a certificate', () async {
        final cert = sampleCertificate();
        await storage.saveCertificate(storeId: storeId, certificate: cert);

        final retrieved = await storage.getCertificate(storeId: storeId);
        expect(retrieved, isNotNull);
        expect(retrieved!.csid, cert.csid);
        expect(retrieved.certificatePem, cert.certificatePem);
        expect(retrieved.privateKeyPem, cert.privateKeyPem);
        expect(retrieved.isProduction, cert.isProduction);
      });

      test('returns null for missing certificate', () async {
        final result = await storage.getCertificate(storeId: 'nonexistent');
        expect(result, isNull);
      });

      test('overwrites existing certificate on save', () async {
        final cert1 = sampleCertificate(csid: 'csid-1');
        final cert2 = sampleCertificate(csid: 'csid-2');

        await storage.saveCertificate(storeId: storeId, certificate: cert1);
        await storage.saveCertificate(storeId: storeId, certificate: cert2);

        final retrieved = await storage.getCertificate(storeId: storeId);
        expect(retrieved!.csid, 'csid-2');
      });

      test('isolates certificates by store ID', () async {
        final certA = sampleCertificate(csid: 'csid-a');
        final certB = sampleCertificate(csid: 'csid-b');

        await storage.saveCertificate(storeId: 'store-a', certificate: certA);
        await storage.saveCertificate(storeId: 'store-b', certificate: certB);

        final retrievedA = await storage.getCertificate(storeId: 'store-a');
        final retrievedB = await storage.getCertificate(storeId: 'store-b');
        expect(retrievedA!.csid, 'csid-a');
        expect(retrievedB!.csid, 'csid-b');
      });
    });

    group('hasCertificate', () {
      test('returns true when certificate exists', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        expect(await storage.hasCertificate(storeId: storeId), isTrue);
      });

      test('returns false when no certificate exists', () async {
        expect(await storage.hasCertificate(storeId: 'missing'), isFalse);
      });
    });

    group('deleteCertificate', () {
      test('removes a stored certificate', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        expect(await storage.hasCertificate(storeId: storeId), isTrue);

        await storage.deleteCertificate(storeId: storeId);
        expect(await storage.hasCertificate(storeId: storeId), isFalse);
        expect(await storage.getCertificate(storeId: storeId), isNull);
      });

      test('is a no-op for missing certificate', () async {
        expect(
          () => storage.deleteCertificate(storeId: 'nonexistent'),
          returnsNormally,
        );
      });

      test('also clears the private key', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        await storage.deleteCertificate(storeId: storeId);
        expect(await storage.getPrivateKey(storeId: storeId), isNull);
      });
    });

    group('getPrivateKey / savePrivateKey', () {
      test('saveCertificate also stores private key separately', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        final key = await storage.getPrivateKey(storeId: storeId);
        expect(key, contains('PRIVATE KEY'));
      });

      test('savePrivateKey stores the private key', () async {
        const pk =
            '-----BEGIN EC PRIVATE KEY-----\nDATA\n-----END EC PRIVATE KEY-----';
        await storage.savePrivateKey(storeId: storeId, privateKeyPem: pk);
        expect(await storage.getPrivateKey(storeId: storeId), pk);
      });

      test('returns null for missing private key', () async {
        expect(await storage.getPrivateKey(storeId: 'nothing'), isNull);
      });
    });

    group('getCertificateMetadata', () {
      test('returns certificate info with redacted private key', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );

        final metadata = await storage.getCertificateMetadata(storeId: storeId);
        expect(metadata, isNotNull);
        expect(metadata!.privateKeyPem, '***REDACTED***');
        expect(metadata.certificatePem, contains('CERTIFICATE'));
        expect(metadata.csid, isNotEmpty);
      });

      test('returns null for missing certificate', () async {
        final metadata = await storage.getCertificateMetadata(
          storeId: 'missing',
        );
        expect(metadata, isNull);
      });
    });

    group('listStoreIds', () {
      test('returns empty list when no certificates stored', () async {
        final ids = await storage.listStoreIds();
        expect(ids, isEmpty);
      });

      test('returns all store IDs with certificates', () async {
        await storage.saveCertificate(
          storeId: 'store-a',
          certificate: sampleCertificate(),
        );
        await storage.saveCertificate(
          storeId: 'store-b',
          certificate: sampleCertificate(),
        );
        await storage.saveCertificate(
          storeId: 'store-c',
          certificate: sampleCertificate(),
        );

        final ids = await storage.listStoreIds();
        expect(ids, containsAll(['store-a', 'store-b', 'store-c']));
        expect(ids.length, 3);
      });
    });
  });

  group('JsonCertificateStorage', () {
    late _TestJsonStorage storage;
    const storeId = 'store-1';

    setUp(() {
      storage = _TestJsonStorage();
    });

    group('saveCertificate / getCertificate', () {
      test('stores and retrieves a certificate via JSON roundtrip', () async {
        final cert = sampleCertificate();
        await storage.saveCertificate(storeId: storeId, certificate: cert);

        final retrieved = await storage.getCertificate(storeId: storeId);
        expect(retrieved, isNotNull);
        expect(retrieved!.csid, cert.csid);
        expect(retrieved.certificatePem, cert.certificatePem);
        expect(retrieved.serialNumber, cert.serialNumber);
        expect(retrieved.issuerName, cert.issuerName);
        expect(retrieved.validTo, cert.validTo);
        expect(retrieved.isProduction, cert.isProduction);
      });

      test('returns null for missing certificate', () async {
        final result = await storage.getCertificate(storeId: 'missing');
        expect(result, isNull);
      });

      test('returns null for corrupted JSON (does not throw)', () async {
        storage.corrupt('zatca_cert_$storeId', 'not-valid-json{');

        final result = await storage.getCertificate(storeId: storeId);
        expect(result, isNull);
      });

      test('updates the index when saving new certificate', () async {
        final cert = sampleCertificate();
        await storage.saveCertificate(storeId: storeId, certificate: cert);

        final ids = await storage.listStoreIds();
        expect(ids, contains(storeId));
      });

      test('does not duplicate store ID in index on overwrite', () async {
        final cert = sampleCertificate();
        await storage.saveCertificate(storeId: storeId, certificate: cert);
        await storage.saveCertificate(storeId: storeId, certificate: cert);

        final ids = await storage.listStoreIds();
        expect(ids.where((id) => id == storeId).length, 1);
      });
    });

    group('deleteCertificate', () {
      test('removes certificate from storage', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        await storage.deleteCertificate(storeId: storeId);

        expect(await storage.getCertificate(storeId: storeId), isNull);
        expect(await storage.hasCertificate(storeId: storeId), isFalse);
      });

      test('removes the store ID from the index', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        await storage.deleteCertificate(storeId: storeId);

        final ids = await storage.listStoreIds();
        expect(ids, isNot(contains(storeId)));
      });
    });

    group('hasCertificate', () {
      test('returns true after save', () async {
        await storage.saveCertificate(
          storeId: storeId,
          certificate: sampleCertificate(),
        );
        expect(await storage.hasCertificate(storeId: storeId), isTrue);
      });

      test('returns false for non-existent store', () async {
        expect(await storage.hasCertificate(storeId: 'nothing'), isFalse);
      });
    });

    group('listStoreIds', () {
      test('returns empty list when index is absent', () async {
        final ids = await storage.listStoreIds();
        expect(ids, isEmpty);
      });

      test('returns empty list when index is corrupted', () async {
        storage.corrupt('zatca_cert_index', 'invalid-json');
        final ids = await storage.listStoreIds();
        expect(ids, isEmpty);
      });
    });
  });
}
