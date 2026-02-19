/// Test helpers for setting up dependencies
/// 
/// TODO: This file needs to be updated once repositories are properly implemented
library;

import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}

final getIt = GetIt.instance;

/// Setup test dependencies
void setupTestDependencies() {
  // Reset GetIt
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.reset();
  }
  
  // Register mocks
  final mockAppDatabase = MockAppDatabase();
  
  getIt.registerSingleton<AppDatabase>(mockAppDatabase);
}

/// Tear down test dependencies
void tearDownTestDependencies() {
  getIt.reset();
}
