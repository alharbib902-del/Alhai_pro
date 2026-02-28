import 'app_endpoints.dart';
import 'app_limits.dart';

/// App configuration for the API
class AppConfig {
  const AppConfig._();

  /// API base URL - should be overridden per environment
  static String apiBaseUrl = AppEndpoints.apiBase;

  /// Request timeout in seconds
  static const int connectTimeout = AppLimits.networkTimeoutSeconds;
  static const int receiveTimeout = AppLimits.networkTimeoutSeconds;
  static const int sendTimeout = AppLimits.networkTimeoutSeconds;

  /// Configure app settings
  static void configure({
    required String baseUrl,
  }) {
    apiBaseUrl = baseUrl;
  }
}
