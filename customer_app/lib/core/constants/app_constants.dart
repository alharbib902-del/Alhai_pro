/// App-wide constants for Customer App
library;

import 'package:alhai_core/alhai_core.dart' show AppEndpoints, AppLimits;

/// Centralized app constants to avoid magic numbers.
class AppConstants {
  AppConstants._();

  /// Default network request timeout.
  static const networkTimeout = Duration(seconds: 15);

  /// OTP lockout duration in seconds.
  static const otpLockoutSeconds = 60;

  /// Default country code.
  static const defaultCountryCode = '+966';

  /// Max retry attempts for network requests.
  static const maxRetryAttempts = 3;
}

/// API Configuration
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = AppEndpoints.apiBase;
  static const Duration timeout = AppLimits.networkTimeout;
}

/// Asset Paths
class AssetPaths {
  AssetPaths._();

  static const String images = 'assets/images';
  static const String icons = 'assets/icons';

  // Placeholder images
  static const String placeholder = '$images/placeholder.png';
  static const String logo = '$images/logo.png';
}

/// Pagination
class PaginationConfig {
  PaginationConfig._();

  static const int defaultPageSize = AppLimits.defaultPageSize;
  static const int searchPageSize = 10;
}

/// Cache Configuration
class CacheConfig {
  CacheConfig._();

  static const Duration productImageCache = Duration(days: 30);
  static const Duration categoryCache = Duration(hours: 24);
}
