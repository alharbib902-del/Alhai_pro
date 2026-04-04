/// Riverpod providers for core dependencies.
///
/// This file defines Riverpod equivalents for all GetIt registrations,
/// enabling gradual migration from GetIt to pure Riverpod DI.
///
/// Migration guide:
///   OLD: final repo = getIt<ProductsRepository>();
///   NEW: final repo = ref.read(productsRepositoryProvider);
///
/// Providers marked with `throw UnimplementedError(...)` need their
/// corresponding Impl classes created before they can be used.
/// Override them in ProviderScope when ready.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Networking
import '../networking/api_dio_holder.dart';
import '../networking/interceptors/auth_interceptor.dart';

// Local DataSources
import '../datasources/local/auth_local_datasource.dart';

// Remote DataSources (abstract contracts)
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/remote/products_remote_datasource.dart';
import '../datasources/remote/categories_remote_datasource.dart';
import '../datasources/remote/orders_remote_datasource.dart';
import '../datasources/remote/delivery_remote_datasource.dart';
import '../datasources/remote/addresses_remote_datasource.dart';
import '../datasources/remote/stores_remote_datasource.dart';
import '../datasources/remote/inventory_remote_datasource.dart';
import '../datasources/remote/suppliers_remote_datasource.dart';
import '../datasources/remote/purchases_remote_datasource.dart';
import '../datasources/remote/debts_remote_datasource.dart';
import '../datasources/remote/reports_remote_datasource.dart';
import '../datasources/remote/analytics_remote_datasource.dart';

// Repositories (abstract contracts)
import '../repositories/auth_repository.dart';
import '../repositories/products_repository.dart';
import '../repositories/categories_repository.dart';
import '../repositories/orders_repository.dart';
import '../repositories/delivery_repository.dart';
import '../repositories/addresses_repository.dart';
import '../repositories/stores_repository.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/suppliers_repository.dart';
import '../repositories/purchases_repository.dart';
import '../repositories/debts_repository.dart';
import '../repositories/reports_repository.dart';
import '../repositories/analytics_repository.dart';

// Repository implementations (only those that exist)
import '../repositories/impl/auth_repository_impl.dart';
import '../repositories/impl/products_repository_impl.dart';
import '../repositories/impl/categories_repository_impl.dart';
import '../repositories/impl/orders_repository_impl.dart';
import '../repositories/impl/delivery_repository_impl.dart';
import '../repositories/impl/addresses_repository_impl.dart';
import '../repositories/impl/stores_repository_impl.dart';
import '../repositories/impl/inventory_repository_impl.dart';
import '../repositories/impl/suppliers_repository_impl.dart';
import '../repositories/impl/purchases_repository_impl.dart';
import '../repositories/impl/debts_repository_impl.dart';
import '../repositories/impl/reports_repository_impl.dart';
import '../repositories/impl/analytics_repository_impl.dart';

// ============================================
// Phase 1: Infrastructure Providers
// ============================================

/// SharedPreferences - override with pre-resolved instance in main()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope. '
    'Example: sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance())',
  );
});

/// FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// ============================================
// Phase 2: Networking Providers
// ============================================

/// ApiDioHolder - manages Dio instances
final apiDioHolderProvider = Provider<ApiDioHolder>((ref) {
  return ApiDioHolder();
});

/// Dio for token refresh (no interceptors)
final refreshDioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Auth local data source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.read(secureStorageProvider),
    prefs: ref.read(sharedPreferencesProvider),
  );
});

/// Auth interceptor for API calls
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    localDataSource: ref.read(authLocalDataSourceProvider),
    apiDioHolder: ref.read(apiDioHolderProvider),
    refreshDio: ref.read(refreshDioProvider),
  );
});

/// Dio for API calls (with auth interceptor)
final apiDioProvider = Provider<Dio>((ref) {
  final holder = ref.read(apiDioHolderProvider);
  final interceptor = ref.read(authInterceptorProvider);
  final dio = Dio();
  dio.interceptors.add(interceptor);
  holder.apiDio = dio;
  return dio;
});

// ============================================
// Phase 3: Remote DataSource Providers
// ============================================

/// Auth remote - implementation exists
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(dio: ref.read(apiDioProvider));
});

/// Orders remote - implementation exists
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSourceImpl(dio: ref.read(apiDioProvider));
});

/// Products remote - override in ProviderScope when Impl is created
final productsRemoteDataSourceProvider =
    Provider<ProductsRemoteDataSource>((ref) {
  throw UnimplementedError(
    'productsRemoteDataSourceProvider: ProductsRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Categories remote - override in ProviderScope when Impl is created
final categoriesRemoteDataSourceProvider =
    Provider<CategoriesRemoteDataSource>((ref) {
  throw UnimplementedError(
    'categoriesRemoteDataSourceProvider: CategoriesRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Delivery remote - override in ProviderScope when Impl is created
final deliveryRemoteDataSourceProvider =
    Provider<DeliveryRemoteDataSource>((ref) {
  throw UnimplementedError(
    'deliveryRemoteDataSourceProvider: DeliveryRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Addresses remote - override in ProviderScope when Impl is created
final addressesRemoteDataSourceProvider =
    Provider<AddressesRemoteDataSource>((ref) {
  throw UnimplementedError(
    'addressesRemoteDataSourceProvider: AddressesRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Stores remote - override in ProviderScope when Impl is created
final storesRemoteDataSourceProvider = Provider<StoresRemoteDataSource>((ref) {
  throw UnimplementedError(
    'storesRemoteDataSourceProvider: StoresRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Inventory remote - override in ProviderScope when Impl is created
final inventoryRemoteDataSourceProvider =
    Provider<InventoryRemoteDataSource>((ref) {
  throw UnimplementedError(
    'inventoryRemoteDataSourceProvider: InventoryRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Suppliers remote - override in ProviderScope when Impl is created
final suppliersRemoteDataSourceProvider =
    Provider<SuppliersRemoteDataSource>((ref) {
  throw UnimplementedError(
    'suppliersRemoteDataSourceProvider: SuppliersRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Purchases remote - override in ProviderScope when Impl is created
final purchasesRemoteDataSourceProvider =
    Provider<PurchasesRemoteDataSource>((ref) {
  throw UnimplementedError(
    'purchasesRemoteDataSourceProvider: PurchasesRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Debts remote - override in ProviderScope when Impl is created
final debtsRemoteDataSourceProvider = Provider<DebtsRemoteDataSource>((ref) {
  throw UnimplementedError(
    'debtsRemoteDataSourceProvider: DebtsRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Reports remote - override in ProviderScope when Impl is created
final reportsRemoteDataSourceProvider =
    Provider<ReportsRemoteDataSource>((ref) {
  throw UnimplementedError(
    'reportsRemoteDataSourceProvider: ReportsRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

/// Analytics remote - override in ProviderScope when Impl is created
final analyticsRemoteDataSourceProvider =
    Provider<AnalyticsRemoteDataSource>((ref) {
  throw UnimplementedError(
    'analyticsRemoteDataSourceProvider: AnalyticsRemoteDataSourceImpl not yet created. '
    'Override this provider in ProviderScope.',
  );
});

// ============================================
// Phase 4: Repository Providers
// ============================================

/// Auth repository - needs both remote and local data sources
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.read(authRemoteDataSourceProvider),
    local: ref.read(authLocalDataSourceProvider),
  );
});

/// Products repository - can be overridden with LocalProductsRepository
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    remote: ref.read(productsRemoteDataSourceProvider),
  );
});

/// Categories repository - can be overridden with LocalCategoriesRepository
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(
    remote: ref.read(categoriesRemoteDataSourceProvider),
  );
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(
    remote: ref.read(ordersRemoteDataSourceProvider),
  );
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(
    remote: ref.read(deliveryRemoteDataSourceProvider),
  );
});

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  return AddressesRepositoryImpl(
    remote: ref.read(addressesRemoteDataSourceProvider),
  );
});

final storesRepositoryProvider = Provider<StoresRepository>((ref) {
  return StoresRepositoryImpl(
    remote: ref.read(storesRemoteDataSourceProvider),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    remote: ref.read(inventoryRemoteDataSourceProvider),
  );
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepositoryImpl(
    remote: ref.read(suppliersRemoteDataSourceProvider),
  );
});

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  return PurchasesRepositoryImpl(
    remote: ref.read(purchasesRemoteDataSourceProvider),
  );
});

final debtsRepositoryProvider = Provider<DebtsRepository>((ref) {
  return DebtsRepositoryImpl(
    remote: ref.read(debtsRemoteDataSourceProvider),
  );
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(
    remote: ref.read(reportsRemoteDataSourceProvider),
  );
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    remote: ref.read(analyticsRemoteDataSourceProvider),
  );
});
