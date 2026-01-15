import 'package:dio/dio.dart';

/// Holds the API Dio instance to break circular dependency
/// AuthInterceptor needs Dio, but Dio needs AuthInterceptor
/// Solution: ApiDioHolder is created first, then apiDio is assigned after creation
class ApiDioHolder {
  /// The main API Dio instance (set after creation)
  late Dio apiDio;
}
