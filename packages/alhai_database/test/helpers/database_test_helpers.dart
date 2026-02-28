import 'package:drift/native.dart';
import 'package:alhai_database/alhai_database.dart';

/// Create an in-memory database for testing
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
