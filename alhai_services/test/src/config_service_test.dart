import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late ConfigService configService;

  setUp(() {
    configService = ConfigService();
  });

  group('ConfigService', () {
    test('should be created', () {
      expect(configService, isNotNull);
    });

    group('set and get', () {
      test('should store and retrieve value', () {
        configService.set('key', 'value');
        expect(configService.get<String>('key'), equals('value'));
      });

      test('should return default for missing key', () {
        final result =
            configService.get<int>('missing', defaultValue: 42);
        expect(result, equals(42));
      });

      test('should override existing value', () {
        configService.set('key', 'old');
        configService.set('key', 'new');
        expect(configService.get<String>('key'), equals('new'));
      });
    });

    group('defaults', () {
      test('should use defaults for missing keys', () {
        configService.setDefaults({'defaultKey': 'defaultValue'});
        expect(
          configService.get<String>('defaultKey'),
          equals('defaultValue'),
        );
      });

      test('explicit value should override default', () {
        configService.setDefaults({'key': 'default'});
        configService.set('key', 'explicit');
        expect(configService.get<String>('key'), equals('explicit'));
      });
    });

    group('containsKey', () {
      test('should find config keys', () {
        configService.set('existing', 'value');
        expect(configService.containsKey('existing'), isTrue);
        expect(configService.containsKey('missing'), isFalse);
      });

      test('should find keys in defaults', () {
        configService.setDefaults({'defaultKey': 'value'});
        expect(configService.containsKey('defaultKey'), isTrue);
      });
    });

    group('remove', () {
      test('should remove a key', () {
        configService.set('key', 'value');
        configService.remove('key');
        expect(configService.containsKey('key'), isFalse);
      });
    });

    group('clear', () {
      test('should clear all config values', () {
        configService.set('a', 1);
        configService.set('b', 2);
        configService.clear();

        expect(configService.containsKey('a'), isFalse);
        expect(configService.containsKey('b'), isFalse);
      });

      test('should not clear defaults', () {
        configService.setDefaults({'default': 'value'});
        configService.set('custom', 'data');
        configService.clear();

        expect(configService.get<String>('default'), equals('value'));
      });
    });

    group('getAll', () {
      test('should return merged defaults and config', () {
        configService.setDefaults({'a': 1, 'b': 2});
        configService.set('b', 3);
        configService.set('c', 4);

        final all = configService.getAll();
        expect(all['a'], equals(1));
        expect(all['b'], equals(3)); // config overrides default
        expect(all['c'], equals(4));
      });
    });

    group('typed properties', () {
      test('language should default to ar', () {
        expect(configService.language, equals('ar'));
      });

      test('should set and get language', () {
        configService.language = 'en';
        expect(configService.language, equals('en'));
      });

      test('isDarkMode should default to false', () {
        expect(configService.isDarkMode, isFalse);
      });

      test('should toggle dark mode', () {
        configService.isDarkMode = true;
        expect(configService.isDarkMode, isTrue);
      });

      test('notificationsEnabled should default to true', () {
        expect(configService.notificationsEnabled, isTrue);
      });

      test('soundEnabled should default to true', () {
        expect(configService.soundEnabled, isTrue);
      });

      test('vibrationEnabled should default to true', () {
        expect(configService.vibrationEnabled, isTrue);
      });

      test('autoPrint should default to false', () {
        expect(configService.autoPrint, isFalse);
      });

      test('autoOpenCashDrawer should default to true', () {
        expect(configService.autoOpenCashDrawer, isTrue);
      });

      test('fontSize should default to 1.0', () {
        expect(configService.fontSize, equals(1.0));
      });

      test('screenTimeout should default to 5', () {
        expect(configService.screenTimeout, equals(5));
      });

      test('lastStoreId should default to null', () {
        expect(configService.lastStoreId, isNull);
      });

      test('isDemoMode should default to false', () {
        expect(configService.isDemoMode, isFalse);
      });

      test('should set lastStoreId', () {
        configService.lastStoreId = 'store-1';
        expect(configService.lastStoreId, equals('store-1'));
      });
    });

    group('ConfigKeys', () {
      test('should have expected key values', () {
        expect(ConfigKeys.language, equals('config.language'));
        expect(ConfigKeys.darkMode, equals('config.dark_mode'));
        expect(ConfigKeys.notifications, equals('config.notifications'));
        expect(ConfigKeys.sound, equals('config.sound'));
        expect(ConfigKeys.vibration, equals('config.vibration'));
        expect(ConfigKeys.autoPrint, equals('config.auto_print'));
        expect(ConfigKeys.autoOpenCashDrawer,
            equals('config.auto_open_cash_drawer'));
        expect(ConfigKeys.fontSize, equals('config.font_size'));
        expect(ConfigKeys.screenTimeout, equals('config.screen_timeout'));
        expect(ConfigKeys.lastStoreId, equals('config.last_store_id'));
        expect(ConfigKeys.demoMode, equals('config.demo_mode'));
      });
    });
  });
}
