import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/theme/app_theme.dart';

// ===========================================
// App Theme Tests
// ===========================================

void main() {
  group('AppTheme Light', () {
    late ThemeData lightTheme;

    setUpAll(() {
      lightTheme = AppTheme.light;
    });

    group('Basic Properties', () {
      test('يستخدم Material 3', () {
        expect(lightTheme.useMaterial3, true);
      });

      test('الـ brightness هو light', () {
        expect(lightTheme.brightness, Brightness.light);
      });

      test('لديه textTheme محدد', () {
        expect(lightTheme.textTheme, isNotNull);
      });

      test('لديه scaffoldBackgroundColor', () {
        expect(lightTheme.scaffoldBackgroundColor, isNotNull);
      });
    });

    group('ColorScheme', () {
      test('لديه primary color', () {
        expect(lightTheme.colorScheme.primary, isNotNull);
      });

      test('لديه onPrimary color', () {
        expect(lightTheme.colorScheme.onPrimary, isNotNull);
      });

      test('لديه secondary color', () {
        expect(lightTheme.colorScheme.secondary, isNotNull);
      });

      test('لديه error color', () {
        expect(lightTheme.colorScheme.error, isNotNull);
      });

      test('لديه surface color', () {
        expect(lightTheme.colorScheme.surface, isNotNull);
      });

      test('ColorScheme.brightness هو light', () {
        expect(lightTheme.colorScheme.brightness, Brightness.light);
      });
    });

    group('AppBar Theme', () {
      test('AppBar centerTitle = false', () {
        expect(lightTheme.appBarTheme.centerTitle, false);
      });

      test('AppBar elevation = 0', () {
        expect(lightTheme.appBarTheme.elevation, 0);
      });

      test('AppBar surfaceTintColor شفاف', () {
        expect(lightTheme.appBarTheme.surfaceTintColor, Colors.transparent);
      });

      test('AppBar لديه backgroundColor', () {
        expect(lightTheme.appBarTheme.backgroundColor, isNotNull);
      });

      test('AppBar لديه foregroundColor', () {
        expect(lightTheme.appBarTheme.foregroundColor, isNotNull);
      });
    });

    group('Card Theme', () {
      test('Card elevation = 0', () {
        expect(lightTheme.cardTheme.elevation, 0);
      });

      test('Card surfaceTintColor شفاف', () {
        expect(lightTheme.cardTheme.surfaceTintColor, Colors.transparent);
      });

      test('Card لديه shape', () {
        expect(lightTheme.cardTheme.shape, isNotNull);
      });

      test('Card margin = EdgeInsets.zero', () {
        expect(lightTheme.cardTheme.margin, EdgeInsets.zero);
      });
    });

    group('Button Themes', () {
      test('ElevatedButton لديه style', () {
        expect(lightTheme.elevatedButtonTheme.style, isNotNull);
      });

      test('FilledButton لديه style', () {
        expect(lightTheme.filledButtonTheme.style, isNotNull);
      });

      test('OutlinedButton لديه style', () {
        expect(lightTheme.outlinedButtonTheme.style, isNotNull);
      });

      test('TextButton لديه style', () {
        expect(lightTheme.textButtonTheme.style, isNotNull);
      });

      test('IconButton لديه style', () {
        expect(lightTheme.iconButtonTheme.style, isNotNull);
      });
    });

    group('Input Theme', () {
      test('Input filled = true', () {
        expect(lightTheme.inputDecorationTheme.filled, true);
      });

      test('Input لديه fillColor', () {
        expect(lightTheme.inputDecorationTheme.fillColor, isNotNull);
      });

      test('Input لديه border', () {
        expect(lightTheme.inputDecorationTheme.border, isNotNull);
      });

      test('Input لديه focusedBorder', () {
        expect(lightTheme.inputDecorationTheme.focusedBorder, isNotNull);
      });

      test('Input لديه errorBorder', () {
        expect(lightTheme.inputDecorationTheme.errorBorder, isNotNull);
      });
    });

    group('Dialog Theme', () {
      test('Dialog لديه shape', () {
        expect(lightTheme.dialogTheme.shape, isNotNull);
      });

      test('Dialog لديه backgroundColor', () {
        expect(lightTheme.dialogTheme.backgroundColor, isNotNull);
      });

      test('Dialog surfaceTintColor شفاف', () {
        expect(lightTheme.dialogTheme.surfaceTintColor, Colors.transparent);
      });
    });

    group('BottomSheet Theme', () {
      test('BottomSheet لديه shape', () {
        expect(lightTheme.bottomSheetTheme.shape, isNotNull);
      });

      test('BottomSheet لديه backgroundColor', () {
        expect(lightTheme.bottomSheetTheme.backgroundColor, isNotNull);
      });

      test('BottomSheet لديه dragHandleColor', () {
        expect(lightTheme.bottomSheetTheme.dragHandleColor, isNotNull);
      });
    });

    group('Snackbar Theme', () {
      test('Snackbar behavior = floating', () {
        expect(lightTheme.snackBarTheme.behavior, SnackBarBehavior.floating);
      });

      test('Snackbar لديه backgroundColor', () {
        expect(lightTheme.snackBarTheme.backgroundColor, isNotNull);
      });

      test('Snackbar لديه shape', () {
        expect(lightTheme.snackBarTheme.shape, isNotNull);
      });
    });

    group('Other Themes', () {
      test('FloatingActionButton لديه theme', () {
        expect(lightTheme.floatingActionButtonTheme, isNotNull);
      });

      test('BottomNavigationBar لديه theme', () {
        expect(lightTheme.bottomNavigationBarTheme, isNotNull);
      });

      test('NavigationRail لديه theme', () {
        expect(lightTheme.navigationRailTheme, isNotNull);
      });

      test('Drawer لديه theme', () {
        expect(lightTheme.drawerTheme, isNotNull);
      });

      test('Chip لديه theme', () {
        expect(lightTheme.chipTheme, isNotNull);
      });

      test('Divider لديه theme', () {
        expect(lightTheme.dividerTheme, isNotNull);
      });

      test('ListTile لديه theme', () {
        expect(lightTheme.listTileTheme, isNotNull);
      });

      test('TabBar لديه theme', () {
        expect(lightTheme.tabBarTheme, isNotNull);
      });

      test('ProgressIndicator لديه theme', () {
        expect(lightTheme.progressIndicatorTheme, isNotNull);
      });

      test('Switch لديه theme', () {
        expect(lightTheme.switchTheme, isNotNull);
      });

      test('Checkbox لديه theme', () {
        expect(lightTheme.checkboxTheme, isNotNull);
      });

      test('Radio لديه theme', () {
        expect(lightTheme.radioTheme, isNotNull);
      });

      test('Slider لديه theme', () {
        expect(lightTheme.sliderTheme, isNotNull);
      });

      test('DataTable لديه theme', () {
        expect(lightTheme.dataTableTheme, isNotNull);
      });

      test('Tooltip لديه theme', () {
        expect(lightTheme.tooltipTheme, isNotNull);
      });

      test('PopupMenu لديه theme', () {
        expect(lightTheme.popupMenuTheme, isNotNull);
      });

      test('DropdownMenu لديه theme', () {
        expect(lightTheme.dropdownMenuTheme, isNotNull);
      });

      test('Badge لديه theme', () {
        expect(lightTheme.badgeTheme, isNotNull);
      });

      test('ExpansionTile لديه theme', () {
        expect(lightTheme.expansionTileTheme, isNotNull);
      });
    });
  });

  group('AppTheme Dark', () {
    late ThemeData darkTheme;

    setUpAll(() {
      darkTheme = AppTheme.dark;
    });

    group('Basic Properties', () {
      test('يستخدم Material 3', () {
        expect(darkTheme.useMaterial3, true);
      });

      test('الـ brightness هو dark', () {
        expect(darkTheme.brightness, Brightness.dark);
      });

      test('لديه textTheme محدد', () {
        expect(darkTheme.textTheme, isNotNull);
      });

      test('لديه scaffoldBackgroundColor', () {
        expect(darkTheme.scaffoldBackgroundColor, isNotNull);
      });
    });

    group('ColorScheme', () {
      test('لديه primary color', () {
        expect(darkTheme.colorScheme.primary, isNotNull);
      });

      test('ColorScheme.brightness هو dark', () {
        expect(darkTheme.colorScheme.brightness, Brightness.dark);
      });

      test('لديه surface color', () {
        expect(darkTheme.colorScheme.surface, isNotNull);
      });

      test('لديه error color', () {
        expect(darkTheme.colorScheme.error, isNotNull);
      });
    });

    group('Dark vs Light', () {
      test('scaffoldBackgroundColor مختلف عن الـ light', () {
        expect(
          darkTheme.scaffoldBackgroundColor,
          isNot(AppTheme.light.scaffoldBackgroundColor),
        );
      });

      test('AppBar backgroundColor مختلف عن الـ light', () {
        expect(
          darkTheme.appBarTheme.backgroundColor,
          isNot(AppTheme.light.appBarTheme.backgroundColor),
        );
      });

      test('Card color مختلف عن الـ light', () {
        expect(
          darkTheme.cardTheme.color,
          isNot(AppTheme.light.cardTheme.color),
        );
      });

      test('Dialog backgroundColor مختلف عن الـ light', () {
        expect(
          darkTheme.dialogTheme.backgroundColor,
          isNot(AppTheme.light.dialogTheme.backgroundColor),
        );
      });

      test('BottomSheet backgroundColor مختلف عن الـ light', () {
        expect(
          darkTheme.bottomSheetTheme.backgroundColor,
          isNot(AppTheme.light.bottomSheetTheme.backgroundColor),
        );
      });
    });

    group('SystemUiOverlayStyle', () {
      test('Light theme status bar icons are dark', () {
        final style = AppTheme.light.appBarTheme.systemOverlayStyle;
        expect(style?.statusBarIconBrightness, Brightness.dark);
      });

      test('Dark theme status bar icons are light', () {
        final style = AppTheme.dark.appBarTheme.systemOverlayStyle;
        expect(style?.statusBarIconBrightness, Brightness.light);
      });

      test('statusBarColor شفاف في الثيمين', () {
        expect(
          AppTheme.light.appBarTheme.systemOverlayStyle?.statusBarColor,
          Colors.transparent,
        );
        expect(
          AppTheme.dark.appBarTheme.systemOverlayStyle?.statusBarColor,
          Colors.transparent,
        );
      });
    });
  });

  group('AppTheme consistency', () {
    test('Both themes use Material 3', () {
      expect(AppTheme.light.useMaterial3, true);
      expect(AppTheme.dark.useMaterial3, true);
    });

    test('Both themes have textTheme', () {
      expect(AppTheme.light.textTheme, isNotNull);
      expect(AppTheme.dark.textTheme, isNotNull);
    });

    test('Both themes have same primary color', () {
      expect(
        AppTheme.light.colorScheme.primary,
        AppTheme.dark.colorScheme.primary,
      );
    });

    test('AppBar elevation is 0 in both themes', () {
      expect(AppTheme.light.appBarTheme.elevation, 0);
      expect(AppTheme.dark.appBarTheme.elevation, 0);
    });

    test('Card elevation is 0 in both themes', () {
      expect(AppTheme.light.cardTheme.elevation, 0);
      expect(AppTheme.dark.cardTheme.elevation, 0);
    });

    test('Snackbar behavior is floating in both themes', () {
      expect(
        AppTheme.light.snackBarTheme.behavior,
        SnackBarBehavior.floating,
      );
      expect(
        AppTheme.dark.snackBarTheme.behavior,
        SnackBarBehavior.floating,
      );
    });
  });
}
