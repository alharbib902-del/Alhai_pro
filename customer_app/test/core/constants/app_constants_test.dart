import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('networkTimeout is 15 seconds', () {
      expect(AppConstants.networkTimeout, const Duration(seconds: 15));
    });

    test('otpLockoutSeconds is 60', () {
      expect(AppConstants.otpLockoutSeconds, 60);
    });

    test('defaultCountryCode is +966', () {
      expect(AppConstants.defaultCountryCode, '+966');
    });

    test('maxRetryAttempts is 3', () {
      expect(AppConstants.maxRetryAttempts, 3);
    });
  });

  group('ApiConfig', () {
    test('baseUrl is non-empty', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
    });

    test('timeout is a positive duration', () {
      expect(ApiConfig.timeout.inSeconds, greaterThan(0));
    });
  });

  group('AssetPaths', () {
    test('images path is assets/images', () {
      expect(AssetPaths.images, 'assets/images');
    });

    test('icons path is assets/icons', () {
      expect(AssetPaths.icons, 'assets/icons');
    });

    test('placeholder path starts with images path', () {
      expect(AssetPaths.placeholder, startsWith(AssetPaths.images));
    });

    test('logo path starts with images path', () {
      expect(AssetPaths.logo, startsWith(AssetPaths.images));
    });
  });

  group('PaginationConfig', () {
    test('defaultPageSize is positive', () {
      expect(PaginationConfig.defaultPageSize, greaterThan(0));
    });

    test('searchPageSize is 10', () {
      expect(PaginationConfig.searchPageSize, 10);
    });
  });

  group('CacheConfig', () {
    test('productImageCache is 30 days', () {
      expect(CacheConfig.productImageCache, const Duration(days: 30));
    });

    test('categoryCache is 24 hours', () {
      expect(CacheConfig.categoryCache, const Duration(hours: 24));
    });
  });
}
