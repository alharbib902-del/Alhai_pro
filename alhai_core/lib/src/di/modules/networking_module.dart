import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../config/environment.dart';
import '../../datasources/local/auth_local_datasource.dart';
import '../../networking/api_dio_holder.dart';
import '../../networking/interceptors/auth_interceptor.dart';

/// Networking module for Dio instances and interceptors
@module
abstract class NetworkingModule {
  /// ApiDioHolder - breaks circular dependency
  @lazySingleton
  ApiDioHolder get apiDioHolder => ApiDioHolder();

  /// Refresh Dio - NO interceptors to avoid loops
  @Named('refreshDio')
  @lazySingleton
  Dio get refreshDio => Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: Duration(seconds: AppConfig.connectTimeout),
          receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
          sendTimeout: Duration(seconds: AppConfig.sendTimeout),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// AuthInterceptor - depends on local datasource, holder, and refreshDio
  @lazySingleton
  AuthInterceptor authInterceptor(
    AuthLocalDataSource localDataSource,
    ApiDioHolder apiDioHolder,
    @Named('refreshDio') Dio refreshDio,
  ) =>
      AuthInterceptor(
        localDataSource: localDataSource,
        apiDioHolder: apiDioHolder,
        refreshDio: refreshDio,
      );

  /// API Dio - with AuthInterceptor and LogInterceptor
  @Named('apiDio')
  @lazySingleton
  Dio apiDio(
    AuthInterceptor authInterceptor,
    ApiDioHolder apiDioHolder,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(seconds: AppConfig.sendTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);

    // Assign to holder for retry mechanism
    apiDioHolder.apiDio = dio;

    return dio;
  }
}
