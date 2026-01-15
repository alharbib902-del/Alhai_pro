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
import 'package:alhai_core/src/datasources/remote/auth_remote_datasource.dart'
    as _i21;
import 'package:alhai_core/src/datasources/remote/orders_remote_datasource.dart'
    as _i757;
import 'package:alhai_core/src/datasources/remote/products_remote_datasource.dart'
    as _i30;
import 'package:alhai_core/src/di/modules/core_module.dart' as _i997;
import 'package:alhai_core/src/di/modules/datasources_module.dart' as _i612;
import 'package:alhai_core/src/di/modules/networking_module.dart' as _i613;
import 'package:alhai_core/src/di/modules/repositories_module.dart' as _i586;
import 'package:alhai_core/src/networking/api_dio_holder.dart' as _i614;
import 'package:alhai_core/src/networking/interceptors/auth_interceptor.dart'
    as _i803;
import 'package:alhai_core/src/repositories/auth_repository.dart' as _i49;
import 'package:alhai_core/src/repositories/orders_repository.dart' as _i849;
import 'package:alhai_core/src/repositories/products_repository.dart' as _i640;
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
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final coreModule = _$CoreModule();
    final networkingModule = _$NetworkingModule();
    final dataSourcesModule = _$DataSourcesModule();
    final repositoriesModule = _$RepositoriesModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => coreModule.secureStorage);
    gh.lazySingleton<_i614.ApiDioHolder>(() => networkingModule.apiDioHolder);
    gh.lazySingleton<_i361.Dio>(
      () => networkingModule.refreshDio,
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i436.AuthLocalDataSource>(
        () => dataSourcesModule.authLocalDataSource(
              gh<_i558.FlutterSecureStorage>(),
              gh<_i460.SharedPreferences>(),
            ));
    gh.lazySingleton<_i803.AuthInterceptor>(
        () => networkingModule.authInterceptor(
              gh<_i436.AuthLocalDataSource>(),
              gh<_i614.ApiDioHolder>(),
              gh<_i361.Dio>(instanceName: 'refreshDio'),
            ));
    gh.lazySingleton<_i361.Dio>(
      () => networkingModule.apiDio(
        gh<_i803.AuthInterceptor>(),
        gh<_i614.ApiDioHolder>(),
      ),
      instanceName: 'apiDio',
    );
    gh.lazySingleton<_i21.AuthRemoteDataSource>(() => dataSourcesModule
        .authRemoteDataSource(gh<_i361.Dio>(instanceName: 'apiDio')));
    gh.lazySingleton<_i757.OrdersRemoteDataSource>(() => dataSourcesModule
        .ordersRemoteDataSource(gh<_i361.Dio>(instanceName: 'apiDio')));
    gh.lazySingleton<_i30.ProductsRemoteDataSource>(() => dataSourcesModule
        .productsRemoteDataSource(gh<_i361.Dio>(instanceName: 'apiDio')));
    gh.lazySingleton<_i49.AuthRepository>(
        () => repositoriesModule.authRepository(
              gh<_i21.AuthRemoteDataSource>(),
              gh<_i436.AuthLocalDataSource>(),
            ));
    gh.lazySingleton<_i640.ProductsRepository>(() => repositoriesModule
        .productsRepository(gh<_i30.ProductsRemoteDataSource>()));
    gh.lazySingleton<_i849.OrdersRepository>(() => repositoriesModule
        .ordersRepository(gh<_i757.OrdersRemoteDataSource>()));
    return this;
  }
}

class _$CoreModule extends _i997.CoreModule {}

class _$NetworkingModule extends _i613.NetworkingModule {}

class _$DataSourcesModule extends _i612.DataSourcesModule {}

class _$RepositoriesModule extends _i586.RepositoriesModule {}
