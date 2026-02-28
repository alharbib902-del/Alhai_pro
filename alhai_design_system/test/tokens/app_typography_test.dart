import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  group('AlhaiTypography', () {
    group('font family', () {
      test('uses Tajawal font family', () {
        expect(AlhaiTypography.fontFamily, 'Tajawal');
      });
    });

    group('display styles', () {
      test('displayLarge has correct font size (57)', () {
        expect(AlhaiTypography.displayLarge.fontSize, 57);
      });

      test('displayMedium has correct font size (45)', () {
        expect(AlhaiTypography.displayMedium.fontSize, 45);
      });

      test('displaySmall has correct font size (36)', () {
        expect(AlhaiTypography.displaySmall.fontSize, 36);
      });

      test('display sizes are in descending order', () {
        expect(
          AlhaiTypography.displayLarge.fontSize!,
          greaterThan(AlhaiTypography.displayMedium.fontSize!),
        );
        expect(
          AlhaiTypography.displayMedium.fontSize!,
          greaterThan(AlhaiTypography.displaySmall.fontSize!),
        );
      });

      test('display styles use Tajawal font', () {
        expect(AlhaiTypography.displayLarge.fontFamily, 'Tajawal');
        expect(AlhaiTypography.displayMedium.fontFamily, 'Tajawal');
        expect(AlhaiTypography.displaySmall.fontFamily, 'Tajawal');
      });
    });

    group('headline styles', () {
      test('headlineLarge has correct font size (32)', () {
        expect(AlhaiTypography.headlineLarge.fontSize, 32);
      });

      test('headlineMedium has correct font size (28)', () {
        expect(AlhaiTypography.headlineMedium.fontSize, 28);
      });

      test('headlineSmall has correct font size (24)', () {
        expect(AlhaiTypography.headlineSmall.fontSize, 24);
      });

      test('headline sizes are in descending order', () {
        expect(
          AlhaiTypography.headlineLarge.fontSize!,
          greaterThan(AlhaiTypography.headlineMedium.fontSize!),
        );
        expect(
          AlhaiTypography.headlineMedium.fontSize!,
          greaterThan(AlhaiTypography.headlineSmall.fontSize!),
        );
      });

      test('headline styles use medium weight', () {
        expect(AlhaiTypography.headlineLarge.fontWeight, FontWeight.w500);
        expect(AlhaiTypography.headlineMedium.fontWeight, FontWeight.w500);
        expect(AlhaiTypography.headlineSmall.fontWeight, FontWeight.w500);
      });
    });

    group('title styles', () {
      test('titleLarge has correct font size (22)', () {
        expect(AlhaiTypography.titleLarge.fontSize, 22);
      });

      test('titleMedium has correct font size (16)', () {
        expect(AlhaiTypography.titleMedium.fontSize, 16);
      });

      test('titleSmall has correct font size (14)', () {
        expect(AlhaiTypography.titleSmall.fontSize, 14);
      });

      test('title sizes are in descending order', () {
        expect(
          AlhaiTypography.titleLarge.fontSize!,
          greaterThan(AlhaiTypography.titleMedium.fontSize!),
        );
        expect(
          AlhaiTypography.titleMedium.fontSize!,
          greaterThan(AlhaiTypography.titleSmall.fontSize!),
        );
      });
    });

    group('body styles', () {
      test('bodyLarge has correct font size (16)', () {
        expect(AlhaiTypography.bodyLarge.fontSize, 16);
      });

      test('bodyMedium has correct font size (14)', () {
        expect(AlhaiTypography.bodyMedium.fontSize, 14);
      });

      test('bodySmall has correct font size (12)', () {
        expect(AlhaiTypography.bodySmall.fontSize, 12);
      });

      test('body sizes are in descending order', () {
        expect(
          AlhaiTypography.bodyLarge.fontSize!,
          greaterThan(AlhaiTypography.bodyMedium.fontSize!),
        );
        expect(
          AlhaiTypography.bodyMedium.fontSize!,
          greaterThan(AlhaiTypography.bodySmall.fontSize!),
        );
      });

      test('body styles use regular weight', () {
        expect(AlhaiTypography.bodyLarge.fontWeight, FontWeight.w400);
        expect(AlhaiTypography.bodyMedium.fontWeight, FontWeight.w400);
        expect(AlhaiTypography.bodySmall.fontWeight, FontWeight.w400);
      });
    });

    group('label styles', () {
      test('labelLarge has correct font size (14)', () {
        expect(AlhaiTypography.labelLarge.fontSize, 14);
      });

      test('labelMedium has correct font size (12)', () {
        expect(AlhaiTypography.labelMedium.fontSize, 12);
      });

      test('labelSmall has correct font size (11)', () {
        expect(AlhaiTypography.labelSmall.fontSize, 11);
      });

      test('label sizes are in descending order', () {
        expect(
          AlhaiTypography.labelLarge.fontSize!,
          greaterThan(AlhaiTypography.labelMedium.fontSize!),
        );
        expect(
          AlhaiTypography.labelMedium.fontSize!,
          greaterThan(AlhaiTypography.labelSmall.fontSize!),
        );
      });

      test('label styles use medium weight', () {
        expect(AlhaiTypography.labelLarge.fontWeight, FontWeight.w500);
        expect(AlhaiTypography.labelMedium.fontWeight, FontWeight.w500);
        expect(AlhaiTypography.labelSmall.fontWeight, FontWeight.w500);
      });
    });

    group('textTheme', () {
      test('textTheme contains all 15 Material 3 text styles', () {
        final textTheme = AlhaiTypography.textTheme;
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.headlineSmall, isNotNull);
        expect(textTheme.titleLarge, isNotNull);
        expect(textTheme.titleMedium, isNotNull);
        expect(textTheme.titleSmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
        expect(textTheme.labelMedium, isNotNull);
        expect(textTheme.labelSmall, isNotNull);
      });

      test('all text styles have positive line height', () {
        final styles = [
          AlhaiTypography.displayLarge,
          AlhaiTypography.displayMedium,
          AlhaiTypography.displaySmall,
          AlhaiTypography.headlineLarge,
          AlhaiTypography.headlineMedium,
          AlhaiTypography.headlineSmall,
          AlhaiTypography.titleLarge,
          AlhaiTypography.titleMedium,
          AlhaiTypography.titleSmall,
          AlhaiTypography.bodyLarge,
          AlhaiTypography.bodyMedium,
          AlhaiTypography.bodySmall,
          AlhaiTypography.labelLarge,
          AlhaiTypography.labelMedium,
          AlhaiTypography.labelSmall,
        ];

        for (final style in styles) {
          expect(style.height, isNotNull);
          expect(style.height!, greaterThan(0));
        }
      });
    });
  });

  group('AlhaiSpacing', () {
    test('base unit is 4dp', () {
      expect(AlhaiSpacing.unit, 4.0);
    });

    test('spacing scale is in ascending order', () {
      final spacings = [
        AlhaiSpacing.zero,
        AlhaiSpacing.xxxs,
        AlhaiSpacing.xxs,
        AlhaiSpacing.xs,
        AlhaiSpacing.sm,
        AlhaiSpacing.md,
        AlhaiSpacing.mdl,
        AlhaiSpacing.lg,
        AlhaiSpacing.xl,
        AlhaiSpacing.xxl,
        AlhaiSpacing.xxxl,
        AlhaiSpacing.huge,
        AlhaiSpacing.massive,
      ];

      for (int i = 0; i < spacings.length - 1; i++) {
        expect(
          spacings[i + 1],
          greaterThan(spacings[i]),
          reason: 'Spacing scale should be monotonically increasing',
        );
      }
    });

    test('minimum touch target is 48dp (accessibility)', () {
      expect(AlhaiSpacing.minTouchTarget, 48.0);
    });

    test('semantic spacings are positive', () {
      expect(AlhaiSpacing.pagePaddingHorizontal, greaterThan(0));
      expect(AlhaiSpacing.pagePaddingVertical, greaterThan(0));
      expect(AlhaiSpacing.cardPadding, greaterThan(0));
      expect(AlhaiSpacing.sectionSpacing, greaterThan(0));
      expect(AlhaiSpacing.itemSpacing, greaterThan(0));
    });
  });

  group('AlhaiRadius', () {
    test('radius scale is in ascending order', () {
      final radii = [
        AlhaiRadius.none,
        AlhaiRadius.xs,
        AlhaiRadius.sm,
        AlhaiRadius.md,
        AlhaiRadius.lg,
        AlhaiRadius.xl,
        AlhaiRadius.xxl,
        AlhaiRadius.rounded,
        AlhaiRadius.full,
      ];

      for (int i = 0; i < radii.length - 1; i++) {
        expect(
          radii[i + 1],
          greaterThan(radii[i]),
          reason: 'Radius scale should be monotonically increasing',
        );
      }
    });

    test('borderRadius helpers return correct types', () {
      expect(AlhaiRadius.borderNone, BorderRadius.zero);
      expect(AlhaiRadius.borderXs, isA<BorderRadius>());
      expect(AlhaiRadius.borderSm, isA<BorderRadius>());
      expect(AlhaiRadius.borderMd, isA<BorderRadius>());
      expect(AlhaiRadius.borderLg, isA<BorderRadius>());
    });

    test('semantic radii are positive', () {
      expect(AlhaiRadius.button, greaterThan(0));
      expect(AlhaiRadius.input, greaterThan(0));
      expect(AlhaiRadius.card, greaterThan(0));
      expect(AlhaiRadius.dialog, greaterThan(0));
      expect(AlhaiRadius.bottomSheet, greaterThan(0));
    });
  });

  group('AlhaiBreakpoints', () {
    test('mobile starts at 0', () {
      expect(AlhaiBreakpoints.mobile, 0.0);
    });

    test('breakpoints are in ascending order', () {
      expect(AlhaiBreakpoints.tablet, greaterThan(AlhaiBreakpoints.mobile));
      expect(AlhaiBreakpoints.desktop, greaterThan(AlhaiBreakpoints.tablet));
      expect(
        AlhaiBreakpoints.desktopLarge,
        greaterThan(AlhaiBreakpoints.desktop),
      );
    });

    test('isMobile returns true for mobile widths', () {
      expect(AlhaiBreakpoints.isMobile(300), isTrue);
      expect(AlhaiBreakpoints.isMobile(599), isTrue);
    });

    test('isMobile returns false for tablet widths', () {
      expect(AlhaiBreakpoints.isMobile(600), isFalse);
    });

    test('isTablet returns true for tablet widths', () {
      expect(AlhaiBreakpoints.isTablet(600), isTrue);
      expect(AlhaiBreakpoints.isTablet(800), isTrue);
    });

    test('isDesktop returns true for desktop widths', () {
      expect(AlhaiBreakpoints.isDesktop(905), isTrue);
      expect(AlhaiBreakpoints.isDesktop(1500), isTrue);
    });

    test('getColumns returns correct column count', () {
      expect(AlhaiBreakpoints.getColumns(300), AlhaiBreakpoints.mobileColumns);
      expect(AlhaiBreakpoints.getColumns(700), AlhaiBreakpoints.tabletColumns);
      expect(
        AlhaiBreakpoints.getColumns(1000),
        AlhaiBreakpoints.desktopColumns,
      );
    });
  });

  group('AlhaiDurations', () {
    test('durations are in ascending order', () {
      final durations = [
        AlhaiDurations.zero,
        AlhaiDurations.ultraFast,
        AlhaiDurations.fast,
        AlhaiDurations.quick,
        AlhaiDurations.standard,
        AlhaiDurations.medium,
        AlhaiDurations.slow,
        AlhaiDurations.verySlow,
        AlhaiDurations.extraSlow,
      ];

      for (int i = 0; i < durations.length - 1; i++) {
        expect(
          durations[i + 1],
          greaterThan(durations[i]),
          reason: 'Duration scale should be monotonically increasing',
        );
      }
    });

    test('semantic durations reference scale values', () {
      expect(AlhaiDurations.buttonPress, AlhaiDurations.quick);
      expect(AlhaiDurations.ripple, AlhaiDurations.standard);
      expect(AlhaiDurations.pageTransition, AlhaiDurations.slow);
    });
  });

  group('AlhaiMotion', () {
    test('standard curves are defined', () {
      expect(AlhaiMotion.standard, isA<Curve>());
      expect(AlhaiMotion.standardAccelerate, isA<Curve>());
      expect(AlhaiMotion.standardDecelerate, isA<Curve>());
    });

    test('emphasized curves are defined', () {
      expect(AlhaiMotion.emphasized, isA<Curve>());
      expect(AlhaiMotion.emphasizedAccelerate, isA<Curve>());
      expect(AlhaiMotion.emphasizedDecelerate, isA<Curve>());
    });

    test('semantic curves are defined', () {
      expect(AlhaiMotion.buttonPress, isA<Curve>());
      expect(AlhaiMotion.pageEnter, isA<Curve>());
      expect(AlhaiMotion.pageExit, isA<Curve>());
      expect(AlhaiMotion.modalEnter, isA<Curve>());
      expect(AlhaiMotion.modalExit, isA<Curve>());
    });

    test('interval returns an Interval curve', () {
      final curve = AlhaiMotion.interval(0.0, 0.5);
      expect(curve, isA<Interval>());
    });

    test('reverse returns a flipped curve', () {
      final curve = AlhaiMotion.reverse(Curves.easeIn);
      expect(curve, isA<FlippedCurve>());
    });

    test('duration constants are in ascending order', () {
      expect(
        AlhaiMotion.durationShort,
        greaterThan(AlhaiMotion.durationExtraShort),
      );
      expect(
        AlhaiMotion.durationFast,
        greaterThan(AlhaiMotion.durationShort),
      );
      expect(
        AlhaiMotion.durationMedium,
        greaterThan(AlhaiMotion.durationFast),
      );
      expect(
        AlhaiMotion.durationLong,
        greaterThan(AlhaiMotion.durationMedium),
      );
      expect(
        AlhaiMotion.durationExtraLong,
        greaterThan(AlhaiMotion.durationLong),
      );
    });
  });
}
