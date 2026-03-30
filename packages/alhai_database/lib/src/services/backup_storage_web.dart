import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

/// تخزين النسخ الاحتياطية على الويب
///
/// يستخدم localStorage للبيانات الوصفية والنسخ الصغيرة
/// و IndexedDB للنسخ الكبيرة (أكثر من 4MB)

/// اسم قاعدة بيانات IndexedDB للنسخ الاحتياطية
const _idbName = 'alhai_backups';
const _idbStoreName = 'backups';
const _idbVersion = 1;
const _metadataKey = 'db_backup_metadata';

/// فتح IndexedDB للنسخ الاحتياطية
Future<JSObject> _openIdb() async {
  final indexedDB = globalContext['indexedDB'] as JSObject;
  final request = indexedDB.callMethod<JSObject>(
    'open'.toJS,
    _idbName.toJS,
    _idbVersion.toJS,
  );

  // معالجة onupgradeneeded لإنشاء object store
  request['onupgradeneeded'] = ((JSObject event) {
    final db = (event['target'] as JSObject)['result'] as JSObject;
    final storeNames = db['objectStoreNames'] as JSObject;
    final contains = storeNames.callMethod<JSBoolean>(
      'contains'.toJS,
      _idbStoreName.toJS,
    );
    if (!contains.toDart) {
      db.callMethod<JSObject>('createObjectStore'.toJS, _idbStoreName.toJS);
    }
  }).toJS;

  // انتظار فتح القاعدة
  final completer = _IdbCompleter();
  request['onsuccess'] = ((JSObject event) {
    completer.complete((event['target'] as JSObject)['result'] as JSObject);
  }).toJS;
  request['onerror'] = ((JSObject event) {
    completer.completeError('Failed to open IndexedDB: $_idbName');
  }).toJS;

  return completer.future;
}

/// مساعد لتحويل IndexedDB callbacks إلى Future
class _IdbCompleter {
  JSObject? _result;
  Object? _error;
  bool _completed = false;
  final List<void Function()> _callbacks = [];

  void complete(JSObject result) {
    _result = result;
    _completed = true;
    for (final cb in _callbacks) {
      cb();
    }
  }

  void completeError(Object error) {
    _error = error;
    _completed = true;
    for (final cb in _callbacks) {
      cb();
    }
  }

  Future<JSObject> get future async {
    if (_completed) {
      if (_error != null) throw _error!;
      return _result!;
    }
    // انتظار بسيط بحلقة polling
    while (!_completed) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    if (_error != null) throw _error!;
    return _result!;
  }
}

/// حفظ بيانات في IndexedDB
Future<void> _idbPut(String key, JSAny? value) async {
  final db = await _openIdb();
  final tx = db.callMethod<JSObject>(
    'transaction'.toJS,
    _idbStoreName.toJS,
    'readwrite'.toJS,
  );
  final store = tx.callMethod<JSObject>('objectStore'.toJS, _idbStoreName.toJS);
  store.callMethod<JSObject>('put'.toJS, value, key.toJS);

  // انتظار إكمال المعاملة
  await Future.delayed(const Duration(milliseconds: 50));
  db.callMethod<JSAny?>('close'.toJS);
}

/// قراءة بيانات من IndexedDB
Future<JSAny?> _idbGet(String key) async {
  final db = await _openIdb();
  final tx = db.callMethod<JSObject>(
    'transaction'.toJS,
    _idbStoreName.toJS,
    'readonly'.toJS,
  );
  final store = tx.callMethod<JSObject>('objectStore'.toJS, _idbStoreName.toJS);
  final request = store.callMethod<JSObject>('get'.toJS, key.toJS);

  // انتظار النتيجة عبر onsuccess
  JSAny? result;
  bool done = false;

  request['onsuccess'] = ((JSObject event) {
    result = (event['target'] as JSObject)['result'];
    done = true;
  }).toJS;
  request['onerror'] = ((JSObject _) {
    done = true;
  }).toJS;

  while (!done) {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  db.callMethod<JSAny?>('close'.toJS);
  return result;
}

/// حذف بيانات من IndexedDB
Future<void> _idbDelete(String key) async {
  final db = await _openIdb();
  final tx = db.callMethod<JSObject>(
    'transaction'.toJS,
    _idbStoreName.toJS,
    'readwrite'.toJS,
  );
  final store = tx.callMethod<JSObject>('objectStore'.toJS, _idbStoreName.toJS);
  store.callMethod<JSObject>('delete'.toJS, key.toJS);

  await Future.delayed(const Duration(milliseconds: 50));
  db.callMethod<JSAny?>('close'.toJS);
}

/// الحصول على جميع المفاتيح من IndexedDB
Future<List<String>> _idbGetAllKeys() async {
  final db = await _openIdb();
  final tx = db.callMethod<JSObject>(
    'transaction'.toJS,
    _idbStoreName.toJS,
    'readonly'.toJS,
  );
  final store = tx.callMethod<JSObject>('objectStore'.toJS, _idbStoreName.toJS);
  final request = store.callMethod<JSObject>('getAllKeys'.toJS);

  List<String> keys = [];
  bool done = false;

  request['onsuccess'] = ((JSObject event) {
    final result = (event['target'] as JSObject)['result'];
    if (result != null) {
      final jsArray = result as JSArray;
      final arrayLength = (jsArray.getProperty('length'.toJS) as JSNumber).toDartInt;
      keys = List.generate(
        arrayLength,
        (i) => (jsArray.getProperty(i.toJS) as JSString).toDart,
      );
    }
    done = true;
  }).toJS;
  request['onerror'] = ((JSObject _) {
    done = true;
  }).toJS;

  while (!done) {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  db.callMethod<JSAny?>('close'.toJS);
  return keys;
}

/// الوصول إلى localStorage
JSObject get _localStorage {
  return (globalContext['window'] as JSObject)['localStorage'] as JSObject;
}

/// حفظ نسخة احتياطية كسلسلة JSON في IndexedDB
Future<void> saveBackupData(String backupId, List<int> data) async {
  // تحويل البيانات إلى Base64 لتخزينها في IndexedDB
  final base64Data = base64Encode(data);
  await _idbPut('backup_$backupId', base64Data.toJS);

  if (kDebugMode) {
    debugPrint('[Backup] Web: saved ${data.length} bytes to IndexedDB');
  }
}

/// تحميل نسخة احتياطية
Future<List<int>?> loadBackupData(String backupId) async {
  final result = await _idbGet('backup_$backupId');
  if (result == null) return null;

  final base64Data = (result as JSString).toDart;
  return base64Decode(base64Data);
}

/// حذف نسخة احتياطية
Future<void> deleteBackupData(String backupId) async {
  await _idbDelete('backup_$backupId');
  await _idbDelete('json_$backupId');
}

/// الحصول على قائمة النسخ الاحتياطية المتاحة
Future<List<String>> listBackupIds() async {
  final keys = await _idbGetAllKeys();
  final backupKeys = keys
      .where((k) => k.startsWith('backup_'))
      .map((k) => k.replaceFirst('backup_', ''))
      .toList();

  // ترتيب بالعكس (الأحدث أولاً بناءً على الاسم الذي يحتوي timestamp)
  backupKeys.sort((a, b) => b.compareTo(a));
  return backupKeys;
}

/// حفظ بيانات JSON
Future<void> saveJsonBackup(String backupId, String jsonData) async {
  await _idbPut('json_$backupId', jsonData.toJS);
}

/// تحميل بيانات JSON
Future<String?> loadJsonBackup(String backupId) async {
  final result = await _idbGet('json_$backupId');
  if (result == null) return null;
  return (result as JSString).toDart;
}

/// حفظ البيانات الوصفية للنسخ الاحتياطية
Future<void> saveBackupMetadata(Map<String, dynamic> metadata) async {
  try {
    _localStorage.callMethod<JSAny?>(
      'setItem'.toJS,
      _metadataKey.toJS,
      jsonEncode(metadata).toJS,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Backup] Web: Failed to save metadata: $e');
    }
  }
}

/// تحميل البيانات الوصفية
Future<Map<String, dynamic>> loadBackupMetadata() async {
  try {
    final result = _localStorage.callMethod<JSAny?>(
      'getItem'.toJS,
      _metadataKey.toJS,
    );
    if (result == null) return {};
    final str = (result as JSString).toDart;
    return jsonDecode(str) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

/// الحصول على حجم النسخة الاحتياطية بالبايت (تقديري)
Future<int> getBackupSize(String backupId) async {
  final result = await _idbGet('backup_$backupId');
  if (result == null) return 0;
  // الحجم التقريبي: طول Base64 * 0.75
  return ((result as JSString).toDart.length * 0.75).round();
}

/// نسخ ملف قاعدة البيانات الحالية - غير مدعوم على الويب
/// على الويب نستخدم exportToJson بدلاً من نسخ الملف
Future<void> copyDatabaseFile(String backupId, {String? dbName}) async {
  // على الويب لا يمكن نسخ ملف OPFS مباشرة
  // يجب استخدام exportToJson من DatabaseBackupService
  if (kDebugMode) {
    debugPrint('[Backup] Web: copyDatabaseFile not supported, use exportToJson');
  }
}

/// استعادة ملف قاعدة البيانات - غير مدعوم على الويب
/// على الويب نستخدم importFromJson بدلاً من استعادة الملف
Future<void> restoreDatabaseFile(String backupId, {String? dbName}) async {
  if (kDebugMode) {
    debugPrint('[Backup] Web: restoreDatabaseFile not supported, use importFromJson');
  }
}
