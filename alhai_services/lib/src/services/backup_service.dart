import 'dart:convert';

/// خدمة النسخ الاحتياطي
/// تستخدم من: admin_pos, pos_app
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

  String _compress(String data) {
    // TODO: Implement actual compression (gzip)
    // For now, just return base64 encoded
    return base64Encode(utf8.encode(data));
  }

  String _decompress(String data) {
    // TODO: Implement actual decompression
    // For now, just decode base64
    try {
      return utf8.decode(base64Decode(data));
    } catch (e) {
      // Assume it's not compressed
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
    createdAt: DateTime.parse(json['createdAt'] as String),
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
  full,       // كل البيانات
  products,   // المنتجات فقط
  orders,     // الطلبات فقط
  customers,  // العملاء فقط
  settings,   // الإعدادات فقط
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
