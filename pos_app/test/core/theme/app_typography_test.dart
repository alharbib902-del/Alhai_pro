import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/theme/app_typography.dart';

// ===========================================
// App Typography Tests
// ===========================================

void main() {
  group('AppTypography - Constants', () {
    test('الخط الأساسي معرف', () {
      expect(AppTypography.fontFamily, 'Tajawal');
      expect(AppTypography.fontFamilyNumbers, 'Tajawal');
    });
  });

  group('AppTypography - Display Styles', () {
    test('displayLarge معرف بقيم صحيحة', () {
      expect(AppTypography.displayLarge.fontSize, 36);
      expect(AppTypography.displayLarge.fontWeight, FontWeight.w700);
      expect(AppTypography.displayLarge.height, 1.2);
      expect(AppTypography.displayLarge.letterSpacing, -0.5);
    });

    test('displayMedium معرف بقيم صحيحة', () {
      expect(AppTypography.displayMedium.fontSize, 28);
      expect(AppTypography.displayMedium.fontWeight, FontWeight.w700);
      expect(AppTypography.displayMedium.height, 1.2);
    });

    test('displaySmall معرف بقيم صحيحة', () {
      expect(AppTypography.displaySmall.fontSize, 24);
      expect(AppTypography.displaySmall.fontWeight, FontWeight.w600);
      expect(AppTypography.displaySmall.height, 1.2);
    });
  });

  group('AppTypography - Headline Styles', () {
    test('headlineLarge معرف', () {
      expect(AppTypography.headlineLarge.fontSize, 24);
      expect(AppTypography.headlineLarge.fontWeight, FontWeight.w600);
      expect(AppTypography.headlineLarge.height, 1.3);
    });

    test('headlineMedium معرف', () {
      expect(AppTypography.headlineMedium.fontSize, 20);
      expect(AppTypography.headlineMedium.fontWeight, FontWeight.w600);
    });

    test('headlineSmall معرف', () {
      expect(AppTypography.headlineSmall.fontSize, 18);
      expect(AppTypography.headlineSmall.fontWeight, FontWeight.w600);
    });
  });

  group('AppTypography - Title Styles', () {
    test('titleLarge معرف', () {
      expect(AppTypography.titleLarge.fontSize, 18);
      expect(AppTypography.titleLarge.fontWeight, FontWeight.w600);
      expect(AppTypography.titleLarge.height, 1.4);
    });

    test('titleMedium معرف', () {
      expect(AppTypography.titleMedium.fontSize, 16);
      expect(AppTypography.titleMedium.fontWeight, FontWeight.w600);
    });

    test('titleSmall معرف', () {
      expect(AppTypography.titleSmall.fontSize, 14);
      expect(AppTypography.titleSmall.fontWeight, FontWeight.w600);
    });
  });

  group('AppTypography - Body Styles', () {
    test('bodyLarge معرف', () {
      expect(AppTypography.bodyLarge.fontSize, 16);
      expect(AppTypography.bodyLarge.fontWeight, FontWeight.w400);
      expect(AppTypography.bodyLarge.height, 1.5);
    });

    test('bodyMedium معرف', () {
      expect(AppTypography.bodyMedium.fontSize, 14);
      expect(AppTypography.bodyMedium.fontWeight, FontWeight.w400);
    });

    test('bodySmall معرف', () {
      expect(AppTypography.bodySmall.fontSize, 12);
      expect(AppTypography.bodySmall.fontWeight, FontWeight.w400);
    });
  });

  group('AppTypography - Label Styles', () {
    test('labelLarge معرف', () {
      expect(AppTypography.labelLarge.fontSize, 14);
      expect(AppTypography.labelLarge.fontWeight, FontWeight.w600);
      expect(AppTypography.labelLarge.letterSpacing, 0.1);
    });

    test('labelMedium معرف', () {
      expect(AppTypography.labelMedium.fontSize, 12);
      expect(AppTypography.labelMedium.fontWeight, FontWeight.w600);
    });

    test('labelSmall معرف', () {
      expect(AppTypography.labelSmall.fontSize, 11);
      expect(AppTypography.labelSmall.fontWeight, FontWeight.w500);
    });
  });

  group('AppTypography - Price Styles', () {
    test('priceLarge معرف', () {
      expect(AppTypography.priceLarge.fontSize, 32);
      expect(AppTypography.priceLarge.fontWeight, FontWeight.w700);
      expect(AppTypography.priceLarge.height, 1.2);
    });

    test('priceMedium معرف', () {
      expect(AppTypography.priceMedium.fontSize, 20);
      expect(AppTypography.priceMedium.fontWeight, FontWeight.w700);
    });

    test('priceSmall معرف', () {
      expect(AppTypography.priceSmall.fontSize, 16);
      expect(AppTypography.priceSmall.fontWeight, FontWeight.w600);
    });
  });

  group('AppTypography - Special Styles', () {
    test('badge معرف', () {
      expect(AppTypography.badge.fontSize, 10);
      expect(AppTypography.badge.fontWeight, FontWeight.w600);
      expect(AppTypography.badge.height, 1.2);
    });
  });

  group('AppTypography - Button Styles', () {
    test('buttonLarge معرف', () {
      expect(AppTypography.buttonLarge.fontSize, 16);
      expect(AppTypography.buttonLarge.fontWeight, FontWeight.w600);
    });

    test('buttonMedium معرف', () {
      expect(AppTypography.buttonMedium.fontSize, 14);
      expect(AppTypography.buttonMedium.fontWeight, FontWeight.w600);
    });

    test('buttonSmall معرف', () {
      expect(AppTypography.buttonSmall.fontSize, 12);
      expect(AppTypography.buttonSmall.fontWeight, FontWeight.w600);
    });
  });

  group('AppTypography - Input Styles', () {
    test('inputText معرف', () {
      expect(AppTypography.inputText.fontSize, 16);
      expect(AppTypography.inputText.fontWeight, FontWeight.w400);
      expect(AppTypography.inputText.height, 1.5);
    });

    test('inputLabel معرف', () {
      expect(AppTypography.inputLabel.fontSize, 14);
      expect(AppTypography.inputLabel.fontWeight, FontWeight.w500);
    });

    test('inputHint معرف', () {
      expect(AppTypography.inputHint.fontSize, 16);
      expect(AppTypography.inputHint.fontWeight, FontWeight.w400);
    });

    test('inputError معرف', () {
      expect(AppTypography.inputError.fontSize, 12);
      expect(AppTypography.inputError.fontWeight, FontWeight.w400);
    });
  });

  group('AppTypography - TextTheme', () {
    test('textTheme يحتوي على جميع الأنماط', () {
      final theme = AppTypography.textTheme;

      expect(theme.displayLarge, isNotNull);
      expect(theme.displayMedium, isNotNull);
      expect(theme.displaySmall, isNotNull);
      expect(theme.headlineLarge, isNotNull);
      expect(theme.headlineMedium, isNotNull);
      expect(theme.headlineSmall, isNotNull);
      expect(theme.titleLarge, isNotNull);
      expect(theme.titleMedium, isNotNull);
      expect(theme.titleSmall, isNotNull);
      expect(theme.bodyLarge, isNotNull);
      expect(theme.bodyMedium, isNotNull);
      expect(theme.bodySmall, isNotNull);
      expect(theme.labelLarge, isNotNull);
      expect(theme.labelMedium, isNotNull);
      expect(theme.labelSmall, isNotNull);
    });

    test('textTheme يُرجع نفس القيم', () {
      final theme = AppTypography.textTheme;

      expect(theme.displayLarge?.fontSize, AppTypography.displayLarge.fontSize);
      expect(theme.bodyMedium?.fontSize, AppTypography.bodyMedium.fontSize);
      expect(theme.labelLarge?.fontWeight, AppTypography.labelLarge.fontWeight);
    });
  });
}
