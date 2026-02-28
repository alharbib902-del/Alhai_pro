import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/core/theme/app_sizes.dart';

void main() {
  group('AppSpacing', () {
    test('values should be increasing', () {
      expect(AppSpacing.xxs, lessThan(AppSpacing.xs));
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
      expect(AppSpacing.xxl, lessThan(AppSpacing.xxxl));
    });

    test('should have expected values', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.xxl, 24.0);
      expect(AppSpacing.xxxl, 32.0);
    });
  });

  group('AppRadius', () {
    test('values should be increasing (except none)', () {
      expect(AppRadius.none, 0.0);
      expect(AppRadius.xs, lessThan(AppRadius.sm));
      expect(AppRadius.sm, lessThan(AppRadius.md));
      expect(AppRadius.md, lessThan(AppRadius.lg));
      expect(AppRadius.lg, lessThan(AppRadius.xl));
      expect(AppRadius.xl, lessThan(AppRadius.xxl));
      expect(AppRadius.xxl, lessThan(AppRadius.full));
    });

    test('full should be a very large value', () {
      expect(AppRadius.full, 999.0);
    });
  });

  group('AppIconSize', () {
    test('values should be increasing', () {
      expect(AppIconSize.xs, lessThan(AppIconSize.sm));
      expect(AppIconSize.sm, lessThan(AppIconSize.md));
      expect(AppIconSize.md, lessThan(AppIconSize.lg));
      expect(AppIconSize.lg, lessThan(AppIconSize.xl));
      expect(AppIconSize.xl, lessThan(AppIconSize.xxl));
      expect(AppIconSize.xxl, lessThan(AppIconSize.huge));
    });
  });

  group('AppButtonSize', () {
    test('heights should be increasing', () {
      expect(AppButtonSize.heightSm, lessThan(AppButtonSize.heightMd));
      expect(AppButtonSize.heightMd, lessThan(AppButtonSize.heightLg));
    });

    test('should have positive min width', () {
      expect(AppButtonSize.minWidth, greaterThan(0));
    });
  });

  group('AppInputSize', () {
    test('heights should be increasing', () {
      expect(AppInputSize.heightSm, lessThan(AppInputSize.heightMd));
      expect(AppInputSize.heightMd, lessThan(AppInputSize.heightLg));
    });
  });

  group('AppSizes', () {
    test('should have consistent values with AppSpacing', () {
      expect(AppSizes.xxs, AppSpacing.xxs);
      expect(AppSizes.xs, AppSpacing.xs);
      expect(AppSizes.sm, AppSpacing.sm);
    });

    test('shadows should return non-empty lists', () {
      expect(AppSizes.shadowSm, isNotEmpty);
      expect(AppSizes.shadowMd, isNotEmpty);
      expect(AppSizes.shadowLg, isNotEmpty);
    });
  });

  group('AppShadows', () {
    test('should return non-empty lists', () {
      expect(AppShadows.sm, isNotEmpty);
      expect(AppShadows.md, isNotEmpty);
      expect(AppShadows.lg, isNotEmpty);
      expect(AppShadows.xl, isNotEmpty);
      expect(AppShadows.primarySm, isNotEmpty);
      expect(AppShadows.primaryMd, isNotEmpty);
    });

    test('none should be empty', () {
      expect(AppShadows.none, isEmpty);
    });
  });

  group('AppDurations', () {
    test('durations should be increasing', () {
      expect(AppDurations.instant, lessThan(AppDurations.fast));
      expect(AppDurations.fast, lessThan(AppDurations.normal));
      expect(AppDurations.normal, lessThan(AppDurations.slow));
      expect(AppDurations.slow, lessThan(AppDurations.slower));
      expect(AppDurations.slower, lessThan(AppDurations.long));
    });
  });

  group('AppDialogSize', () {
    test('widths should be increasing', () {
      expect(AppDialogSize.widthSm, lessThan(AppDialogSize.widthMd));
      expect(AppDialogSize.widthMd, lessThan(AppDialogSize.widthLg));
      expect(AppDialogSize.widthLg, lessThan(AppDialogSize.widthXl));
    });
  });

  group('AppSidebarSize', () {
    test('collapsed should be less than expanded', () {
      expect(AppSidebarSize.collapsedWidth, lessThan(AppSidebarSize.width));
    });
  });

  group('AppCardSize', () {
    test('paddings should be increasing', () {
      expect(AppCardSize.paddingSm, lessThan(AppCardSize.paddingMd));
      expect(AppCardSize.paddingMd, lessThan(AppCardSize.paddingLg));
      expect(AppCardSize.paddingLg, lessThan(AppCardSize.paddingXl));
    });
  });

  group('AppAvatarSize', () {
    test('sizes should be increasing', () {
      expect(AppAvatarSize.xs, lessThan(AppAvatarSize.sm));
      expect(AppAvatarSize.sm, lessThan(AppAvatarSize.md));
      expect(AppAvatarSize.md, lessThan(AppAvatarSize.lg));
      expect(AppAvatarSize.lg, lessThan(AppAvatarSize.xl));
      expect(AppAvatarSize.xl, lessThan(AppAvatarSize.xxl));
    });
  });
}
