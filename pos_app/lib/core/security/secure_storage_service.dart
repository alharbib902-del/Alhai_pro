/// خدمة التخزين الآمن
/// 
/// تُستخدم لتخزين البيانات الحساسة مثل:
/// - مفتاح تشفير قاعدة البيانات
/// - Access tokens
/// - Refresh tokens
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interface for storage operations (for testing)
abstract class StorageInterface {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

/// Real implementation using FlutterSecureStorage
class _RealStorage implements StorageInterface {
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
  static StorageInterface _storage = _RealStorage();

  /// Set storage implementation (for testing)
  static void setStorage(StorageInterface storage) {
    _storage = storage;
  }

  /// Reset to real storage
  static void resetStorage() {
    _storage = _RealStorage();
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
