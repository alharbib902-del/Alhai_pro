import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app_database.dart';
import 'backup_storage.dart' as storage;

/// تقرير سلامة قاعدة البيانات
class DatabaseHealthReport {
  /// حالة السلامة العامة
  final DatabaseHealthStatus status;

  /// رسائل التفاصيل
  final List<String> messages;

  /// عدد الأخطاء في فحص المفاتيح الأجنبية
  final int foreignKeyErrors;

  /// وقت إنشاء التقرير
  final DateTime timestamp;

  const DatabaseHealthReport({
    required this.status,
    required this.messages,
    this.foreignKeyErrors = 0,
    required this.timestamp,
  });

  /// هل قاعدة البيانات سليمة
  bool get isHealthy => status == DatabaseHealthStatus.ok;

  @override
  String toString() =>
      'DatabaseHealthReport('
      'status: $status, '
      'messages: ${messages.length}, '
      'fkErrors: $foreignKeyErrors)';
}

/// حالات سلامة قاعدة البيانات
enum DatabaseHealthStatus {
  /// سليمة بالكامل
  ok,

  /// توجد تحذيرات (مثل أخطاء مفاتيح أجنبية) لكن البيانات متاحة
  warnings,

  /// قاعدة البيانات تالفة
  corrupted,
}

/// معلومات نسخة احتياطية
class BackupInfo {
  /// معرف النسخة الاحتياطية
  final String id;

  /// نوع النسخة (periodic, pre_migration, manual)
  final String type;

  /// وقت الإنشاء
  final DateTime createdAt;

  /// الحجم بالبايت
  final int sizeBytes;

  /// إصدار الـ schema عند إنشاء النسخة
  final int schemaVersion;

  /// ملاحظات إضافية
  final String? notes;

  const BackupInfo({
    required this.id,
    required this.type,
    required this.createdAt,
    this.sizeBytes = 0,
    this.schemaVersion = 0,
    this.notes,
  });

  /// الحجم بصيغة مقروءة
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'sizeBytes': sizeBytes,
    'schemaVersion': schemaVersion,
    'notes': notes,
  };

  factory BackupInfo.fromJson(Map<String, dynamic> json) => BackupInfo(
    id: json['id'] as String,
    type: json['type'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    sizeBytes: json['sizeBytes'] as int? ?? 0,
    schemaVersion: json['schemaVersion'] as int? ?? 0,
    notes: json['notes'] as String?,
  );
}

/// خدمة النسخ الاحتياطي لقاعدة البيانات
///
/// توفر:
/// - نسخ احتياطي دوري تلقائي (كل ساعتين افتراضياً)
/// - نسخ احتياطي قبل الترحيل (migration)
/// - تصدير/استيراد JSON يدوي
/// - فحص سلامة قاعدة البيانات
/// - استعادة من نسخة احتياطية
class DatabaseBackupService {
  final AppDatabase _db;

  /// الفترة بين النسخ الاحتياطية التلقائية
  final Duration backupInterval;

  /// الحد الأقصى لعدد النسخ الاحتياطية المحتفظ بها
  final int maxBackups;

  /// مؤقت النسخ الاحتياطي الدوري
  Timer? _periodicTimer;

  /// هل الخدمة تعمل
  bool _isRunning = false;

  /// الجداول المهمة للتصدير
  static const _criticalTables = [
    'sales',
    'sale_items',
    'customers',
    'products',
    'categories',
    'shifts',
    'expenses',
    'returns',
    'return_items',
    'sync_queue',
    'settings',
    'accounts',
    'inventory_movements',
    'stores',
    'users',
  ];

  DatabaseBackupService(
    this._db, {
    this.backupInterval = const Duration(hours: 2),
    this.maxBackups = 5,
  });

  // ==========================================================================
  // A. النسخ الاحتياطي الدوري التلقائي
  // ==========================================================================

  /// بدء النسخ الاحتياطي الدوري
  void startPeriodicBackup() {
    if (_isRunning) return;
    _isRunning = true;

    _periodicTimer = Timer.periodic(backupInterval, (_) async {
      try {
        await createPeriodicBackup();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Backup] Periodic backup failed: $e');
        }
      }
    });

    if (kDebugMode) {
      debugPrint(
        '[Backup] Periodic backup started '
        '(interval: ${backupInterval.inMinutes} minutes, '
        'max: $maxBackups backups)',
      );
    }
  }

  /// إيقاف النسخ الاحتياطي الدوري
  void stopPeriodicBackup() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isRunning = false;
    if (kDebugMode) {
      debugPrint('[Backup] Periodic backup stopped');
    }
  }

  /// إنشاء نسخة احتياطية دورية
  Future<BackupInfo> createPeriodicBackup() async {
    final backupId = _generateBackupId('periodic');

    if (kDebugMode) {
      debugPrint('[Backup] Creating periodic backup: $backupId');
    }

    // تصدير البيانات كـ JSON
    final jsonData = await _exportTablesAsJson();
    await storage.saveJsonBackup(backupId, jsonData);

    // حفظ البيانات الوصفية
    final info = BackupInfo(
      id: backupId,
      type: 'periodic',
      createdAt: DateTime.now(),
      sizeBytes: jsonData.length,
      schemaVersion: _db.schemaVersion,
    );

    await _saveBackupInfo(info);

    // تدوير النسخ القديمة
    await _rotateBackups('periodic');

    if (kDebugMode) {
      debugPrint('[Backup] Periodic backup completed: ${info.formattedSize}');
    }

    return info;
  }

  // ==========================================================================
  // B. النسخ الاحتياطي قبل الترحيل
  // ==========================================================================

  /// إنشاء نسخة احتياطية قبل ترحيل الـ schema
  /// يُستدعى تلقائياً من MigrationStrategy
  Future<BackupInfo> createPreMigrationBackup(int fromVersion) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupId = 'backup_pre_migration_v${fromVersion}_$timestamp';

    if (kDebugMode) {
      debugPrint(
        '[Backup] Creating pre-migration backup (v$fromVersion): $backupId',
      );
    }

    // تصدير البيانات كـ JSON
    final jsonData = await _exportTablesAsJson();
    await storage.saveJsonBackup(backupId, jsonData);

    final info = BackupInfo(
      id: backupId,
      type: 'pre_migration',
      createdAt: DateTime.now(),
      sizeBytes: jsonData.length,
      schemaVersion: fromVersion,
      notes: 'Pre-migration backup from schema v$fromVersion',
    );

    await _saveBackupInfo(info);

    if (kDebugMode) {
      debugPrint(
        '[Backup] Pre-migration backup completed: ${info.formattedSize}',
      );
    }

    return info;
  }

  /// إنشاء نسخة احتياطية بعد ترحيل الـ schema بنجاح
  /// يُستدعى تلقائياً من MigrationStrategy بعد نجاح الهجرة
  Future<BackupInfo> createPostMigrationBackup(int toVersion) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupId = 'backup_post_migration_v${toVersion}_$timestamp';

    if (kDebugMode) {
      debugPrint(
        '[Backup] Creating post-migration backup (v$toVersion): $backupId',
      );
    }

    // تصدير البيانات كـ JSON
    final jsonData = await _exportTablesAsJson();
    await storage.saveJsonBackup(backupId, jsonData);

    final info = BackupInfo(
      id: backupId,
      type: 'post_migration',
      createdAt: DateTime.now(),
      sizeBytes: jsonData.length,
      schemaVersion: toVersion,
      notes:
          'Post-migration backup after successful upgrade to schema v$toVersion',
    );

    await _saveBackupInfo(info);

    if (kDebugMode) {
      debugPrint(
        '[Backup] Post-migration backup completed: ${info.formattedSize}',
      );
    }

    return info;
  }

  // ==========================================================================
  // C. التصدير والاستيراد اليدوي
  // ==========================================================================

  /// تصدير الجداول المهمة كـ JSON
  ///
  /// يمكن حفظ النتيجة في ملف أو إرسالها للمستخدم
  Future<String> exportToJson() async {
    if (kDebugMode) {
      debugPrint('[Backup] Exporting database to JSON...');
    }

    final jsonData = await _exportTablesAsJson();

    if (kDebugMode) {
      debugPrint('[Backup] Export completed: ${jsonData.length} characters');
    }

    return jsonData;
  }

  /// استيراد بيانات من JSON
  ///
  /// [jsonString] - سلسلة JSON تم تصديرها سابقاً بـ [exportToJson]
  /// [clearExisting] - حذف البيانات الموجودة قبل الاستيراد
  Future<Map<String, int>> importFromJson(
    String jsonString, {
    bool clearExisting = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[Backup] Importing database from JSON...');
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final importCounts = <String, int>{};

    // التحقق من إصدار التصدير
    final exportVersion = data['_meta']?['schemaVersion'] as int?;
    if (exportVersion != null && exportVersion > _db.schemaVersion) {
      throw StateError(
        'Backup schema version ($exportVersion) is newer than '
        'current schema version (${_db.schemaVersion}). '
        'Please update the app first.',
      );
    }

    await _db.transaction(() async {
      for (final tableName in _criticalTables) {
        final tableData = data[tableName] as List<dynamic>?;
        if (tableData == null || tableData.isEmpty) continue;

        if (clearExisting) {
          await _db.customStatement('DELETE FROM $tableName');
        }

        // Get the whitelist of allowed columns from the Drift schema
        final allowedColumns = _getAllowedColumns(tableName);

        int count = 0;
        for (final row in tableData) {
          try {
            final rowMap = row as Map<String, dynamic>;
            final columns = rowMap.keys.toList();

            // Validate columns against the schema whitelist
            if (allowedColumns != null) {
              final invalidColumns =
                  columns.where((c) => !allowedColumns.contains(c)).toList();
              if (invalidColumns.isNotEmpty) {
                debugPrint(
                  '[Backup] SECURITY: Rejected backup for table $tableName — '
                  'invalid column names: $invalidColumns',
                );
                throw ArgumentError(
                  'Backup contains invalid column names for table '
                  '$tableName: $invalidColumns',
                );
              }
            }

            final safeColumns = allowedColumns != null
                ? columns.where((c) => allowedColumns.contains(c)).toList()
                : columns;

            final placeholders = safeColumns.map((_) => '?').join(', ');
            final values = safeColumns.map((c) {
              final v = rowMap[c];
              if (v == null) return null;
              if (v is int) return v;
              if (v is double) return v;
              if (v is bool) return v ? 1 : 0;
              return v.toString();
            }).toList();

            await _db.customStatement(
              'INSERT OR REPLACE INTO $tableName (${safeColumns.join(', ')}) '
              'VALUES ($placeholders)',
              values,
            );
            count++;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[Backup] Import error in $tableName: $e');
            }
            // Re-throw ArgumentError (security violation) — don't swallow it
            if (e is ArgumentError) rethrow;
          }
        }

        importCounts[tableName] = count;
      }
    });

    if (kDebugMode) {
      debugPrint('[Backup] Import completed: $importCounts');
    }

    return importCounts;
  }

  /// حفظ تصدير JSON يدوي
  Future<BackupInfo> saveManualBackup({String? notes}) async {
    final backupId = _generateBackupId('manual');
    final jsonData = await _exportTablesAsJson();
    await storage.saveJsonBackup(backupId, jsonData);

    final info = BackupInfo(
      id: backupId,
      type: 'manual',
      createdAt: DateTime.now(),
      sizeBytes: jsonData.length,
      schemaVersion: _db.schemaVersion,
      notes: notes,
    );

    await _saveBackupInfo(info);
    return info;
  }

  // ==========================================================================
  // D. فحص السلامة
  // ==========================================================================

  /// فحص سلامة قاعدة البيانات
  ///
  /// يجري:
  /// 1. PRAGMA integrity_check - فحص البنية الداخلية
  /// 2. PRAGMA foreign_key_check - فحص المفاتيح الأجنبية
  ///
  /// يُرجع تقرير بالحالة والتفاصيل
  Future<DatabaseHealthReport> checkIntegrity() async {
    final messages = <String>[];
    var status = DatabaseHealthStatus.ok;
    var fkErrors = 0;

    try {
      // فحص البنية الداخلية
      final integrityResult = await _db
          .customSelect('PRAGMA integrity_check', readsFrom: {})
          .get();

      for (final row in integrityResult) {
        final msg = row.read<String>('integrity_check');
        if (msg != 'ok') {
          messages.add('Integrity: $msg');
          status = DatabaseHealthStatus.corrupted;
        }
      }

      if (status == DatabaseHealthStatus.ok) {
        messages.add('Integrity check: OK');
      }
    } catch (e) {
      messages.add('Integrity check failed: $e');
      status = DatabaseHealthStatus.corrupted;
    }

    try {
      // فحص المفاتيح الأجنبية
      final fkResult = await _db
          .customSelect('PRAGMA foreign_key_check', readsFrom: {})
          .get();

      fkErrors = fkResult.length;
      if (fkErrors > 0) {
        messages.add('Foreign key violations: $fkErrors');
        if (status != DatabaseHealthStatus.corrupted) {
          status = DatabaseHealthStatus.warnings;
        }
      } else {
        messages.add('Foreign key check: OK');
      }
    } catch (e) {
      messages.add('Foreign key check failed: $e');
      if (status != DatabaseHealthStatus.corrupted) {
        status = DatabaseHealthStatus.warnings;
      }
    }

    // فحص حجم قاعدة البيانات
    try {
      final pageCount = await _db
          .customSelect('PRAGMA page_count', readsFrom: {})
          .getSingle();
      final pageSize = await _db
          .customSelect('PRAGMA page_size', readsFrom: {})
          .getSingle();

      final pages = pageCount.read<int>('page_count');
      final size = pageSize.read<int>('page_size');
      final totalBytes = pages * size;
      final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);
      messages.add('Database size: $totalMB MB ($pages pages)');
    } catch (e) {
      messages.add('Size check failed: $e');
    }

    final report = DatabaseHealthReport(
      status: status,
      messages: messages,
      foreignKeyErrors: fkErrors,
      timestamp: DateTime.now(),
    );

    if (kDebugMode) {
      debugPrint('[Backup] Health check: $report');
      for (final msg in messages) {
        debugPrint('  - $msg');
      }
    }

    return report;
  }

  /// فحص السلامة ومحاولة الاسترداد التلقائي إذا كانت تالفة
  Future<DatabaseHealthReport> checkAndAutoRecover() async {
    final report = await checkIntegrity();

    if (report.status == DatabaseHealthStatus.corrupted) {
      if (kDebugMode) {
        debugPrint('[Backup] Database corrupted! Attempting auto-recovery...');
      }

      try {
        await recoverFromCorruption();
        // إعادة الفحص بعد الاسترداد
        return checkIntegrity();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Backup] Auto-recovery failed: $e');
        }
      }
    }

    return report;
  }

  // ==========================================================================
  // E. الاسترداد
  // ==========================================================================

  /// استعادة من نسخة احتياطية محددة
  Future<void> recoverFromBackup(String backupId) async {
    if (kDebugMode) {
      debugPrint('[Backup] Recovering from backup: $backupId');
    }

    // محاولة تحميل JSON أولاً
    final jsonData = await storage.loadJsonBackup(backupId);
    if (jsonData != null) {
      await importFromJson(jsonData, clearExisting: true);
      if (kDebugMode) {
        debugPrint('[Backup] Recovery from JSON backup completed');
      }
      return;
    }

    // إذا لم يوجد JSON، حاول استعادة ملف SQLite (native فقط)
    try {
      await storage.restoreDatabaseFile(backupId);
      if (kDebugMode) {
        debugPrint('[Backup] Recovery from SQLite backup completed');
      }
    } catch (e) {
      throw StateError('Backup not found or corrupted: $backupId - $e');
    }
  }

  /// اكتشاف التلف والاسترداد من أحدث نسخة سليمة
  Future<void> recoverFromCorruption() async {
    if (kDebugMode) {
      debugPrint('[Backup] Starting corruption recovery...');
    }

    // الحصول على قائمة النسخ الاحتياطية
    final backups = await listBackups();

    if (backups.isEmpty) {
      throw StateError(
        'No backups available for recovery. '
        'Database may need manual intervention.',
      );
    }

    // محاولة الاسترداد من أحدث نسخة
    for (final backup in backups) {
      try {
        if (kDebugMode) {
          debugPrint(
            '[Backup] Trying backup: ${backup.id} '
            '(${backup.createdAt.toIso8601String()})',
          );
        }

        await recoverFromBackup(backup.id);

        // التحقق من السلامة بعد الاسترداد
        final report = await checkIntegrity();
        if (report.isHealthy) {
          if (kDebugMode) {
            debugPrint('[Backup] Recovery successful from: ${backup.id}');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Backup] Backup ${backup.id} failed: $e');
        }
        continue;
      }
    }

    throw StateError('All backup recovery attempts failed');
  }

  // ==========================================================================
  // إدارة النسخ الاحتياطية
  // ==========================================================================

  /// الحصول على قائمة النسخ الاحتياطية المتاحة
  Future<List<BackupInfo>> listBackups() async {
    final metadata = await storage.loadBackupMetadata();
    final backupsList = metadata['backups'] as List<dynamic>?;
    if (backupsList == null) return [];

    final backups = backupsList
        .map((b) => BackupInfo.fromJson(b as Map<String, dynamic>))
        .toList();

    // ترتيب: الأحدث أولاً
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// حذف نسخة احتياطية محددة
  Future<void> deleteBackup(String backupId) async {
    await storage.deleteBackupData(backupId);
    await _removeBackupInfo(backupId);

    if (kDebugMode) {
      debugPrint('[Backup] Deleted backup: $backupId');
    }
  }

  /// تنظيف جميع النسخ الاحتياطية
  Future<void> clearAllBackups() async {
    final backups = await listBackups();
    for (final backup in backups) {
      await storage.deleteBackupData(backup.id);
    }
    await storage.saveBackupMetadata({'backups': []});

    if (kDebugMode) {
      debugPrint('[Backup] All backups cleared');
    }
  }

  /// التخلص من الموارد
  void dispose() {
    stopPeriodicBackup();
  }

  // ==========================================================================
  // مساعدات داخلية
  // ==========================================================================

  /// تصدير الجداول المهمة كـ JSON
  Future<String> _exportTablesAsJson() async {
    final data = <String, dynamic>{
      '_meta': {
        'exportedAt': DateTime.now().toIso8601String(),
        'schemaVersion': _db.schemaVersion,
        'tables': _criticalTables,
      },
    };

    for (final tableName in _criticalTables) {
      try {
        final rows = await _db
            .customSelect('SELECT * FROM $tableName', readsFrom: {})
            .get();

        if (rows.isEmpty) continue;

        final tableRows = <Map<String, dynamic>>[];
        for (final row in rows) {
          tableRows.add(row.data);
        }

        data[tableName] = tableRows;
      } catch (e) {
        // الجدول قد لا يكون موجوداً (في حال schema قديم)
        if (kDebugMode) {
          debugPrint('[Backup] Skipping table $tableName: $e');
        }
      }
    }

    return jsonEncode(data);
  }

  /// توليد معرف نسخة احتياطية
  String _generateBackupId(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'backup_${type}_$timestamp';
  }

  /// حفظ معلومات نسخة احتياطية في البيانات الوصفية
  Future<void> _saveBackupInfo(BackupInfo info) async {
    final metadata = await storage.loadBackupMetadata();
    final backups = (metadata['backups'] as List<dynamic>?)?.toList() ?? [];
    backups.add(info.toJson());
    metadata['backups'] = backups;
    await storage.saveBackupMetadata(metadata);
  }

  /// إزالة معلومات نسخة احتياطية من البيانات الوصفية
  Future<void> _removeBackupInfo(String backupId) async {
    final metadata = await storage.loadBackupMetadata();
    final backups = (metadata['backups'] as List<dynamic>?)?.toList() ?? [];
    backups.removeWhere((b) => (b as Map<String, dynamic>)['id'] == backupId);
    metadata['backups'] = backups;
    await storage.saveBackupMetadata(metadata);
  }

  /// Returns the set of allowed column names for a given table from the Drift
  /// schema.  Returns `null` if the table is not found (caller should reject
  /// or skip).
  Set<String>? _getAllowedColumns(String tableName) {
    for (final table in _db.allTables) {
      if (table.actualTableName == tableName) {
        return table.$columns.map((c) => c.name).toSet();
      }
    }
    return null;
  }

  /// تدوير النسخ الاحتياطية (حذف القديمة عند تجاوز الحد)
  Future<void> _rotateBackups(String type) async {
    final allBackups = await listBackups();
    final typeBackups = allBackups.where((b) => b.type == type).toList();

    if (typeBackups.length <= maxBackups) return;

    // حذف النسخ الأقدم
    final toDelete = typeBackups.sublist(maxBackups);
    for (final backup in toDelete) {
      await deleteBackup(backup.id);
    }

    if (kDebugMode) {
      debugPrint('[Backup] Rotated ${toDelete.length} old $type backups');
    }
  }
}
