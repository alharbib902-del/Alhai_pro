import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/driver_auth_datasource.dart';
import '../features/deliveries/data/delivery_datasource.dart';
import '../features/deliveries/data/order_datasource.dart';
import '../features/shifts/data/shifts_datasource.dart';
import '../features/proof/data/proof_datasource.dart';
import '../features/chat/data/chat_datasource.dart';
import '../features/earnings/data/earnings_datasource.dart';

final locator = GetIt.instance;

void configureDependencies() {
  locator.allowReassignment = true;

  // Register Supabase client
  try {
    final client = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(client);
  } catch (_) {
    // Supabase not initialized - offline mode
  }

  // Datasources
  if (locator.isRegistered<SupabaseClient>()) {
    final client = locator<SupabaseClient>();

    locator.registerLazySingleton(() => DriverAuthDatasource(client));
    locator.registerLazySingleton(() => DeliveryDatasource(client));
    locator.registerLazySingleton(() => OrderDatasource(client));
    locator.registerLazySingleton(() => ShiftsDatasource(client));
    locator.registerLazySingleton(() => ProofDatasource(client));
    locator.registerLazySingleton(() => ChatDatasource(client));
    locator.registerLazySingleton(() => EarningsDatasource(client));
  }

  locator.allowReassignment = false;
}
