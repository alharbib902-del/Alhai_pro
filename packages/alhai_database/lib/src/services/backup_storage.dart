/// واجهة تخزين النسخ الاحتياطية
///
/// تستخدم conditional imports لاختيار التنفيذ المناسب:
/// - Native: نسخ ملفات SQLite في مجلد النسخ الاحتياطية
/// - Web: تخزين في IndexedDB
export 'backup_storage_native.dart'
    if (dart.library.html) 'backup_storage_web.dart';
