import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/theme/app_sizes.dart';

// ===========================================
// App Sizes Tests
// ===========================================

void main() {
  group('AppSizes', () {
    test('المسافات الأساسية معرفة', () {
      expect(AppSizes.xxs, 2.0);
      expect(AppSizes.xs, 4.0);
      expect(AppSizes.sm, 8.0);
      expect(AppSizes.md, 12.0);
      expect(AppSizes.lg, 16.0);
      expect(AppSizes.xl, 20.0);
      expect(AppSizes.xxl, 24.0);
      expect(AppSizes.xxxl, 32.0);
    });

    test('الـ Radius معرف', () {
      expect(AppSizes.radiusXs, 4.0);
      expect(AppSizes.radiusSm, 6.0);
      expect(AppSizes.radiusMd, 8.0);
      expect(AppSizes.radiusLg, 12.0);
      expect(AppSizes.radiusXl, 16.0);
      expect(AppSizes.radiusXxl, 20.0);
      expect(AppSizes.radiusFull, 999.0);
    });

    test('Breakpoints معرفة', () {
      expect(AppSizes.breakpointMobile, 640.0);
      expect(AppSizes.breakpointTablet, 768.0);
      expect(AppSizes.breakpointDesktop, 1024.0);
    });

    test('Shadows تُرجع قوائم صالحة', () {
      expect(AppSizes.shadowSm, isA<List<BoxShadow>>());
      expect(AppSizes.shadowSm.length, 1);
      expect(AppSizes.shadowMd, isA<List<BoxShadow>>());
      expect(AppSizes.shadowMd.length, 1);
      expect(AppSizes.shadowLg, isA<List<BoxShadow>>());
      expect(AppSizes.shadowLg.length, 1);
    });
  });

  group('AppSpacing', () {
    test('جميع المسافات معرفة', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.xxl, 24.0);
      expect(AppSpacing.xxxl, 32.0);
      expect(AppSpacing.huge, 48.0);
      expect(AppSpacing.page, 24.0);
      expect(AppSpacing.section, 32.0);
    });
  });

  group('AppRadius', () {
    test('جميع القيم معرفة', () {
      expect(AppRadius.none, 0.0);
      expect(AppRadius.xs, 4.0);
      expect(AppRadius.sm, 6.0);
      expect(AppRadius.md, 8.0);
      expect(AppRadius.lg, 12.0);
      expect(AppRadius.xl, 16.0);
      expect(AppRadius.xxl, 20.0);
      expect(AppRadius.full, 999.0);
    });
  });

  group('AppShadows', () {
    test('جميع الظلال تُرجع قوائم BoxShadow', () {
      expect(AppShadows.sm, isA<List<BoxShadow>>());
      expect(AppShadows.md, isA<List<BoxShadow>>());
      expect(AppShadows.lg, isA<List<BoxShadow>>());
      expect(AppShadows.xl, isA<List<BoxShadow>>());
      expect(AppShadows.primarySm, isA<List<BoxShadow>>());
      expect(AppShadows.primaryMd, isA<List<BoxShadow>>());
      expect(AppShadows.none, isEmpty);
    });

    test('الظلال تحتوي على عنصر واحد', () {
      expect(AppShadows.sm.length, 1);
      expect(AppShadows.md.length, 1);
      expect(AppShadows.lg.length, 1);
      expect(AppShadows.xl.length, 1);
      expect(AppShadows.primarySm.length, 1);
      expect(AppShadows.primaryMd.length, 1);
    });
  });

  group('AppBreakpoints', () {
    test('القيم الأساسية معرفة', () {
      expect(AppBreakpoints.mobileSmall, 320.0);
      expect(AppBreakpoints.mobile, 640.0);
      expect(AppBreakpoints.tablet, 768.0);
      expect(AppBreakpoints.laptop, 1024.0);
      expect(AppBreakpoints.desktop, 1280.0);
      expect(AppBreakpoints.wide, 1536.0);
    });
  });

  group('AppIconSize', () {
    test('أحجام الأيقونات معرفة', () {
      expect(AppIconSize.xs, 16.0);
      expect(AppIconSize.sm, 20.0);
      expect(AppIconSize.md, 24.0);
      expect(AppIconSize.lg, 32.0);
      expect(AppIconSize.xl, 48.0);
      expect(AppIconSize.xxl, 64.0);
      expect(AppIconSize.huge, 80.0);
    });
  });

  group('AppButtonSize', () {
    test('أحجام الأزرار معرفة', () {
      expect(AppButtonSize.heightSm, 36.0);
      expect(AppButtonSize.heightMd, 44.0);
      expect(AppButtonSize.heightLg, 52.0);
      expect(AppButtonSize.paddingHorizontal, 16.0);
      expect(AppButtonSize.paddingHorizontalLg, 24.0);
      expect(AppButtonSize.paddingVertical, 12.0);
      expect(AppButtonSize.minWidth, 80.0);
    });
  });

  group('AppInputSize', () {
    test('أحجام حقول الإدخال معرفة', () {
      expect(AppInputSize.heightSm, 40.0);
      expect(AppInputSize.heightMd, 48.0);
      expect(AppInputSize.heightLg, 56.0);
      expect(AppInputSize.padding, 16.0);
      expect(AppInputSize.paddingSm, 12.0);
    });
  });

  group('AppCardSize', () {
    test('أحجام البطاقات معرفة', () {
      expect(AppCardSize.paddingSm, 12.0);
      expect(AppCardSize.paddingMd, 16.0);
      expect(AppCardSize.paddingLg, 20.0);
      expect(AppCardSize.paddingXl, 24.0);
      expect(AppCardSize.elevation, 2.0);
      expect(AppCardSize.elevationHigh, 4.0);
    });
  });

  group('AppAvatarSize', () {
    test('أحجام الصور الرمزية معرفة', () {
      expect(AppAvatarSize.xs, 24.0);
      expect(AppAvatarSize.sm, 32.0);
      expect(AppAvatarSize.md, 40.0);
      expect(AppAvatarSize.lg, 56.0);
      expect(AppAvatarSize.xl, 80.0);
      expect(AppAvatarSize.xxl, 120.0);
    });
  });

  group('AppSidebarSize', () {
    test('أحجام الشريط الجانبي معرفة', () {
      expect(AppSidebarSize.width, 260.0);
      expect(AppSidebarSize.collapsedWidth, 72.0);
      expect(AppSidebarSize.itemHeight, 48.0);
      expect(AppSidebarSize.itemPadding, 12.0);
    });
  });

  group('AppTopBarSize', () {
    test('أحجام الشريط العلوي معرفة', () {
      expect(AppTopBarSize.height, 64.0);
      expect(AppTopBarSize.paddingHorizontal, 24.0);
    });
  });

  group('AppBottomSheetSize', () {
    test('أحجام الـ Bottom Sheet معرفة', () {
      expect(AppBottomSheetSize.topRadius, 20.0);
      expect(AppBottomSheetSize.handleHeight, 4.0);
      expect(AppBottomSheetSize.handleWidth, 40.0);
      expect(AppBottomSheetSize.padding, 24.0);
      expect(AppBottomSheetSize.maxWidth, 500.0);
    });
  });

  group('AppDialogSize', () {
    test('أحجام الـ Dialog معرفة', () {
      expect(AppDialogSize.widthSm, 400.0);
      expect(AppDialogSize.widthMd, 500.0);
      expect(AppDialogSize.widthLg, 600.0);
      expect(AppDialogSize.widthXl, 800.0);
      expect(AppDialogSize.padding, 24.0);
      expect(AppDialogSize.radius, 16.0);
    });
  });

  group('AppTableSize', () {
    test('أحجام الجداول معرفة', () {
      expect(AppTableSize.rowHeight, 52.0);
      expect(AppTableSize.headerHeight, 48.0);
      expect(AppTableSize.cellPadding, 16.0);
      expect(AppTableSize.cellPaddingH, 16.0);
      expect(AppTableSize.cellPaddingV, 12.0);
    });
  });

  group('AppBarSize', () {
    test('أحجام شريط التطبيق معرفة', () {
      expect(AppBarSize.height, 56.0);
      expect(AppBarSize.heightLarge, 64.0);
      expect(AppBarSize.heightWithSearch, 120.0);
    });
  });

  group('AppDurations', () {
    test('مدد الحركة معرفة', () {
      expect(AppDurations.instant, const Duration(milliseconds: 100));
      expect(AppDurations.fast, const Duration(milliseconds: 200));
      expect(AppDurations.normal, const Duration(milliseconds: 300));
      expect(AppDurations.slow, const Duration(milliseconds: 400));
      expect(AppDurations.slower, const Duration(milliseconds: 500));
      expect(AppDurations.long, const Duration(milliseconds: 600));
    });
  });

  group('AppCurves', () {
    test('منحنيات الحركة معرفة', () {
      expect(AppCurves.defaultCurve, Curves.easeOutCubic);
      expect(AppCurves.enter, Curves.easeOut);
      expect(AppCurves.exit, Curves.easeIn);
      expect(AppCurves.bounce, Curves.elasticOut);
      expect(AppCurves.fast, Curves.easeOutQuart);
    });
  });
}
