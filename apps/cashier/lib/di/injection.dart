import 'package:flutter/foundation.dart';
import 'package:alhai_core/alhai_core.dart' as core;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import '../core/services/audit_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';

/// GetIt instance - uses the same instance as alhai_core
final getIt = core.getIt;

/// Dependency Injection Configuration
///
/// Uses alhai_core's getIt for core dependencies
/// and registers local Cashier app dependencies.

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

  // Override core repositories with local (offline) implementations
  final db = getIt<AppDatabase>();

  // Replace core ProductsRepository with local one (offline-first)
  getIt.registerLazySingleton<core.ProductsRepository>(
    () => LocalProductsRepository(db),
  );

  // Replace core CategoriesRepository with local one (offline-first)
  getIt.registerLazySingleton<core.CategoriesRepository>(
    () => LocalCategoriesRepository(db),
  );

  // Register AuditService
  getIt.registerLazySingleton<AuditService>(() => AuditService(db));

  // Register OfflineQueueService (singleton -- encrypted queue for POS ops)
  getIt.registerLazySingleton<OfflineQueueService>(
    () => OfflineQueueService.instance,
  );

  // Register ConnectivityService (singleton -- monitors network state)
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService.instance,
  );

  // Initialize connectivity monitoring
  await ConnectivityService.instance.initialize();

  // Register Supabase client (if initialized)
  try {
    final supabase = Supabase.instance.client;
    if (!getIt.isRegistered<SupabaseClient>()) {
      getIt.registerSingleton<SupabaseClient>(supabase);
    }
    if (kDebugMode) {
      debugPrint('✅ [DI] SupabaseClient registered in GetIt — sync will be ACTIVE');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [DI] SupabaseClient NOT registered — sync DISABLED! Error: $e');
    }
  }

  // Disable reassignment after setup
  getIt.allowReassignment = false;
}

/// Get the local database instance
AppDatabase get appDatabase => getIt<AppDatabase>();
