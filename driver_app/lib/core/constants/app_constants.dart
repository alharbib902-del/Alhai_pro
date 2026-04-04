/// Centralized app constants for the driver app.
class AppConstants {
  AppConstants._();

  /// Default network request timeout.
  static const networkTimeout = Duration(seconds: 15);

  /// Default country code (Saudi Arabia).
  static const defaultCountryCode = '+966';

  /// Max retry attempts for network requests.
  static const maxRetryAttempts = 3;

  /// Location update interval in seconds.
  static const locationUpdateInterval = Duration(seconds: 10);

  /// Cache TTL for local data.
  static const cacheTtl = Duration(hours: 24);
}
