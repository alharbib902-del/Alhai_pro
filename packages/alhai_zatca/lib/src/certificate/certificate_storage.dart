import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';

/// Secure storage for ZATCA certificates and private keys
///
/// Implementations should use platform-specific secure storage
/// (e.g., Keychain on iOS, Keystore on Android, encrypted prefs).
abstract class CertificateStorage {
  /// Store a certificate for a given store
  Future<void> saveCertificate({
    required String storeId,
    required CertificateInfo certificate,
  });

  /// Retrieve the stored certificate for a store
  ///
  /// Returns null if no certificate is stored.
  Future<CertificateInfo?> getCertificate({required String storeId});

  /// Delete the stored certificate for a store
  Future<void> deleteCertificate({required String storeId});

  /// Check if a certificate exists for a store
  Future<bool> hasCertificate({required String storeId});

  /// Store the private key PEM separately (for implementations that
  /// use a different secure vault for keys)
  Future<void> savePrivateKey({
    required String storeId,
    required String privateKeyPem,
  });

  /// Retrieve a stored private key PEM
  Future<String?> getPrivateKey({required String storeId});

  /// Get certificate info without the private key (safe for display)
  Future<CertificateInfo?> getCertificateMetadata({
    required String storeId,
  }) async {
    final cert = await getCertificate(storeId: storeId);
    if (cert == null) return null;
    return cert.copyWith(privateKeyPem: '***REDACTED***');
  }

  /// List all store IDs that have a certificate stored
  Future<List<String>> listStoreIds();
}

/// In-memory certificate storage for testing and development.
///
/// Must NOT be used in release builds -- certificates would be lost
/// on restart and are not encrypted at rest.
class InMemoryCertificateStorage implements CertificateStorage {
  InMemoryCertificateStorage() {
    assert(
      kDebugMode,
      'InMemoryCertificateStorage must not be used in production. '
      'Use a secure CertificateStorage implementation instead.',
    );
  }

  final Map<String, CertificateInfo> _certificates = {};
  final Map<String, String> _privateKeys = {};

  @override
  Future<void> saveCertificate({
    required String storeId,
    required CertificateInfo certificate,
  }) async {
    _certificates[storeId] = certificate;
    // Also store the private key separately
    _privateKeys[storeId] = certificate.privateKeyPem;
  }

  @override
  Future<CertificateInfo?> getCertificate({required String storeId}) async {
    return _certificates[storeId];
  }

  @override
  Future<void> deleteCertificate({required String storeId}) async {
    _certificates.remove(storeId);
    _privateKeys.remove(storeId);
  }

  @override
  Future<bool> hasCertificate({required String storeId}) async {
    return _certificates.containsKey(storeId);
  }

  @override
  Future<void> savePrivateKey({
    required String storeId,
    required String privateKeyPem,
  }) async {
    _privateKeys[storeId] = privateKeyPem;
  }

  @override
  Future<String?> getPrivateKey({required String storeId}) async {
    return _privateKeys[storeId];
  }

  @override
  Future<CertificateInfo?> getCertificateMetadata({
    required String storeId,
  }) async {
    final cert = _certificates[storeId];
    if (cert == null) return null;
    return cert.copyWith(privateKeyPem: '***REDACTED***');
  }

  @override
  Future<List<String>> listStoreIds() async {
    return _certificates.keys.toList();
  }
}

/// JSON-backed certificate storage for persistence.
///
/// Stores certificates as JSON strings using a key-value backend.
/// Subclasses must implement [readValue] and [writeValue] for the
/// actual storage mechanism (encrypted Hive, secure-storage, etc.).
///
/// WARNING: Subclasses MUST use encrypted storage in production
/// (e.g., flutter_secure_storage, encrypted Hive). Plain unencrypted
/// key-value stores are NOT acceptable for ZATCA certificates.
abstract class JsonCertificateStorage implements CertificateStorage {
  static const String _prefix = 'zatca_cert_';
  static const String _keyPrefix = 'zatca_pk_';
  static const String _indexKey = 'zatca_cert_index';

  /// Read a string value from persistent storage
  Future<String?> readValue(String key);

  /// Write a string value to persistent storage
  Future<void> writeValue(String key, String? value);

  @override
  Future<void> saveCertificate({
    required String storeId,
    required CertificateInfo certificate,
  }) async {
    final json = jsonEncode(certificate.toJson());
    await writeValue('$_prefix$storeId', json);
    await savePrivateKey(
      storeId: storeId,
      privateKeyPem: certificate.privateKeyPem,
    );
    // Update the index
    final ids = await listStoreIds();
    if (!ids.contains(storeId)) {
      ids.add(storeId);
      await writeValue(_indexKey, jsonEncode(ids));
    }
  }

  @override
  Future<CertificateInfo?> getCertificate({required String storeId}) async {
    final json = await readValue('$_prefix$storeId');
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return CertificateInfo.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteCertificate({required String storeId}) async {
    await writeValue('$_prefix$storeId', null);
    await writeValue('$_keyPrefix$storeId', null);
    final ids = await listStoreIds();
    ids.remove(storeId);
    await writeValue(_indexKey, jsonEncode(ids));
  }

  @override
  Future<bool> hasCertificate({required String storeId}) async {
    final value = await readValue('$_prefix$storeId');
    return value != null;
  }

  @override
  Future<void> savePrivateKey({
    required String storeId,
    required String privateKeyPem,
  }) async {
    await writeValue('$_keyPrefix$storeId', privateKeyPem);
  }

  @override
  Future<String?> getPrivateKey({required String storeId}) async {
    return readValue('$_keyPrefix$storeId');
  }

  @override
  Future<CertificateInfo?> getCertificateMetadata({
    required String storeId,
  }) async {
    final cert = await getCertificate(storeId: storeId);
    if (cert == null) return null;
    return cert.copyWith(privateKeyPem: '***REDACTED***');
  }

  @override
  Future<List<String>> listStoreIds() async {
    final indexJson = await readValue(_indexKey);
    if (indexJson == null) return [];
    try {
      final list = jsonDecode(indexJson) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }
}
