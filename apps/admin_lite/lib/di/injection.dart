/// Admin Lite Dependency Injection
///
/// Lite DI - read-focused, pull-on-demand sync.
/// Registers only the dependencies needed for monitoring, reports, and AI.
/// Does NOT register write-heavy repos (sales, purchases).
library;

import 'package:alhai_core/alhai_core.dart' as core;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_database/alhai_database.dart';

import '../core/services/sentry_service.dart' as sentry;

/// GetIt instance - uses the same instance as alhai_core
final getIt = core.getIt;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> configureDependencies({String? environment}) async {
  // Allow reassignment so we can override core repos with local ones
  getIt.allowReassignment = true;

  // Initialize core dependencies first
  await core.configureDependencies(environment: environment);

  // Register local database (cache)
  if (!getIt.isRegistered<AppDatabase>()) {
    final database = AppDatabase();
    getIt.registerSingleton<AppDatabase>(database);
  }

  // Override core repositories with local (read-focused) implementations
  final db = getIt<AppDatabase>();

  // Replace core ProductsRepository with local one (read-focused)
  getIt.registerLazySingleton<core.ProductsRepository>(
    () => LocalProductsRepository(db),
  );

  // Replace core CategoriesRepository with local one (read-focused)
  getIt.registerLazySingleton<core.CategoriesRepository>(
    () => LocalCategoriesRepository(db),
  );

  // Register Supabase client (required for Lite - auth & sync)
  try {
    final supabase = Supabase.instance.client;
    if (!getIt.isRegistered<SupabaseClient>()) {
      getIt.registerSingleton<SupabaseClient>(supabase);
    }
  } catch (e, st) {
    sentry.reportError(e, stackTrace: st, hint: 'injection: Supabase registration');
    // Supabase not initialized - offline mode only
  }

  // NOTE: Admin Lite does NOT register write-heavy repos:
  // - No SalesRepository (read-only from sync)
  // - No PurchasesRepository (read-only from sync)
  // - No CartRepository (no POS functionality)

  // Disable reassignment after setup
  getIt.allowReassignment = false;
}

/// Get the local database instance
AppDatabase get appDatabase => getIt<AppDatabase>();
