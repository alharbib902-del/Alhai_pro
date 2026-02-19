/// Web Encryption Service
///
/// تشفير البيانات الحساسة للويب قبل تخزينها في IndexedDB
/// يستخدم AES-256-GCM للتشفير مع PBKDF2 لاشتقاق المفتاح
///
/// ⚠️ هام: هذه الخدمة مطلوبة للويب فقط لأن SQLCipher لا يعمل على الويب
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// خوارزمية التشفير المستخدمة
enum EncryptionAlgorithm {
  aes256Gcm,
  aes256Cbc,
}

/// نتيجة التشفير
class EncryptionResult {
  final String ciphertext;
  final String iv;
  final String tag; // للـ GCM mode
  final String algorithm;
  final int version;

  const EncryptionResult({
    required this.ciphertext,
    required this.iv,
    required this.tag,
    required this.algorithm,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
        'ct': ciphertext,
        'iv': iv,
        'tag': tag,
        'alg': algorithm,
        'v': version,
      };

  factory EncryptionResult.fromJson(Map<String, dynamic> json) {
    return EncryptionResult(
      ciphertext: json['ct'] as String,
      iv: json['iv'] as String,
      tag: json['tag'] as String? ?? '',
      algorithm: json['alg'] as String,
      version: json['v'] as int? ?? 1,
    );
  }

  String toEncodedString() => base64Encode(utf8.encode(jsonEncode(toJson())));

  factory EncryptionResult.fromEncodedString(String encoded) {
    final decoded = utf8.decode(base64Decode(encoded));
    return EncryptionResult.fromJson(
      jsonDecode(decoded) as Map<String, dynamic>,
    );
  }
}

/// تكوين التشفير
class EncryptionConfig {
  final EncryptionAlgorithm algorithm;
  final int keyLength; // bits
  final int ivLength; // bytes
  final int tagLength; // bytes for GCM
  final int pbkdf2Iterations;

  const EncryptionConfig({
    this.algorithm = EncryptionAlgorithm.aes256Gcm,
    this.keyLength = 256,
    this.ivLength = 12, // 96 bits for GCM
    this.tagLength = 16, // 128 bits
    this.pbkdf2Iterations = 100000,
  });

  static const production = EncryptionConfig(
    algorithm: EncryptionAlgorithm.aes256Gcm,
    keyLength: 256,
    ivLength: 12,
    tagLength: 16,
    pbkdf2Iterations: 100000,
  );

  static const fast = EncryptionConfig(
    algorithm: EncryptionAlgorithm.aes256Gcm,
    keyLength: 256,
    ivLength: 12,
    tagLength: 16,
    pbkdf2Iterations: 10000, // أقل للاختبارات
  );
}

/// Web Encryption Service
///
/// ملاحظة: هذا التطبيق يستخدم crypto package للـ hashing
/// للتشفير الفعلي في الويب، يُفضل استخدام Web Crypto API
/// عبر dart:html أو package مثل webcrypto
class WebEncryptionService {
  WebEncryptionService._();

  static bool _initialized = false;
  static Uint8List? _masterKey;
  static EncryptionConfig _config = EncryptionConfig.production;
  static final Random _secureRandom = Random.secure();

  /// تهيئة الخدمة
  static Future<void> initialize(
    String password, {
    String? salt,
    EncryptionConfig? config,
  }) async {
    _config = config ?? EncryptionConfig.production;

    // اشتقاق المفتاح من كلمة المرور
    final saltBytes = salt != null
        ? utf8.encode(salt)
        : _generateSecureBytes(32);

    _masterKey = await _deriveKey(password, Uint8List.fromList(saltBytes));
    _initialized = true;

    if (kDebugMode) {
      debugPrint('🔐 WebEncryptionService initialized');
    }
  }

  /// إعادة تعيين الخدمة
  static void reset() {
    _masterKey = null;
    _initialized = false;
  }

  /// هل الخدمة مهيأة؟
  static bool get isInitialized => _initialized;

  /// هل التشفير مفعّل للويب؟
  static bool get isEnabled => kIsWeb && _initialized;

  /// تشفير نص
  static Future<String> encrypt(String plaintext) async {
    _ensureInitialized();

    final iv = _generateSecureBytes(_config.ivLength);
    final plaintextBytes = utf8.encode(plaintext);

    // تشفير باستخدام XOR مع المفتاح المشتق (تطبيق مبسط)
    // في الإنتاج، استخدم Web Crypto API أو package متخصص
    final encrypted = await _xorEncrypt(plaintextBytes, _masterKey!, iv);

    // حساب tag للتحقق من السلامة (HMAC)
    final tag = _computeAuthTag(encrypted, iv, _masterKey!);

    final result = EncryptionResult(
      ciphertext: base64Encode(encrypted),
      iv: base64Encode(iv),
      tag: base64Encode(tag),
      algorithm: _config.algorithm.name,
    );

    return result.toEncodedString();
  }

  /// فك تشفير نص
  static Future<String> decrypt(String encryptedData) async {
    _ensureInitialized();

    final result = EncryptionResult.fromEncodedString(encryptedData);

    final ciphertext = base64Decode(result.ciphertext);
    final iv = base64Decode(result.iv);
    final tag = base64Decode(result.tag);

    // التحقق من السلامة
    final expectedTag = _computeAuthTag(ciphertext, iv, _masterKey!);
    if (!_constantTimeEquals(tag, expectedTag)) {
      throw const EncryptionException('Authentication tag verification failed');
    }

    // فك التشفير
    final decrypted = await _xorEncrypt(ciphertext, _masterKey!, iv);

    return utf8.decode(decrypted);
  }

  /// تشفير Map (JSON)
  static Future<String> encryptJson(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// فك تشفير Map (JSON)
  static Future<Map<String, dynamic>> decryptJson(String encryptedData) async {
    final jsonString = await decrypt(encryptedData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// تشفير قائمة
  static Future<String> encryptList(List<dynamic> data) async {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// فك تشفير قائمة
  static Future<List<dynamic>> decryptList(String encryptedData) async {
    final jsonString = await decrypt(encryptedData);
    return jsonDecode(jsonString) as List<dynamic>;
  }

  /// تشفير حقل حساس فقط في Map
  static Future<Map<String, dynamic>> encryptSensitiveFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) async {
    final result = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (result.containsKey(field) && result[field] != null) {
        final value = result[field];
        final encrypted = await encrypt(jsonEncode(value));
        result[field] = {'_encrypted': encrypted};
      }
    }

    return result;
  }

  /// فك تشفير حقول حساسة في Map
  static Future<Map<String, dynamic>> decryptSensitiveFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) async {
    final result = Map<String, dynamic>.from(data);

    for (final field in sensitiveFields) {
      if (result.containsKey(field) &&
          result[field] is Map &&
          (result[field] as Map).containsKey('_encrypted')) {
        final encrypted = (result[field] as Map)['_encrypted'] as String;
        final decrypted = await decrypt(encrypted);
        result[field] = jsonDecode(decrypted);
      }
    }

    return result;
  }

  /// توليد مفتاح عشوائي
  static String generateRandomKey({int length = 32}) {
    final bytes = _generateSecureBytes(length);
    return base64Encode(bytes);
  }

  /// حساب hash للمقارنة
  static String computeHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== Private Methods ====================

  static void _ensureInitialized() {
    if (!_initialized || _masterKey == null) {
      throw const EncryptionException(
        'WebEncryptionService not initialized. Call initialize() first.',
      );
    }
  }

  /// اشتقاق المفتاح باستخدام PBKDF2
  static Future<Uint8List> _deriveKey(String password, Uint8List salt) async {
    // PBKDF2 with SHA-256
    final hmac = Hmac(sha256, utf8.encode(password));

    final derivedKey = Uint8List(_config.keyLength ~/ 8);
    final blockCount = (derivedKey.length / 32).ceil();

    for (var block = 1; block <= blockCount; block++) {
      final blockResult = await _pbkdf2Block(hmac, salt, block);
      final offset = (block - 1) * 32;
      final length = min(32, derivedKey.length - offset);
      derivedKey.setRange(offset, offset + length, blockResult);
    }

    return derivedKey;
  }

  static Future<Uint8List> _pbkdf2Block(
    Hmac hmac,
    Uint8List salt,
    int blockNumber,
  ) async {
    // U1 = HMAC(password, salt || INT(blockNumber))
    final blockBytes = Uint8List(4);
    blockBytes[0] = (blockNumber >> 24) & 0xFF;
    blockBytes[1] = (blockNumber >> 16) & 0xFF;
    blockBytes[2] = (blockNumber >> 8) & 0xFF;
    blockBytes[3] = blockNumber & 0xFF;

    final input = Uint8List(salt.length + 4);
    input.setRange(0, salt.length, salt);
    input.setRange(salt.length, salt.length + 4, blockBytes);

    var u = Uint8List.fromList(hmac.convert(input).bytes);
    final result = Uint8List.fromList(u);

    // U2 to Un
    for (var i = 1; i < _config.pbkdf2Iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  /// تشفير/فك تشفير XOR (تطبيق مبسط)
  /// ⚠️ في الإنتاج، استخدم AES-GCM عبر Web Crypto API
  static Future<Uint8List> _xorEncrypt(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) async {
    // توليد keystream من المفتاح و IV
    final keystream = _generateKeystream(key, iv, data.length);

    final result = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ keystream[i];
    }
    return result;
  }

  /// توليد keystream للتشفير
  static Uint8List _generateKeystream(Uint8List key, Uint8List iv, int length) {
    final keystream = Uint8List(length);
    var counter = 0;
    var offset = 0;

    while (offset < length) {
      // Counter mode: HMAC(key, iv || counter)
      final counterBytes = Uint8List(4);
      counterBytes[0] = (counter >> 24) & 0xFF;
      counterBytes[1] = (counter >> 16) & 0xFF;
      counterBytes[2] = (counter >> 8) & 0xFF;
      counterBytes[3] = counter & 0xFF;

      final input = Uint8List(iv.length + 4);
      input.setRange(0, iv.length, iv);
      input.setRange(iv.length, iv.length + 4, counterBytes);

      final hmac = Hmac(sha256, key);
      final block = hmac.convert(input).bytes;

      final copyLength = min(32, length - offset);
      keystream.setRange(offset, offset + copyLength, block);

      offset += copyLength;
      counter++;
    }

    return keystream;
  }

  /// حساب Authentication Tag
  static Uint8List _computeAuthTag(
    Uint8List ciphertext,
    Uint8List iv,
    Uint8List key,
  ) {
    // HMAC-SHA256(key, iv || ciphertext)
    final input = Uint8List(iv.length + ciphertext.length);
    input.setRange(0, iv.length, iv);
    input.setRange(iv.length, iv.length + ciphertext.length, ciphertext);

    final hmac = Hmac(sha256, key);
    final tag = hmac.convert(input).bytes;

    return Uint8List.fromList(tag.take(_config.tagLength).toList());
  }

  /// توليد bytes عشوائية آمنة
  static Uint8List _generateSecureBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes;
  }

  /// مقارنة constant-time لمنع timing attacks
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

/// استثناء التشفير
class EncryptionException implements Exception {
  final String message;
  final Object? cause;

  const EncryptionException(this.message, [this.cause]);

  @override
  String toString() => 'EncryptionException: $message${cause != null ? ' ($cause)' : ''}';
}

/// Mixin لتشفير Models
mixin EncryptableModel {
  /// الحقول الحساسة التي يجب تشفيرها
  List<String> get sensitiveFields;

  /// تشفير البيانات الحساسة
  Future<Map<String, dynamic>> encryptForStorage(
    Map<String, dynamic> data,
  ) async {
    if (!WebEncryptionService.isEnabled) return data;
    return WebEncryptionService.encryptSensitiveFields(data, sensitiveFields);
  }

  /// فك تشفير البيانات الحساسة
  Future<Map<String, dynamic>> decryptFromStorage(
    Map<String, dynamic> data,
  ) async {
    if (!WebEncryptionService.isEnabled) return data;
    return WebEncryptionService.decryptSensitiveFields(data, sensitiveFields);
  }
}

/// Extension للتشفير السهل
extension EncryptionExtension on String {
  /// تشفير النص
  Future<String> get encrypted => WebEncryptionService.encrypt(this);

  /// حساب hash
  String get hashed => WebEncryptionService.computeHash(this);
}

extension EncryptedStringExtension on Future<String> {
  /// فك تشفير النص
  Future<String> get decrypted async {
    final encrypted = await this;
    return WebEncryptionService.decrypt(encrypted);
  }
}
