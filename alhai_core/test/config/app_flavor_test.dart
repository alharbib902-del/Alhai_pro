import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/src/config/app_flavor.dart';

void main() {
  group('AppFlavor', () {
    test('has three values', () {
      expect(AppFlavor.values, hasLength(3));
      expect(AppFlavor.values, contains(AppFlavor.dev));
      expect(AppFlavor.values, contains(AppFlavor.staging));
      expect(AppFlavor.values, contains(AppFlavor.prod));
    });

    test('isDev/isStaging/isProd flags are exclusive', () {
      expect(AppFlavor.dev.isDev, isTrue);
      expect(AppFlavor.dev.isStaging, isFalse);
      expect(AppFlavor.dev.isProd, isFalse);

      expect(AppFlavor.staging.isDev, isFalse);
      expect(AppFlavor.staging.isStaging, isTrue);
      expect(AppFlavor.staging.isProd, isFalse);

      expect(AppFlavor.prod.isDev, isFalse);
      expect(AppFlavor.prod.isStaging, isFalse);
      expect(AppFlavor.prod.isProd, isTrue);
    });

    test('label returns correct values', () {
      expect(AppFlavor.dev.label, 'DEV');
      expect(AppFlavor.staging.label, 'STG');
      expect(AppFlavor.prod.label, '');
    });

    test('appNameSuffix returns correct values', () {
      expect(AppFlavor.dev.appNameSuffix, ' (Dev)');
      expect(AppFlavor.staging.appNameSuffix, ' (Staging)');
      expect(AppFlavor.prod.appNameSuffix, '');
    });

    test('current defaults to dev when no env var', () {
      // When FLAVOR is not defined via --dart-define, defaults to 'dev'
      expect(AppFlavor.current, AppFlavor.dev);
    });
  });

  group('EnvConfig', () {
    test('flavor defaults to dev', () {
      expect(EnvConfig.flavor, AppFlavor.dev);
    });

    test('enableDebugLogs is true in dev/staging', () {
      // Since we default to dev, debug logs should be enabled
      expect(EnvConfig.enableDebugLogs, isTrue);
    });

    test('isConfigured is false when env vars not set', () {
      // Without --dart-define, supabase values are empty
      expect(EnvConfig.isConfigured, isFalse);
    });

    test('configSummary is a string', () {
      expect(EnvConfig.configSummary, isA<String>());
      expect(EnvConfig.configSummary, contains('Flavor:'));
    });
  });
}
