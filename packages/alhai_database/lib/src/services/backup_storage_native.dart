import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// تخزين النسخ الاحتياطية على النظام المحلي (Android, iOS, Desktop)
///
/// يخزن النسخ كملفات .sqlite في مجلد النسخ الاحتياطية
/// ويخزن بيانات JSON كملفات .json

/// الحصول على مجلد النسخ الاحتياطية
Future<Directory> _getBackupDir() async {
  final appDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory(p.join(appDir.path, 'alhai_pos', 'backups'));
  if (!backupDir.existsSync()) {
    backupDir.createSync(recursive: true);
  }
  return backupDir;
}

/// حفظ نسخة احتياطية من ملف قاعدة البيانات
Future<void> saveBackupData(String backupId, List<int> data) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.sqlite'));
  await file.writeAsBytes(data, flush: true);
  if (kDebugMode) {
    debugPrint('[Backup] Native: saved ${data.length} bytes to ${file.path}');
  }
}

/// تحميل نسخة احتياطية
Future<List<int>?> loadBackupData(String backupId) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.sqlite'));
  if (!file.existsSync()) return null;
  return file.readAsBytes();
}

/// حذف نسخة احتياطية
Future<void> deleteBackupData(String backupId) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.sqlite'));
  if (file.existsSync()) {
    await file.delete();
  }
  // حذف ملف JSON المرتبط أيضاً
  final jsonFile = File(p.join(dir.path, '$backupId.json'));
  if (jsonFile.existsSync()) {
    await jsonFile.delete();
  }
}

/// الحصول على قائمة النسخ الاحتياطية المتاحة
Future<List<String>> listBackupIds() async {
  final dir = await _getBackupDir();
  if (!dir.existsSync()) return [];

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sqlite'))
      .toList();

  // ترتيب حسب تاريخ التعديل (الأحدث أولاً)
  files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  return files.map((f) => p.basenameWithoutExtension(f.path)).toList();
}

/// حفظ بيانات JSON
Future<void> saveJsonBackup(String backupId, String jsonData) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.json'));
  await file.writeAsString(jsonData, flush: true);
}

/// تحميل بيانات JSON
Future<String?> loadJsonBackup(String backupId) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.json'));
  if (!file.existsSync()) return null;
  return file.readAsString();
}

/// حفظ البيانات الوصفية للنسخ الاحتياطية
Future<void> saveBackupMetadata(Map<String, dynamic> metadata) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '_metadata.json'));
  await file.writeAsString(jsonEncode(metadata), flush: true);
}

/// تحميل البيانات الوصفية
Future<Map<String, dynamic>> loadBackupMetadata() async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '_metadata.json'));
  if (!file.existsSync()) return {};
  try {
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

/// الحصول على حجم النسخة الاحتياطية بالبايت
Future<int> getBackupSize(String backupId) async {
  final dir = await _getBackupDir();
  final file = File(p.join(dir.path, '$backupId.sqlite'));
  if (!file.existsSync()) return 0;
  return file.lengthSync();
}

/// نسخ ملف قاعدة البيانات الحالية كنسخة احتياطية
Future<void> copyDatabaseFile(String backupId, {String? dbName}) async {
  final appDir = await getApplicationDocumentsDirectory();
  final dbFile = File(
    p.join(appDir.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'),
  );

  if (!dbFile.existsSync()) {
    throw StateError('Database file not found: ${dbFile.path}');
  }

  final backupDir = await _getBackupDir();
  final backupFile = File(p.join(backupDir.path, '$backupId.sqlite'));
  await dbFile.copy(backupFile.path);

  if (kDebugMode) {
    final size = backupFile.lengthSync();
    debugPrint(
      '[Backup] Native: copied DB file (${(size / 1024).toStringAsFixed(1)} KB)',
    );
  }
}

/// استعادة ملف قاعدة البيانات من نسخة احتياطية
Future<void> restoreDatabaseFile(String backupId, {String? dbName}) async {
  final backupDir = await _getBackupDir();
  final backupFile = File(p.join(backupDir.path, '$backupId.sqlite'));

  if (!backupFile.existsSync()) {
    throw StateError('Backup file not found: ${backupFile.path}');
  }

  final appDir = await getApplicationDocumentsDirectory();
  final dbFile = File(
    p.join(appDir.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'),
  );

  // نسخ النسخة الاحتياطية فوق الملف الحالي
  await backupFile.copy(dbFile.path);

  if (kDebugMode) {
    debugPrint('[Backup] Native: restored DB from $backupId');
  }
}
