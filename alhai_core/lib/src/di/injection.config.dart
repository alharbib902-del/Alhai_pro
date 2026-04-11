// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alhai_core/src/datasources/local/auth_local_datasource.dart'
    as _i436;
import 'package:alhai_core/src/datasources/remote/addresses_remote_datasource.dart'
    as _i450;
import 'package:alhai_core/src/datasources/remote/analytics_remote_datasource.dart'
    as _i761;
import 'package:alhai_core/src/datasources/remote/auth_remote_datasource.dart'
    as _i21;
import 'package:alhai_core/src/datasources/remote/categories_remote_datasource.dart'
    as _i435;
import 'package:alhai_core/src/datasources/remote/debts_remote_datasource.dart'
    as _i774;
import 'package:alhai_core/src/datasources/remote/delivery_remote_datasource.dart'
    as _i410;
import 'package:alhai_core/src/datasources/remote/inventory_remote_datasource.dart'
    as _i973;
import 'package:alhai_core/src/datasources/remote/orders_remote_datasource.dart'
    as _i757;
import 'package:alhai_core/src/datasources/remote/products_remote_datasource.dart'
    as _i30;
import 'package:alhai_core/src/datasources/remote/purchases_remote_datasource.dart'
    as _i288;
import 'package:alhai_core/src/datasources/remote/reports_remote_datasource.dart'
    as _i641;
import 'package:alhai_core/src/datasources/remote/stores_remote_datasource.dart'
    as _i927;
import 'package:alhai_core/src/datasources/remote/suppliers_remote_datasource.dart'
    as _i719;
import 'package:alhai_core/src/di/modules/core_module.dart' as _i997;
import 'package:alhai_core/src/di/modules/datasources_module.dart' as _i612;
import 'package:alhai_core/src/di/modules/networking_module.dart' as _i613;
import 'package:alhai_core/src/di/modules/repositories_module.dart' as _i586;
import 'package:alhai_core/src/networking/api_dio_holder.dart' as _i614;
import 'package:alhai_core/src/networking/interceptors/auth_interceptor.dart'
    as _i803;
import 'package:alhai_core/src/repositories/addresses_repository.dart' as _i757;
import 'package:alhai_core/src/repositories/analytics_repository.dart'
    as _i1023;
import 'package:alhai_core/src/repositories/auth_repository.dart' as _i49;
import 'package:alhai_core/src/repositories/categories_repository.dart' as _i99;
import 'package:alhai_core/src/repositories/debts_repository.dart' as _i822;
import 'package:alhai_core/src/repositories/delivery_repository.dart' as _i520;
import 'package:alhai_core/src/repositories/inventory_repository.dart' as _i414;
import 'package:alhai_core/src/repositories/orders_repository.dart' as _i849;
import 'package:alhai_core/src/repositories/products_repository.dart' as _i640;
import 'package:alhai_core/src/repositories/purchases_repository.dart' as _i701;
import 'package:alhai_core/src/repositories/reports_repository.dart' as _i416;
import 'package:alhai_core/src/repositories/stores_repository.dart' as _i270;
import 'package:alhai_core/src/repositories/suppliers_repository.dart' as _i466;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final networkingModule = _$NetworkingModule();
    final dataSourcesModule = _$DataSourcesModule();
    final repositoriesModule = _$RepositoriesModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage,
    );
    gh.lazySingleton<_i614.ApiDioHolder>(() => networkingModule.apiDioHolder);
    gh.lazySingleton<_i361.Dio>(
      () => networkingModule.refreshDio,
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i436.AuthLocalDataSource>(
      () => dataSourcesModule.authLocalDataSource(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i803.AuthInterceptor>(
      () => networkingModule.authInterceptor(
        gh<_i436.AuthLocalDataSource>(),
        gh<_i614.ApiDioHolder>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkingModule.apiDio(
        gh<_i803.AuthInterceptor>(),
        gh<_i614.ApiDioHolder>(),
      ),
      instanceName: 'apiDio',
    );
    gh.lazySingleton<_i21.AuthRemoteDataSource>(
      () => dataSourcesModule.authRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i30.ProductsRemoteDataSource>(
      () => dataSourcesModule.productsRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i435.CategoriesRemoteDataSource>(
      () => dataSourcesModule.categoriesRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i757.OrdersRemoteDataSource>(
      () => dataSourcesModule.ordersRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i410.DeliveryRemoteDataSource>(
      () => dataSourcesModule.deliveryRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i450.AddressesRemoteDataSource>(
      () => dataSourcesModule.addressesRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i927.StoresRemoteDataSource>(
      () => dataSourcesModule.storesRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i973.InventoryRemoteDataSource>(
      () => dataSourcesModule.inventoryRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i719.SuppliersRemoteDataSource>(
      () => dataSourcesModule.suppliersRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i288.PurchasesRemoteDataSource>(
      () => dataSourcesModule.purchasesRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i774.DebtsRemoteDataSource>(
      () => dataSourcesModule.debtsRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i641.ReportsRemoteDataSource>(
      () => dataSourcesModule.reportsRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i761.AnalyticsRemoteDataSource>(
      () => dataSourcesModule.analyticsRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'apiDio'),
      ),
    );
    gh.lazySingleton<_i270.StoresRepository>(
      () => repositoriesModule.storesRepository(
        gh<_i927.StoresRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i49.AuthRepository>(
      () => repositoriesModule.authRepository(
        gh<_i21.AuthRemoteDataSource>(),
        gh<_i436.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i466.SuppliersRepository>(
      () => repositoriesModule.suppliersRepository(
        gh<_i719.SuppliersRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1023.AnalyticsRepository>(
      () => repositoriesModule.analyticsRepository(
        gh<_i761.AnalyticsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i99.CategoriesRepository>(
      () => repositoriesModule.categoriesRepository(
        gh<_i435.CategoriesRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i757.AddressesRepository>(
      () => repositoriesModule.addressesRepository(
        gh<_i450.AddressesRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i520.DeliveryRepository>(
      () => repositoriesModule.deliveryRepository(
        gh<_i410.DeliveryRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i640.ProductsRepository>(
      () => repositoriesModule.productsRepository(
        gh<_i30.ProductsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i414.InventoryRepository>(
      () => repositoriesModule.inventoryRepository(
        gh<_i973.InventoryRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i849.OrdersRepository>(
      () => repositoriesModule.ordersRepository(
        gh<_i757.OrdersRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i416.ReportsRepository>(
      () => repositoriesModule.reportsRepository(
        gh<_i641.ReportsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i822.DebtsRepository>(
      () =>
          repositoriesModule.debtsRepository(gh<_i774.DebtsRemoteDataSource>()),
    );
    gh.lazySingleton<_i701.PurchasesRepository>(
      () => repositoriesModule.purchasesRepository(
        gh<_i288.PurchasesRemoteDataSource>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i997.CoreModule {}

class _$NetworkingModule extends _i613.NetworkingModule {}

class _$DataSourcesModule extends _i612.DataSourcesModule {}

class _$RepositoriesModule extends _i586.RepositoriesModule {}
