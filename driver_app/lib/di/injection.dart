import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/local_cache_service.dart';
import '../core/services/sentry_service.dart';
import '../features/auth/data/driver_auth_datasource.dart';
import '../features/deliveries/data/delivery_datasource.dart';
import '../features/shifts/data/shifts_datasource.dart';
import '../features/proof/data/proof_datasource.dart';
import '../features/chat/data/chat_datasource.dart';
import '../features/earnings/data/earnings_datasource.dart';

final locator = GetIt.instance;

void configureDependencies() {
  locator.allowReassignment = true;

  // Local cache – registered unconditionally so it is available offline.
  locator.registerLazySingleton<LocalCacheService>(() => LocalCacheService());

  // Register Supabase client
  try {
    final client = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(client);
  } catch (e, st) {
    reportError(
      e,
      stackTrace: st,
      hint: 'DI: Supabase not initialized - offline mode',
    );
    if (kDebugMode)
      debugPrint('Supabase not initialized - running in offline mode');
  }

  // Datasources
  if (locator.isRegistered<SupabaseClient>()) {
    final client = locator<SupabaseClient>();
    final cache = locator<LocalCacheService>();

    locator.registerLazySingleton(() => DriverAuthDatasource(client));
    locator.registerLazySingleton(() => DeliveryDatasource(client, cache));
    locator.registerLazySingleton(() => ShiftsDatasource(client));
    locator.registerLazySingleton(() => ProofDatasource(client));
    locator.registerLazySingleton(() => ChatDatasource(client));
    locator.registerLazySingleton(() => EarningsDatasource(client, cache));
  }

  locator.allowReassignment = false;
}
