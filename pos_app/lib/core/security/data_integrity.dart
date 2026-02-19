/// Data Integrity Service
///
/// خدمة سلامة البيانات لضمان:
/// - عدم التلاعب بالبيانات
/// - اكتشاف التغييرات غير المصرح بها
/// - Checksums و Hashing
/// - تسجيل التغييرات
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// نتيجة فحص السلامة
class IntegrityCheckResult {
  final bool isValid;
  final String? expectedHash;
  final String? actualHash;
  final List<String> violations;
  final DateTime checkedAt;

  IntegrityCheckResult({
    required this.isValid,
    this.expectedHash,
    this.actualHash,
    this.violations = const [],
  }) : checkedAt = DateTime.now();

  factory IntegrityCheckResult.valid() => IntegrityCheckResult(isValid: true);

  factory IntegrityCheckResult.invalid({
    required String expected,
    required String actual,
    List<String>? violations,
  }) => IntegrityCheckResult(
    isValid: false,
    expectedHash: expected,
    actualHash: actual,
    violations: violations ?? ['Hash mismatch'],
  );
}

/// سجل تغيير
class ChangeRecord {
  final String entityType;
  final String entityId;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final String hash;
  final DateTime timestamp;

  ChangeRecord({
    required this.entityType,
    required this.entityId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.hash,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'fieldName': fieldName,
    'oldValue': oldValue,
    'newValue': newValue,
    'hash': hash,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Data Integrity Service
class DataIntegrity {
  DataIntegrity._();

  // مفتاح HMAC (يجب تخزينه بشكل آمن)
  static String? _hmacKey;

  // سجل التغييرات
  static final List<ChangeRecord> _changeLog = [];
  static const int _maxChangeLogEntries = 5000;

  // Hashes المخزنة
  static final Map<String, String> _storedHashes = {};

  /// تهيئة الخدمة
  static void initialize(String hmacKey) {
    _hmacKey = hmacKey;
    if (kDebugMode) {
      debugPrint('🔐 DataIntegrity initialized');
    }
  }

  /// حساب Hash للبيانات
  static String computeHash(dynamic data) {
    String serialized;

    if (data is Map) {
      // ترتيب المفاتيح للحصول على hash ثابت
      serialized = _serializeMap(data as Map<String, dynamic>);
    } else if (data is List) {
      serialized = jsonEncode(data);
    } else {
      serialized = data.toString();
    }

    // SHA-256 hash
    final bytes = utf8.encode(serialized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// حساب HMAC للبيانات
  static String computeHmac(dynamic data) {
    if (_hmacKey == null) {
      throw IntegrityException('DataIntegrity not initialized');
    }

    String serialized;
    if (data is Map) {
      serialized = _serializeMap(data as Map<String, dynamic>);
    } else {
      serialized = data.toString();
    }

    final key = utf8.encode(_hmacKey!);
    final bytes = utf8.encode(serialized);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);

    return digest.toString();
  }

  /// تسجيل Hash جديد
  static void registerHash(String key, dynamic data) {
    final hash = computeHash(data);
    _storedHashes[key] = hash;

    if (kDebugMode) {
      debugPrint('🔐 Hash registered for $key: ${hash.substring(0, 16)}...');
    }
  }

  /// التحقق من سلامة البيانات
  static IntegrityCheckResult verifyIntegrity(String key, dynamic data) {
    final currentHash = computeHash(data);
    final storedHash = _storedHashes[key];

    if (storedHash == null) {
      return IntegrityCheckResult(
        isValid: false,
        actualHash: currentHash,
        violations: ['No stored hash found for $key'],
      );
    }

    if (currentHash == storedHash) {
      return IntegrityCheckResult.valid();
    }

    return IntegrityCheckResult.invalid(
      expected: storedHash,
      actual: currentHash,
      violations: ['Data has been modified'],
    );
  }

  /// التحقق من HMAC
  static bool verifyHmac(dynamic data, String expectedHmac) {
    final actualHmac = computeHmac(data);
    return _constantTimeEquals(actualHmac, expectedHmac);
  }

  /// تسجيل تغيير
  static void logChange({
    required String entityType,
    required String entityId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    final now = DateTime.now();
    final changeData = {
      'entityType': entityType,
      'entityId': entityId,
      'fieldName': fieldName,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': now.toIso8601String(),
    };

    final hash = computeHmac(changeData);

    final record = ChangeRecord(
      entityType: entityType,
      entityId: entityId,
      fieldName: fieldName,
      oldValue: oldValue,
      newValue: newValue,
      hash: hash,
      timestamp: now,
    );

    _changeLog.add(record);

    // الحفاظ على الحد الأقصى
    while (_changeLog.length > _maxChangeLogEntries) {
      _changeLog.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('📝 Change logged: $entityType:$entityId.$fieldName');
    }
  }

  /// التحقق من سلامة سجل التغييرات
  static bool verifyChangeLog() {
    for (final record in _changeLog) {
      final changeData = {
        'entityType': record.entityType,
        'entityId': record.entityId,
        'fieldName': record.fieldName,
        'oldValue': record.oldValue,
        'newValue': record.newValue,
        'timestamp': record.timestamp.toIso8601String(),
      };

      final expectedHash = computeHmac(changeData);

      if (!_constantTimeEquals(record.hash, expectedHash)) {
        if (kDebugMode) {
          debugPrint('⚠️ Change log integrity violation detected!');
        }
        return false;
      }
    }

    return true;
  }

  /// الحصول على سجل التغييرات لكيان معين
  static List<ChangeRecord> getChangeHistory({
    required String entityType,
    required String entityId,
  }) {
    return _changeLog
        .where((r) => r.entityType == entityType && r.entityId == entityId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// إنشاء Checksum لقائمة
  static String computeListChecksum(List<Map<String, dynamic>> items) {
    final hashes = items.map((item) => computeHash(item)).toList();
    hashes.sort(); // ترتيب للحصول على checksum ثابت
    return computeHash(hashes.join(''));
  }

  /// التحقق من Checksum القائمة
  static bool verifyListChecksum(
    List<Map<String, dynamic>> items,
    String expectedChecksum,
  ) {
    final actualChecksum = computeListChecksum(items);
    return _constantTimeEquals(actualChecksum, expectedChecksum);
  }

  /// حساب Hash لملف (بيانات)
  static String computeFileHash(List<int> bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// إنشاء توقيع للبيانات (للتحقق لاحقاً)
  static String sign(dynamic data) {
    return computeHmac(data);
  }

  /// التحقق من التوقيع
  static bool verify(dynamic data, String signature) {
    return verifyHmac(data, signature);
  }

  /// مسح البيانات (للاختبار)
  @visibleForTesting
  static void clear() {
    _storedHashes.clear();
    _changeLog.clear();
  }

  /// تسلسل Map بترتيب ثابت
  static String _serializeMap(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <String, dynamic>{};

    for (final key in sortedKeys) {
      var value = map[key];
      if (value is Map<String, dynamic>) {
        value = _serializeMap(value);
      }
      sortedMap[key] = value;
    }

    return jsonEncode(sortedMap);
  }

  /// مقارنة آمنة ضد timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

/// استثناء سلامة البيانات
class IntegrityException implements Exception {
  final String message;

  IntegrityException(this.message);

  @override
  String toString() => 'IntegrityException: $message';
}

/// Mixin للكيانات التي تدعم التحقق من السلامة
mixin IntegrityCheckable {
  /// الحصول على البيانات للتحقق
  Map<String, dynamic> getIntegrityData();

  /// الحصول على مفتاح الكيان
  String getIntegrityKey();

  /// تسجيل Hash جديد
  void registerIntegrity() {
    DataIntegrity.registerHash(getIntegrityKey(), getIntegrityData());
  }

  /// التحقق من السلامة
  IntegrityCheckResult verifyIntegrity() {
    return DataIntegrity.verifyIntegrity(getIntegrityKey(), getIntegrityData());
  }

  /// الحصول على التوقيع
  String getSignature() {
    return DataIntegrity.sign(getIntegrityData());
  }

  /// التحقق من التوقيع
  bool verifySignature(String signature) {
    return DataIntegrity.verify(getIntegrityData(), signature);
  }
}
