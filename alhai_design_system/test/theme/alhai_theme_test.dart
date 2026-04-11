import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  group('AlhaiTheme', () {
    group('light theme', () {
      final theme = AlhaiTheme.light;

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('has light brightness', () {
        expect(theme.brightness, Brightness.light);
      });

      test('has color scheme', () {
        expect(theme.colorScheme, isNotNull);
      });

      test('has text theme', () {
        expect(theme.textTheme, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
      });

      test('text theme uses Tajawal font family', () {
        // Verify text styles are using Tajawal via the textTheme
        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AlhaiTypography.fontFamily,
        );
      });

      test('has status colors extension', () {
        final statusColors = theme.extension<AlhaiStatusColors>();
        expect(statusColors, isNotNull);
      });

      test('app bar is centered', () {
        expect(theme.appBarTheme.centerTitle, isTrue);
      });

      test('app bar has no elevation', () {
        expect(theme.appBarTheme.elevation, 0);
      });

      test('card has no elevation', () {
        expect(theme.cardTheme.elevation, 0);
      });

      test('snackbar is floating', () {
        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      });

      test('bottom sheet shows drag handle', () {
        expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      });
    });

    group('dark theme', () {
      final theme = AlhaiTheme.dark;

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('has dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('has color scheme', () {
        expect(theme.colorScheme, isNotNull);
      });

      test('has text theme', () {
        expect(theme.textTheme, isNotNull);
      });

      test('text theme uses Tajawal font family', () {
        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AlhaiTypography.fontFamily,
        );
      });

      test('has status colors extension', () {
        final statusColors = theme.extension<AlhaiStatusColors>();
        expect(statusColors, isNotNull);
      });
    });

    group('theme consistency', () {
      test('both themes use the same font family in text theme', () {
        expect(
          AlhaiTheme.light.textTheme.bodyMedium?.fontFamily,
          AlhaiTheme.dark.textTheme.bodyMedium?.fontFamily,
        );
      });

      test('both themes use Material 3', () {
        expect(AlhaiTheme.light.useMaterial3, isTrue);
        expect(AlhaiTheme.dark.useMaterial3, isTrue);
      });

      test('both themes have status colors extension', () {
        expect(AlhaiTheme.light.extension<AlhaiStatusColors>(), isNotNull);
        expect(AlhaiTheme.dark.extension<AlhaiStatusColors>(), isNotNull);
      });
    });
  });

  group('AlhaiStatusColors', () {
    test('light colors are defined', () {
      const colors = AlhaiStatusColors.light;
      expect(colors.success, isA<Color>());
      expect(colors.successLight, isA<Color>());
      expect(colors.onSuccess, isA<Color>());
      expect(colors.warning, isA<Color>());
      expect(colors.warningLight, isA<Color>());
      expect(colors.onWarning, isA<Color>());
      expect(colors.info, isA<Color>());
      expect(colors.infoLight, isA<Color>());
      expect(colors.onInfo, isA<Color>());
      expect(colors.error, isA<Color>());
      expect(colors.errorLight, isA<Color>());
      expect(colors.onError, isA<Color>());
    });

    test('dark colors are defined', () {
      const colors = AlhaiStatusColors.dark;
      expect(colors.success, isA<Color>());
      expect(colors.warning, isA<Color>());
      expect(colors.info, isA<Color>());
      expect(colors.error, isA<Color>());
    });

    test('copyWith creates a new instance', () {
      const original = AlhaiStatusColors.light;
      final modified = original.copyWith(success: Colors.purple);
      expect(modified.success, Colors.purple);
      expect(modified.warning, original.warning); // unchanged
    });

    test('lerp interpolates between two color sets', () {
      const a = AlhaiStatusColors.light;
      const b = AlhaiStatusColors.dark;
      final mid = a.lerp(b, 0.5);
      expect(mid, isA<AlhaiStatusColors>());
      // The interpolated color should be between a and b
      expect(mid.success, isNot(equals(a.success)));
    });

    test('lerp with non-AlhaiStatusColors returns this', () {
      const a = AlhaiStatusColors.light;
      final result = a.lerp(null, 0.5);
      expect(result.success, a.success);
    });
  });
}
