import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'gzip_helper_stub.dart' if (dart.library.io) 'gzip_helper_native.dart'
    as gzip_helper;

/// خدمة النسخ الاحتياطي
/// تستخدم من: admin_pos, cashier
///
/// Uses gzip compression on native platforms (via dart:io GZipCodec).
/// Falls back to base64 encoding on web where dart:io is unavailable.
///
/// ملاحظة: تحتاج تنفيذ platform-specific للتخزين
class BackupService {
  /// إنشاء نسخة احتياطية
  Future<BackupResult> createBackup({
    required String storeId,
    required Map<String, dynamic> data,
    BackupType type = BackupType.full,
  }) async {
    try {
      final backup = BackupData(
        id: _generateBackupId(),
        storeId: storeId,
        type: type,
        data: data,
        createdAt: DateTime.now(),
        version: '1.0.0',
      );

      final jsonData = jsonEncode(backup.toJson());
      final compressedData = _compress(jsonData);

      return BackupResult(
        success: true,
        backup: backup,
        sizeBytes: compressedData.length,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        error: 'فشل إنشاء النسخة الاحتياطية: $e',
      );
    }
  }

  /// استعادة من نسخة احتياطية
  Future<RestoreResult> restoreBackup(String backupJson) async {
    try {
      final decompressed = _decompress(backupJson);
      final data = jsonDecode(decompressed) as Map<String, dynamic>;
      final backup = BackupData.fromJson(data);

      return RestoreResult(
        success: true,
        backup: backup,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        error: 'فشل استعادة النسخة الاحتياطية: $e',
      );
    }
  }

  /// التحقق من صحة ملف النسخة الاحتياطية
  BackupValidationResult validateBackup(String backupJson) {
    try {
      final decompressed = _decompress(backupJson);
      final data = jsonDecode(decompressed) as Map<String, dynamic>;

      // Check required fields
      if (!data.containsKey('id') ||
          !data.containsKey('storeId') ||
          !data.containsKey('data')) {
        return BackupValidationResult(
          isValid: false,
          error: 'ملف النسخة الاحتياطية غير صالح',
        );
      }

      final backup = BackupData.fromJson(data);

      return BackupValidationResult(
        isValid: true,
        backupId: backup.id,
        storeId: backup.storeId,
        createdAt: backup.createdAt,
        version: backup.version,
        type: backup.type,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        error: 'فشل التحقق من النسخة الاحتياطية: $e',
      );
    }
  }

  /// تصدير النسخة الاحتياطية كـ JSON
  String exportToJson(BackupData backup) {
    return jsonEncode(backup.toJson());
  }

  // ==================== Helpers ====================

  String _generateBackupId() {
    final now = DateTime.now();
    return 'backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';
  }

  /// Compresses data using gzip (native) then base64-encodes for storage.
  /// Output is prefixed with 'gz:' to distinguish from plain base64 data.
  /// Falls back to plain base64 on web where gzip is unavailable.
  ///
  /// Typical compression ratios for JSON backup data:
  /// - gzip: ~60-70% size reduction
  /// - base64 only: ~33% size increase (no compression)
  String _compress(String data) {
    final rawBytes = utf8.encode(data);
    try {
      final gzipBytes = gzip_helper.gzipEncode(rawBytes);
      final compressed = 'gz:${base64Encode(gzipBytes)}';
      final ratio = rawBytes.isNotEmpty
          ? (1 - gzipBytes.length / rawBytes.length) * 100
          : 0;
      // Log compression ratio in debug mode.
      // TODO: migrate to the shared AppLogger from alhai_core once it is
      // exported from the package barrel (currently only ProductionLogger is
      // re-exported). debugPrint is a minimal upgrade from print() because it
      // is a no-op in release mode.
      debugPrint(
          '[Backup] Compressed: ${rawBytes.length} -> ${gzipBytes.length} bytes (${ratio.toStringAsFixed(1)}% reduction)');
      return compressed;
    } catch (_) {
      // Fallback to plain base64 if gzip is unavailable (e.g., web platform)
      return base64Encode(rawBytes);
    }
  }

  /// Decompresses data. Supports both gzip-compressed ('gz:' prefix) and
  /// plain base64-encoded backup formats for backward compatibility.
  String _decompress(String data) {
    try {
      if (data.startsWith('gz:')) {
        // Gzip-compressed format
        final compressedBytes = base64Decode(data.substring(3));
        final decompressedBytes = gzip_helper.gzipDecode(compressedBytes);
        return utf8.decode(decompressedBytes);
      }
      // Legacy plain base64 format
      return utf8.decode(base64Decode(data));
    } catch (_) {
      // Assume it's uncompressed plain text
      return data;
    }
  }
}

/// بيانات النسخة الاحتياطية
class BackupData {
  final String id;
  final String storeId;
  final BackupType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String version;

  const BackupData({
    required this.id,
    required this.storeId,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.version,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
        id: json['id'] as String,
        storeId: json['storeId'] as String,
        type: BackupType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => BackupType.full,
        ),
        data: json['data'] as Map<String, dynamic>,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now(),
        version: json['version'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'type': type.name,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'version': version,
      };
}

/// نوع النسخة الاحتياطية
enum BackupType {
  full, // كل البيانات
  products, // المنتجات فقط
  orders, // الطلبات فقط
  customers, // العملاء فقط
  settings, // الإعدادات فقط
}

/// نتيجة إنشاء نسخة احتياطية
class BackupResult {
  final bool success;
  final String? error;
  final BackupData? backup;
  final int? sizeBytes;

  const BackupResult({
    required this.success,
    this.error,
    this.backup,
    this.sizeBytes,
  });
}

/// نتيجة الاستعادة
class RestoreResult {
  final bool success;
  final String? error;
  final BackupData? backup;

  const RestoreResult({
    required this.success,
    this.error,
    this.backup,
  });
}

/// نتيجة التحقق
class BackupValidationResult {
  final bool isValid;
  final String? error;
  final String? backupId;
  final String? storeId;
  final DateTime? createdAt;
  final String? version;
  final BackupType? type;

  const BackupValidationResult({
    required this.isValid,
    this.error,
    this.backupId,
    this.storeId,
    this.createdAt,
    this.version,
    this.type,
  });
}
