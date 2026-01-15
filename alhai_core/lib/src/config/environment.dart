/// App configuration for the API
class AppConfig {
  const AppConfig._();

  /// API base URL - should be overridden per environment
  static String apiBaseUrl = 'https://api.alhai.app';

  /// Request timeout in seconds
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  /// Configure app settings
  static void configure({
    required String baseUrl,
  }) {
    apiBaseUrl = baseUrl;
  }
}
