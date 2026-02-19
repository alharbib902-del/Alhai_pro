import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/security/secure_storage_service.dart';

/// اتصال Native مع التشفير (Android, iOS, Desktop)
QueryExecutor openNativeConnection({String? dbName}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'));
    
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    
    // الحصول على مفتاح التشفير
    final encryptionKey = await SecureStorageService.getDatabaseKey();
    
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // تفعيل التشفير باستخدام SQLCipher
        db.execute("PRAGMA key = '$encryptionKey'");
      },
    );
  });
}
