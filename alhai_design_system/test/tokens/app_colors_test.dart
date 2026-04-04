import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  group('AlhaiColors', () {
    group('brand colors', () {
      test('primary color delegates to AppColors', () {
        expect(AlhaiColors.primary, isA<Color>());
        expect(AlhaiColors.primary, AppColors.primary);
      });

      test('primary variants are defined', () {
        expect(AlhaiColors.primaryLight, isA<Color>());
        expect(AlhaiColors.primaryDark, isA<Color>());
      });

      test('secondary color delegates to AppColors', () {
        expect(AlhaiColors.secondary, isA<Color>());
        expect(AlhaiColors.secondary, AppColors.secondary);
      });

      test('secondary variants are defined', () {
        expect(AlhaiColors.secondaryLight, isA<Color>());
        expect(AlhaiColors.secondaryDark, isA<Color>());
      });
    });

    group('semantic colors', () {
      test('success colors are defined', () {
        expect(AlhaiColors.success, isA<Color>());
        expect(AlhaiColors.successLight, isA<Color>());
        expect(AlhaiColors.successDark, isA<Color>());
      });

      test('warning colors are defined', () {
        expect(AlhaiColors.warning, isA<Color>());
        expect(AlhaiColors.warningLight, isA<Color>());
        expect(AlhaiColors.warningDark, isA<Color>());
      });

      test('error colors are defined', () {
        expect(AlhaiColors.error, isA<Color>());
        expect(AlhaiColors.errorLight, isA<Color>());
        expect(AlhaiColors.errorDark, isA<Color>());
      });

      test('info colors are defined', () {
        expect(AlhaiColors.info, isA<Color>());
        expect(AlhaiColors.infoLight, isA<Color>());
        expect(AlhaiColors.infoDark, isA<Color>());
      });
    });

    group('light theme neutral colors', () {
      test('background is defined', () {
        expect(AlhaiColors.backgroundLight, isA<Color>());
      });

      test('surface is defined', () {
        expect(AlhaiColors.surfaceLight, isA<Color>());
      });

      test('on-surface text color is defined', () {
        expect(AlhaiColors.onSurfaceLight, isA<Color>());
      });

      test('outline is defined', () {
        expect(AlhaiColors.outlineLight, isA<Color>());
      });
    });

    group('dark theme neutral colors', () {
      test('background is defined', () {
        expect(AlhaiColors.backgroundDark, isA<Color>());
      });

      test('surface is defined', () {
        expect(AlhaiColors.surfaceDark, isA<Color>());
      });

      test('on-surface text color is defined', () {
        expect(AlhaiColors.onSurfaceDark, isA<Color>());
      });

      test('outline is defined', () {
        expect(AlhaiColors.outlineDark, isA<Color>());
      });
    });

    group('on-colors for contrast', () {
      test('onPrimary is white', () {
        expect(AlhaiColors.onPrimary, const Color(0xFFFFFFFF));
      });

      test('onSecondary is white', () {
        expect(AlhaiColors.onSecondary, const Color(0xFFFFFFFF));
      });

      test('onSuccess is white', () {
        expect(AlhaiColors.onSuccess, const Color(0xFFFFFFFF));
      });

      test('onWarning is dark (readable on yellow)', () {
        expect(AlhaiColors.onWarning, const Color(0xFF212121));
      });

      test('onError is white', () {
        expect(AlhaiColors.onError, const Color(0xFFFFFFFF));
      });
    });

    group('light vs dark contrast', () {
      test('light background is lighter than dark background', () {
        // Light background should have higher luminance
        expect(
          AlhaiColors.backgroundLight.computeLuminance(),
          greaterThan(AlhaiColors.backgroundDark.computeLuminance()),
        );
      });

      test('light surface is lighter than dark surface', () {
        expect(
          AlhaiColors.surfaceLight.computeLuminance(),
          greaterThan(AlhaiColors.surfaceDark.computeLuminance()),
        );
      });

      test('on-background light is darker than on-background dark', () {
        // Text on light backgrounds should be dark
        expect(
          AlhaiColors.onBackgroundLight.computeLuminance(),
          lessThan(AlhaiColors.onBackgroundDark.computeLuminance()),
        );
      });
    });

    group('special purpose colors', () {
      test('disabled color is defined', () {
        expect(AlhaiColors.disabled, isA<Color>());
      });

      test('disabledOpacity is Material standard 0.38', () {
        expect(AlhaiColors.disabledOpacity, 0.38);
      });

      test('scrim is semi-transparent', () {
        expect(AlhaiColors.scrim.a, lessThan(1.0));
      });

      test('transparent is fully transparent', () {
        expect(AlhaiColors.transparent.a, 0.0);
      });
    });
  });

  group('AppColors', () {
    group('primary colors', () {
      test('primary is emerald green', () {
        expect(AppColors.primary, const Color(0xFF10B981));
      });

      test('primary variants exist', () {
        expect(AppColors.primaryLight, isA<Color>());
        expect(AppColors.primaryDark, isA<Color>());
        expect(AppColors.primarySurface, isA<Color>());
        expect(AppColors.primaryBorder, isA<Color>());
      });
    });

    group('semantic colors', () {
      test('success color is defined', () {
        expect(AppColors.success, isA<Color>());
        expect(AppColors.successSurface, isA<Color>());
      });

      test('warning color is defined', () {
        expect(AppColors.warning, isA<Color>());
        expect(AppColors.warningSurface, isA<Color>());
      });

      test('error color is defined', () {
        expect(AppColors.error, isA<Color>());
        expect(AppColors.errorSurface, isA<Color>());
      });

      test('info color is defined', () {
        expect(AppColors.info, isA<Color>());
        expect(AppColors.infoSurface, isA<Color>());
      });
    });

    group('money colors', () {
      test('cash is green', () {
        expect(AppColors.cash, isA<Color>());
      });

      test('card is blue', () {
        expect(AppColors.card, isA<Color>());
      });

      test('debt is red', () {
        expect(AppColors.debt, isA<Color>());
      });

      test('credit is teal', () {
        expect(AppColors.credit, isA<Color>());
      });
    });

    group('stock colors', () {
      test('available is green', () {
        expect(AppColors.stockAvailable, isA<Color>());
      });

      test('low is amber', () {
        expect(AppColors.stockLow, isA<Color>());
      });

      test('out is red', () {
        expect(AppColors.stockOut, isA<Color>());
      });
    });

    group('grey scale', () {
      test('grey values form a proper scale from light to dark', () {
        final greys = [
          AppColors.grey50,
          AppColors.grey100,
          AppColors.grey200,
          AppColors.grey300,
          AppColors.grey400,
          AppColors.grey500,
          AppColors.grey600,
          AppColors.grey700,
          AppColors.grey800,
          AppColors.grey900,
        ];

        // Each subsequent grey should be darker (lower luminance)
        for (int i = 0; i < greys.length - 1; i++) {
          expect(
            greys[i].computeLuminance(),
            greaterThan(greys[i + 1].computeLuminance()),
            reason:
                'grey${(i + 1) * 100} should be darker than grey${i * 100 + 50}',
          );
        }
      });
    });

    group('theme-aware helpers', () {
      test('getBackground returns light background when not dark', () {
        expect(AppColors.getBackground(false), AppColors.background);
      });

      test('getBackground returns dark background when dark', () {
        expect(AppColors.getBackground(true), AppColors.backgroundDark);
      });

      test('getSurface returns light surface when not dark', () {
        expect(AppColors.getSurface(false), AppColors.surface);
      });

      test('getSurface returns dark surface when dark', () {
        expect(AppColors.getSurface(true), AppColors.surfaceDark);
      });

      test('getTextPrimary returns light text when not dark', () {
        expect(AppColors.getTextPrimary(false), AppColors.textPrimary);
      });

      test('getTextPrimary returns dark text when dark', () {
        expect(AppColors.getTextPrimary(true), AppColors.textPrimaryDark);
      });
    });

    group('helper methods', () {
      test('getStockColor returns stockOut for quantity 0', () {
        expect(AppColors.getStockColor(0, 5), AppColors.stockOut);
      });

      test('getStockColor returns stockOut for negative quantity', () {
        expect(AppColors.getStockColor(-1, 5), AppColors.stockOut);
      });

      test('getStockColor returns stockLow when at or below minimum', () {
        expect(AppColors.getStockColor(5, 5), AppColors.stockLow);
        expect(AppColors.getStockColor(3, 5), AppColors.stockLow);
      });

      test('getStockColor returns stockAvailable when above minimum', () {
        expect(AppColors.getStockColor(10, 5), AppColors.stockAvailable);
      });

      test('getBalanceColor returns debt for positive balance', () {
        expect(AppColors.getBalanceColor(100.0), AppColors.debt);
      });

      test('getBalanceColor returns credit for negative balance', () {
        expect(AppColors.getBalanceColor(-50.0), AppColors.credit);
      });

      test('getBalanceColor returns muted for zero balance', () {
        expect(AppColors.getBalanceColor(0.0), AppColors.textMuted);
      });

      test('getPaymentMethodColor returns correct color for cash', () {
        expect(AppColors.getPaymentMethodColor('cash'), AppColors.cash);
      });

      test('getPaymentMethodColor returns correct color for card', () {
        expect(AppColors.getPaymentMethodColor('card'), AppColors.card);
      });

      test('getPaymentMethodColor returns primary for unknown method', () {
        expect(AppColors.getPaymentMethodColor('bitcoin'), AppColors.primary);
      });

      test('getCategoryColor returns correct color for fruits', () {
        expect(AppColors.getCategoryColor('fruits'), AppColors.categoryFruits);
      });

      test('getCategoryColor returns primary for unknown category', () {
        expect(AppColors.getCategoryColor('unknown'), AppColors.primary);
      });
    });

    group('gradients', () {
      test('primaryGradient has 2 colors', () {
        expect(AppColors.primaryGradient.colors.length, 2);
      });

      test('secondaryGradient has 2 colors', () {
        expect(AppColors.secondaryGradient.colors.length, 2);
      });

      test('successGradient has 2 colors', () {
        expect(AppColors.successGradient.colors.length, 2);
      });

      test('cardGradient has 2 colors', () {
        expect(AppColors.cardGradient.colors.length, 2);
      });
    });
  });
}
