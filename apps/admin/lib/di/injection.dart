/// Admin Dependency Injection Configuration
///
/// Uses alhai_core's getIt for core dependencies
/// and registers local Admin app dependencies.
/// Admin is online-first but still has local fallback.
library;

import 'package:flutter/foundation.dart';
import 'package:alhai_core/alhai_core.dart' as core;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_database/alhai_database.dart';

/// GetIt instance - uses the same instance as alhai_core
final getIt = core.getIt;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> configureDependencies({String? environment}) async {
  // Allow reassignment so we can override core repos with local ones
  getIt.allowReassignment = true;

  // Initialize core dependencies first
  await core.configureDependencies(environment: environment);

  // Register local database
  if (!getIt.isRegistered<AppDatabase>()) {
    final database = AppDatabase();
    getIt.registerSingleton<AppDatabase>(database);
  }

  // Override core repositories with local (offline-capable) implementations
  final db = getIt<AppDatabase>();

  // Replace core ProductsRepository with local one
  getIt.registerLazySingleton<core.ProductsRepository>(
    () => LocalProductsRepository(db),
  );

  // Replace core CategoriesRepository with local one
  getIt.registerLazySingleton<core.CategoriesRepository>(
    () => LocalCategoriesRepository(db),
  );

  // Register Supabase client (required for admin - online-first)
  try {
    final supabase = Supabase.instance.client;
    if (!getIt.isRegistered<SupabaseClient>()) {
      getIt.registerSingleton<SupabaseClient>(supabase);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Warning: Supabase not initialized for Admin. '
        'Some features may not work. Error: $e',
      );
    }
  }

  // Disable reassignment after setup
  getIt.allowReassignment = false;
}

/// Get the local database instance
AppDatabase get appDatabase => getIt<AppDatabase>();
