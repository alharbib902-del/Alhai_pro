import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// TODO: migrate to sqlcipher_flutter_libs for real at-rest encryption.
// Plain sqlite3 does not support PRAGMA key — the statement silently does nothing.
// See: https://pub.dev/packages/sqlcipher_flutter_libs

/// اتصال Native (Android, iOS, Desktop)
QueryExecutor openNativeConnection({String? dbName}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'));

    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Enable WAL for better performance
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA synchronous=NORMAL');
        db.execute('PRAGMA foreign_keys=ON');
      },
    );
  });
}
