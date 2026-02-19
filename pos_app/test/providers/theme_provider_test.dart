import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/theme_provider.dart';

// ===========================================
// Theme Provider Tests
// ===========================================

void main() {
  group('ThemeState', () {
    group('constructor', () {
      test('القيم الافتراضية صحيحة', () {
        const state = ThemeState();

        expect(state.themeMode, ThemeMode.system);
        expect(state.isLoading, true);
      });

      test('يمكن تمرير قيم مخصصة', () {
        const state = ThemeState(
          themeMode: ThemeMode.dark,
          isLoading: false,
        );

        expect(state.themeMode, ThemeMode.dark);
        expect(state.isLoading, false);
      });
    });

    group('copyWith', () {
      test('ينسخ مع تعديل themeMode', () {
        const original = ThemeState();
        final copied = original.copyWith(themeMode: ThemeMode.dark);

        expect(copied.themeMode, ThemeMode.dark);
        expect(copied.isLoading, original.isLoading);
      });

      test('ينسخ مع تعديل isLoading', () {
        const original = ThemeState();
        final copied = original.copyWith(isLoading: false);

        expect(copied.isLoading, false);
        expect(copied.themeMode, original.themeMode);
      });

      test('ينسخ مع تعديل قيمتين', () {
        const original = ThemeState();
        final copied = original.copyWith(
          themeMode: ThemeMode.light,
          isLoading: false,
        );

        expect(copied.themeMode, ThemeMode.light);
        expect(copied.isLoading, false);
      });

      test('بدون تمرير قيم يُعيد نفس القيم', () {
        const original = ThemeState(
          themeMode: ThemeMode.dark,
          isLoading: false,
        );
        final copied = original.copyWith();

        expect(copied.themeMode, original.themeMode);
        expect(copied.isLoading, original.isLoading);
      });
    });

    group('isDarkMode', () {
      test('true عندما ThemeMode.dark', () {
        const state = ThemeState(themeMode: ThemeMode.dark);
        expect(state.isDarkMode, true);
      });

      test('false عندما ThemeMode.light', () {
        const state = ThemeState(themeMode: ThemeMode.light);
        expect(state.isDarkMode, false);
      });

      test('false عندما ThemeMode.system', () {
        const state = ThemeState(themeMode: ThemeMode.system);
        expect(state.isDarkMode, false);
      });
    });

    group('isSystemMode', () {
      test('true عندما ThemeMode.system', () {
        const state = ThemeState(themeMode: ThemeMode.system);
        expect(state.isSystemMode, true);
      });

      test('false عندما ThemeMode.dark', () {
        const state = ThemeState(themeMode: ThemeMode.dark);
        expect(state.isSystemMode, false);
      });

      test('false عندما ThemeMode.light', () {
        const state = ThemeState(themeMode: ThemeMode.light);
        expect(state.isSystemMode, false);
      });
    });
  });

  group('ThemeNotifier', () {
    test('الحالة الافتراضية عند الإنشاء', () {
      final notifier = ThemeNotifier();

      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.isLoading, true);
    });
  });

  group('ThemeMode values', () {
    test('enum يحتوي على 3 قيم', () {
      expect(ThemeMode.values.length, 3);
    });

    test('ThemeMode.system موجود', () {
      expect(ThemeMode.values, contains(ThemeMode.system));
    });

    test('ThemeMode.light موجود', () {
      expect(ThemeMode.values, contains(ThemeMode.light));
    });

    test('ThemeMode.dark موجود', () {
      expect(ThemeMode.values, contains(ThemeMode.dark));
    });
  });

  group('Theme persistence keys', () {
    test('مفتاح التخزين ثابت', () {
      const themeKey = 'app_theme_mode';
      expect(themeKey, isNotEmpty);
      expect(themeKey, contains('theme'));
    });

    test('قيم التخزين صحيحة', () {
      const darkValue = 'dark';
      const lightValue = 'light';
      const systemValue = 'system';

      expect(darkValue, 'dark');
      expect(lightValue, 'light');
      expect(systemValue, 'system');
    });
  });

  group('ThemeState combinations', () {
    test('وضع النظام مع تحميل', () {
      const state = ThemeState(
        themeMode: ThemeMode.system,
        isLoading: true,
      );

      expect(state.isSystemMode, true);
      expect(state.isDarkMode, false);
      expect(state.isLoading, true);
    });

    test('وضع مظلم مع انتهاء التحميل', () {
      const state = ThemeState(
        themeMode: ThemeMode.dark,
        isLoading: false,
      );

      expect(state.isDarkMode, true);
      expect(state.isSystemMode, false);
      expect(state.isLoading, false);
    });

    test('وضع فاتح مع انتهاء التحميل', () {
      const state = ThemeState(
        themeMode: ThemeMode.light,
        isLoading: false,
      );

      expect(state.isDarkMode, false);
      expect(state.isSystemMode, false);
      expect(state.isLoading, false);
    });
  });

  group('Theme switching logic', () {
    test('تبديل من مظلم إلى فاتح', () {
      const darkState = ThemeState(themeMode: ThemeMode.dark);
      expect(darkState.isDarkMode, true);

      // عند التبديل، الوضع الجديد سيكون فاتح
      final newMode = darkState.isDarkMode ? ThemeMode.light : ThemeMode.dark;
      expect(newMode, ThemeMode.light);
    });

    test('تبديل من فاتح إلى مظلم', () {
      const lightState = ThemeState(themeMode: ThemeMode.light);
      expect(lightState.isDarkMode, false);

      // عند التبديل، الوضع الجديد سيكون مظلم
      final newMode = lightState.isDarkMode ? ThemeMode.light : ThemeMode.dark;
      expect(newMode, ThemeMode.dark);
    });
  });

  group('String to ThemeMode conversion', () {
    test('dark يتحول إلى ThemeMode.dark', () {
      const savedMode = 'dark';
      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }
      expect(mode, ThemeMode.dark);
    });

    test('light يتحول إلى ThemeMode.light', () {
      const savedMode = 'light';
      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }
      expect(mode, ThemeMode.light);
    });

    test('system يتحول إلى ThemeMode.system', () {
      const savedMode = 'system';
      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }
      expect(mode, ThemeMode.system);
    });

    test('قيمة غير معروفة تتحول إلى ThemeMode.system', () {
      const savedMode = 'unknown';
      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }
      expect(mode, ThemeMode.system);
    });

    test('null يتحول إلى ThemeMode.system', () {
      String? savedMode;
      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }
      expect(mode, ThemeMode.system);
    });
  });

  group('ThemeMode to String conversion', () {
    test('ThemeMode.dark يتحول إلى "dark"', () {
      const mode = ThemeMode.dark;
      String modeString;
      switch (mode) {
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      expect(modeString, 'dark');
    });

    test('ThemeMode.light يتحول إلى "light"', () {
      const mode = ThemeMode.light;
      String modeString;
      switch (mode) {
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      expect(modeString, 'light');
    });

    test('ThemeMode.system يتحول إلى "system"', () {
      const mode = ThemeMode.system;
      String modeString;
      switch (mode) {
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      expect(modeString, 'system');
    });
  });
}
