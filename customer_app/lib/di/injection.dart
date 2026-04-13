import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/sentry_service.dart';

import '../features/auth/data/auth_datasource.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/stores/data/stores_datasource.dart';
import '../features/stores/data/stores_repository_impl.dart';
import '../features/catalog/data/products_datasource.dart';
import '../features/catalog/data/products_repository_impl.dart';
import '../features/catalog/data/categories_datasource.dart';
import '../features/catalog/data/categories_repository_impl.dart';
import '../features/checkout/data/orders_datasource.dart';
import '../features/checkout/data/orders_repository_impl.dart';
import '../features/addresses/data/addresses_datasource.dart';
import '../features/addresses/data/addresses_repository_impl.dart';
import '../features/tracking/data/delivery_datasource.dart';
import '../features/tracking/data/delivery_repository_impl.dart';

final locator = GetIt.instance;

void configureDependencies() {
  // Allow reassignment during setup
  locator.allowReassignment = true;

  // Register Supabase client
  try {
    final client = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(client);
  } catch (e, stack) {
    if (kDebugMode) debugPrint('Supabase not initialized: $e');
    reportError(e, stackTrace: stack, hint: 'DI: Supabase not initialized - offline mode');
  }

  // Datasources
  if (locator.isRegistered<SupabaseClient>()) {
    final client = locator<SupabaseClient>();

    locator.registerLazySingleton(() => AuthDatasource(client));
    locator.registerLazySingleton(() => StoresDatasource(client));
    locator.registerLazySingleton(() => ProductsDatasource(client));
    locator.registerLazySingleton(() => CategoriesDatasource(client));
    locator.registerLazySingleton(() => OrdersDatasource(client));
    locator.registerLazySingleton(() => AddressesDatasource(client));
    locator.registerLazySingleton(() => DeliveryDatasource(client));

    // Repositories
    locator.registerLazySingleton(
      () => AuthRepositoryImpl(locator<AuthDatasource>()),
    );
    locator.registerLazySingleton(
      () => StoresRepositoryImpl(locator<StoresDatasource>()),
    );
    locator.registerLazySingleton(
      () => ProductsRepositoryImpl(locator<ProductsDatasource>()),
    );
    locator.registerLazySingleton(
      () => CategoriesRepositoryImpl(locator<CategoriesDatasource>()),
    );
    locator.registerLazySingleton(
      () => OrdersRepositoryImpl(locator<OrdersDatasource>()),
    );
    locator.registerLazySingleton(
      () => AddressesRepositoryImpl(locator<AddressesDatasource>()),
    );
    locator.registerLazySingleton(
      () => DeliveryRepositoryImpl(locator<DeliveryDatasource>()),
    );
  }

  locator.allowReassignment = false;
}
