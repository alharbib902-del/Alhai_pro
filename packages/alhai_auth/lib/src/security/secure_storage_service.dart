/// خدمة التخزين الآمن
///
/// تُستخدم لتخزين البيانات الحساسة مثل:
/// - مفتاح تشفير قاعدة البيانات
/// - Access tokens
/// - Refresh tokens
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for storage operations (for testing)
abstract class StorageInterface {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

/// Native implementation using FlutterSecureStorage (Android/iOS/macOS/Linux/Windows)
class _NativeStorage implements StorageInterface {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// Simple obfuscation for web storage values.
/// Not cryptographically strong, but prevents casual reading from DevTools.
class _WebCrypto {
  static const _salt = 'alhai_pos_2026_web_storage';

  static String _deriveKey() {
    final keyMaterial = '$_salt|${Uri.base.origin}';
    // Simple hash: sum of char codes modulo-shifted
    final chars = keyMaterial.codeUnits;
    final keyChars = <int>[];
    for (var i = 0; i < 64; i++) {
      keyChars.add((chars[i % chars.length] * 31 + i * 17) & 0xFF);
    }
    return String.fromCharCodes(keyChars);
  }

  static String obfuscate(String plaintext) {
    final key = _deriveKey();
    final bytes = utf8.encode(plaintext);
    final keyBytes = key.codeUnits;
    final result = Uint8List(bytes.length);
    for (var i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ keyBytes[i % keyBytes.length];
    }
    return base64Url.encode(result);
  }

  static String? deobfuscate(String encoded) {
    try {
      final key = _deriveKey();
      final bytes = base64Url.decode(encoded);
      final keyBytes = key.codeUnits;
      final result = Uint8List(bytes.length);
      for (var i = 0; i < bytes.length; i++) {
        result[i] = bytes[i] ^ keyBytes[i % keyBytes.length];
      }
      return utf8.decode(result);
    } catch (_) {
      return null; // Failed to decode - might be legacy plaintext
    }
  }
}

/// Web fallback using SharedPreferences with obfuscation.
/// Web storage is not as secure as native keychain. Sensitive data should
/// use server-side storage in production. This fallback ensures the app
/// is functional on web where FlutterSecureStorage has no native keychain.
class _WebStorage implements StorageInterface {
  static const String _prefix = 'secure_storage_';
  SharedPreferences? _prefs;
  final Map<String, String> _cache = {};

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String?> read({required String key}) async {
    // Check cache first
    if (_cache.containsKey(key)) return _cache[key];

    final prefs = await _getPrefs();
    final stored = prefs.getString('$_prefix$key');
    if (stored == null) return null;

    // Try to deobfuscate
    final decoded = _WebCrypto.deobfuscate(stored);
    if (decoded != null) {
      _cache[key] = decoded;
      return decoded;
    }

    // Legacy plaintext - migrate by re-saving obfuscated
    _cache[key] = stored;
    await prefs.setString('$_prefix$key', _WebCrypto.obfuscate(stored));
    return stored;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _cache[key] = value;
    final prefs = await _getPrefs();
    await prefs.setString('$_prefix$key', _WebCrypto.obfuscate(value));
  }

  @override
  Future<void> delete({required String key}) async {
    _cache.remove(key);
    final prefs = await _getPrefs();
    await prefs.remove('$_prefix$key');
  }

  @override
  Future<void> deleteAll() async {
    _cache.clear();
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// In-memory implementation for testing
class InMemoryStorage implements StorageInterface {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({required String key}) async => _data[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _data.clear();
  }
}

class SecureStorageService {
  // Auto-select backend: web uses SharedPreferences, native uses FlutterSecureStorage
  static StorageInterface _storage = kIsWeb ? _WebStorage() : _NativeStorage();

  /// Set storage implementation (for testing)
  static void setStorage(StorageInterface storage) {
    _storage = storage;
  }

  /// Reset to platform-appropriate storage
  static void resetStorage() {
    _storage = kIsWeb ? _WebStorage() : _NativeStorage();
  }
  
  // ============================================================================
  // KEYS
  // ============================================================================
  
  static const _keyDatabaseEncryption = 'db_encryption_key';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keySessionExpiry = 'session_expiry';
  static const _keyUserId = 'user_id';
  static const _keyStoreId = 'store_id';
  
  // ============================================================================
  // DATABASE ENCRYPTION
  // ============================================================================
  
  /// الحصول على مفتاح تشفير قاعدة البيانات
  /// إذا لم يكن موجوداً، يتم توليد مفتاح جديد
  static Future<String> getDatabaseKey() async {
    String? key = await _storage.read(key: _keyDatabaseEncryption);
    
    if (key == null) {
      key = _generateSecureKey(32);
      await _storage.write(key: _keyDatabaseEncryption, value: key);
    }
    
    return key;
  }
  
  // ============================================================================
  // TOKENS
  // ============================================================================
  
  /// حفظ Access Token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }
  
  /// الحصول على Access Token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }
  
  /// حفظ Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }
  
  /// الحصول على Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }
  
  /// حفظ الـ tokens معاً
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      _storage.write(key: _keySessionExpiry, value: expiry.toIso8601String()),
    ]);
  }
  
  /// التحقق من صلاحية الجلسة
  static Future<bool> isSessionValid() async {
    final expiryStr = await _storage.read(key: _keySessionExpiry);
    if (expiryStr == null) return false;
    
    final expiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(expiry);
  }
  
  /// الحصول على وقت انتهاء الجلسة
  static Future<DateTime?> getSessionExpiry() async {
    final expiryStr = await _storage.read(key: _keySessionExpiry);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }
  
  // ============================================================================
  // USER DATA
  // ============================================================================
  
  /// حفظ بيانات المستخدم
  static Future<void> saveUserData({
    required String userId,
    required String storeId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyStoreId, value: storeId),
    ]);
  }
  
  /// الحصول على User ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }
  
  /// الحصول على Store ID
  static Future<String?> getStoreId() async {
    return await _storage.read(key: _keyStoreId);
  }
  
  // ============================================================================
  // CLEAR
  // ============================================================================
  
  /// مسح بيانات الجلسة (عند تسجيل الخروج)
  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keySessionExpiry),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyStoreId),
    ]);
  }
  
  /// مسح كل البيانات (عند إعادة تعيين التطبيق)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // ============================================================================
  // HELPERS
  // ============================================================================
  
  /// توليد مفتاح آمن عشوائي
  static String _generateSecureKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }
  
  // ============================================================================
  // GENERIC STORAGE (for BiometricService & PinService)
  // ============================================================================
  
  /// قراءة قيمة
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
  
  /// كتابة قيمة
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  /// حذف قيمة
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
