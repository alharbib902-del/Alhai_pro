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
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
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

/// Security Note: Web storage cannot be truly encrypted since the key must
/// be accessible to JavaScript. This obfuscation layer prevents casual
/// inspection but is NOT equivalent to native SecureStorage/Keychain.
/// For production, consider using HttpOnly cookies set by the server.
///
/// Improvement over simple XOR: uses a per-session random key combined
/// with the app salt, so the effective key changes every browser session.
/// This means stored tokens become unreadable after the session ends,
/// which limits the window of exposure from DevTools inspection.
class _WebCrypto {
  static const _salt = 'alhai_pos_2026_web_storage';
  static String? _webSessionKey;

  /// Generate a per-session random key for web storage obfuscation.
  /// The key lives only in memory (lost on page refresh), which means
  /// previously stored values cannot be decoded in a new session.
  /// This is intentional: tokens should be refreshed via the server.
  static String _getOrCreateSessionKey() {
    final existing = _webSessionKey;
    if (existing != null && existing.isNotEmpty) return existing;

    // Generate 32 random bytes as hex
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    _webSessionKey = key;
    return key;
  }

  /// Enhanced web obfuscation using combined session + app key.
  /// The combined key includes the static salt, the origin, and a
  /// per-session random component, making the XOR output unique per session.
  static String obfuscate(String plaintext) {
    final sessionKey = _getOrCreateSessionKey();
    final combinedKey = '$_salt:${Uri.base.origin}:$sessionKey';
    final keyBytes = utf8.encode(combinedKey);
    final dataBytes = utf8.encode(plaintext);
    final result = List<int>.generate(
      dataBytes.length,
      (i) => dataBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64Url.encode(result);
  }

  static String? deobfuscate(String encoded) {
    try {
      final sessionKey = _getOrCreateSessionKey();
      final combinedKey = '$_salt:${Uri.base.origin}:$sessionKey';
      final keyBytes = utf8.encode(combinedKey);
      final encBytes = base64Url.decode(encoded);
      final result = List<int>.generate(
        encBytes.length,
        (i) => encBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(result);
    } catch (_) {
      return null; // Failed to decode - session key changed or legacy data
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

  // ============================================================================
  // ENCRYPTION KEY BACKUP / RESTORE
  // ============================================================================

  static const _keyBackupDone = 'db_key_backup_done';

  /// اشتقاق مفتاح تشفير من معرّف المستخدم لتشفير مفتاح قاعدة البيانات
  /// يُستخدم HMAC-SHA256 مع ملح ثابت لضمان الاتساق عبر الأجهزة
  static List<int> _deriveKeyFromUserId(String userId) {
    const salt = 'alhai_db_key_backup_2026';
    final hmacKey = Hmac(sha256, utf8.encode(salt));
    final digest = hmacKey.convert(utf8.encode(userId));
    return digest.bytes;
  }

  /// تشفير مفتاح قاعدة البيانات باستخدام XOR مع مفتاح مشتق من userId
  static String _encryptDbKey(String dbKey, String userId) {
    final derivedKey = _deriveKeyFromUserId(userId);
    final dbKeyBytes = utf8.encode(dbKey);
    final encrypted = Uint8List(dbKeyBytes.length);
    for (var i = 0; i < dbKeyBytes.length; i++) {
      encrypted[i] = dbKeyBytes[i] ^ derivedKey[i % derivedKey.length];
    }
    return base64Url.encode(encrypted);
  }

  /// فك تشفير مفتاح قاعدة البيانات
  static String _decryptDbKey(String encryptedKey, String userId) {
    final derivedKey = _deriveKeyFromUserId(userId);
    final encBytes = base64Url.decode(encryptedKey);
    final decrypted = Uint8List(encBytes.length);
    for (var i = 0; i < encBytes.length; i++) {
      decrypted[i] = encBytes[i] ^ derivedKey[i % derivedKey.length];
    }
    return utf8.decode(decrypted);
  }

  /// رفع مفتاح تشفير قاعدة البيانات إلى Supabase (user metadata)
  ///
  /// يُشفَّر المفتاح باستخدام مفتاح مشتق من معرّف المستخدم قبل الإرسال.
  /// يُستدعى بعد تسجيل الدخول إذا لم يكن قد تم النسخ الاحتياطي بعد.
  static Future<bool> backupEncryptionKeyToServer() async {
    try {
      final dbKey = await _storage.read(key: _keyDatabaseEncryption);
      if (dbKey == null || dbKey.isEmpty) return false;

      // تحقق: هل تم النسخ الاحتياطي من قبل؟
      final backupDone = await _storage.read(key: _keyBackupDone);
      if (backupDone == 'true') return true;

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return false;

      final encryptedKey = _encryptDbKey(dbKey, user.id);

      // تخزين المفتاح المشفر في user_metadata
      await client.auth.updateUser(
        UserAttributes(
          data: {...?user.userMetadata, 'encrypted_db_key': encryptedKey},
        ),
      );

      // تسجيل أن النسخ الاحتياطي تم
      await _storage.write(key: _keyBackupDone, value: 'true');

      if (kDebugMode) {
        debugPrint('[KeyBackup] DB encryption key backed up to server');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[KeyBackup] Backup failed: $e');
      }
      return false;
    }
  }

  /// استعادة مفتاح تشفير قاعدة البيانات من Supabase
  ///
  /// يُستدعى عند التثبيت الجديد أو إعادة التثبيت إذا لم يكن هناك مفتاح محلي.
  /// يفك تشفير المفتاح المخزن في user_metadata ويحفظه في SecureStorage.
  static Future<bool> restoreEncryptionKeyFromServer() async {
    try {
      // تحقق: هل يوجد مفتاح محلي بالفعل؟
      final existingKey = await _storage.read(key: _keyDatabaseEncryption);
      if (existingKey != null && existingKey.isNotEmpty) return true;

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return false;

      final encryptedKey = user.userMetadata?['encrypted_db_key'] as String?;
      if (encryptedKey == null || encryptedKey.isEmpty) return false;

      final dbKey = _decryptDbKey(encryptedKey, user.id);
      await _storage.write(key: _keyDatabaseEncryption, value: dbKey);

      // تسجيل أن النسخ الاحتياطي موجود
      await _storage.write(key: _keyBackupDone, value: 'true');

      if (kDebugMode) {
        debugPrint('[KeyBackup] DB encryption key restored from server');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[KeyBackup] Restore failed: $e');
      }
      return false;
    }
  }

  /// محاولة نسخ احتياطي أو استعادة المفتاح حسب الحالة
  ///
  /// يُستدعى بعد كل تسجيل دخول ناجح:
  /// - إذا لم يكن هناك مفتاح محلي → يحاول الاستعادة من السيرفر
  /// - إذا كان هناك مفتاح محلي ولم يتم النسخ الاحتياطي → يرفعه للسيرفر
  static Future<void> ensureEncryptionKeyBackup() async {
    try {
      final dbKey = await _storage.read(key: _keyDatabaseEncryption);

      if (dbKey == null || dbKey.isEmpty) {
        // لا يوجد مفتاح محلي → محاولة الاستعادة من السيرفر
        await restoreEncryptionKeyFromServer();
      } else {
        // يوجد مفتاح محلي → تأكد من وجود نسخة احتياطية
        await backupEncryptionKeyToServer();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[KeyBackup] ensureEncryptionKeyBackup error: $e');
      }
    }
  }
}
