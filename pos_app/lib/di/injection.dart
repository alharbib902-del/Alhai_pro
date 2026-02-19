import 'package:alhai_core/alhai_core.dart' as core;

import '../data/local/app_database.dart';
import '../data/repositories/local_products_repository.dart';
import '../data/repositories/local_categories_repository.dart';

/// GetIt instance - uses the same instance as alhai_core
final getIt = core.getIt;

/// Dependency Injection Configuration
///
/// Uses alhai_core's getIt for core dependencies
/// and registers local POS app dependencies.

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

  // Disable reassignment after setup
  getIt.allowReassignment = false;
}

/// Get the local database instance
AppDatabase get appDatabase => getIt<AppDatabase>();
