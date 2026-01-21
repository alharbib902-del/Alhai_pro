/// App-wide constants for Customer App
library;

/// API Configuration
class ApiConfig {
  ApiConfig._();
  
  static const String baseUrl = 'https://api.alhai.app';
  static const Duration timeout = Duration(seconds: 30);
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
  
  static const int defaultPageSize = 20;
  static const int searchPageSize = 10;
}

/// Cache Configuration
class CacheConfig {
  CacheConfig._();
  
  static const Duration productImageCache = Duration(days: 30);
  static const Duration categoryCache = Duration(hours: 24);
}
